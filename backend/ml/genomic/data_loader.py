import gzip
import logging
from pathlib import Path
from typing import Tuple, List, Dict, Optional
import numpy as np
import pandas as pd

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)


def load_tcga_phenotype(pheno_path: str) -> pd.DataFrame:
    """
    Loads and parses the TCGA clinical phenotype dataset.
    
    Returns:
        DataFrame with columns: ['sample', 'sample_type_id', 'sample_type', '_primary_disease']
    """
    logger.info(f"Loading phenotype data from: {pheno_path}")
    with gzip.open(pheno_path, "rt") as f:
        df_pheno = pd.read_csv(f, sep="\t")
    
    # Clean whitespace
    df_pheno["sample"] = df_pheno["sample"].astype(str).str.strip()
    df_pheno["_primary_disease"] = df_pheno["_primary_disease"].astype(str).str.strip()
    
    # Drop any records with missing critical identifiers
    df_pheno = df_pheno.dropna(subset=["sample", "_primary_disease"])
    df_pheno = df_pheno.drop_duplicates(subset=["sample"], keep="first")
    
    logger.info(f"Loaded {len(df_pheno)} phenotype sample records across {df_pheno['_primary_disease'].nunique()} cancer types.")
    return df_pheno


def load_tcga_expression(
    expr_path: str,
    max_samples: Optional[int] = None
) -> Tuple[pd.DataFrame, List[str]]:
    """
    Loads and parses the high-dimensional TCGA RNA-Seq expression matrix.
    
    The raw matrix is oriented as (genes x samples): 20,531 rows x 11,069 columns.
    This function transposes it so the output DataFrame is (samples x genes): 11,060 x 20,530.
    
    Handles:
        1. Duplicate sample column headers (deduplicated by keeping first occurrence -> 11,060 unique).
        2. Duplicate gene names (e.g., 'SLC35E2' deduplicated by keeping first occurrence -> 20,530 unique).
    
    Returns:
        df_expr: DataFrame of shape (n_samples, n_genes) in float32
        gene_names: List of unique gene identifiers
    """
    logger.info(f"Reading expression matrix from: {expr_path}...")
    
    # Read matrix with pandas
    df_raw = pd.read_csv(
        expr_path,
        sep="\t",
        compression="gzip",
        index_col=0
    )
    
    logger.info(f"Raw expression matrix read: {df_raw.shape[0]} rows (genes) x {df_raw.shape[1]} columns (samples).")
    
    # 1. Deduplicate duplicate gene rows (e.g., SLC35E2 on chr1p36.33 loci)
    df_raw.index = df_raw.index.astype(str).str.strip()
    df_dedup_genes = df_raw[~df_raw.index.duplicated(keep="first")]
    
    # 2. Deduplicate duplicate sample columns (9 replicate headers)
    df_dedup_genes.columns = df_dedup_genes.columns.astype(str).str.strip()
    df_dedup = df_dedup_genes.loc[:, ~df_dedup_genes.columns.duplicated(keep="first")]
    
    if max_samples is not None and max_samples < df_dedup.shape[1]:
        df_dedup = df_dedup.iloc[:, :max_samples]
        
    logger.info(f"Deduplicated matrix: {df_dedup.shape[0]} unique genes x {df_dedup.shape[1]} unique samples.")
    
    # Transpose to (samples x genes) and cast to float32
    logger.info("Transposing expression matrix to (samples x genes)...")
    df_expr = df_dedup.T.astype(np.float32)
    gene_names = list(df_expr.columns)
    
    logger.info(f"Expression matrix successfully structured: {df_expr.shape[0]} samples x {df_expr.shape[1]} genes (float32).")
    return df_expr, gene_names


def load_and_match_tcga_dataset(
    expr_path: str,
    pheno_path: str,
    max_samples: Optional[int] = None
) -> Tuple[pd.DataFrame, pd.Series, pd.DataFrame]:
    """
    Loads both datasets and performs exact matching on sample barcodes.
    
    Returns:
        X: Feature matrix (DataFrame of shape n_samples x n_genes)
        y: Target label vector (Series of cancer type names)
        metadata: Clinical and sample metadata DataFrame
    """
    df_pheno = load_tcga_phenotype(pheno_path)
    df_expr, gene_names = load_tcga_expression(expr_path, max_samples=max_samples)
    
    logger.info("Matching expression samples with phenotype annotations...")
    
    # Index phenotype by sample barcode
    df_pheno = df_pheno.set_index("sample")
    
    # Find common samples
    common_samples = df_expr.index.intersection(df_pheno.index)
    logger.info(f"Matched {len(common_samples)} samples across expression and phenotype datasets.")
    
    # Align datasets
    X = df_expr.loc[common_samples]
    metadata = df_pheno.loc[common_samples]
    y = metadata["_primary_disease"]
    
    # Verify class distribution
    class_counts = y.value_counts()
    logger.info(f"Dataset matched successfully: {len(X)} samples, {len(X.columns)} genes, {len(class_counts)} cancer classes.")
    
    return X, y, metadata
