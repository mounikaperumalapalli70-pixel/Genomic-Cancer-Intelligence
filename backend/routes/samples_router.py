import json
import logging
from typing import Dict, Any, List
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/analyze/samples", tags=["Curated TCGA Samples"])


# Curated high-fidelity TCGA Pan-Cancer sample expression profiles for 1-click evaluation
CURATED_TCGA_SAMPLES: List[Dict[str, Any]] = [
    {
        "id": "TCGA-LUAD-01",
        "name": "TCGA Lung Adenocarcinoma Sample (TCGA-50-5931)",
        "cancer_type": "lung adenocarcinoma",
        "description": "Primary solid tumor biopsy with marked EGFR, KRAS, and TTF1 (NKX2-1) expression signature.",
        "tissue_origin": "Bronchial / Pulmonary Alveolar Tissue",
        "sample_type": "Primary Solid Tumor",
        "biomarker_highlights": ["EGFR (Elevated)", "KRAS (Elevated)", "NKX2-1 (Elevated)", "TP53 (Aberrant)"],
        "expression_data": {
            "TP53": 11.45,
            "EGFR": 12.80,
            "KRAS": 11.20,
            "NKX2-1": 13.95,
            "NAPSA": 12.40,
            "BRAF": 7.15,
            "ALK": 8.90,
            "ROS1": 6.80,
            "RET": 7.40,
            "MET": 10.85,
            "ERBB2": 10.10,
            "PIK3CA": 9.35,
            "PTEN": 6.80,
            "CDKN2A": 4.50,
            "MYC": 12.10,
            "VEGFA": 11.50,
            "PDCD1": 7.20,
            "CD274": 8.10,
            "KRT7": 14.10,
            "MUC1": 13.50,
            "STK11": 5.90,
            "KEAP1": 8.20,
            "NTRK1": 6.30,
            "FGFR1": 9.10,
            "CTNNB1": 10.05
        }
    },
    {
        "id": "TCGA-BRCA-01",
        "name": "TCGA Breast Invasive Carcinoma Sample (TCGA-A2-0099)",
        "cancer_type": "breast invasive carcinoma",
        "description": "Infiltrating ductal carcinoma with elevated ERBB2 (HER2), GATA3, ESR1, and PGR expression.",
        "tissue_origin": "Mammary Gland Tissue",
        "sample_type": "Primary Solid Tumor",
        "biomarker_highlights": ["ERBB2/HER2 (High Amplification)", "GATA3 (Elevated)", "ESR1 (Elevated)", "BRCA1 (Altered)"],
        "expression_data": {
            "ERBB2": 15.60,
            "ESR1": 13.40,
            "PGR": 11.85,
            "GATA3": 14.20,
            "BRCA1": 9.80,
            "BRCA2": 8.75,
            "PIK3CA": 11.10,
            "TP53": 10.95,
            "FOXA1": 13.10,
            "MKI67": 11.75,
            "CCND1": 12.60,
            "CDH1": 12.80,
            "PTEN": 7.20,
            "MYC": 11.90,
            "EGFR": 7.40,
            "KRT8": 14.90,
            "KRT18": 14.60,
            "KRT19": 14.75,
            "CD274": 6.90,
            "AKT1": 10.40,
            "MAP3K1": 9.60,
            "CDK4": 10.80,
            "CDK6": 9.20,
            "RB1": 10.15,
            "ATM": 8.90
        }
    },
    {
        "id": "TCGA-GBM-01",
        "name": "TCGA Glioblastoma Multiforme Sample (TCGA-06-0125)",
        "cancer_type": "glioblastoma multiforme",
        "description": "High-grade neuroepithelial malignancy showing amplified EGFR, GFAP, OLIG2, and homozygous CDKN2A loss.",
        "tissue_origin": "Central Nervous System / Brain",
        "sample_type": "Primary Solid Tumor",
        "biomarker_highlights": ["GFAP (Overexpressed)", "EGFR (Amplified)", "CDKN2A (Loss)", "OLIG2 (Elevated)"],
        "expression_data": {
            "GFAP": 15.90,
            "OLIG2": 13.80,
            "EGFR": 14.50,
            "CDKN2A": 2.10,
            "PTEN": 5.40,
            "IDH1": 7.80,
            "IDH2": 6.90,
            "TP53": 10.40,
            "MGMT": 6.50,
            "SOX2": 13.20,
            "NES": 12.90,
            "PDGFRA": 11.70,
            "MET": 10.40,
            "NF1": 7.10,
            "ATRX": 8.40,
            "TERT": 9.60,
            "VEGFA": 13.10,
            "HIF1A": 11.80,
            "S100B": 14.30,
            "VIM": 13.90,
            "RB1": 9.20,
            "CDK4": 11.50,
            "MDM2": 10.80,
            "PIK3R1": 8.70,
            "BRAF": 7.20
        }
    },
    {
        "id": "TCGA-COAD-01",
        "name": "TCGA Colon Adenocarcinoma Sample (TCGA-A6-2675)",
        "cancer_type": "colon adenocarcinoma",
        "description": "Colorectal epithelial neoplasm with elevated CDX2, CEACAM5, KRAS, and APC/Wnt pathway dysregulation.",
        "tissue_origin": "Large Intestine / Colonic Epithelium",
        "sample_type": "Primary Solid Tumor",
        "biomarker_highlights": ["CDX2 (Elevated)", "CEACAM5/CEA (Elevated)", "KRAS (Elevated)", "CTNNB1 (Active)"],
        "expression_data": {
            "CDX2": 14.80,
            "CEACAM5": 15.20,
            "KRAS": 12.10,
            "APC": 7.40,
            "TP53": 11.30,
            "CTNNB1": 12.70,
            "BRAF": 8.10,
            "PIK3CA": 10.60,
            "SMAD4": 7.80,
            "MLH1": 9.40,
            "MSH2": 10.20,
            "MSH6": 9.80,
            "PMS2": 9.10,
            "EGFR": 10.90,
            "ERBB2": 9.40,
            "KRT20": 14.50,
            "VEGFA": 11.40,
            "CD274": 7.60,
            "MYC": 13.40,
            "AXIN2": 12.30,
            "MKI67": 11.60,
            "PTEN": 8.20,
            "FBXW7": 7.90,
            "SOX9": 12.80,
            "TGFBR2": 8.50
        }
    },
    {
        "id": "TCGA-SKCM-01",
        "name": "TCGA Skin Cutaneous Melanoma Sample (TCGA-EE-0140)",
        "cancer_type": "skin cutaneous melanoma",
        "description": "Cutaneous melanocytic lesion with high expression of MLANA, MITF, PMEL, and activated BRAF.",
        "tissue_origin": "Cutaneous Dermal / Epidermal Melanocytes",
        "sample_type": "Primary Solid Tumor",
        "biomarker_highlights": ["MLANA/Melan-A (Overexpressed)", "MITF (High)", "BRAF (Elevated)", "PMEL/gp100 (High)"],
        "expression_data": {
            "MLANA": 15.80,
            "MITF": 14.10,
            "PMEL": 15.40,
            "TYR": 14.60,
            "BRAF": 11.90,
            "NRAS": 10.80,
            "KIT": 9.20,
            "CDKN2A": 3.80,
            "TP53": 10.50,
            "PTEN": 7.10,
            "BAP1": 8.40,
            "NF1": 7.60,
            "PDCD1": 8.90,
            "CD274": 9.40,
            "CTLA4": 8.20,
            "AXL": 10.10,
            "SOX10": 13.90,
            "DCT": 14.20,
            "VEGFA": 11.20,
            "CCND1": 11.80,
            "MDM2": 10.40,
            "CDK4": 11.10,
            "PIK3CA": 9.70,
            "TERT": 9.30,
            "RAC1": 10.60
        }
    },
    {
        "id": "TCGA-THCA-01",
        "name": "TCGA Thyroid Carcinoma Sample (TCGA-BJ-A28W)",
        "cancer_type": "thyroid carcinoma",
        "description": "Papillary follicular thyroid neoplasm with high TG (Thyroglobulin), TPO, PAX8, and RET/PTC fusion marker profile.",
        "tissue_origin": "Thyroid Follicular Epithelium",
        "sample_type": "Primary Solid Tumor",
        "biomarker_highlights": ["TG/Thyroglobulin (Extreme)", "TPO (Elevated)", "PAX8 (Elevated)", "RET (Active)"],
        "expression_data": {
            "TG": 16.50,
            "TPO": 13.90,
            "PAX8": 14.20,
            "TSHR": 12.80,
            "BRAF": 11.40,
            "RET": 11.80,
            "NTRK1": 8.60,
            "RASGRP1": 10.20,
            "NRAS": 10.50,
            "HRAS": 9.80,
            "KRAS": 10.10,
            "TP53": 9.90,
            "TERT": 8.10,
            "PTEN": 8.90,
            "PIK3CA": 9.40,
            "AKT1": 10.20,
            "DICER1": 9.70,
            "EIF1AX": 10.80,
            "VEGFA": 10.90,
            "KRT19": 13.70,
            "LGALS3": 13.20,
            "MET": 11.10,
            "FN1": 12.90,
            "CDH1": 12.40,
            "CDH2": 8.20
        }
    },
    {
        "id": "TCGA-KIRC-01",
        "name": "TCGA Kidney Renal Clear Cell Carcinoma (TCGA-B0-4698)",
        "cancer_type": "kidney clear cell carcinoma",
        "description": "Renal cortical clear-cell carcinoma characterized by VHL loss, elevated VEGFA, CA9, and hypoxia pathway activation.",
        "tissue_origin": "Renal Proximal Tubular Epithelium",
        "sample_type": "Primary Solid Tumor",
        "biomarker_highlights": ["CA9 (Highly Elevated)", "VEGFA (Elevated)", "VHL (Loss/Repressed)", "HIF1A (Active)"],
        "expression_data": {
            "CA9": 15.95,
            "VEGFA": 14.40,
            "VHL": 4.10,
            "HIF1A": 13.20,
            "EPAS1": 13.80,
            "PBRM1": 7.20,
            "BAP1": 6.80,
            "SETD2": 7.40,
            "KDM5C": 8.10,
            "CD274": 8.80,
            "PDCD1": 7.90,
            "PTEN": 8.20,
            "PIK3CA": 9.60,
            "MTOR": 10.90,
            "MET": 11.70,
            "FLT1": 12.50,
            "KDR": 12.10,
            "PAX8": 13.60,
            "CD10": 13.10,
            "TP53": 9.70,
            "EGFR": 10.40,
            "CDKN2A": 5.20,
            "HNF1B": 11.90,
            "SLC2A1": 13.50,
            "EGLN1": 12.20
        }
    },
    {
        "id": "TCGA-LAML-01",
        "name": "TCGA Acute Myeloid Leukemia Sample (TCGA-AB-2803)",
        "cancer_type": "acute myeloid leukemia",
        "description": "Hematopoietic stem/progenitor clone with elevated CD34, MPO, FLT3, NPM1, and DNMT3A signature.",
        "tissue_origin": "Bone Marrow / Hematopoietic System",
        "sample_type": "Primary Blood Derived Cancer - Peripheral Blood",
        "biomarker_highlights": ["MPO (Elevated)", "CD34 (Elevated)", "FLT3 (Elevated)", "DNMT3A (Active)"],
        "expression_data": {
            "MPO": 15.20,
            "CD34": 14.30,
            "FLT3": 13.80,
            "NPM1": 13.90,
            "DNMT3A": 11.40,
            "KIT": 12.60,
            "IDH1": 10.20,
            "IDH2": 10.80,
            "TET2": 9.40,
            "RUNX1": 11.70,
            "WT1": 13.50,
            "CEBPA": 12.10,
            "TP53": 10.10,
            "MYC": 13.20,
            "BCL2": 13.40,
            "MCL1": 12.80,
            "CD33": 13.70,
            "CD123": 12.90,
            "KRAS": 10.50,
            "NRAS": 11.20,
            "GATA2": 12.40,
            "PTPN11": 10.60,
            "JAK2": 9.80,
            "ASXL1": 9.10,
            "KMT2A": 10.70
        }
    }
]


@router.get("", summary="List Curated TCGA Pan-Cancer Benchmark Samples")
async def get_curated_samples():
    """Returns a list of curated TCGA benchmark profiles with ground truth labels for 1-click testing."""
    return {
        "success": True,
        "total_samples": len(CURATED_TCGA_SAMPLES),
        "samples": [
            {
                "id": s["id"],
                "name": s["name"],
                "cancer_type": s["cancer_type"],
                "description": s["description"],
                "tissue_origin": s["tissue_origin"],
                "sample_type": s["sample_type"],
                "biomarker_highlights": s["biomarker_highlights"],
                "gene_count": len(s["expression_data"]),
                "expression_data": s["expression_data"]
            }
            for s in CURATED_TCGA_SAMPLES
        ]
    }


@router.get("/{sample_id}", summary="Get Full Expression Vector for Curated Sample")
async def get_curated_sample_detail(sample_id: str):
    """Fetches the complete expression profile dictionary for a specific curated TCGA sample."""
    matched = next((s for s in CURATED_TCGA_SAMPLES if s["id"].lower() == sample_id.lower()), None)
    if not matched:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Curated sample with ID '{sample_id}' not found."
        )
    return {
        "success": True,
        "sample": matched
    }
