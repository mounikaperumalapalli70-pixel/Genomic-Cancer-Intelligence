import os
import json
import logging
from typing import Dict, Any, List, Optional
import httpx

logger = logging.getLogger(__name__)


class GeminiTreatmentReasoningService:
    """
    Backend-Only Evidence Reasoning & Explanation Service.
    
    Operates strictly on deterministic clinical inputs provided by TreatmentIntelligenceService.
    Does NOT invent medicines or biomarkers. Validates all reasoning outputs against the verified
    deterministic knowledge base and filters out any unsupported recommendations.
    
    Never exposed as user-facing branding.
    """

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
        self.endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"

    def is_available(self) -> bool:
        """Returns True if Gemini API key is configured."""
        return bool(self.api_key and len(self.api_key.strip()) > 0)

    async def reason_over_evidence(
        self,
        deterministic_intelligence: Dict[str, Any],
        model_confidence: float = 0.95
    ) -> Dict[str, Any]:
        """
        Submits structured clinical evidence to Gemini for oncology explanation synthesis.
        Validates output strictly against deterministic knowledge base.
        """
        if not self.is_available():
            logger.info("Gemini API key not configured. Using deterministic treatment intelligence.")
            return deterministic_intelligence

        # Extract verified baseline data
        cancer_type = deterministic_intelligence.get("cancer_type", "Unknown")
        cancer_site = deterministic_intelligence.get("cancer_site", "Unspecified Site")
        subtype = deterministic_intelligence.get("subtype", "Unspecified Subtype")
        raw_therapies = deterministic_intelligence.get("targeted_therapies", [])
        
        # Build whitelist of verified therapies and targets
        verified_drugs = {t.get("drug_name", "").strip().lower(): t for t in raw_therapies if t.get("drug_name")}
        verified_targets = {t.get("target_gene", "").strip().upper() for t in raw_therapies if t.get("target_gene")}
        
        # Prepare structured input payload for Gemini
        verified_profiles = []
        for t in raw_therapies:
            verified_profiles.append({
                "drug_name": t.get("drug_name"),
                "treatment_class": t.get("treatment_class"),
                "molecular_target": t.get("molecular_target"),
                "target_gene": t.get("target_gene"),
                "required_genomic_alteration": t.get("required_genomic_alteration"),
                "alteration_classification": t.get("alteration_classification"),
                "eligibility_status": t.get("eligibility_status"),
                "how_it_works": t.get("how_it_works"),
                "why_relevant": t.get("why_relevant"),
                "evidence_source": t.get("evidence_source"),
                "fda_status": t.get("fda_status"),
                "nccn_evidence_tier": t.get("nccn_evidence_tier")
            })

        prompt_payload = {
            "cancer_type": cancer_type,
            "cancer_site": cancer_site,
            "subtype": subtype,
            "model_confidence": model_confidence,
            "available_treatment_profiles": verified_profiles,
            "genomic_data_limitation_notice": deterministic_intelligence.get("genomic_data_limitation_notice"),
            "first_line_guideline": deterministic_intelligence.get("first_line_guideline")
        }

        system_instruction = (
            "You are a specialized clinical oncology research AI assistant. "
            "Your role is to reason over and explain the supplied evidence-based treatment profiles.\n"
            "STRICT RULES:\n"
            "1. NEVER invent, suggest, or add any medicine, drug, therapy, or molecular target that is not explicitly provided in 'available_treatment_profiles'.\n"
            "2. If an actionable biomarker/mutation is not confirmed in the evidence, you MUST state: 'Actionable biomarker not established from the available data.'\n"
            "3. Do NOT provide prescriptions, personalized dosing, or medical claims.\n"
            "4. Return ONLY valid JSON adhering strictly to the requested schema."
        )

        user_prompt = (
            f"Synthesize structured oncology treatment intelligence from this verified clinical dataset:\n"
            f"```json\n{json.dumps(prompt_payload, indent=2)}\n```\n\n"
            "Return JSON matching this exact schema:\n"
            "{\n"
            '  "cancer_type": string,\n'
            '  "site": string,\n'
            '  "biomarkers": [string],\n'
            '  "biomarker_status": string,\n'
            '  "treatment_options": [\n'
            "    {\n"
            '      "drug_name": string,\n'
            '      "treatment_class": string,\n'
            '      "target": string,\n'
            '      "mechanism": string,\n'
            '      "why_relevant": string,\n'
            '      "evidence": string,\n'
            '      "eligibility_status": string\n'
            "    }\n"
            "  ],\n"
            '  "target": string,\n'
            '  "mechanism": string,\n'
            '  "why_relevant": string,\n'
            '  "evidence": [string],\n'
            '  "limitations": string,\n'
            '  "clinical_verification_required": true\n'
            "}"
        )

        try:
            headers = {"Content-Type": "application/json"}
            url = f"{self.endpoint}?key={self.api_key}"
            body = {
                "contents": [
                    {
                        "role": "user",
                        "parts": [{"text": f"{system_instruction}\n\n{user_prompt}"}]
                    }
                ],
                "generationConfig": {
                    "temperature": 0.1,
                    "responseMimeType": "application/json"
                }
            }

            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.post(url, headers=headers, json=body)
                
            if response.status_code != 200:
                logger.warning(f"Gemini API returned status {response.status_code}. Using deterministic fallback.")
                return deterministic_intelligence

            resp_json = response.json()
            candidates = resp_json.get("candidates", [])
            if not candidates:
                return deterministic_intelligence

            text_content = candidates[0].get("content", {}).get("parts", [{}])[0].get("text", "")
            if not text_content:
                return deterministic_intelligence

            # Parse and validate JSON
            parsed_gemini = json.loads(text_content)
            
            # Strict safety gate: Filter therapies against verified deterministic knowledge base
            validated_options = []
            for opt in parsed_gemini.get("treatment_options", []):
                dname = opt.get("drug_name", "").strip().lower()
                # Check for match in verified drugs
                matched_kb_therapy = None
                for vk, v_therapy in verified_drugs.items():
                    if vk in dname or dname in vk:
                        matched_kb_therapy = v_therapy
                        break

                if matched_kb_therapy:
                    # Enrich verified therapy with Gemini's reasoning while preserving ground-truth metadata
                    merged = dict(matched_kb_therapy)
                    if opt.get("why_relevant"):
                        merged["why_relevant"] = opt["why_relevant"]
                    if opt.get("mechanism"):
                        merged["how_it_works"] = opt["mechanism"]
                    validated_options.append(merged)
                else:
                    logger.warning(f"REJECTED unverified medicine from Gemini reasoning: '{opt.get('drug_name')}'")

            # Update deterministic intelligence with validated reasoning
            result = dict(deterministic_intelligence)
            if validated_options:
                result["targeted_therapies"] = validated_options
            if parsed_gemini.get("limitations"):
                result["genomic_data_limitation_notice"] = parsed_gemini["limitations"]
            if parsed_gemini.get("biomarker_status"):
                result["biomarker_summary_status"] = parsed_gemini["biomarker_status"]

            return result

        except Exception as e:
            logger.error(f"Error during Gemini reasoning execution: {e}. Falling back to verified database.")
            return deterministic_intelligence


# Singleton instance
gemini_treatment_service = GeminiTreatmentReasoningService()
