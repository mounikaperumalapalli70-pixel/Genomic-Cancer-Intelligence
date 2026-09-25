import pytest
from fastapi.testclient import TestClient

from backend.main import app

client = TestClient(app)


def test_root_endpoint():
    """Tests root health and metadata endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "operational"
    assert "disclaimer" in data


def test_health_check_endpoint():
    """Tests /health endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_genomic_metadata_endpoint():
    """Tests /api/v1/analyze/genomic/metadata endpoint."""
    response = client.get("/api/v1/analyze/genomic/metadata")
    assert response.status_code in [200, 500]  # If models not trained yet, 500 or 200
    if response.status_code == 200:
        data = response.json()
        assert data["success"] is True
        assert "cancer_classes" in data["data"]


def test_genomic_invalid_empty_input():
    """Tests that submitting empty expression dictionary returns 400 Bad Request."""
    response = client.post(
        "/api/v1/analyze/genomic",
        json={"expression_data": {}}
    )
    assert response.status_code == 400
    assert "empty" in response.json()["detail"].lower() or "insufficient" in response.json()["detail"].lower()


def test_genomic_invalid_non_numeric_input():
    """Tests submitting non-numeric expression values."""
    response = client.post(
        "/api/v1/analyze/genomic",
        json={"expression_data": {"TP53": "INVALID_VALUE", "EGFR": "STRING"}}
    )
    assert response.status_code == 422 or response.status_code == 400


def test_genomic_unsupported_file_extension():
    """Tests uploading an unsupported file format (.exe, .pdf)."""
    response = client.post(
        "/api/v1/analyze/genomic/upload",
        files={"file": ("test.pdf", b"%PDF-1.4...", "application/pdf")}
    )
    assert response.status_code == 400
    assert "unsupported file format" in response.json()["detail"].lower()
