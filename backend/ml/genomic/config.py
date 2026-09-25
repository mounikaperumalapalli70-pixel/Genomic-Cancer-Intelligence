import os
from pathlib import Path
from dataclasses import dataclass, field
from typing import List, Dict, Any

# Project Base Directory
BASE_DIR = Path(__file__).resolve().parent.parent.parent.parent

@dataclass
class GenomicConfig:
    # Randomness and Reproducibility
    random_seed: int = 42
    
    # Dataset Paths (relative to workspace root)
    expr_path: str = str(BASE_DIR / "data" / "tcga" / "EB++AdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp (2).xena.gz")
    pheno_path: str = str(BASE_DIR / "data" / "tcga" / "TCGA_phenotype_denseDataOnlyDownload.tsv.gz")
    
    # Artifact Output Directory
    artifacts_dir: str = str(BASE_DIR / "backend" / "models" / "genomic")
    
    # Data Split Parameters
    test_size: float = 0.15
    val_size: float = 0.15  # 15% Val, 15% Test, 70% Train
    stratify: bool = True
    
    # Feature Selection Configurations to Compare
    feature_counts: List[int] = field(default_factory=lambda: [100, 250, 500, 1000, 2000])
    feature_selection_method: str = "f_classif"  # ANOVA F-value
    variance_threshold: float = 0.05
    
    # Model Versioning & Metadata
    model_version: str = "1.0.0-tcga-pancan"
    model_name: str = "TCGA Multiclass Genomic Cancer Classifier"
    
    # Models to Evaluate
    models_to_evaluate: List[str] = field(default_factory=lambda: [
        "logistic_regression",
        "linear_svc",
        "random_forest",
        "xgboost",
        "lightgbm",
        "mlp"
    ])
    
    # Primary Model Selection Metric
    primary_metric: str = "macro_f1"

# Global default instance
config = GenomicConfig()
