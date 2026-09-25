# TCGA Genomic Cancer-Type Classification Pipeline

## 1. Overview
The Genomic Machine Learning Pipeline provides high-dimensional transcriptomic (RNA-Seq) cancer-type classification across 33 distinct Pan-Cancer primary disease sites from the TCGA (The Cancer Genome Atlas) cohort.

## 2. Dataset Description
- **Gene Expression Matrix**: `EB++AdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.xena.gz`
  - Dimensions: 20,530 unique genes × 11,060 matched patient samples.
  - Normalization: Batch-corrected, log2(RSEM + 1) transformed RNA-Seq V2 values.
- **Clinical Phenotype Annotations**: `TCGA_phenotype_denseDataOnlyDownload.tsv.gz`
  - Target Label: `_primary_disease` across 33 cancer types.
- **Sample Matching & Deduplication**:
  - 11,060 samples possess 100% matched expression and phenotype records.
  - 9 duplicate sample headers and 1 duplicate gene row (`SLC35E2`) are resolved systematically by keeping the first complete record.

## 3. Data Preprocessing & Leakage Prevention
To prevent data leakage, all preprocessing and feature transformation parameters are strictly fitted **ONLY** on the training partition after stratified splitting.

1. **Stratified Partitioning**:
   - Training Set: **70%** (7,742 samples)
   - Validation Set: **15%** (1,659 samples)
   - Held-Out Test Set: **15%** (1,659 samples)
2. **Missing Value Imputation**:
   - Gene medians computed strictly on the training partition.
3. **Variance Threshold Filtering**:
   - Removal of non-informative, zero/near-zero variance genes (`threshold = 0.05`).
4. **Standardization**:
   - `StandardScaler` fitted strictly on training partition to produce zero-mean, unit-variance biomarker distributions.

## 4. Feature Selection Methodology
- Supervised ranking using **ANOVA F-statistic (`f_classif`)** calculated exclusively on the training partition.
- Feature counts systematically evaluated: **Top 100, Top 250, Top 500, Top 1000, and Top 2000 genes**.
- Model selection is guided by **Validation Macro F1-Score** to ensure balanced performance across both common (e.g., Breast Invasive Carcinoma, $N=1218$) and rare cancer classes (e.g., Cholangiocarcinoma, $N=45$).

## 5. Model Architecture Comparison
The pipeline evaluates 6 multiclass algorithms:
1. **Multinomial Logistic Regression** (`L-BFGS`, `C=1.0`)
2. **Linear Support Vector Classifier** (Calibrated with `CalibratedClassifierCV` for reliable class probabilities)
3. **Random Forest Classifier** (`n_estimators=200`, `max_depth=25`)
4. **XGBoost Classifier** (`n_estimators=150`, `learning_rate=0.1`, `max_depth=6`)
5. **LightGBM Classifier** (`n_estimators=150`, `num_leaves=31`, `learning_rate=0.1`)
6. **Multilayer Perceptron (MLP)** (`hidden_layers=(256, 128)`, early stopping)

## 6. Serialized Model Artifacts (`backend/models/genomic/`)
- `model.joblib`: Trained winning classifier.
- `preprocessor.joblib`: Fitted imputation, variance filter, and scaler.
- `feature_selector.joblib`: Fitted ANOVA F-score biomarker selector.
- `label_encoder.joblib`: Target cancer-type label encoder.
- `selected_genes.json`: Ordered list of discriminative biomarker genes.
- `classes.json`: 33 cancer type class mapping.
- `metadata.json`: Full model provenance, timestamps, hyperparameters, validation, and test metrics.
- `validation_leaderboard.json`: Comparison metrics across all model and feature count permutations.
- `test_metrics.json`: Unbiased evaluation metrics on held-out test partition.

## 7. Prediction Input & Output Formats

### Input (JSON Payload or CSV/TSV File)
```json
{
  "patient_id": "TCGA-DEMO-001",
  "expression_data": {
    "TP53": 11.24,
    "EGFR": 9.15,
    "BRCA1": 8.70,
    "PTEN": 7.42,
    "MYC": 12.80
  },
  "top_k": 5
}
```

### Output Response
```json
{
  "success": true,
  "prediction": {
    "cancer_type": "breast invasive carcinoma",
    "probability": 0.9421,
    "model_version": "1.0.0-tcga-pancan",
    "model_name": "TCGA Multiclass Genomic Cancer Classifier"
  },
  "class_probabilities": {
    "breast invasive carcinoma": 0.9421,
    "ovarian serous cystadenocarcinoma": 0.0312,
    "uterine corpus endometrial carcinoma": 0.0145
  },
  "top_classes": [
    {"cancer_type": "breast invasive carcinoma", "probability": 0.9421}
  ],
  "top_contributing_biomarkers": [
    {
      "gene": "ESR1",
      "expression_value": 13.4,
      "reference_median": 8.1,
      "z_score_deviation": 2.45,
      "status": "upregulated"
    }
  ],
  "disclaimer": "FOR RESEARCH AND EDUCATIONAL USE ONLY. NOT FOR CLINICAL DIAGNOSTIC DECISIONS OR MEDICAL PRESCRIPTIONS."
}
```

## 8. Limitations & Clinical Safety
- **Research Prototype**: This software is designed exclusively for research, benchmarking, and educational explorations.
- **No Definitive Diagnosis**: Predictions reflect statistical similarity to TCGA reference cohort profiles and must never be used as a standalone diagnostic tool or to prescribe medications.
