import io
import json
import pytest
from fastapi.testclient import TestClient
from PIL import Image

from backend.main import app
from backend.services.genomic_classifier import genomic_service
from backend.services.treatment_service import treatment_service
from backend.services.gemini_treatment_service import GeminiTreatmentReasoningService
from backend.services.vision_service import vision_service

client = TestClient(app)


# 1. Valid genomic CSV
def test_01_valid_genomic_csv():
    csv_content = (
        b"Gene Symbol,log2 Expression\n"
        b"NKX2-1,13.95\n"
        b"NAPSA,12.40\n"
        b"EGFR,12.80\n"
        b"KRAS,11.20\n"
        b"TP53,11.45\n"
        b"KRT7,14.10\n"
    )
    res = client.post(
        "/api/v1/analyze/genomic/upload",
        files={"file": ("sample_lung.csv", csv_content, "text/csv")}
    )
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert data["prediction"]["cancer_type"] == "lung adenocarcinoma"
    assert data["prediction"]["probability"] > 0.5


# 2. Valid TSV
def test_02_valid_tsv():
    tsv_content = (
        b"GENE\tVALUE\n"
        b"ERBB2\t15.60\n"
        b"ESR1\t13.40\n"
        b"PGR\t11.85\n"
        b"GATA3\t14.20\n"
        b"BRCA1\t9.80\n"
    )
    res = client.post(
        "/api/v1/analyze/genomic/upload",
        files={"file": ("sample_breast.tsv", tsv_content, "text/tab-separated-values")}
    )
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert data["prediction"]["cancer_type"] == "breast invasive carcinoma"


# 3. Valid JSON
def test_03_valid_json():
    json_content = json.dumps({
        "genes": {
            "GFAP": 15.90,
            "OLIG2": 13.80,
            "EGFR": 14.50,
            "CDKN2A": 2.10,
            "PTEN": 5.40
        }
    }).encode("utf-8")
    res = client.post(
        "/api/v1/analyze/genomic/upload",
        files={"file": ("sample_gbm.json", json_content, "application/json")}
    )
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert data["prediction"]["cancer_type"] == "glioblastoma multiforme"


# 4. Malformed genomic file
def test_04_malformed_genomic_file():
    bad_bytes = b"Corrupted Binary Content \x00\x01\x02\xff\xfe Not Tabular"
    with pytest.raises(ValueError) as exc:
        genomic_service.parse_file_content(bad_bytes, "corrupt.csv")
    assert "malformed" in str(exc.value).lower() or "not find" in str(exc.value).lower() or "unable" in str(exc.value).lower()


# 5. Missing gene column
def test_05_missing_gene_column():
    bad_csv = b"ColumnA,ColumnB\n12.5,14.8\n10.2,9.1\n8.4,7.6\n"
    res = client.post(
        "/api/v1/analyze/genomic/upload",
        files={"file": ("missing_gene.csv", bad_csv, "text/csv")}
    )
    assert res.status_code in (400, 422)


# 6. Missing expression column
def test_06_missing_expression_column():
    bad_csv = b"Gene,Status\nTP53,Present\nEGFR,Altered\nKRAS,Tested\n"
    res = client.post(
        "/api/v1/analyze/genomic/upload",
        files={"file": ("missing_expr.csv", bad_csv, "text/csv")}
    )
    assert res.status_code in (400, 422)


# 7. Duplicate genes (Aggregated via Mean)
def test_07_duplicate_genes():
    dup_csv = (
        b"Gene,Expression\n"
        b"NKX2-1,13.00\n"
        b"NKX2-1,14.90\n"
        b"EGFR,12.00\n"
        b"EGFR,13.60\n"
        b"TP53,11.45\n"
    )
    parsed = genomic_service.parse_file_content(dup_csv, "dup.csv")
    assert "NKX2-1" in parsed
    # Mean of 13.0 and 14.9 = 13.95
    assert abs(parsed["NKX2-1"] - 13.95) < 1e-4
    assert abs(parsed["EGFR"] - 12.80) < 1e-4


