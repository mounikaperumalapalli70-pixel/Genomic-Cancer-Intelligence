import logging
from typing import Dict, Any, Optional, List
from fastapi import APIRouter, HTTPException, UploadFile, File, Form, status
from pydantic import BaseModel, Field, ConfigDict

from backend.services.genomic_classifier import genomic_service
from backend.services.xai_service import xai_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/analyze/genomic", tags=["Genomic Analysis"])


# Pydantic Request Models
class GenomicAnalysisRequest(BaseModel):
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "patient_id": "TCGA-DEMO-001",
                "expression_data": {
                    "TP53": 11.24,
                    "EGFR": 9.15,
                    "BRCA1": 8.70,
                    "PTEN": 7.42,
                    "MYC": 12.80,
                    "KRAS": 10.33,
                    "BRAF": 6.89,
                    "CDKN2A": 5.12,
                    "PIK3CA": 9.45,
                    "ERBB2": 13.20
                },
                "top_k": 5
            }
        }
    )
    
    patient_id: Optional[str] = Field(None, description="Optional de-identified patient or sample ID")
    expression_data: Dict[str, Any] = Field(..., description="Key-value mapping of Gene Symbol to log2-normalized expression value")
    top_k: int = Field(5, ge=1, le=33, description="Number of top class probabilities to return")


class GenomicAnalysisResponse(BaseModel):
    success: bool = True
    prediction: Dict[str, Any]
    class_probabilities: Dict[str, float]
    top_classes: List[Dict[str, Any]]
    top_contributing_biomarkers: List[Dict[str, Any]]
    input_summary: Dict[str, Any]
    disclaimer: str


# Endpoints
@router.get("/metadata", summary="Get Genomic Model Metadata & Classes")
async def get_metadata():
    """Returns the trained genomic model metadata, classes, version, and primary biomarker features."""
    try:
        meta = genomic_service.get_model_metadata()
        return {
            "success": True,
            "data": meta
        }
    except Exception as e:
        logger.error(f"Error fetching model metadata: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve model metadata."
        )


@router.post("", response_model=GenomicAnalysisResponse, summary="Analyze Genomic Gene Expression (JSON)")
async def analyze_genomic_expression(payload: GenomicAnalysisRequest):
    """
    Submits a gene-expression profile for multiclass TCGA cancer type prediction.
    """
    try:
        result = genomic_service.predict_expression(
            expression_data=payload.expression_data,
            top_k=payload.top_k
        )
        return result
    except ValueError as ve:
        logger.warning(f"Validation error in genomic prediction: {ve}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(ve)
        )
    except RuntimeError as re:
        logger.error(f"Runtime error in genomic analysis: {re}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(re)
        )
    except Exception as e:
        logger.error(f"Unexpected error in genomic analysis: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while processing the genomic expression profile."
        )


@router.post("/upload", response_model=GenomicAnalysisResponse, summary="Analyze Genomic File Upload (CSV/TSV/JSON)")
async def analyze_genomic_file(
    file: UploadFile = File(..., description="Genomic expression file (.csv, .tsv, .txt, or .json)"),
    top_k: int = Form(5)
):
    """
    Uploads a genomic expression matrix file (CSV, TSV, or JSON) for cancer classification.
    """
    filename = file.filename or "uploaded_expression.csv"
    allowed_exts = (".csv", ".tsv", ".txt", ".json")
    if not filename.lower().endswith(allowed_exts):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported file format '{filename}'. Supported formats: {', '.join(allowed_exts)}"
        )
        
    try:
        content = await file.read()
        if len(content) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Uploaded file is empty."
            )
            
        result = genomic_service.predict_expression(
            expression_data=content,
            filename=filename,
            top_k=top_k
        )
        return result
    except ValueError as ve:
        logger.warning(f"File validation error: {ve}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(ve)
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"File analysis error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to parse and analyze the uploaded genomic file."
        )


@router.post("/explain", summary="Explain Biomarker Attributions for Sample")
async def explain_genomic_sample(payload: GenomicAnalysisRequest):
    """
    Returns biomarker z-score deviations and top contributing genes for a sample.
    """
    try:
        explanation = xai_service.explain_sample_prediction(
            expression_dict=payload.expression_data,
            top_n=10
        )
        return {
            "success": True,
            "explanation": explanation
        }
    except ValueError as ve:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(ve))
    except Exception as e:
        logger.error(f"XAI explanation error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate biomarker explanation."
        )
