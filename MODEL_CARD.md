# Model Card: TCGA Genomic Cancer-Type Classification Engine

## 1. Model Details
- **Model Name**: TCGA Multiclass Genomic Cancer Classifier
- **Model Version**: `1.0.0-tcga-pancan`
- **Architecture**: Supervised Multiclass Classifier with ANOVA F-score Biomarker Feature Selection and Standardized Preprocessing.
- **Developers**: Genomic Cancer Intelligence ML Team
- **Release Date**: September 2026
- **License**: MIT / Research Open Source

## 2. Intended Use
- **Primary Use Case**: Computational research and bioinformatics discovery to identify pan-cancer transcriptomic expression signatures and prioritize potential biomarker candidates across 33 primary tumor sites.
- **Target Audience**: Computational biologists, cancer genomic researchers, biomedical data scientists, and oncology software developers.
- **Out-of-Scope Use Cases**:
  - Direct clinical diagnosis for individual patients.
  - Making therapeutic decisions, chemotherapy selection, or issuing medical prescriptions.
  - Replacement for histopathological biopsy, immunohistochemistry (IHC), or certified clinical next-generation sequencing panels.

## 3. Dataset & Provenance
- **Dataset**: The Cancer Genome Atlas (TCGA) Pan-Cancer Atlas.
  - **Expression Data**: `EB++AdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.xena.gz` (20,530 unique genes).
  - **Clinical Annotation**: `TCGA_phenotype_denseDataOnlyDownload.tsv.gz` (33 primary disease categories).
- **Matched Cohort Size**: 11,060 unique patient primary and metastatic tissue samples.
- **Class Breakdown**: 33 cancer types ranging from Breast Invasive Carcinoma ($N=1218$) to Cholangiocarcinoma ($N=45$).

## 4. Evaluation Methodology & Leakage Prevention
- **Splitting Strategy**: Stratified 70% Train (7,742 samples), 15% Validation (1,659 samples), and 15% Held-Out Test (1,659 samples).
- **Strict Data Isolation**:
  - Variance filtering, missing-value median imputation, and standard scaling are fitted **exclusively on the training split**.
  - Feature selection is fitted **exclusively on the training split**.
  - Hyperparameter tuning and model selection are conducted on the **validation split**.
  - The held-out test partition is evaluated **exactly once** on the finalized model pipeline.
- **Primary Metric**: **Macro F1-Score** (to ensure robust, unweighted performance across rare and common cancer types alike).
- **Secondary Metrics**: Accuracy, Macro Precision, Macro Recall, Weighted F1-Score, Top-3 Categorical Accuracy.

## 5. Quantitative Performance Summary
*Metrics dynamically updated upon pipeline training completion:*
- **Total Validated Samples**: 11,060
- **Total Cancer Classes**: 33
- **Selected Biomarker Genes**: 500 – 1000 top discriminative genes
- **Evaluation Splits**: 70% Train / 15% Val / 15% Test

## 6. Safety, Ethical Considerations & Clinical Disclaimers
> [!IMPORTANT]
> **RESEARCH PROTOTYPE NOTICE**:
> This model is an artificial intelligence research prototype developed for academic and computational exploration. It does not provide medical advice or definitive diagnoses.
> 
> All model predictions represent statistical probabilities conditioned on TCGA retrospective cohort data. Clinical validation by certified medical professionals, licensed oncologists, and pathologist review is mandatory before any clinical interpretation.

## 7. Caveats & Known Limitations
1. **Batch Effects & Platform Dependence**: The model is trained on Illumina HiSeq RNA-Seq V2 log2(RSEM + 1) normalized counts. Cross-platform microarray or single-cell RNA-seq data may experience distribution shift.
2. **Class Imbalance**: Common cancers (BRCA, KIRC, LUAD) have substantially higher sample representations than rare tumor types (CHOL, UCS, DLBC).
3. **Correlation vs. Causation**: High feature attribution / ANOVA F-scores demonstrate statistical classification utility within the TCGA cohort and do not independently establish mechanistic disease etiology.
