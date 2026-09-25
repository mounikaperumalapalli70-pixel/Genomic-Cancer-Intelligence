import logging
from typing import Dict, Any, Optional
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field, ConfigDict

from backend.services.quantum_service import quantum_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/quantum", tags=["Quantum Machine Learning (Qiskit)"])


class QuantumExperimentRequest(BaseModel):
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "expression_data": {
                    "TP53": 11.45,
                    "EGFR": 12.80,
                    "KRAS": 11.20,
                    "BRCA1": 7.10
                },
                "cancer_type_hypothesis": "lung adenocarcinoma",
                "n_qubits": 4,
                "entanglement": "linear"
            }
        }
    )

    expression_data: Dict[str, float] = Field(default_factory=dict, description="Key-value mapping of gene symbol to expression value")
    cancer_type_hypothesis: Optional[str] = Field("lung adenocarcinoma", description="Hypothesized cancer class for quantum state overlap testing")
    n_qubits: Optional[int] = Field(4, ge=2, le=8, description="Number of qubits in quantum circuit register (2-8)")
    entanglement: Optional[str] = Field("linear", description="Entanglement topology ('linear', 'circular', 'full')")


@router.post("/experiment", summary="Run Qiskit Quantum Kernel Genomic Classification Experiment")
async def run_quantum_experiment(payload: QuantumExperimentRequest):
    """
    Executes a Qiskit quantum kernel state fidelity experiment on reduced genomic expression features.
    """
    try:
        result = quantum_service.run_quantum_experiment(
            expression_vector=payload.expression_data,
            cancer_type_hypothesis=payload.cancer_type_hypothesis or "lung adenocarcinoma",
            n_qubits=payload.n_qubits or 4,
            entanglement=payload.entanglement or "linear"
        )
        return result
    except Exception as e:
        logger.error(f"Quantum experiment execution error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to execute quantum machine learning experiment."
        )
