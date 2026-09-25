import io
import csv
import json
import logging
from pathlib import Path
from typing import Dict, Any, Union, Optional, List
import pandas as pd
import numpy as np

from backend.ml.genomic.predict import get_genomic_predictor, GenomicPredictor

logger = logging.getLogger(__name__)


class GenomicClassifierService:
    """
    High-level business logic service for TCGA genomic cancer-type prediction.
    """

    def __init__(self, predictor: Optional[GenomicPredictor] = None):
        self._predictor = predictor

    @property
    def predictor(self) -> GenomicPredictor:
        if self._predictor is None:
            self._predictor = get_genomic_predictor()
        return self._predictor

    def get_model_metadata(self) -> Dict[str, Any]:
        """Returns public model metadata and supported cancer classes."""
        if not self.predictor.is_loaded:
            self.predictor.load_artifacts()
            
        meta = self.predictor.metadata or {}
        return {
            "model_version": meta.get("model_version", "1.0.0-tcga-pancan"),
            "model_name": meta.get("model_name", "TCGA Multiclass Genomic Cancer Classifier"),
            "cancer_classes_count": len(self.predictor.classes),
            "cancer_classes": self.predictor.classes,
            "total_biomarker_features": len(self.predictor.selected_genes),
            "top_biomarker_genes": self.predictor.selected_genes[:25],
            "validation_macro_f1": meta.get("validation_metrics", {}).get("macro_f1"),
            "test_macro_f1": meta.get("test_metrics", {}).get("macro_f1"),
            "disclaimer": "FOR RESEARCH AND EDUCATIONAL USE ONLY. NOT FOR CLINICAL DIAGNOSTIC DECISIONS OR MEDICAL PRESCRIPTIONS."
        }

    def parse_file_content(self, file_content: bytes, filename: str) -> Dict[str, float]:
        """
        Parses uploaded file (CSV, TSV, TXT, or JSON) into a normalized gene expression dictionary.
        
        Features:
        - Normalizes whitespace, quotes, and uppercase gene symbols.
        - Supports 2-column tabular formats (e.g. 'Gene Symbol,log2 Expression', 'Gene,Value').
        - Supports wide matrix tabular formats (sample rows with gene column headers).
        - Supports nested and array-based JSON formats.
        - Robustly aggregates duplicate genes using their mean value.
        - Logs temporary safe metrics (rows parsed, genes parsed, first 3 symbols, numeric values, matching features).
        """
        if not file_content or len(file_content.strip()) == 0:
            raise ValueError("Uploaded file is empty.")
            
        fname_lower = filename.lower()
        
        # 1. JSON Parsing
        if fname_lower.endswith(".json"):
            try:
                try:
                    text = file_content.decode("utf-8-sig").strip()
                except UnicodeDecodeError:
                    text = file_content.decode("latin-1").strip()
                data = json.loads(text)
                
                gene_dict: Dict[str, List[float]] = {}
                
                def add_val(g: Any, v: Any):
                    if g is None or v is None:
                        return
                    g_clean = str(g).strip().strip('"\'').upper()
                    if not g_clean or g_clean.lower() in ("gene", "symbol", "id", "sample", "gene_symbol", "gene symbol"):
                        return
                    try:
                        num_val = float(v)
                        if not np.isnan(num_val) and not np.isinf(num_val):
                            gene_dict.setdefault(g_clean, []).append(num_val)
                    except (ValueError, TypeError):
                        pass

                if isinstance(data, dict):
                    if "genes" in data and isinstance(data["genes"], dict):
                        for k, v in data["genes"].items():
                            add_val(k, v)
                    elif "expression" in data and isinstance(data["expression"], dict):
                        for k, v in data["expression"].items():
                            add_val(k, v)
                    elif "expression_data" in data and isinstance(data["expression_data"], dict):
                        for k, v in data["expression_data"].items():
                            add_val(k, v)
                    else:
                        for k, v in data.items():
                            if isinstance(v, (int, float, str)):
                                add_val(k, v)
                elif isinstance(data, list):
                    for item in data:
                        if isinstance(item, dict):
                            # Case: {"gene": "TP53", "expression": 11.2}
                            g_val = item.get("gene") or item.get("symbol") or item.get("gene_symbol") or item.get("Gene") or item.get("Gene Symbol")
                            e_val = item.get("expression") or item.get("value") or item.get("log2_expression") or item.get("log2 Expression") or item.get("Expression")
                            if g_val is not None and e_val is not None:
                                add_val(g_val, e_val)
                            else:
                                for k, v in item.items():
                                    add_val(k, v)
                else:
                    raise ValueError("JSON must be an object of {gene: expression} or a list of gene items.")
                    
                if not gene_dict:
                    raise ValueError("No valid numeric gene expression values found in JSON file.")
                    
                result_dict = {g: float(np.mean(vals)) for g, vals in gene_dict.items()}
                
                # Temporary safe debug logging
                matching_features = len(set(result_dict.keys()).intersection(set(self.predictor.all_genes)))
                logger.info(
                    f"Genomic JSON parsed: "
                    f"rows_parsed={len(data) if isinstance(data, list) else len(data.keys())}, "
                    f"genes_parsed={len(result_dict)}, "
                    f"first_3_gene_symbols={list(result_dict.keys())[:3]}, "
                    f"numeric_expression_values_count={len(result_dict)}, "
                    f"matching_model_features={matching_features}"
                )
                return result_dict
            except ValueError:
                raise
            except Exception as e:
                raise ValueError(f"Failed to parse JSON file: {str(e)}")
                
        # 2. Tabular (CSV, TSV, TXT) Parsing
        try:
            text = file_content.decode("utf-8-sig").strip()
            if not text:
                raise ValueError("Uploaded file contains no readable text.")
        except UnicodeDecodeError:
            try:
                text = file_content.decode("latin-1").strip()
                if not text:
                    raise ValueError("Uploaded file contains no readable text.")
            except Exception as e:
                raise ValueError(f"Unable to decode text file: {str(e)}")
        except Exception as e:
            raise ValueError(f"Unable to decode text file: {str(e)}")

        lines = [line.strip() for line in text.splitlines() if line.strip()]
        if not lines:
            raise ValueError("Uploaded tabular file contains no data rows.")

        # Detect delimiter: tab, comma, semicolon, or whitespace
        first_line = lines[0]
        if "\t" in first_line:
            sep = "\t"
        elif "," in first_line:
            sep = ","
        elif ";" in first_line:
            sep = ";"
        else:
            sep = r"\s+"

        try:
            df = pd.read_csv(io.StringIO(text), sep=sep, engine="python")
        except Exception as e:
            raise ValueError(f"Malformed tabular expression file: {str(e)}")

        if df.empty and df.shape[1] == 0:
            raise ValueError("Uploaded tabular file contains no columns or data.")

        gene_dict: Dict[str, List[float]] = {}

        def add_entry(gene_raw: Any, val_raw: Any):
            if pd.isna(gene_raw) or pd.isna(val_raw):
                return
            g = str(gene_raw).strip().strip('"\'').upper()
            if not g or g.lower() in ("gene", "gene_symbol", "genesymbol", "symbol", "id", "sample_id", "sample", "gene symbol", "gene_name", "genename"):
                return
            try:
                v = float(val_raw)
                if not np.isnan(v) and not np.isinf(v):
                    gene_dict.setdefault(g, []).append(v)
            except (ValueError, TypeError):
                pass

        # Check for standard 2-column format (e.g. 'Gene Symbol,log2 Expression' or 'EGFR,10.8')
        if df.shape[1] == 2:
            col_gene, col_val = df.columns[0], df.columns[1]
            # Check if header itself is data (headerless CSV)
            try:
                header_val = float(col_val)
                if not np.isnan(header_val) and not np.isinf(header_val):
                    add_entry(col_gene, header_val)
            except (ValueError, TypeError):
                pass

            for _, row in df.iterrows():
                add_entry(row[col_gene], row[col_val])

            if gene_dict:
                result_dict = {g: float(np.mean(vals)) for g, vals in gene_dict.items()}
                matching_features = len(set(result_dict.keys()).intersection(set(self.predictor.all_genes)))
                logger.info(
                    f"Genomic 2-column tabular file parsed: "
                    f"rows_parsed={len(df)}, "
                    f"genes_parsed={len(result_dict)}, "
                    f"first_3_gene_symbols={list(result_dict.keys())[:3]}, "
                    f"numeric_expression_values_count={len(result_dict)}, "
                    f"matching_model_features={matching_features}"
                )
                return result_dict
            else:
                raise ValueError("Missing valid numeric expression column in 2-column tabular file.")

        # Check for named columns (e.g. 'Gene Symbol' and 'log2 Expression' among multiple columns)
        cols_lower = {str(c).strip().lower(): c for c in df.columns}
        gene_col = None
        for cand in ["gene", "gene_symbol", "symbol", "gene symbol", "genename", "gene_name", "hgnc_symbol", "genesymbol"]:
            if cand in cols_lower:
                gene_col = cols_lower[cand]
                break

        val_col = None
        for cand in [
            "expression", "log2 expression", "log2_expression", "log2(expression)", 
            "expression_log2", "value", "rpkm", "tpm", "fpkm", "normalized_count",
            "expression_value", "log2_tpm", "log2_fpkm", "normalized_expression"
        ]:
            if cand in cols_lower:
                val_col = cols_lower[cand]
                break

        if gene_col is not None and val_col is not None:
            for _, row in df.iterrows():
                add_entry(row[gene_col], row[val_col])
            if gene_dict:
                result_dict = {g: float(np.mean(vals)) for g, vals in gene_dict.items()}
                matching_features = len(set(result_dict.keys()).intersection(set(self.predictor.all_genes)))
                logger.info(
                    f"Genomic named-columns tabular file parsed: "
                    f"rows_parsed={len(df)}, "
                    f"genes_parsed={len(result_dict)}, "
                    f"first_3_gene_symbols={list(result_dict.keys())[:3]}, "
                    f"numeric_expression_values_count={len(result_dict)}, "
                    f"matching_model_features={matching_features}"
                )
                return result_dict
            else:
                raise ValueError("Could not extract valid numeric expression entries from identified gene/expression columns.")

        # Scenario: 1 or more sample rows with gene column headers (wide matrix)
        if not df.empty and len(df) > 0:
            first_row = df.iloc[0]
            for col_name, val in first_row.items():
                add_entry(col_name, val)

        if gene_dict:
            result_dict = {g: float(np.mean(vals)) for g, vals in gene_dict.items()}
            matching_features = len(set(result_dict.keys()).intersection(set(self.predictor.all_genes)))
            logger.info(
                f"Genomic wide-matrix tabular file parsed: "
                f"rows_parsed={len(df)}, "
                f"genes_parsed={len(result_dict)}, "
                f"first_3_gene_symbols={list(result_dict.keys())[:3]}, "
                f"numeric_expression_values_count={len(result_dict)}, "
                f"matching_model_features={matching_features}"
            )
            return result_dict

        raise ValueError("Could not find recognized gene symbols or numeric expression values in the uploaded file.")

    def predict_expression(
        self,
        expression_data: Union[Dict[str, float], bytes],
        filename: Optional[str] = None,
        top_k: int = 5
    ) -> Dict[str, Any]:
        """
        Executes prediction on either a dictionary of expression values or raw file bytes.
        """
        if isinstance(expression_data, (bytes, bytearray)):
            if not filename:
                filename = "expression_data.csv"
            parsed_dict = self.parse_file_content(expression_data, filename)
        elif isinstance(expression_data, dict):
            parsed_dict = expression_data
        else:
            raise ValueError(f"Invalid input type: {type(expression_data)}. Expected dict or file bytes.")
            
        # Run prediction
        result = self.predictor.predict(parsed_dict, top_k_classes=top_k)
        return result


# Singleton instance
genomic_service = GenomicClassifierService()
