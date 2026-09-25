# 📊 TCGA Pan-Cancer Dataset Audit & Analysis Report

**Generated Date:** September 17, 2026  
**Project:** Genomic Cancer Intelligence (Phase 2)  
**Dataset Directory:** `data/tcga/`  
**Dataset Files:**
1. `EB++AdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp (2).xena.gz` *(331.0 MB compressed ~ 1.8 GB uncompressed)*
2. `TCGA_phenotype_denseDataOnlyDownload.tsv.gz` *(61.2 KB compressed ~ 450 KB uncompressed)*

---

## 1. Executive Summary

Both TCGA Pan-Cancer datasets placed in `data/tcga/` have been successfully located, verified, decompressed, and analyzed.

- **Sample Coverage:** **11,060 unique patient samples** have complete RNA-Seq gene expression profiles that **100% match** the TCGA clinical phenotype annotations.
- **Gene Coverage:** **20,530 unique human genes** across 20,531 transcriptomic rows.
- **Disease Coverage:** **33 distinct cancer types** spanning solid tumors, liquid malignancies, and matched normal control tissues.
- **Data Completeness:** **98.25%** overall matrix density (only 1.75% missing values, concentrated in 4,196 genes, with **16,335 genes having 0 missing values across all samples**).
- **Scale:** Log2-transformed and batch-effect normalized expression values ranging from **-6.83 to 23.24**.

---

## 2. Dataset Structure & Dimensions

```
                                 TCGA PAN-CANCER DATASET SCHEMATIC

  ┌─────────────────────────────────────────────────────────┐
  │  GENE EXPRESSION MATRIX (.xena.gz)                      │
  │  - Shape: 20,531 Rows (Genes) × 11,070 Columns          │
  │  - Row Identifier: Entrez Gene ID / Hugo Gene Symbol    │
  │  - Column 0: 'sample'                                   │
  │  - Columns 1..11069: TCGA Sample Barcodes               │
  └────────────────────────────┬────────────────────────────┘
                               │
                               │ Sample ID Matching on Barcode
                               │ (e.g., 'TCGA-OR-A5J1-01')
                               ▼
  ┌─────────────────────────────────────────────────────────┐
  │  PHENOTYPE ANNOTATION TABLE (.tsv.gz)                   │
  │  - Shape: 12,804 Rows × 4 Columns                       │
  │  - Primary Key: 'sample' (TCGA Barcode)                 │
  │  - Target Label: '_primary_disease' (Cancer Class)      │
  │  - Tissue Type: 'sample_type' (Primary, Normal, etc.)   │
  └─────────────────────────────────────────────────────────┘
```

### 2.1 Phenotype Dataset (`TCGA_phenotype_denseDataOnlyDownload.tsv.gz`)
- **Total Records:** 12,804 samples
- **Columns (4):**
  1. `sample` *(String)*: Unique TCGA sample barcode (e.g., `TCGA-D3-A1QA-07`, `TCGA-OR-A5J1-01`).
  2. `sample_type_id` *(Float/Categorical)*: Numeric code for tissue type (e.g., `1` for Primary Solid Tumor, `11` for Solid Tissue Normal, `6` for Metastatic).
  3. `sample_type` *(String)*: Human-readable tissue category.
  4. `_primary_disease` *(String)*: The primary cancer diagnosis / disease cohort (33 distinct classes).
- **Missing Values in Phenotype:**
  - `sample`: 0 missing (100% complete)
  - `_primary_disease`: 0 missing (100% complete)
  - `sample_type` & `sample_type_id`: 72 missing (0.56%)

### 2.2 Gene Expression Dataset (`EB++AdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp (2).xena.gz`)
- **Matrix Orientation:** Genes as Rows (20,531 rows), Samples as Columns (11,069 sample columns + 1 header column).
- **Total Data Points:** 227,257,639 numerical values.
- **Value Representation:** Batch-corrected normalized RNA-Seq log2(norm_count + 1) RSEM expression.
- **Value Bounds:** Minimum = `-6.83`, Maximum = `23.24`, Median ~ `0.00`.

---

## 3. Sample ID Mapping & Sample Matching

