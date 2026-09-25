import logging
from typing import Dict, Any, List, Optional
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field, ConfigDict

from backend.services.treatment_service import treatment_service
from backend.services.gemini_treatment_service import gemini_treatment_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/treatment", tags=["Precision Medicine & Treatment Intelligence"])


class BiomarkerItem(BaseModel):
    gene: str = Field(..., description="Gene symbol (e.g. EGFR, KRAS, BRCA1)")
    status: Optional[str] = Field("upregulated", description="Biomarker alteration status (upregulated, downregulated, baseline)")
    z_score_deviation: Optional[float] = Field(None, description="Z-score deviation relative to TCGA baseline")


class TreatmentIntelligenceRequest(BaseModel):
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "cancer_type": "lung adenocarcinoma",
                "biomarkers": [
                    {"gene": "EGFR", "status": "upregulated", "z_score_deviation": 2.45},
                    {"gene": "KRAS", "status": "upregulated", "z_score_deviation": 1.80},
                    {"gene": "TP53", "status": "aberrant", "z_score_deviation": 1.20}
                ],
                "is_image_upload": False,
                "confirmed_alterations": []
            }
        }
    )

    cancer_type: str = Field(..., description="Predicted or specified TCGA cancer type name")
    biomarkers: Optional[List[BiomarkerItem]] = Field(default_factory=list, description="List of detected genomic biomarker alterations")
    is_image_upload: bool = Field(False, description="Whether this query originated from a medical image upload (where genomic data is absent)")
    confirmed_alterations: Optional[List[str]] = Field(default_factory=list, description="List of confirmed genomic somatic mutations or alterations")


@router.post("/intelligence", summary="Get Evidence-Based Targeted Therapies & Clinical Trials")
async def get_treatment_intelligence(payload: TreatmentIntelligenceRequest):
    """
    Returns structured NCCN-aligned targeted therapies, FDA drug approvals, resistance pathways,
    clinical trial eligibility criteria, and oncology nutrition guidance for a cancer phenotype.
    """
    try:
        biomarker_dicts = [b.model_dump() for b in payload.biomarkers] if payload.biomarkers else []
        base_intelligence = treatment_service.get_treatment_intelligence(
            cancer_type=payload.cancer_type,
            biomarkers=biomarker_dicts,
            is_image_upload=payload.is_image_upload,
            confirmed_alterations=payload.confirmed_alterations
        )
        
        # Enhance with backend-only validated Gemini reasoning if available
        final_intelligence = await gemini_treatment_service.reason_over_evidence(
            deterministic_intelligence=base_intelligence
        )
        return final_intelligence
    except Exception as e:
        logger.error(f"Error generating treatment intelligence: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate treatment intelligence."
        )