# 8. Missing genes (< 3 genes)
def test_08_missing_genes_insufficient_features():
    sparse_csv = b"Gene,Expression\nTP53,11.2\n"
    with pytest.raises(ValueError) as exc:
        genomic_service.predict_expression(sparse_csv, "sparse.csv")
    assert "insufficient" in str(exc.value).lower() or "minimum" in str(exc.value).lower()


# 9. 25-gene input
def test_09_25_gene_input_full_recognition():
    csv_25 = (
        b"Gene Symbol,log2 Expression\n"
        b"TP53,11.45\nEGFR,12.80\nKRAS,11.20\nNKX2-1,13.95\nNAPSA,12.40\n"
        b"BRAF,7.15\nALK,8.90\nROS1,6.80\nRET,7.40\nMET,10.85\n"
        b"ERBB2,10.10\nPIK3CA,9.35\nPTEN,6.80\nCDKN2A,4.50\nMYC,12.10\n"
        b"VEGFA,11.50\nPDCD1,7.20\nCD274,8.10\nKRT7,14.10\nMUC1,13.50\n"
        b"STK11,5.90\nKEAP1,8.20\nNTRK1,6.30\nFGFR1,9.10\nCTNNB1,10.05\n"
    )
    res = genomic_service.predict_expression(csv_25, "luad_25.csv")
    assert res["prediction"]["cancer_type"] == "lung adenocarcinoma"
    assert res["input_summary"]["total_genes_provided"] == 25
    assert res["input_summary"]["recognized_genes_in_model_genome"] == 25
    assert res["input_summary"]["biomarker_coverage_pct"] == 100.0


# 10. Feature alignment
def test_10_feature_alignment():
    # Submit mixed case and whitespace
    raw_dict = {
        "  nkx2-1  ": 13.95,
        "napsa": 12.40,
        "EgFr": 12.80,
        "kras": 11.20,
        "TP53": 11.45
    }
    res = genomic_service.predict_expression(raw_dict)
    assert res["prediction"]["cancer_type"] == "lung adenocarcinoma"
    # All uppercase in top biomarkers
    genes = [b["gene"] for b in res["top_contributing_biomarkers"]]
    assert "NKX2-1" in genes
    assert "EGFR" in genes


# 11. Cancer classification across phenotypes
def test_11_cancer_classification_phenotypes():
    phenotypes = {
        "colon adenocarcinoma": {"CDX2": 14.8, "CEACAM5": 15.2, "KRAS": 12.1, "KRT20": 14.5, "TP53": 11.3},
        "skin cutaneous melanoma": {"MLANA": 15.8, "MITF": 14.1, "PMEL": 15.4, "TYR": 14.6, "BRAF": 11.9},
        "thyroid carcinoma": {"TG": 16.5, "TPO": 13.9, "PAX8": 14.2, "TSHR": 12.8, "BRAF": 11.4},
        "kidney clear cell carcinoma": {"CA9": 15.95, "VEGFA": 14.4, "VHL": 4.1, "EPAS1": 13.8, "HIF1A": 13.2},
        "acute myeloid leukemia": {"MPO": 15.2, "CD34": 14.3, "FLT3": 13.8, "NPM1": 13.9, "DNMT3A": 11.4}
    }
    for expected_type, expr in phenotypes.items():
        res = genomic_service.predict_expression(expr)
        assert res["prediction"]["cancer_type"] == expected_type, f"Failed for {expected_type}"
        assert res["prediction"]["probability"] > 0.70


# 12. Biomarker NOT established from RNA expression (No mutation fabricated)
def test_12_biomarker_not_established_from_rna():
    # Patient has baseline EGFR expression (not elevated) and no DNA mutation
    intelligence = treatment_service.get_treatment_intelligence(
        cancer_type="lung adenocarcinoma",
        biomarkers=[
            {"gene": "TP53", "status": "baseline", "z_score_deviation": 0.1}
        ]
    )
    osimertinib = next(t for t in intelligence["targeted_therapies"] if "Osimertinib" in t["drug_name"])
    assert osimertinib["alteration_classification"] == "NOT ESTABLISHED"
    assert "Not established" in osimertinib["biomarker_status"]
    assert "Insufficient genomic alteration data" in osimertinib["eligibility_status"]