### 3.1 Mapping Mechanism
Gene expression sample headers correspond directly to the `sample` column in the phenotype table via standard **TCGA 15-character/16-character sample barcodes**:

$$\text{Format: } \underbrace{\text{TCGA}}_{\text{Project}}-\underbrace{\text{XX}}_{\text{TSS Code}}-\underbrace{\text{XXXX}}_{\text{Participant}}-\underbrace{\text{01}}_{\text{Sample Type}}$$

Where the last two digits denote the sample type:
- `01` / `03` = Primary Tumor / Primary Blood Derived Cancer
- `02` = Recurrent Tumor
- `06` / `07` = Metastatic Lesion
- `11` = Solid Tissue Normal Control

### 3.2 Sample Intersection Breakdown
- **Total Unique Samples in Expression Matrix:** **11,060**
- **Total Unique Samples in Phenotype Table:** **12,804**
- **Matched Samples (Intersection):** **11,060** (*100% of all unique expression samples have verified cancer type annotations*)
- **Expression Samples without Phenotype:** **0**
- **Phenotype Samples without Expression:** 1,744 (samples profiled only on microarray/WES/copy-number platforms, not in RNASeqV2).

---

## 4. Cancer Class Distribution (All 33 TCGA Cohorts)

The 11,060 matched samples are distributed across **33 cancer disease categories**:

| # | TCGA Cancer Disease (`_primary_disease`) | Abbr | Sample Count | Percentage |
|---|---|:---:|:---:|:---:|
| 1 | Breast invasive carcinoma | `BRCA` | 1,218 | 11.00% |
| 2 | Kidney clear cell carcinoma | `KIRC` | 606 | 5.47% |
| 3 | Lung adenocarcinoma | `LUAD` | 576 | 5.20% |
| 4 | Thyroid carcinoma | `THCA` | 572 | 5.17% |
| 5 | Uterine corpus endometrioid carcinoma | `UCEC` | 567 | 5.12% |
| 6 | Head & neck squamous cell carcinoma | `HNSC` | 566 | 5.11% |
| 7 | Lung squamous cell carcinoma | `LUSC` | 554 | 5.00% |
| 8 | Prostate adenocarcinoma | `PRAD` | 550 | 4.97% |
| 9 | Brain lower grade glioma | `LGG` | 534 | 4.82% |
| 10 | Colon adenocarcinoma | `COAD` | 495 | 4.47% |
| 11 | Skin cutaneous melanoma | `SKCM` | 474 | 4.28% |
| 12 | Stomach adenocarcinoma | `STAD` | 450 | 4.07% |
| 13 | Bladder urothelial carcinoma | `BLCA` | 427 | 3.86% |
| 14 | Liver hepatocellular carcinoma | `LIHC` | 424 | 3.83% |
| 15 | Kidney papillary cell carcinoma | `KIRP` | 323 | 2.92% |
| 16 | Cervical & endocervical cancer | `CESC` | 310 | 2.80% |
| 17 | Ovarian serous cystadenocarcinoma | `OV` | 309 | 2.79% |
| 18 | Sarcoma | `SARC` | 265 | 2.39% |
| 19 | Esophageal carcinoma | `ESCA` | 196 | 1.77% |
| 20 | Pheochromocytoma & paraganglioma | `PCPG` | 187 | 1.69% |
| 21 | Pancreatic adenocarcinoma | `PAAD` | 183 | 1.65% |
| 22 | Glioblastoma multiforme | `GBM` | 174 | 1.57% |
| 23 | Acute myeloid leukemia | `LAML` | 173 | 1.56% |
| 24 | Rectum adenocarcinoma | `READ` | 171 | 1.54% |
| 25 | Testicular germ cell tumor | `TGCT` | 156 | 1.41% |
| 26 | Thymoma | `THYM` | 122 | 1.10% |
| 27 | Kidney chromophobe | `KICH` | 91 | 0.82% |
| 28 | Mesothelioma | `MESO` | 87 | 0.79% |
| 29 | Uveal melanoma | `UVM` | 80 | 0.72% |
| 30 | Adrenocortical cancer | `ACC` | 79 | 0.71% |
| 31 | Uterine carcinosarcoma | `UCS` | 57 | 0.51% |
| 32 | Diffuse large B-cell lymphoma | `DLBC` | 48 | 0.43% |
| 33 | Cholangiocarcinoma | `CHOL` | 45 | 0.41% |
| **Total** | **All 33 Pan-Cancer Cohorts** | — | **11,060** | **100.00%** |

