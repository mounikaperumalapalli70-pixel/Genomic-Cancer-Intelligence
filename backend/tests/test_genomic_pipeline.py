import pytest
import numpy as np
import pandas as pd
from sklearn.preprocessing import LabelEncoder

from backend.ml.genomic.preprocessing import split_dataset_stratified, GenomicPreprocessor, fit_label_encoder
from backend.ml.genomic.feature_selection import GenomicFeatureSelector
from backend.ml.genomic.evaluate import evaluate_predictions
from backend.ml.genomic.predict import GenomicPredictor


@pytest.fixture
def synthetic_genomic_data():
    """Generates synthetic high-dimensional expression matrix and multi-class cancer labels."""
    np.random.seed(42)
    n_samples = 150
    n_genes = 60
    n_classes = 5
    
    # 5 cancer classes with varying sample counts
    classes = [f"CANCER_TYPE_{i}" for i in range(n_classes)]
    y_labels = np.random.choice(classes, size=n_samples, p=[0.3, 0.25, 0.2, 0.15, 0.1])
    
    gene_names = [f"GENE_{i}" for i in range(n_genes)]
    
    # Generate base expression matrix
    X_mat = np.random.normal(loc=8.0, scale=2.0, size=(n_samples, n_genes)).astype(np.float32)
    
    # Add 5 constant/zero-variance genes
    X_mat[:, 0:5] = 5.0
    
    # Add class-specific biomarker signals to first 10 informative genes
    for i, c in enumerate(classes):
        mask = (y_labels == c)
        X_mat[mask, 5 + i * 2 : 7 + i * 2] += 4.0
        
    df_X = pd.DataFrame(X_mat, index=[f"TCGA-SAMPLE-{i:03d}" for i in range(n_samples)], columns=gene_names)
    s_y = pd.Series(y_labels, index=df_X.index, name="_primary_disease")
    
    return df_X, s_y


def test_stratified_split(synthetic_genomic_data):
    """Verifies stratified splitting without data leakage."""
    X, y = synthetic_genomic_data
    X_train, X_val, X_test, y_train, y_val, y_test = split_dataset_stratified(
        X, y, test_size=0.15, val_size=0.15, random_seed=42
    )
    
    # Verify no sample index overlap
    train_idx = set(X_train.index)
    val_idx = set(X_val.index)
    test_idx = set(X_test.index)
    
    assert len(train_idx.intersection(val_idx)) == 0
    assert len(train_idx.intersection(test_idx)) == 0
    assert len(val_idx.intersection(test_idx)) == 0
    assert len(train_idx) + len(val_idx) + len(test_idx) == len(X)
    
    # Verify all classes exist in partitions
    assert set(y_train.unique()) == set(y.unique())
    assert set(y_val.unique()) == set(y.unique())
    assert set(y_test.unique()) == set(y.unique())


def test_genomic_preprocessor(synthetic_genomic_data):
    """Verifies preprocessor imputes, filters low variance, and scales features."""
    X, y = synthetic_genomic_data
    X_train, X_val, X_test, y_train, y_val, y_test = split_dataset_stratified(
        X, y, test_size=0.15, val_size=0.15, random_seed=42
    )
    
    # Introduce NaNs in train and val to test imputation
    X_train_corrupt = X_train.copy()
    X_train_corrupt.iloc[0, 10] = np.nan
    X_train_corrupt.iloc[2, 15] = np.nan
    
    preprocessor = GenomicPreprocessor(variance_threshold=0.05, apply_scaling=True)
    X_train_prep = preprocessor.fit_transform(X_train_corrupt)
    X_val_prep = preprocessor.transform(X_val)
    
    assert preprocessor.is_fitted
    assert not X_train_prep.isna().any().any()
    assert not X_val_prep.isna().any().any()
    
    # Zero-variance genes (GENE_0 to GENE_4) should be removed
    for low_var_gene in [f"GENE_{i}" for i in range(5)]:
        assert low_var_gene not in X_train_prep.columns
        assert low_var_gene not in X_val_prep.columns
        
    # Check standardization (mean approx 0, std approx 1 on train)
    np.testing.assert_allclose(X_train_prep.mean(axis=0), 0.0, atol=1e-1)


def test_feature_selection(synthetic_genomic_data):
    """Verifies ANOVA F-score feature selection subsets to requested k features."""
    X, y = synthetic_genomic_data
    X_train, X_val, X_test, y_train, y_val, y_test = split_dataset_stratified(
        X, y, test_size=0.15, val_size=0.15, random_seed=42
    )
    
    le = fit_label_encoder(y_train)
    y_train_enc = le.transform(y_train)
    
    preprocessor = GenomicPreprocessor(variance_threshold=0.05, apply_scaling=True)
    X_train_prep = preprocessor.fit_transform(X_train)
    X_val_prep = preprocessor.transform(X_val)
    
    k = 20
    selector = GenomicFeatureSelector(k=k, score_func="f_classif")
    X_train_k = selector.fit_transform(X_train_prep, y_train_enc)
    X_val_k = selector.transform(X_val_prep)
    
    assert selector.is_fitted
    assert X_train_k.shape[1] == k
    assert X_val_k.shape[1] == k
    assert len(selector.selected_genes_) == k
    assert len(selector.gene_scores_) > 0


def test_evaluate_metrics():
    """Verifies multi-class evaluation metric calculations."""
    y_true = np.array([0, 1, 2, 0, 1, 2, 0, 1, 2])
    y_pred = np.array([0, 1, 2, 0, 2, 2, 0, 1, 1])
    class_names = ["ClassA", "ClassB", "ClassC"]
    
    metrics = evaluate_predictions(y_true, y_pred, class_names=class_names)
    
    assert "accuracy" in metrics
    assert "macro_f1" in metrics
    assert "weighted_f1" in metrics
    assert "per_class" in metrics
    assert "confusion_matrix" in metrics
    assert 0.0 <= metrics["accuracy"] <= 1.0
    assert 0.0 <= metrics["macro_f1"] <= 1.0
    assert len(metrics["per_class"]) == 3