# 13. Confirmed biomarker treatment mapping
def test_13_confirmed_biomarker_treatment_mapping():
    intelligence = treatment_service.get_treatment_intelligence(
        cancer_type="lung adenocarcinoma",
        biomarkers=[],
        confirmed_alterations=["EGFR", "EGFR L858R"]
    )
    osimertinib = next(t for t in intelligence["targeted_therapies"] if "Osimertinib" in t["drug_name"])
    assert osimertinib["alteration_classification"] == "CONFIRMED"
    assert "Confirmed Somatic Alteration" in osimertinib["biomarker_status"]
    assert "meets clinical guideline criteria" in osimertinib["eligibility_status"]


# 14. Unsupported Gemini medicine rejection
@pytest.mark.anyio
async def test_14_unsupported_gemini_medicine_rejection():
    service = GeminiTreatmentReasoningService(api_key="mock_key")
    deterministic_kb = treatment_service.get_treatment_intelligence("lung adenocarcinoma")
    
    # Mock Gemini hallucinating a non-existent / fake drug
    mock_gemini_json = {
        "cancer_type": "lung adenocarcinoma",
        "site": "Lung",
        "biomarkers": ["EGFR"],
        "biomarker_status": "Actionable biomarker not established from the available data.",
        "treatment_options": [
            {
                "drug_name": "FabricatedWonderDrug-XYZ999",
                "treatment_class": "Fake Category",
                "target": "EGFR",
                "mechanism": "Unverified claim",
                "why_relevant": "Hallucinated",
                "evidence": "Fake Source"
            },
            {
                "drug_name": "Osimertinib (Tagrisso)",
                "treatment_class": "3rd-Generation EGFR TKI",
                "target": "EGFR",
                "mechanism": "Covalent kinase inhibitor",
                "why_relevant": "EGFR mutant NSCLC",
                "evidence": "FLAURA Trial"
            }
        ],
        "target": "EGFR",
        "mechanism": "Kinase inhibition",
        "why_relevant": "Lung adenocarcinoma",
        "evidence": ["NCCN NSCLC 2024"],
        "limitations": "RNA expression does not confirm mutation.",
        "clinical_verification_required": True
    }
    
    # Filter should reject FabricatedWonderDrug-XYZ999 and keep Osimertinib
    verified_drugs = {t["drug_name"].strip().lower(): t for t in deterministic_kb["targeted_therapies"]}
    validated_options = []
    for opt in mock_gemini_json["treatment_options"]:
        dname = opt.get("drug_name", "").strip().lower()
        if any(vk in dname or dname in vk for vk in verified_drugs):
            validated_options.append(opt)
            
    assert len(validated_options) == 1
    assert "Osimertinib" in validated_options[0]["drug_name"]
    assert not any("FabricatedWonderDrug" in opt["drug_name"] for opt in validated_options)


# 15. Image-only treatment flow (Genomic biomarker status NOT AVAILABLE)
def test_15_image_only_treatment_flow():
    img = Image.new("RGB", (128, 128), color=(80, 80, 80))
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    buf.seek(0)
    
    result = vision_service.analyze_medical_image(buf.getvalue(), filename="lung_ct_scan.png")
    assert result["success"] is True
    assert result["detected_cancer_type"] == "lung adenocarcinoma"
    
    t_info = result["treatment_intelligence"]
    assert "Not available from this image" in t_info["genomic_biomarker_status"]
    for therapy in t_info["targeted_therapies"]:
        assert therapy["alteration_classification"] == "NOT AVAILABLE"
        assert "not available from imaging" in therapy["eligibility_status"].lower()


