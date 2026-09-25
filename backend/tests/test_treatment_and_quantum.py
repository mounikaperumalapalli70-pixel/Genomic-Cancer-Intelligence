import io
from fastapi.testclient import TestClient
from PIL import Image

from backend.main import app

client = TestClient(app)


def test_root_and_health():
    res = client.get("/")
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "operational"
    assert "active_modules" in data

    res2 = client.get("/health")
    assert res2.status_code == 200
    assert res2.json()["status"] == "healthy"


def test_curated_samples_endpoint():
    res = client.get("/api/v1/analyze/samples")
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert len(data["samples"]) >= 5
    sample_ids = [s["id"] for s in data["samples"]]
    assert "TCGA-LUAD-01" in sample_ids
    assert "TCGA-BRCA-01" in sample_ids

    # Detail endpoint
    res_detail = client.get("/api/v1/analyze/samples/TCGA-LUAD-01")
    assert res_detail.status_code == 200
    detail = res_detail.json()
    assert detail["success"] is True
    assert "expression_data" in detail["sample"]
    assert "TP53" in detail["sample"]["expression_data"]


def test_treatment_intelligence_endpoint():
    payload = {
        "cancer_type": "lung adenocarcinoma",
        "biomarkers": [
            {"gene": "EGFR", "status": "upregulated", "z_score_deviation": 2.45},
            {"gene": "KRAS", "status": "upregulated", "z_score_deviation": 1.80}
        ]
    }
    res = client.post("/api/v1/treatment/intelligence", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert len(data["targeted_therapies"]) >= 2
    assert "cancer_site" in data
    assert "subtype" in data
    assert "genomic_data_limitation_notice" in data
    
    # Check Osimertinib entry
    osimertinib = next((t for t in data["targeted_therapies"] if "Osimertinib" in t["drug_name"]), None)
    assert osimertinib is not None
    assert osimertinib["target_gene"] == "EGFR"
    assert "treatment_class" in osimertinib
    assert "molecular_target" in osimertinib
    assert "target_biological_function" in osimertinib
    assert "how_it_works" in osimertinib
    assert "why_relevant" in osimertinib
    assert "evidence_source" in osimertinib
    assert "required_genomic_alteration" in osimertinib
    assert osimertinib["sample_match"] is True
    assert "Expression" in osimertinib["biomarker_status"]
    assert "SUPPORTED / INFERRED" in osimertinib["alteration_classification"]

    # Check unmatched therapy (e.g., ALK / Alectinib where ALK was not in biomarkers list)
    alectinib = next((t for t in data["targeted_therapies"] if "Alectinib" in t["drug_name"]), None)
    assert alectinib is not None
    assert alectinib["sample_match"] is False
    assert "Not established" in alectinib["biomarker_status"]
    assert "NOT ESTABLISHED" in alectinib["alteration_classification"]
    assert "Insufficient genomic alteration data" in alectinib["eligibility_status"]

    assert "nutrition_and_metabolic_guidance" in data


def test_quantum_experiment_endpoint():
    payload = {
        "expression_data": {
            "TP53": 11.45,
            "EGFR": 12.80,
            "KRAS": 11.20,
            "NKX2-1": 13.95
        },
        "cancer_type_hypothesis": "lung adenocarcinoma",
        "n_qubits": 4,
        "entanglement": "linear"
    }
    res = client.post("/api/v1/quantum/experiment", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert "circuit_specifications" in data
    assert data["circuit_specifications"]["qubit_count"] == 4
    assert "quantum_kernel_fidelity" in data
    assert "qasm_representation" in data


def test_medical_image_endpoint():
    # Create test in-memory image
    img = Image.new("RGB", (128, 128), color=(70, 70, 70))
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    buf.seek(0)

    files = {"file": ("chest_ct_scan.png", buf.getvalue(), "image/png")}
    res = client.post("/api/v1/analyze/image", files=files)
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert "classification" in data
    assert "gradcam_saliency_heatmap" in data
    assert data["gradcam_saliency_heatmap"]["data_uri"].startswith("data:image/jpeg;base64,")


def test_real_histopathology_image_classification():
    from pathlib import Path
    img_path = Path("Cancer img for testing.jpg")
    if img_path.exists():
        with open(img_path, "rb") as f:
            img_bytes = f.read()
        files = {"file": ("Cancer img for testing.jpg", img_bytes, "image/jpeg")}
        res = client.post("/api/v1/analyze/image", files=files)
        assert res.status_code == 200
        data = res.json()
        assert data["success"] is True
        assert data["can_determine_reliably"] is True
        assert data["scan_modality"] == "H&E Histopathology Biopsy"
        assert data["detected_cancer_type"] in ["colon adenocarcinoma", "lung adenocarcinoma"]
        assert data["classification"]["confidence_score"] >= 0.85
        assert data["treatment_intelligence"] is not None
        assert "targeted_therapies" in data["treatment_intelligence"]


def test_unsupported_non_medical_image():
    # Create invalid blank / non-medical image
    img = Image.new("RGB", (64, 64), color=(0, 0, 0))
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    buf.seek(0)

    files = {"file": ("unsupported_document.png", buf.getvalue(), "image/png")}
    res = client.post("/api/v1/analyze/image", files=files)
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert data["can_determine_reliably"] is False
    assert data["detected_cancer_type"] is None
    assert "Unable to determine reliably from this image" in data["classification"]["primary_finding"]
    assert data["treatment_intelligence"] is None

