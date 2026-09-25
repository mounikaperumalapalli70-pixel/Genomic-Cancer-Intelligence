import os
import sys
import json
import time
import logging
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, List, Tuple

import joblib
import numpy as np
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.svm import LinearSVC
from sklearn.calibration import CalibratedClassifierCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.neural_network import MLPClassifier

# Add project root to sys.path to allow imports when run as script
project_root = Path(__file__).resolve().parent.parent.parent.parent
if str(project_root) not in sys.path:
    sys.path.insert(0, str(project_root))

from backend.ml.genomic.config import config, GenomicConfig
from backend.ml.genomic.data_loader import load_and_match_tcga_dataset
from backend.ml.genomic.preprocessing import (
    split_dataset_stratified,
    GenomicPreprocessor,
    fit_label_encoder
)
from backend.ml.genomic.feature_selection import GenomicFeatureSelector
from backend.ml.genomic.evaluate import evaluate_predictions, log_metrics_summary

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger("GenomicTrainingPipeline")


def initialize_model(model_type: str, random_seed: int = 42):
    """Factory creating multiclass classifiers configured for genomic expression data."""
    if model_type == "logistic_regression":
        return LogisticRegression(
            C=1.0,
            max_iter=1000,
            solver="lbfgs",
            random_state=random_seed,
            n_jobs=-1
        )
    elif model_type == "linear_svc":
        # Wrap LinearSVC in CalibratedClassifierCV to provide well-calibrated class probabilities
        base_svc = LinearSVC(
            C=0.1,
            max_iter=2000,
            random_state=random_seed,
            dual="auto"
        )
        return CalibratedClassifierCV(estimator=base_svc, cv=3)
    elif model_type == "random_forest":
        return RandomForestClassifier(
            n_estimators=200,
            max_depth=25,
            min_samples_split=4,
            random_state=random_seed,
            n_jobs=-1
        )
    elif model_type == "xgboost":
        try:
            from xgboost import XGBClassifier
        except ImportError:
            raise ImportError("xgboost is not installed. Run 'pip install xgboost' to train XGBoost models.")
        return XGBClassifier(
            n_estimators=150,
            max_depth=6,
            learning_rate=0.1,
            subsample=0.8,
            colsample_bytree=0.8,
            random_state=random_seed,
            eval_metric="mlogloss",
            n_jobs=-1
        )
    elif model_type == "lightgbm":
        try:
            from lightgbm import LGBMClassifier
        except ImportError:
            raise ImportError("lightgbm is not installed. Run 'pip install lightgbm' to train LightGBM models.")
        return LGBMClassifier(
            n_estimators=150,
            num_leaves=31,
            learning_rate=0.1,
            subsample=0.8,
            colsample_bytree=0.8,
            random_state=random_seed,
            n_jobs=-1,
            verbose=-1
        )
    elif model_type == "mlp":
        return MLPClassifier(
            hidden_layer_sizes=(256, 128),
            max_iter=250,
            early_stopping=True,
            n_iter_no_change=10,
            random_state=random_seed
        )
    else:
        raise ValueError(f"Unsupported model type: {model_type}")