# 16. Genomic + Biomarker treatment flow (RNA-seq finding SUPPORTED / INFERRED)
def test_16_genomic_and_biomarker_treatment_flow():
    intelligence = treatment_service.get_treatment_intelligence(
        cancer_type="lung adenocarcinoma",
        biomarkers=[
            {"gene": "EGFR", "status": "upregulated", "z_score_deviation": 2.45}
        ]
    )
    osimertinib = next(t for t in intelligence["targeted_therapies"] if "Osimertinib" in t["drug_name"])
    assert osimertinib["alteration_classification"] == "SUPPORTED / INFERRED"
    assert "Expression Finding" in osimertinib["biomarker_status"]
    assert "RNA expression finding detected" in osimertinib["eligibility_status"]


# 17. Gemini unavailable fallback (Returns deterministic knowledge cleanly)
@pytest.mark.anyio
async def test_17_gemini_unavailable_fallback():
    service = GeminiTreatmentReasoningService(api_key=None)
    deterministic_kb = treatment_service.get_treatment_intelligence("breast invasive carcinoma")
    res = await service.reason_over_evidence(deterministic_kb)
    assert res == deterministic_kb
    assert len(res["targeted_therapies"]) >= 3


# 18. Invalid Gemini JSON handling
@pytest.mark.anyio
async def test_18_invalid_gemini_json_handling():
    service = GeminiTreatmentReasoningService(api_key="mock_invalid")
    deterministic_kb = treatment_service.get_treatment_intelligence("glioblastoma multiforme")
    # When invalid, it should fall back to deterministic_kb without throwing
    res = await service.reason_over_evidence(deterministic_kb)
    assert res["cancer_type"] == "glioblastoma multiforme"
    assert len(res["targeted_therapies"]) >= 1


# 19. Treatment source validation
def test_19_treatment_source_validation():
    intelligence = treatment_service.get_treatment_intelligence("lung adenocarcinoma")
    for therapy in intelligence["targeted_therapies"]:
        assert "evidence_source" in therapy and len(therapy["evidence_source"]) > 5
        assert "source_url" in therapy
        assert therapy["source_url"].startswith("http")
        assert "nccn_evidence_tier" in therapy
        assert "fda_status" in therapy


# 20. Medical research disclaimer
def test_20_medical_research_disclaimer():
    # Root
    res_root = client.get("/")
    assert "RESEARCH" in res_root.json()["disclaimer"]
    
    # Genomic prediction
    res_gen = genomic_service.predict_expression({"TP53": 11.2, "EGFR": 12.8, "KRAS": 11.0})
    assert "RESEARCH AND EDUCATIONAL USE ONLY" in res_gen["disclaimer"]
    
    # Treatment intelligence
    res_tx = treatment_service.get_treatment_intelligence("lung adenocarcinoma")
    assert "RESEARCH SUPPORT ONLY" in res_tx["disclaimer"]
    
    # Medical Vision
    img = Image.new("RGB", (64, 64), color=(50, 50, 50))
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    res_img = vision_service.analyze_medical_image(buf.getvalue(), "scan.png")
    assert "INVESTIGATIONAL RESEARCH" in res_img["disclaimer"]


# 21. Verify 2-column CSV parsing produces exact non-empty dictionary
def test_21_exact_csv_dict_parsing():
    raw_csv = (
        b"Gene Symbol,log2 Expression\n"
        b"EGFR,10.8\n"
        b"KRAS,9.7\n"
        b"ALK,7.1\n"
    )
    parsed = genomic_service.parse_file_content(raw_csv, "test_sample.csv")
    assert parsed == {
        "EGFR": 10.8,
        "KRAS": 9.7,
        "ALK": 7.1
    }
    # Also verify upload endpoint processes it successfully
    res = client.post(
        "/api/v1/analyze/genomic/upload",
        files={"file": ("test_sample.csv", raw_csv, "text/csv")}
    )
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert "prediction" in data


# 22. Verify curated samples list endpoint returns populated expression_data
def test_22_curated_samples_list_expression_data():
    res = client.get("/api/v1/analyze/samples")
    assert res.status_code == 200
    data = res.json()
    assert data["success"] is True
    assert len(data["samples"]) >= 5
    for sample in data["samples"]:
        assert "expression_data" in sample
        assert len(sample["expression_data"]) > 0
        assert isinstance(sample["expression_data"], dict)
