import os
import sys
import logging
from pathlib import Path
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Ensure project root is in sys.path for direct module execution
project_root = str(Path(__file__).resolve().parent.parent)
if project_root not in sys.path:
    sys.path.insert(0, project_root)

from backend.routes.analysis_router import router as analysis_router
from backend.routes.samples_router import router as samples_router
from backend.routes.treatment_router import router as treatment_router
from backend.routes.quantum_router import router as quantum_router
from backend.routes.image_router import router as image_router

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
)
logger = logging.getLogger("GenomicCancerIntelligenceBackend")

app = FastAPI(
    title="Genomic Cancer Intelligence API",
    description="Precision Oncology Multimodal AI Platform — TCGA Pan-Cancer Classification, Biomarker XAI, Treatment Intelligence, and Quantum Machine Learning.",
    version="1.0.0"
)

# Configure CORS for Flutter Web / Vercel frontend and local development
raw_origins = os.environ.get("ALLOWED_ORIGINS", "*")
if raw_origins and raw_origins != "*":
    allowed_origins = [origin.strip() for origin in raw_origins.split(",") if origin.strip()]
else:
    allowed_origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_origin_regex=r"https://.*\.vercel\.app|https://.*\.onrender\.com|http://localhost(:\d+)?|http://127\.0\.0\.1(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# Register Routers
app.include_router(analysis_router)
app.include_router(samples_router)
app.include_router(treatment_router)
app.include_router(quantum_router)
app.include_router(image_router)


@app.get("/", tags=["Health"])
async def root():
    return {
        "service": "Genomic Cancer Intelligence API",
        "status": "operational",
        "version": "1.0.0",
        "active_modules": [
            "tcga_genomic_classification",
            "biomarker_xai",
            "curated_tcga_samples",
            "treatment_and_medicine_intelligence",
            "quantum_machine_learning_qiskit",
            "medical_image_diagnostics"
        ],
        "disclaimer": "FOR RESEARCH AND EDUCATIONAL USE ONLY. NOT FOR CLINICAL DIAGNOSTIC DECISIONS."
    }


@app.get("/health", tags=["Health"])
async def health_check():
    return {
        "status": "healthy",
        "service": "genomic-cancer-intelligence"
    }


if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("backend.main:app", host="0.0.0.0", port=port, reload=False)
