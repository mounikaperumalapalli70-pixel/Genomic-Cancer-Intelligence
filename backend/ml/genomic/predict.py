import os
import json
import logging
from pathlib import Path
from typing import Dict, Any, List, Union, Optional
import joblib
import numpy as np
import pandas as pd

logger = logging.getLogger(__name__)

DEFAULT_ARTIFACTS_DIR = Path(__file__).resolve().parent.parent.parent / "models" / "genomic"


class GenomicPredictor:
    """
    Production Inference Engine for Genomic Pan-Cancer Classification.
    
    Loads pre-trained model artifacts (preprocessor, feature selector, classifier, label encoder, metadata)
    and executes fast, memory-efficient inference without reloading training datasets.
    """
    
    def __init__(self, artifacts_dir: Optional[Union[str, Path]] = None):
        self.artifacts_dir = Path(artifacts_dir) if artifacts_dir else DEFAULT_ARTIFACTS_DIR
        self.model = None
        self.preprocessor = None
        self.feature_selector = None
        self.label_encoder = None
        self.selected_genes: List[str] = []
        self.all_genes: List[str] = []
        self.classes: List[str] = []
        self.metadata: Dict[str, Any] = {}
        self.is_loaded = False
        
        self.load_artifacts()

    def load_artifacts(self) -> None:
        """Loads all serialized artifacts from disk."""
        if not self.artifacts_dir.exists():
            logger.warning(f"Genomic artifacts directory does not exist: {self.artifacts_dir}")
            self.is_loaded = False
            return
            
        try:
            logger.info(f"Loading genomic model artifacts from: {self.artifacts_dir}")
            model_path = self.artifacts_dir / "model.joblib"
            prep_path = self.artifacts_dir / "preprocessor.joblib"
            feat_path = self.artifacts_dir / "feature_selector.joblib"
            lbl_path = self.artifacts_dir / "label_encoder.joblib"
            
            if not (model_path.exists() and prep_path.exists() and feat_path.exists() and lbl_path.exists()):
                logger.warning(f"One or more required artifact files missing in {self.artifacts_dir}")
                self.is_loaded = False
                return
                
            self.model = joblib.load(model_path)
            self.preprocessor = joblib.load(prep_path)
            self.feature_selector = joblib.load(feat_path)
            self.label_encoder = joblib.load(lbl_path)
            
            genes_json = self.artifacts_dir / "selected_genes.json"
            if genes_json.exists():
                with open(genes_json, "r") as f:
                    self.selected_genes = json.load(f)
            else:
                self.selected_genes = getattr(self.feature_selector, "selected_genes_", [])
                
            classes_json = self.artifacts_dir / "classes.json"
            if classes_json.exists():
                with open(classes_json, "r") as f:
                    class_data = json.load(f)
                    self.classes = class_data.get("classes", list(self.label_encoder.classes_))
            else:
                self.classes = list(self.label_encoder.classes_)
                
            meta_json = self.artifacts_dir / "metadata.json"
            if meta_json.exists():
                with open(meta_json, "r") as f:
                    self.metadata = json.load(f)
                    
            self.all_genes = getattr(self.preprocessor, "original_feature_names_", self.selected_genes)
            self.is_loaded = True
            logger.info(f"GenomicPredictor successfully loaded. Model version: {self.metadata.get('model_version')}")
        except Exception as e:
            logger.error(f"Failed to load genomic model artifacts: {e}")
            self.is_loaded = False

    # Hallmark Lineage & Oncogenic Driver Signatures for TCGA Classes
    HALLMARK_SIGNATURES: Dict[str, List[str]] = {
        "lung adenocarcinoma": ["NKX2-1", "NAPSA", "SFTA3", "KRT7", "MUC1", "EGFR"],
        "breast invasive carcinoma": ["GATA3", "ESR1", "PGR", "ERBB2", "FOXA1"],
        "glioblastoma multiforme": ["GFAP", "OLIG2", "NES", "SOX2", "EGFR"],
        "colon adenocarcinoma": ["CDX2", "CEACAM5", "KRT20", "AXIN2"],
        "skin cutaneous melanoma": ["PMEL", "MLANA", "TYR", "MITF", "SOX10", "DCT"],
        "thyroid carcinoma": ["TG", "TPO", "PAX8", "TSHR"],
        "kidney clear cell carcinoma": ["CA9", "EPAS1", "VEGFA"],
        "acute myeloid leukemia": ["MPO", "CD34", "FLT3"],
        "prostate adenocarcinoma": ["KLK3", "KLK2", "FOLH1", "AR"],
        "liver hepatocellular carcinoma": ["AFP", "ALB", "GPC3", "APOA1"],
        "pancreatic adenocarcinoma": ["PDX1", "GATA6", "MUC1"],
        "stomach adenocarcinoma": ["MUC5AC", "MUC6", "CDH1"],
        "ovarian serous cystadenocarcinoma": ["MUC16", "WT1", "PAX8"],
        "bladder urothelial carcinoma": ["UPK1A", "UPK2", "UPK3A"],
        "head & neck squamous cell carcinoma": ["TP63", "KRT5"],
        "uterine corpus endometrioid carcinoma": ["PTEN", "ARID1A", "ESR1"]
    }

    def validate_input(
        self,
        raw_input: Union[Dict[str, float], pd.DataFrame, List[Dict[str, Any]]]
    ) -> pd.DataFrame:
        """
        Validates and formats incoming genomic expression values.
        
        Requirements:
        1. Non-empty data.
        2. Valid numeric values (no non-numeric strings or infinities).
        3. Sufficient overlap with known TCGA biomarker gene space.
        """
        if raw_input is None:
            raise ValueError("Input data cannot be null or empty.")
            
        # Convert dictionary or list to DataFrame
        if isinstance(raw_input, dict):
            if not raw_input:
                raise ValueError("Genomic expression input dictionary is empty.")
            # Normalize keys to uppercase stripped strings
            clean_dict = {str(k).strip().upper(): v for k, v in raw_input.items()}
            df = pd.DataFrame([clean_dict])
        elif isinstance(raw_input, list):
            if len(raw_input) == 0:
                raise ValueError("Genomic expression input list is empty.")
            clean_list = []
            for item in raw_input:
                if isinstance(item, dict):
                    clean_list.append({str(k).strip().upper(): v for k, v in item.items()})
            df = pd.DataFrame(clean_list)
        elif isinstance(raw_input, pd.DataFrame):
            if raw_input.empty:
                raise ValueError("Genomic expression DataFrame is empty.")
            df = raw_input.copy()
            df.columns = [str(c).strip().upper() for c in df.columns]
        else:
            raise TypeError(f"Unsupported input type: {type(raw_input)}. Expected dict, list of dicts, or DataFrame.")

        # Ensure numeric values and convert
        for col in df.columns:
            try:
                df[col] = pd.to_numeric(df[col], errors="coerce")
            except Exception:
                pass
                
        # Check if all columns are NaN or non-numeric
        if df.isna().all().all():
            raise ValueError("All provided expression values are NaN or non-numeric.")

        if not self.is_loaded:
            self.load_artifacts()
            if not self.is_loaded:
                raise RuntimeError("Model artifacts are not loaded. Run the training pipeline first.")

        # Check feature overlap with full genome (20,530 genes) and selected genes (2,000 genes)
        provided_genes = set(df.columns)
        all_genome_set = set(self.all_genes)
        selected_genes_set = set(self.selected_genes)
        
        overlap_all = provided_genes.intersection(all_genome_set)
        overlap_selected = provided_genes.intersection(selected_genes_set)
        
        # We require at least 3 valid provided genes and at least 1 matching the TCGA genome space
        if len(provided_genes) < 3:
            raise ValueError(
                f"Insufficient genomic features provided ({len(provided_genes)} genes). "
                f"A minimum of 3 valid gene expression values is required for genomic cancer screening."
            )
            
        if len(overlap_all) < 1 and len(overlap_selected) < 1:
            raise ValueError(
                f"None of the {len(provided_genes)} provided genes match known TCGA biomarker space. "
                f"Please provide standard HGNC gene symbols (e.g., TP53, EGFR, BRCA1, MYC, NKX2-1, KRAS)."
            )

        return df

    def predict(
        self,
        raw_input: Union[Dict[str, float], pd.DataFrame],
        top_k_classes: int = 5,
        top_biomarkers_count: int = 5
    ) -> Dict[str, Any]:
        """
        Runs cancer-type prediction on genomic expression profile.
        Supports both full high-dimensional RNA-seq expression matrices and targeted biomarker panels.
        """
        # Validate and align input
        aligned_df = self.validate_input(raw_input)
        
        if not self.is_loaded:
            raise RuntimeError("Model artifacts are not loaded.")
            
        # Preprocessing & Feature Selection
        X_prep = self.preprocessor.transform(aligned_df)
        X_selected = self.feature_selector.transform(X_prep)
        
        # Base Model Inference
        raw_probs = None
        if hasattr(self.model, "predict_proba"):
            raw_probs = self.model.predict_proba(X_selected)[0]
        elif hasattr(self.model, "decision_function"):
            dfunc = self.model.decision_function(X_selected)[0]
            exp_df = np.exp(dfunc - np.max(dfunc))
            raw_probs = exp_df / np.sum(exp_df)
        else:
            raw_probs = np.zeros(len(self.classes))
            raw_probs[0] = 1.0

        class_names = list(self.label_encoder.classes_)
        prob_dict = {cname: float(p) for cname, p in zip(class_names, raw_probs)}

        # Check for targeted panel signature evidence when input is sparse
        provided_keys = set(aligned_df.columns)
        overlap_selected = provided_keys.intersection(set(self.selected_genes))
        overlap_genome = provided_keys.intersection(set(self.all_genes))
        
        # When fewer than 200 of the 2,000 ANOVA features are supplied, evaluate hallmark oncogenic signatures
        if len(overlap_selected) < 200 and len(provided_keys) > 0:
            signature_scores = {}
            for ctype, markers in self.HALLMARK_SIGNATURES.items():
                if ctype not in class_names:
                    continue
                matched_markers = [m for m in markers if m in provided_keys]
                if matched_markers:
                    # Calculate z-score / deviation sum above reference median for matched markers
                    elevations = []
                    for m in matched_markers:
                        val = float(aligned_df.iloc[0].get(m, 0.0))
                        ref_med = float(self.preprocessor.impute_values_.get(m, 0.0))
                        diff = max(0.0, val - ref_med)
                        elevations.append(diff)
                    mean_elev = float(np.mean(elevations))
                    coverage_weight = len(matched_markers) / len(markers)
                    signature_scores[ctype] = mean_elev * (1.0 + coverage_weight)

            if signature_scores:
                best_sig_ctype = max(signature_scores, key=signature_scores.get)
                best_sig_val = signature_scores[best_sig_ctype]
                
                # If strong hallmark evidence exists, blend into calibrated distribution
                if best_sig_val > 2.0:
                    adjusted_scores = np.zeros(len(class_names))
                    for i, cname in enumerate(class_names):
                        base_p = prob_dict.get(cname, 0.001)
                        sig_boost = signature_scores.get(cname, 0.0)
                        adjusted_scores[i] = np.log(max(base_p, 1e-4)) + (sig_boost * 2.2)
                    
                    # Softmax with temperature
                    exp_scores = np.exp(adjusted_scores - np.max(adjusted_scores))
                    calibrated_probs = exp_scores / np.sum(exp_scores)
                    prob_dict = {cname: float(round(float(p), 4)) for cname, p in zip(class_names, calibrated_probs)}

        # Sort final probabilities
        sorted_probs = dict(sorted(prob_dict.items(), key=lambda item: item[1], reverse=True))
        predicted_cancer_type = list(sorted_probs.keys())[0]
        top_prob = float(round(float(sorted_probs[predicted_cancer_type]), 4))

        # Calculate feature attribution / top discriminative biomarkers for this sample
        biomarker_attributions = []
        sample_selected_vals = X_selected.iloc[0]
        
        # Include provided genes with highest deviation first
        provided_deviations = []
        for gene in provided_keys:
            if gene in self.all_genes:
                raw_val = float(aligned_df.iloc[0].get(gene, np.nan))
                ref_median = float(self.preprocessor.impute_values_.get(gene, 0.0))
                # Compute approximate z-score
                z_val = (raw_val - ref_median) / 2.0
                provided_deviations.append((gene, raw_val, ref_median, z_val, abs(z_val)))
                
        provided_deviations.sort(key=lambda x: x[4], reverse=True)
        
        for gene, raw_val, ref_med, z_val, _ in provided_deviations[:max(top_biomarkers_count, 10)]:
            biomarker_attributions.append({
                "gene": str(gene),
                "expression_value": round(raw_val, 4) if not np.isnan(raw_val) else None,
                "reference_median": round(ref_med, 4),
                "z_score_deviation": round(float(z_val), 4),
                "status": "upregulated" if z_val > 0.5 else ("downregulated" if z_val < -0.5 else "baseline")
            })

        return {
            "success": True,
            "prediction": {
                "cancer_type": predicted_cancer_type,
                "probability": top_prob,
                "model_version": self.metadata.get("model_version", "1.0.0-tcga-pancan"),
                "model_name": self.metadata.get("model_name", "TCGA Multiclass Genomic Cancer Classifier")
            },
            "class_probabilities": sorted_probs,
            "top_classes": [
                {"cancer_type": c, "probability": p}
                for c, p in list(sorted_probs.items())[:top_k_classes]
            ],
            "top_contributing_biomarkers": biomarker_attributions,
            "input_summary": {
                "total_genes_provided": len(provided_keys),
                "recognized_genes_in_model_genome": len(overlap_genome),
                "selected_biomarkers_matched": len(overlap_selected) if len(overlap_selected) > 0 else len(overlap_genome),
                "total_model_features": len(self.selected_genes),
                "biomarker_coverage_pct": round(len(overlap_genome) / max(1, len(provided_keys)) * 100, 1)
            },
            "disclaimer": "FOR RESEARCH AND EDUCATIONAL USE ONLY. NOT FOR CLINICAL DIAGNOSTIC DECISIONS OR MEDICAL PRESCRIPTIONS."
        }


# Singleton predictor instance for memory-efficient reuse
_global_predictor: Optional[GenomicPredictor] = None

def get_genomic_predictor(artifacts_dir: Optional[Union[str, Path]] = None) -> GenomicPredictor:
    """Returns the singleton GenomicPredictor instance."""
    global _global_predictor
    if _global_predictor is None:
        _global_predictor = GenomicPredictor(artifacts_dir)
    elif not _global_predictor.is_loaded:
        _global_predictor.load_artifacts()
    return _global_predictor
