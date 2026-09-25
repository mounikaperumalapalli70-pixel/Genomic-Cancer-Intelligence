import logging
from typing import Dict, Any, List, Optional
import numpy as np
import pandas as pd

from backend.ml.genomic.predict import get_genomic_predictor, GenomicPredictor

logger = logging.getLogger(__name__)


class ExplainabilityService:
    """
    Explainable AI (XAI) service for Genomic Biomarker Attributions.
    
    Provides feature attribution, z-score deviation profiling, and model-level
    biomarker importance rankings.
    
    NOTE ON MEDICAL INTERPRETABILITY:
    Biomarker feature attributions indicate statistical correlation with
    pan-cancer molecular subtypes within the TCGA cohort. They do NOT imply
    direct individual causation or clinical mechanism without independent
    experimental validation.
    """

    def __init__(self, predictor: Optional[GenomicPredictor] = None):
        self._predictor = predictor

    @property
    def predictor(self) -> GenomicPredictor:
        if self._predictor is None:
            self._predictor = get_genomic_predictor()
        return self._predictor

    def explain_sample_prediction(
        self,
        expression_dict: Dict[str, float],
        top_n: int = 10
    ) -> Dict[str, Any]:
        """
        Computes sample-level biomarker deviations and statistical contributions.
        """
        if not self.predictor.is_loaded:
            self.predictor.load_artifacts()

        # Run prediction to get aligned feature vectors
        aligned_df = self.predictor.validate_input(expression_dict)
        X_prep = self.predictor.preprocessor.transform(aligned_df)
        X_selected = self.predictor.feature_selector.transform(X_prep)
        
        y_pred_idx = self.predictor.model.predict(X_selected)[0]
        predicted_class = str(self.predictor.label_encoder.inverse_transform([y_pred_idx])[0])
        
        # Calculate biomarker attributions based on normalized z-score deviations
        sample_vals = X_selected.iloc[0]
        sorted_genes = sample_vals.abs().sort_values(ascending=False).head(top_n)
        
        attributions = []
        for gene, z_val in sorted_genes.items():
            raw_val = float(aligned_df.iloc[0].get(gene, np.nan))
            ref_median = float(self.predictor.preprocessor.impute_values_.get(gene, 0.0))
            attributions.append({
                "gene": str(gene),
                "sample_expression": round(raw_val, 4) if not np.isnan(raw_val) else None,
                "cohort_median": round(ref_median, 4),
                "z_score": round(float(z_val), 4),
                "direction": "overexpressed" if z_val > 0 else "underexpressed",
                "relative_impact_magnitude": round(abs(float(z_val)), 4)
            })
            
        return {
            "predicted_cancer_type": predicted_class,
            "top_biomarker_attributions": attributions,
            "methodology": "Z-score cohort baseline deviation & ANOVA F-score biomarker alignment",
            "clinical_disclaimer": "Feature importance reflects statistical association with TCGA reference cohort profiles and does not establish individual etiology."
        }


# Singleton instance
xai_service = ExplainabilityService()
