import logging
import pandas as pd
import numpy as np
from typing import List, Dict, Tuple, Optional
from sklearn.feature_selection import SelectKBest, f_classif, mutual_info_classif

logger = logging.getLogger(__name__)

class GenomicFeatureSelector:
    """
    Supervised Feature Selection for High-Dimensional TCGA Gene Expression Data.
    
    Fits strictly on training features and training class labels to select top
    discriminative biomarker genes (e.g. 100, 250, 500, 1000, 2000).
    """
    
    def __init__(self, k: int = 500, score_func: str = "f_classif"):
        self.k = k
        self.score_func_name = score_func
        self.selector_: Optional[SelectKBest] = None
        self.selected_genes_: Optional[List[str]] = None
        self.gene_scores_: Optional[pd.DataFrame] = None
        self.is_fitted: bool = False

    def fit(self, X_train: pd.DataFrame, y_train: np.ndarray) -> "GenomicFeatureSelector":
        """
        Fits feature ranking on training data using ANOVA F-value.
        """
        logger.info(f"Fitting GenomicFeatureSelector (k={self.k}, method={self.score_func_name}) on {X_train.shape[1]} input features...")
        
        score_fn = f_classif if self.score_func_name == "f_classif" else mutual_info_classif
        
        # Ensure k is bounded by available features
        actual_k = min(self.k, X_train.shape[1])
        self.selector_ = SelectKBest(score_func=score_fn, k=actual_k)
        self.selector_.fit(X_train, y_train)
        
        # Extract selected feature names
        mask = self.selector_.get_support()
        self.selected_genes_ = [gene for gene, selected in zip(X_train.columns, mask) if selected]
        
        # Build comprehensive gene score table
        scores = self.selector_.scores_
        pvalues = getattr(self.selector_, "pvalues_", [np.nan] * len(scores))
        
        df_scores = pd.DataFrame({
            "gene": X_train.columns,
            "f_score": scores,
            "p_value": pvalues
        })
        df_scores = df_scores.sort_values(by="f_score", ascending=False).reset_index(drop=True)
        df_scores["rank"] = df_scores.index + 1
        df_scores["is_selected"] = df_scores["gene"].isin(self.selected_genes_)
        self.gene_scores_ = df_scores
        
        logger.info(f"Selected top {len(self.selected_genes_)} discriminative genes. Top 5: {self.gene_scores_['gene'].head(5).tolist()}")
        self.is_fitted = True
        return self

    def transform(self, X: pd.DataFrame) -> pd.DataFrame:
        """
        Subsets DataFrame to only the top k selected genes.
        """
        if not self.is_fitted:
            raise ValueError("GenomicFeatureSelector must be fitted before transform.")
        
        # Align columns
        available_selected = [g for g in self.selected_genes_ if g in X.columns]
        if len(available_selected) < len(self.selected_genes_):
            logger.warning(f"Input data missing {len(self.selected_genes_) - len(available_selected)} selected features.")
        
        return X[self.selected_genes_]

    def fit_transform(self, X_train: pd.DataFrame, y_train: np.ndarray) -> pd.DataFrame:
        return self.fit(X_train, y_train).transform(X_train)

    def get_top_features_table(self, top_n: int = 50) -> pd.DataFrame:
        """Returns the top N scored biomarker genes with statistics."""
        if not self.is_fitted or self.gene_scores_ is None:
            raise ValueError("Selector must be fitted.")
        return self.gene_scores_.head(top_n)
