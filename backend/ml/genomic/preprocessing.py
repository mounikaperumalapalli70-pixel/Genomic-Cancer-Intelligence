import logging
import numpy as np
import pandas as pd
from typing import Tuple, List, Dict, Any, Optional
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler, RobustScaler
from sklearn.feature_selection import VarianceThreshold

logger = logging.getLogger(__name__)

def split_dataset_stratified(
    X: pd.DataFrame,
    y: pd.Series,
    test_size: float = 0.15,
    val_size: float = 0.15,
    random_seed: int = 42
) -> Tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame, pd.Series, pd.Series, pd.Series]:
    """
    Splits dataset into Stratified Train, Validation, and Test partitions.
    
    Strict Data Leakage Prevention:
    - Test set is isolated immediately and NEVER seen during preprocessing, feature selection, or validation tuning.
    
    Returns:
        X_train, X_val, X_test, y_train, y_val, y_test
    """
    logger.info(f"Splitting dataset ({len(X)} samples) -> Train/Val/Test (Test={test_size:.2f}, Val={val_size:.2f})...")
    
    # 1. Split into (Train + Val) and Test
    X_train_val, X_test, y_train_val, y_test = train_test_split(
        X, y,
        test_size=test_size,
        stratify=y,
        random_state=random_seed
    )
    
    # 2. Split (Train + Val) into Train and Val
    # Adjust val_size relative to remaining train_val data
    adjusted_val_size = val_size / (1.0 - test_size)
    X_train, X_val, y_train, y_val = train_test_split(
        X_train_val, y_train_val,
        test_size=adjusted_val_size,
        stratify=y_train_val,
        random_state=random_seed
    )
    
    logger.info(f"Dataset split complete: Train={len(X_train)} ({len(X_train)/len(X):.1%}), "
                f"Val={len(X_val)} ({len(X_val)/len(X):.1%}), Test={len(X_test)} ({len(X_test)/len(X):.1%})")
    
    return X_train, X_val, X_test, y_train, y_val, y_test


class GenomicPreprocessor:
    """
    Production Preprocessor for High-Dimensional Genomic Expression Data.
    
    Fitted STRICTLY on training data:
    1. Imputes missing values using training gene medians.
    2. Filters zero and near-zero variance genes (VarianceThreshold).
    3. Normalizes feature scale using StandardScaler fitted on training partition.
    """
    
    def __init__(self, variance_threshold: float = 0.05, apply_scaling: bool = True):
        self.variance_threshold = variance_threshold
        self.apply_scaling = apply_scaling
        
        self.impute_values_: Optional[pd.Series] = None
        self.passed_variance_genes_: Optional[List[str]] = None
        self.scaler_: Optional[StandardScaler] = None
        self.original_feature_names_: Optional[List[str]] = None
        self.is_fitted: bool = False

    def fit(self, X_train: pd.DataFrame, y_train: Optional[pd.Series] = None) -> "GenomicPreprocessor":
        """Fits imputer, variance filter, and scaler strictly on training samples."""
        logger.info("Fitting GenomicPreprocessor on training data...")
        self.original_feature_names_ = list(X_train.columns)
        
        # 1. Compute training medians for imputation
        self.impute_values_ = X_train.median(axis=0).fillna(0.0)
        X_imputed = X_train.fillna(self.impute_values_)
        
        # 2. Fit variance threshold on training features
        var_selector = VarianceThreshold(threshold=self.variance_threshold)
        var_selector.fit(X_imputed)
        
        self.passed_variance_mask_ = var_selector.get_support()
        self.passed_variance_genes_ = [
            gene for gene, passed in zip(self.original_feature_names_, self.passed_variance_mask_)
            if passed
        ]
        logger.info(f"Variance filter (threshold={self.variance_threshold}): "
                    f"{len(self.original_feature_names_)} -> {len(self.passed_variance_genes_)} genes retained.")
        
        # 3. Fit Scaler on training features that passed variance filtering
        X_filtered = X_imputed[self.passed_variance_genes_]
        if self.apply_scaling:
            self.scaler_ = StandardScaler()
            self.scaler_.fit(X_filtered)
        
        self.is_fitted = True
        return self

    def transform(self, X: pd.DataFrame) -> pd.DataFrame:
        """Transforms new samples using fitted training parameters."""
        if not self.is_fitted:
            raise ValueError("GenomicPreprocessor must be fitted before transform.")
        
        # High-performance 1ms vector alignment
        impute_arr = self.impute_values_.values if isinstance(self.impute_values_, pd.Series) else np.array(self.impute_values_)
        full_matrix = np.tile(impute_arr, (len(X), 1))
        
        gene_to_idx = {g: i for i, g in enumerate(self.original_feature_names_)}
        for gene in X.columns:
            if gene in gene_to_idx:
                idx = gene_to_idx[gene]
                vals = pd.to_numeric(X[gene], errors="coerce").values
                valid_mask = ~pd.isna(vals)
                full_matrix[valid_mask, idx] = vals[valid_mask]
        
        # Retain variance-passing features
        X_filtered = full_matrix[:, self.passed_variance_mask_]
        
        # Apply standard scaling
        if self.apply_scaling and self.scaler_ is not None:
            scaled_data = self.scaler_.transform(X_filtered)
            return pd.DataFrame(scaled_data, index=X.index, columns=self.passed_variance_genes_)
        
        return pd.DataFrame(X_filtered, index=X.index, columns=self.passed_variance_genes_)

    def fit_transform(self, X_train: pd.DataFrame, y_train: Optional[pd.Series] = None) -> pd.DataFrame:
        return self.fit(X_train, y_train).transform(X_train)


def fit_label_encoder(y_train: pd.Series) -> LabelEncoder:
    """Fits LabelEncoder on training class labels."""
    le = LabelEncoder()
    le.fit(y_train)
    logger.info(f"LabelEncoder fitted with {len(le.classes_)} classes.")
    return le