---

## 5. Sample Type Breakdown

Within the 11,060 matched transcriptomes, the biological tissue sources are:

| Sample Type Category | Code | Sample Count | Percentage |
|---|:---:|:---:|:---:|
| **Primary Solid Tumor** | `01` | **9,704** | 87.74% |
| **Solid Tissue Normal (Controls)** | `11` | **737** | 6.66% |
| **Metastatic Tumor** | `06` | **395** | 3.57% |
| **Primary Blood Derived Cancer** | `03` | **173** | 1.56% |
| **Recurrent Solid Tumor** | `02` | **48** | 0.43% |
| **Additional New Primary** | `10` | **11** | 0.10% |
| **Additional Metastatic** | `07` | **1** | 0.01% |
| **Total Matched Samples** | — | **11,060** | **100.00%** |

---

## 6. Duplicate & Missing Value Analysis

### 6.1 Duplicate Checks
1. **Sample Column Headers:** 
   - 9 sample barcodes appear twice in the expression file header:
     - `TCGA-21-1076-01`, `TCGA-DD-AACA-02`, `TCGA-06-0156-01`, `TCGA-06-0211-01`, `TCGA-DU-6404-02`, `TCGA-DU-6407-02`, `TCGA-FG-5965-02`, `TCGA-TQ-A7RK-02`, `TCGA-23-1023-01`.
   - *Resolution for Training Pipeline:* Deduplicate columns by taking the first occurrence or averaging duplicate replicates during preprocessing.
2. **Gene Row Identifiers:**
   - 1 gene name is duplicated: `SLC35E2` (appears on 2 rows due to paralogous chromosome 1p36.33 loci).
   - *Resolution for Training Pipeline:* Deduplicate or append locus suffix (`SLC35E2_1`, `SLC35E2_2`).

### 6.2 Missing Value (NaN) Checks
- **Total Missing Cells:** 3,973,192 out of 227,257,639 (1.75%).
- **Completely Missing Genes:** **0 genes have 100% missing values**.
- **Complete Genes:** **16,335 genes have exactly 0 missing values across all 11,060 samples**.
- **Partially Missing Genes:** 4,196 genes have minor missing values (easily handled via median/zero imputation or feature selection).

---

## 7. Usable Dataset Dimensions for Machine Learning

| Dimension | Total Raw | High-Confidence Cleaned | Strategy for ML Pipeline |
|---|:---:|:---:|---|
| **Unique Samples** | 11,069 | **11,060** | Deduplicate 9 replicate columns. |
| **Tumor Samples** | 10,323 | **9,704 Primary Tumors** | Clean cohort for multi-class tumor classification. |
| **Normal Control Samples**| 737 | **737** | Baseline healthy tissue discrimination. |
| **Cancer Classes** | 33 | **33 (or Top 10-15 Major Types)** | Multi-class classification (e.g. Lung, Breast, Colon, Prostate, Liver, Kidney, Glioma, Melanoma). |
| **Unique Genes** | 20,531 | **20,530** (or Top 500-2,000 variance / oncogenic drivers) | Variance thresholding + ANOVA / Random Forest feature importance + Oncogenic signature filtering (*TP53, EGFR, KRAS, MYC, ERBB2, BRCA1, PTEN, etc.*). |

---

## 8. Conclusion & Readiness for Next Steps

The datasets provided are official, high-quality TCGA Pan-Cancer Atlas assets with **perfect 100% sample alignment** between transcriptomic profiles and clinical phenotypes. 

The dataset is fully prepared for:
1. Stratified Train / Validation / Test splitting.
2. Feature selection of top cancer biomarker genes.
3. Training the multiclass genomic classifier (e.g. LightGBM / XGBoost / PyTorch MLP).
4. Extracting SHAP feature attributions for Explainable AI (XAI).
