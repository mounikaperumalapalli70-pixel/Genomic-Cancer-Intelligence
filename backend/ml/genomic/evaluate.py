import logging
import numpy as np
import pandas as pd
from typing import Dict, Any, List, Optional
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    classification_report,
    confusion_matrix,
    top_k_accuracy_score
)

logger = logging.getLogger(__name__)

def evaluate_predictions(
    y_true: np.ndarray,
    y_pred: np.ndarray,
    y_prob: Optional[np.ndarray] = None,
    class_names: Optional[List[str]] = None
) -> Dict[str, Any]:
    """
    Computes comprehensive multiclass classification metrics for genomic cancer type prediction.
    
    Args:
        y_true: Array of true class labels (integer encoded or string names)
        y_pred: Array of predicted class labels
        y_prob: Array of predicted class probability distributions (shape: n_samples x n_classes)
        class_names: List of cancer class names in index order
        
    Returns:
        Dictionary of aggregate and per-class evaluation metrics
    """
    # 1. Global Aggregated Metrics
    acc = float(accuracy_score(y_true, y_pred))
    macro_prec = float(precision_score(y_true, y_pred, average="macro", zero_division=0))
    macro_rec = float(recall_score(y_true, y_pred, average="macro", zero_division=0))
    macro_f1 = float(f1_score(y_true, y_pred, average="macro", zero_division=0))
    
    weighted_prec = float(precision_score(y_true, y_pred, average="weighted", zero_division=0))
    weighted_rec = float(recall_score(y_true, y_pred, average="weighted", zero_division=0))
    weighted_f1 = float(f1_score(y_true, y_pred, average="weighted", zero_division=0))
    
    # 2. Top-k accuracy if probability distribution provided
    top3_acc = None
    if y_prob is not None and y_prob.shape[1] >= 3:
        try:
            top3_acc = float(top_k_accuracy_score(y_true, y_prob, k=3))
        except Exception as e:
            logger.debug(f"Top-3 accuracy computation skipped: {e}")
            top3_acc = None
            
    # 3. Per-class metrics
    labels = list(range(len(class_names))) if class_names is not None else None
    target_names = class_names if class_names is not None else None
    
    clf_report_dict = classification_report(
        y_true,
        y_pred,
        labels=labels,
        target_names=target_names,
        output_dict=True,
        zero_division=0
    )
    
    # Format per-class dictionary
    per_class_metrics = {}
    if target_names:
        for cname in target_names:
            if cname in clf_report_dict:
                per_class_metrics[cname] = {
                    "precision": float(clf_report_dict[cname]["precision"]),
                    "recall": float(clf_report_dict[cname]["recall"]),
                    "f1_score": float(clf_report_dict[cname]["f1-score"]),
                    "support": int(clf_report_dict[cname]["support"])
                }
    
    # 4. Confusion Matrix
    cm = confusion_matrix(y_true, y_pred, labels=labels)
    cm_list = cm.tolist()
    
    results = {
        "accuracy": acc,
        "macro_precision": macro_prec,
        "macro_recall": macro_rec,
        "macro_f1": macro_f1,
        "weighted_precision": weighted_prec,
        "weighted_recall": weighted_rec,
        "weighted_f1": weighted_f1,
        "top3_accuracy": top3_acc,
        "per_class": per_class_metrics,
        "confusion_matrix": cm_list,
        "class_names": class_names if class_names else []
    }
    
    return results


def log_metrics_summary(model_name: str, metrics: Dict[str, Any], prefix: str = "Validation") -> None:
    """Logs a clean table of key metrics to the terminal/logger."""
    logger.info("=" * 70)
    logger.info(f"[{prefix.upper()} METRICS] Model: {model_name}")
    logger.info(f"Accuracy:          {metrics['accuracy']:.4f}")
    logger.info(f"Macro F1-Score:    {metrics['macro_f1']:.4f} (Primary Metric)")
    logger.info(f"Weighted F1-Score: {metrics['weighted_f1']:.4f}")
    logger.info(f"Macro Precision:   {metrics['macro_precision']:.4f}")
    logger.info(f"Macro Recall:      {metrics['macro_recall']:.4f}")
    if metrics.get("top3_accuracy") is not None:
        logger.info(f"Top-3 Accuracy:    {metrics['top3_accuracy']:.4f}")
    logger.info("=" * 70)