def run_training_pipeline(cfg: GenomicConfig = config) -> Dict[str, Any]:
    """
    Executes the complete, leakage-free TCGA training and evaluation workflow.
    
    1. Loads expression and phenotype data.
    2. Performs stratified Train (70%), Validation (15%), Test (15%) split.
    3. Fits preprocessor strictly on training split.
    4. Evaluates multiple feature counts (100, 250, 500, 1000, 2000) and model architectures.
    5. Selects best pipeline based on Validation Macro F1.
    6. Evaluates selected pipeline ONCE on held-out Test set.
    7. Serializes all artifacts and metadata to disk.
    """
    start_total_time = time.time()
    logger.info("=" * 80)
    logger.info("STARTING TCGA PAN-CANCER GENOMIC CLASSIFICATION TRAINING PIPELINE")
    logger.info(f"Model Version: {cfg.model_version}")
    logger.info(f"Random Seed:   {cfg.random_seed}")
    logger.info("=" * 80)
    
    # 1. Load Data
    X_raw, y_raw, meta_df = load_and_match_tcga_dataset(
        expr_path=cfg.expr_path,
        pheno_path=cfg.pheno_path
    )
    n_total_samples, n_initial_genes = X_raw.shape
    unique_classes = sorted(y_raw.unique().tolist())
    n_classes = len(unique_classes)
    
    logger.info(f"Dataset Verified: {n_total_samples} samples, {n_initial_genes} genes, {n_classes} cancer types.")
    
    # 2. Stratified Split (Leakage Prevention)
    X_train_raw, X_val_raw, X_test_raw, y_train_str, y_val_str, y_test_str = split_dataset_stratified(
        X=X_raw,
        y=y_raw,
        test_size=cfg.test_size,
        val_size=cfg.val_size,
        random_seed=cfg.random_seed
    )
    
    # Fit Label Encoder on training targets
    label_encoder = fit_label_encoder(y_train_str)
    y_train = label_encoder.transform(y_train_str)
    y_val = label_encoder.transform(y_val_str)
    y_test = label_encoder.transform(y_test_str)
    class_names = list(label_encoder.classes_)
    
    # 3. Fit Preprocessor Strictly on Training Data
    preprocessor = GenomicPreprocessor(
        variance_threshold=cfg.variance_threshold,
        apply_scaling=True
    )
    logger.info("Fitting preprocessor on training data...")
    X_train_prep = preprocessor.fit_transform(X_train_raw)
    X_val_prep = preprocessor.transform(X_val_raw)
    X_test_prep = preprocessor.transform(X_test_raw)
    
    genes_after_variance = len(preprocessor.passed_variance_genes_)
    logger.info(f"Genes after variance filter: {genes_after_variance}")
    
    # 4. Model & Feature Count Comparison on Validation Set
    validation_leaderboard: List[Dict[str, Any]] = []
    trained_candidates: Dict[str, Any] = {}
    fitted_selectors: Dict[int, GenomicFeatureSelector] = {}
    
    best_config = {
        "macro_f1": -1.0,
        "k_features": None,
        "model_type": None,
        "model_instance": None,
        "selector_instance": None,
        "val_metrics": None
    }
    
    for k in cfg.feature_counts:
        logger.info("-" * 75)
        logger.info(f"EVALUATING FEATURE COUNT: Top {k} Genes (ANOVA F-Score)")
        logger.info("-" * 75)
        
        # Fit feature selector strictly on X_train_prep and y_train
        selector = GenomicFeatureSelector(k=k, score_func=cfg.feature_selection_method)
        X_train_k = selector.fit_transform(X_train_prep, y_train)
        X_val_k = selector.transform(X_val_prep)
        fitted_selectors[k] = selector
        
        for model_type in cfg.models_to_evaluate:
            model_key = f"{model_type}_k{k}"
            logger.info(f"Training [{model_type.upper()}] with {k} features...")
            t0 = time.time()
            
            clf = initialize_model(model_type, random_seed=cfg.random_seed)
            clf.fit(X_train_k, y_train)
            train_duration = time.time() - t0
            
            # Predict on Validation Set
            y_val_pred = clf.predict(X_val_k)
            y_val_prob = clf.predict_proba(X_val_k) if hasattr(clf, "predict_proba") else None
            
            val_metrics = evaluate_predictions(
                y_true=y_val,
                y_pred=y_val_pred,
                y_prob=y_val_prob,
                class_names=class_names
            )
            
            val_macro_f1 = val_metrics["macro_f1"]
            val_acc = val_metrics["accuracy"]
            val_weighted_f1 = val_metrics["weighted_f1"]
            
            logger.info(
                f"--> [{model_type.upper()} | k={k}] "
                f"Val Acc: {val_acc:.4f} | Val Macro F1: {val_macro_f1:.4f} | "
                f"Val Weighted F1: {val_weighted_f1:.4f} (Fit Time: {train_duration:.2f}s)"
            )
            
            entry = {
                "model_key": model_key,
                "model_type": model_type,
                "k_features": k,
                "training_time_sec": round(train_duration, 2),
                "accuracy": val_acc,
                "macro_precision": val_metrics["macro_precision"],
                "macro_recall": val_metrics["macro_recall"],
                "macro_f1": val_macro_f1,
                "weighted_f1": val_weighted_f1,
                "top3_accuracy": val_metrics.get("top3_accuracy")
            }
            validation_leaderboard.append(entry)
            
            # Check for best validation Macro F1
            if val_macro_f1 > best_config["macro_f1"]:
                best_config["macro_f1"] = val_macro_f1
                best_config["k_features"] = k
                best_config["model_type"] = model_type
                best_config["model_instance"] = clf
                best_config["selector_instance"] = selector
                best_config["val_metrics"] = val_metrics
    
    # Sort leaderboard by macro F1 descending
    validation_leaderboard.sort(key=lambda x: x["macro_f1"], reverse=True)
    
    logger.info("=" * 80)
    logger.info("VALIDATION COMPARISON LEADERBOARD (Top 10 Configurations):")
    for rank, entry in enumerate(validation_leaderboard[:10], 1):
        logger.info(
            f"{rank:2d}. {entry['model_key']:<26} | "
            f"Macro F1: {entry['macro_f1']:.4f} | "
            f"Accuracy: {entry['accuracy']:.4f} | "
            f"Weighted F1: {entry['weighted_f1']:.4f}"
        )
    logger.info("=" * 80)
    
    selected_k = best_config["k_features"]
    selected_model_type = best_config["model_type"]
    best_model = best_config["model_instance"]
    best_selector = best_config["selector_instance"]
    best_val_metrics = best_config["val_metrics"]
    
    logger.info(
        f"WINNING CONFIGURATION: [{selected_model_type.upper()}] with Top {selected_k} Genes "
        f"(Validation Macro F1: {best_config['macro_f1']:.4f})"
    )
    
    # 5. Evaluate WINNING Model Exactly ONCE on Held-Out Test Set
    logger.info("=" * 80)
    logger.info("EVALUATING FINAL SELECTED MODEL ON HELD-OUT TEST SET (NEVER SEEN BEFORE)")
    logger.info("=" * 80)
    
    X_test_selected = best_selector.transform(X_test_prep)
    y_test_pred = best_model.predict(X_test_selected)
    y_test_prob = best_model.predict_proba(X_test_selected) if hasattr(best_model, "predict_proba") else None
    
    test_metrics = evaluate_predictions(
        y_true=y_test,
        y_pred=y_test_pred,
        y_prob=y_test_prob,
        class_names=class_names
    )
    
    log_metrics_summary(
        model_name=f"{selected_model_type.upper()} (k={selected_k})",
        metrics=test_metrics,
        prefix="Held-Out Test"
    )
    
    # 6. Extract Feature Importance / Biomarker Analysis
    selected_genes = best_selector.selected_genes_
    gene_scores_table = best_selector.gene_scores_
    top_biomarkers = gene_scores_table[gene_scores_table["is_selected"]].head(100).to_dict(orient="records")
    
    # 7. Serialize Artifacts
    artifacts_dir = Path(cfg.artifacts_dir)
    artifacts_dir.mkdir(parents=True, exist_ok=True)
    
    logger.info(f"Saving model artifacts to: {artifacts_dir.resolve()}")
    
    # Core model files
    joblib.dump(best_model, artifacts_dir / "model.joblib")
    joblib.dump(preprocessor, artifacts_dir / "preprocessor.joblib")
    joblib.dump(best_selector, artifacts_dir / "feature_selector.joblib")
    joblib.dump(label_encoder, artifacts_dir / "label_encoder.joblib")
    
    # JSON metadata & configurations
    with open(artifacts_dir / "selected_genes.json", "w") as f:
        json.dump(selected_genes, f, indent=2)
        
    with open(artifacts_dir / "classes.json", "w") as f:
        json.dump({
            "classes": class_names,
            "class_to_idx": {c: i for i, c in enumerate(class_names)},
            "idx_to_class": {i: c for i, c in enumerate(class_names)}
        }, f, indent=2)
        
    with open(artifacts_dir / "validation_leaderboard.json", "w") as f:
        json.dump(validation_leaderboard, f, indent=2)
        
    with open(artifacts_dir / "validation_best_metrics.json", "w") as f:
        json.dump(best_val_metrics, f, indent=2)
        
    with open(artifacts_dir / "test_metrics.json", "w") as f:
        json.dump(test_metrics, f, indent=2)
        
    with open(artifacts_dir / "top_biomarkers.json", "w") as f:
        json.dump(top_biomarkers, f, indent=2)
        
    # Comprehensive Metadata JSON
    metadata = {
        "model_version": cfg.model_version,
        "model_name": cfg.model_name,
        "training_timestamp": datetime.utcnow().isoformat() + "Z",
        "random_seed": cfg.random_seed,
        "dataset_summary": {
            "expression_file": Path(cfg.expr_path).name,
            "phenotype_file": Path(cfg.pheno_path).name,
            "total_usable_samples": n_total_samples,
            "total_initial_genes": n_initial_genes,
            "genes_after_variance_filter": genes_after_variance,
            "selected_features_k": selected_k,
            "cancer_classes_count": n_classes,
            "cancer_classes": class_names,
            "train_samples": len(X_train_raw),
            "val_samples": len(X_val_raw),
            "test_samples": len(X_test_raw),
            "split_ratio": {"train": 0.70, "val": 0.15, "test": 0.15}
        },
        "winning_model": {
            "model_type": selected_model_type,
            "selected_features_k": selected_k,
            "feature_selection_method": cfg.feature_selection_method,
            "variance_threshold": cfg.variance_threshold
        },
        "validation_metrics": {
            "accuracy": best_val_metrics["accuracy"],
            "macro_precision": best_val_metrics["macro_precision"],
            "macro_recall": best_val_metrics["macro_recall"],
            "macro_f1": best_val_metrics["macro_f1"],
            "weighted_f1": best_val_metrics["weighted_f1"],
            "top3_accuracy": best_val_metrics.get("top3_accuracy")
        },
        "test_metrics": {
            "accuracy": test_metrics["accuracy"],
            "macro_precision": test_metrics["macro_precision"],
            "macro_recall": test_metrics["macro_recall"],
            "macro_f1": test_metrics["macro_f1"],
            "weighted_f1": test_metrics["weighted_f1"],
            "top3_accuracy": test_metrics.get("top3_accuracy")
        },
        "safety_and_compliance": {
            "intended_use": "Research prototype for genomic biomarker analysis and Pan-Cancer molecular classification.",
            "disclaimer": "FOR RESEARCH AND EDUCATIONAL USE ONLY. NOT FOR CLINICAL DIAGNOSTIC DECISIONS OR MEDICAL PRESCRIPTIONS."
        }
    }
    
    with open(artifacts_dir / "metadata.json", "w") as f:
        json.dump(metadata, f, indent=2)
        
    total_elapsed = time.time() - start_total_time
    logger.info(f"TRAINING PIPELINE COMPLETED IN {total_elapsed / 60:.2f} MINUTES.")
    logger.info(f"Artifacts successfully stored at: {artifacts_dir.resolve()}")
    
    return {
        "metadata": metadata,
        "validation_leaderboard": validation_leaderboard,
        "test_metrics": test_metrics,
        "artifacts_dir": str(artifacts_dir.resolve())
    }


if __name__ == "__main__":
    run_training_pipeline()
