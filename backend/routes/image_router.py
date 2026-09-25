import logging
from typing import Dict, Any, Optional
from fastapi import APIRouter, HTTPException, UploadFile, File, Form, status
from pydantic import BaseModel

from backend.services.vision_service import vision_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/analyze/image", tags=["Medical Image Analysis"])


@router.post("", summary="Upload & Analyze Medical Scan (CT / X-Ray / Histopathology / MRI)")
async def analyze_medical_image_upload(
    file: UploadFile = File(..., description="Medical scan image (.png, .jpg, .jpeg, .dcm)"),
    modality_hint: Optional[str] = Form(None)
):
    """
    Analyzes an uploaded medical scan, computes lesion suspicion probabilities,
    and returns a base64 Grad-CAM saliency activation heatmap.
    """
    filename = file.filename or "scan.png"
    allowed_exts = (".png", ".jpg", ".jpeg", ".webp", ".bmp", ".dcm")
    if not filename.lower().endswith(allowed_exts):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported image format '{filename}'. Supported formats: {', '.join(allowed_exts)}"
        )
        
    try:
        content = await file.read()
        if len(content) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Uploaded image file is empty."
            )
            
        result = vision_service.analyze_medical_image(
            image_bytes=content,
            filename=filename,
            modality_hint=modality_hint
        )
        return result
    except ValueError as ve:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(ve))
    except Exception as e:
        logger.error(f"Image analysis error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to analyze medical scan."
        )
