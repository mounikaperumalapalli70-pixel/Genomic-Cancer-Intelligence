import logging
from typing import Dict, Any, List, Optional

logger = logging.getLogger(__name__)


class TreatmentIntelligenceService:
    """
    Evidence-based Oncology & Precision Medicine Intelligence Service.
    
    Translates predicted TCGA cancer phenotypes and detected genomic biomarker alterations
    into structured, clinically referenced targeted therapies, FDA-approved drugs,
    molecular targets, biological mechanisms, and regulatory guidelines.
    
    Adheres strictly to evidence guidelines from NCCN, FDA, NCI, NIH, and ClinicalTrials.gov.
    Distinguishes clearly between gene expression findings (RNA-seq), confirmed DNA alterations,
    and actionable clinical eligibility.
    """

    CANCER_TREATMENT_KNOWLEDGE: Dict[str, Dict[str, Any]] = {
        "lung adenocarcinoma": {
            "disease_name": "Lung Adenocarcinoma (NSCLC)",
            "cancer_site": "Bronchial & Pulmonary Alveolar Tissue / Lung",
            "subtype": "Non-Small Cell Lung Cancer (Adenocarcinoma Histology)",
            "primary_biomarkers": ["EGFR", "KRAS", "ALK", "ROS1", "BRAF", "MET", "RET", "ERBB2", "PDCD1", "CD274"],
            "genomic_data_limitation_notice": "TCGA dataset reflects RNA-seq quantitative gene expression. Clinically actionable eligibility for targeted kinase inhibitors requires diagnostic DNA next-generation sequencing (NGS) to establish somatic activating mutations (e.g., EGFR Exon 19 del / L858R, KRAS G12C, BRAF V600E).",
            "first_line_guideline": "NCCN Guidelines (NSCLC v2.2024): Mandatory broad molecular panel testing for EGFR, ALK, KRAS G12C, ROS1, BRAF V600E, RET, METex14, ERBB2, and PD-L1 IHC expression before systemic therapy initiation.",
            "targeted_therapies": [
                {
                    "drug_name": "Osimertinib (Tagrisso)",
                    "treatment_class": "3rd-Generation Irreversible EGFR Tyrosine Kinase Inhibitor (TKI)",
                    "molecular_target": "Epidermal Growth Factor Receptor (EGFR / ErbB-1 / HER1)",
                    "target_gene": "EGFR",
                    "target_biological_function": "Transmembrane receptor tyrosine kinase activating Ras-Raf-MEK-ERK and PI3K-Akt cascades that drive epithelial cell survival, proliferation, and anti-apoptosis.",
                    "how_it_works": "Covalently binds cysteine 797 (C797) in the ATP-binding pocket of mutated EGFR kinase domain, selectively shutting down kinase auto-phosphorylation and triggering tumor apoptosis.",
                    "why_relevant": "Preferred first-line standard for EGFR-mutated advanced NSCLC (Exon 19 deletions or Exon 21 L858R) and secondary T790M gatekeeper resistance, with demonstrated blood-brain barrier penetration.",
                    "required_genomic_alteration": "Sensitizing EGFR Exon 19 In-Frame Deletion or Exon 21 L858R Substitution (Diagnostic DNA NGS/PCR required).",
                    "fda_status": "FDA Approved (1st-line Advanced/Metastatic & Adjuvant Post-Resection)",
                    "nccn_evidence_tier": "NCCN Category 1 (Preferred 1st-Line)",
                    "evidence_source": "NCCN Guidelines NSCLC v2.2024; FDA Label Tagrisso; Soria JC et al., FLAURA Trial, N Engl J Med 2018; 378:113-125; Wu YL et al., ADAURA Trial, N Engl J Med 2020.",
                    "clinical_notes": "Demonstrated statistically significant overall survival (OS) advantage vs. 1st-generation TKIs (erlotinib/gefitinib) and median progression-free survival (PFS) of 18.9 months."
                },
                {
                    "drug_name": "Sotorasib (Lumakras) / Adagrasib (Krazati)",
                    "treatment_class": "KRAS G12C Covalent Small Molecule Inhibitor",
                    "molecular_target": "Kirsten Rat Sarcoma Viral Oncogene Homolog (KRAS GTPase)",
                    "target_gene": "KRAS",
                    "target_biological_function": "Binary GDP/GTP molecular switch regulating intracellular signal transduction downstream of growth factor receptors toward MAPK cell-division pathways.",
                    "how_it_works": "Irreversibly traps the mutant cysteine 12 of KRAS in its inactive GDP-bound conformation, preventing RAF binding and blocking downstream MAPK signaling.",
                    "why_relevant": "Specifically active in NSCLC tumors harboring the somatic KRAS p.G12C activating transversion mutation.",
                    "required_genomic_alteration": "Somatic KRAS G12C Point Mutation (c.34G>T, Confirmed by NGS panel).",
                    "fda_status": "FDA Accelerated Approval (Subsequent Therapy for KRAS G12C+)",
                    "nccn_evidence_tier": "NCCN Category 2A",
                    "evidence_source": "NCCN Guidelines NSCLC v2.2024; FDA Label Lumakras/Krazati; Skoulidis F et al., CodeBreaK 100, N Engl J Med 2021; 384:2371-2381; Jänne PA et al., KRYSTAL-1, N Engl J Med 2022.",
                    "clinical_notes": "Directly overcomes the historical undruggability of KRAS; provides objective response rates of 37-43% in heavily pretreated KRAS G12C NSCLC."
                },
                {
                    "drug_name": "Alectinib (Alecensa) / Brigatinib (Alunbrig)",
                    "treatment_class": "2nd-Generation Highly Selective ALK Tyrosine Kinase Inhibitor",
                    "molecular_target": "Anaplastic Lymphoma Receptor Tyrosine Kinase (ALK Fusion Oncoprotein)",
                    "target_gene": "ALK",
                    "target_biological_function": "Chimeric fusion kinase (predominantly EML4-ALK) with constitutive kinase activation driving sustained oncogenic proliferative signaling.",
                    "how_it_works": "Selectively competes with ATP for binding to ALK kinase domain, inhibiting auto-phosphorylation and blocking STAT3, AKT, and ERK downstream signaling.",
                    "why_relevant": "Preferred first-line standard for ALK-rearranged NSCLC, exhibiting superior CNS penetration and overcoming crizotinib-resistant gatekeeper mutations.",
                    "required_genomic_alteration": "Chromosomal ALK Gene Rearrangement / EML4-ALK Inversion (FISH or NGS Breakpoint Assay).",
                    "fda_status": "FDA Approved (1st-line Advanced ALK+ NSCLC & Adjuvant)",
                    "nccn_evidence_tier": "NCCN Category 1 (Preferred 1st-Line)",
                    "evidence_source": "NCCN Guidelines NSCLC v2.2024; FDA Label Alecensa; Peters S et al., ALEX Trial, N Engl J Med 2017; 377:829-838; Mok T et al., Updated ALEX, Ann Oncol 2020.",
                    "clinical_notes": "Achieved landmark 5-year overall survival rate of 62.5% and 34.8-month median progression-free survival in treatment-naive ALK+ NSCLC."
                },
                {
                    "drug_name": "Dabrafenib (Tafinlar) + Trametinib (Mekinist)",
                    "treatment_class": "Dual BRAF Kinase Inhibitor + MEK1/2 Allosteric Inhibitor Combination",
                    "molecular_target": "B-Raf Proto-Oncogene Kinase (BRAF) & Mitogen-Activated Kinase Kinase (MEK1/2)",
                    "target_gene": "BRAF",
                    "target_biological_function": "Serine/threonine kinase components of the canonical MAPK signaling cascade governing cell cycle entry and survival.",
                    "how_it_works": "Dabrafenib inhibits mutant BRAF V600 kinase monomers while Trametinib inhibits downstream MEK1/2, providing synergistic vertical pathway inhibition and preventing paradoxical MAPK reactivation.",
                    "why_relevant": "Established standard targeted regimen for metastatic NSCLC with confirmed BRAF V600E point mutations.",
                    "required_genomic_alteration": "BRAF V600E (c.1799T>A) Activating Point Mutation (NGS / PCR).",
                    "fda_status": "FDA Approved (BRAF V600E-mutant Metastatic NSCLC)",
                    "nccn_evidence_tier": "NCCN Category 1",
                    "evidence_source": "NCCN Guidelines NSCLC v2.2024; Planchard D et al., Lancet Oncol 2016; 17(7):984-993; Planchard D et al., Phase 2 Cohort, Lancet Oncol 2017; 18(10):1307-1316.",
                    "source_url": "https://www.nccn.org/guidelines/guidelines-detail?category=1&id=1450",
                    "clinical_notes": "Objective response rate of 64% in treatment-naive and 63% in previously treated BRAF V600E metastatic NSCLC."
                },
                {
                    "drug_name": "Capmatinib (Tabrecta) / Tepotinib (Tepmetko)",
                    "treatment_class": "Highly Selective MET Receptor Tyrosine Kinase Inhibitor",
                    "molecular_target": "MET Proto-Oncogene / Hepatocyte Growth Factor Receptor (HGFR)",
                    "target_gene": "MET",
                    "target_biological_function": "Receptor tyrosine kinase governing invasive growth, cell motility, and embryonic tissue morphogenesis.",
                    "how_it_works": "Selectively blocks MET phosphorylation and downstream signaling in tumors with MET exon 14 skipping alterations.",
                    "why_relevant": "Targeted first-line and subsequent therapy for metastatic NSCLC with MET exon 14 skipping alterations.",
                    "required_genomic_alteration": "MET Exon 14 Skipping Mutation (RNA-seq / DNA NGS panel).",
                    "fda_status": "FDA Approved (MET Exon 14 Skipping Metastatic NSCLC)",
                    "nccn_evidence_tier": "NCCN Category 1",
                    "evidence_source": "NCCN Guidelines NSCLC v2.2024; Wolf J et al., GEOMETRY mono-1, N Engl J Med 2020; 383:944-957; Paik PK et al., VISION Trial, N Engl J Med 2020.",
                    "source_url": "https://www.cancer.gov/types/lung",
                    "clinical_notes": "Demonstrated overall response rate of 68% in treatment-naive METex14-altered metastatic NSCLC."
                },
                {
                    "drug_name": "Selpercatinib (Retevmo) / Pralsetinib (Gavreto)",
                    "treatment_class": "Potent and Selective RET Receptor Tyrosine Kinase Inhibitor",
                    "molecular_target": "Receptor Tyrosine Kinase Encoded by the RET Proto-Oncogene",
                    "target_gene": "RET",
                    "target_biological_function": "Cell-surface receptor essential for neural crest and renal development, forming oncogenic fusions in cancer.",
                    "how_it_works": "Competitively inhibits RET kinase activity, shutting down downstream MAPK and PI3K oncogenic signaling in RET-rearranged tumors.",
                    "why_relevant": "Preferred first-line therapy for metastatic NSCLC harboring RET gene fusions (e.g. KIF5B-RET).",
                    "required_genomic_alteration": "Confirmed RET In-Frame Gene Fusion (NGS / FISH).",
                    "fda_status": "FDA Approved (RET Fusion-Positive Metastatic NSCLC)",
                    "nccn_evidence_tier": "NCCN Category 1",
                    "evidence_source": "NCCN Guidelines NSCLC v2.2024; Drilon A et al., LIBRETTO-001, N Engl J Med 2020; 383:813-824; Gainor JF et al., ARROW Trial, Lancet Oncol 2021.",
                    "source_url": "https://www.fda.gov/drugs",
                    "clinical_notes": "Demonstrated 84% objective response rate in treatment-naive RET-fusion metastatic NSCLC."
                },
                {
                    "drug_name": "Crizotinib (Xalkori) / Entrectinib (Rozlytrek)",
                    "treatment_class": "Small Molecule ROS1 Receptor Tyrosine Kinase Inhibitor",
                    "molecular_target": "ROS Proto-Oncogene 1 Receptor Tyrosine Kinase (ROS1)",
                    "target_gene": "ROS1",
                    "target_biological_function": "Orphan receptor tyrosine kinase belonging to the insulin receptor family.",
                    "how_it_works": "Inhibits ROS1 kinase phosphorylation, suppressing cell survival signaling in ROS1-rearranged lung carcinomas.",
                    "why_relevant": "Standard first-line therapy for metastatic NSCLC harboring ROS1 gene fusions.",
                    "required_genomic_alteration": "Chromosomal ROS1 In-Frame Gene Rearrangement (FISH / NGS).",
                    "fda_status": "FDA Approved (ROS1-positive Metastatic NSCLC)",
                    "nccn_evidence_tier": "NCCN Category 1",
                    "evidence_source": "NCCN Guidelines NSCLC v2.2024; Shaw AT et al., PROFILE 1001, N Engl J Med 2014; 371:1963-1971; Drilon A et al., Lancet Oncol 2020.",
                    "source_url": "https://clinicaltrials.gov",
                    "clinical_notes": "Produced 72% objective response rate with 19.3-month median duration of response in ROS1+ NSCLC."
                },
                {
                    "drug_name": "Trastuzumab Deruxtecan (Enhertu)",
                    "treatment_class": "HER2-Targeted Antibody-Drug Conjugate (ADC)",
                    "molecular_target": "Human Epidermal Growth Factor Receptor 2 (HER2 / ERBB2)",
                    "target_gene": "ERBB2",
                    "target_biological_function": "ErbB family receptor tyrosine kinase driving cell growth and survival.",
                    "how_it_works": "Anti-HER2 antibody delivers topoisomerase I inhibitor payload directly to HER2-expressing/mutated tumor cells.",
                    "why_relevant": "First approved targeted therapy for pretreated metastatic NSCLC with activating HER2/ERBB2 mutations.",
                    "required_genomic_alteration": "Activating ERBB2 (HER2) Kinase Domain Somatic Mutation (Exon 20 insertion).",
                    "fda_status": "FDA Accelerated Approval (Pretreated HER2-mutant Metastatic NSCLC)",
                    "nccn_evidence_tier": "NCCN Category 2A",
                    "evidence_source": "NCCN Guidelines NSCLC v2.2024; Li BT et al., DESTINY-Lung01, N Engl J Med 2022; 386:241-251.",
                    "source_url": "https://www.cancer.gov",
                    "clinical_notes": "Achieved confirmed 55% objective response rate in previously treated HER2-mutant NSCLC."
                },
                {
                    "drug_name": "Pembrolizumab (Keytruda)",
                    "treatment_class": "Anti-PD-1 Humanized Monoclonal Antibody (Immune Checkpoint Inhibitor)",
                    "molecular_target": "Programmed Cell Death Protein 1 (PD-1 / CD279) & PD-L1 (CD274)",
                    "target_gene": "CD274",
                    "target_biological_function": "Immune checkpoint pathway utilized by tumor cells expressing PD-L1 to engage T-cell PD-1, inducing T-cell anergy and immune evasion.",
                    "how_it_works": "High-affinity binding to PD-1 receptor on cytotoxic T-lymphocytes prevents interaction with PD-L1/PD-L2, releasing the brake on anti-tumor immune response.",
                    "why_relevant": "First-line standard monotherapy for advanced NSCLC without targetable oncogenic driver mutations exhibiting high PD-L1 tumor proportion score (TPS >= 50%) or combined with platinum chemotherapy.",
                    "required_genomic_alteration": "PD-L1 Expression by IHC (TPS >= 1% or >= 50%) & Absence of Sensitizing EGFR/ALK Drivers.",
                    "fda_status": "FDA Approved (1st-line Monotherapy & Chemo-combination)",
                    "nccn_evidence_tier": "NCCN Category 1",
                    "evidence_source": "NCCN Guidelines NSCLC v2.2024; Reck M et al., KEYNOTE-024 5-Year Update, J Clin Oncol 2021; 39:2339-2349; Gandhi L et al., KEYNOTE-189, N Engl J Med 2018.",
                    "source_url": "https://www.cancer.gov",
                    "clinical_notes": "Doubled 5-year overall survival rate (31.9% vs. 16.3%) compared to platinum doublet chemotherapy in PD-L1 >= 50% advanced NSCLC."
                }
            ],
            "resistance_mechanisms": [
                "EGFR C797S tertiary mutation mediating Osimertinib resistance; MET gene amplification driving bypass signaling.",
                "Acquired KRAS Y96D/C alterations or secondary RTK bypass activation.",
                "Histological transformation from NSCLC to Small Cell Lung Cancer (SCLC)."
            ],
            "clinical_trials_criteria": [
                "NCT04077463 (MARIPOSA): Phase III Bispecific EGFR/MET Antibody (Amivantamab) + Lazertinib.",
                "NCT04619797 (HERTHENA-Lung01): Phase II HER3-directed ADC (Patritumab Deruxtecan).",
                "NCT05048797 (TROPION-Lung01): Phase III TROP2-directed ADC (Datopotamab Deruxtecan)."
            ],
            "nutrition_and_metabolic_guidance": {
                "caloric_support": "High-protein, anti-inflammatory Mediterranean dietary profile.",
                "key_nutrients": [
                    "Omega-3 fatty acids (EPA/DHA 2g/day) for cancer cachexia and inflammatory cytokine mitigation",
                    "Vitamin D3 (immunomodulatory support during checkpoint therapy)",
                    "Cruciferous vegetables rich in sulforaphane"
                ],
                "precautions": "Avoid high-dose synthetic beta-carotene supplements in active or former smokers due to documented adverse pulmonary risks."
            }
        },
        "breast invasive carcinoma": {
            "disease_name": "Breast Invasive Carcinoma (BRCA)",
            "cancer_site": "Mammary Gland Tissue / Breast",
            "subtype": "Infiltrating Ductal / Lobular Carcinoma (Subtyped by ER/PR/HER2/BRCA status)",
            "primary_biomarkers": ["ERBB2", "ESR1", "PGR", "BRCA1", "BRCA2", "PIK3CA", "AKT1", "CDK4", "CDK6"],
            "genomic_data_limitation_notice": "TCGA gene expression indicates RNA transcript levels (e.g., ERBB2, ESR1, BRCA1). Clinical qualification for anti-HER2 antibodies requires standardized IHC (3+) or FISH amplification testing; PARP inhibitors require germline/somatic deleterious BRCA1/2 DNA sequencing.",
            "first_line_guideline": "NCCN Guidelines (Breast Cancer v1.2024): Receptor stratification by ER/PR hormone receptors, HER2 amplification (IHC/FISH), germline BRCA1/2 mutation status, and PIK3CA/AKT1 hotspot mutation profiling.",
            "targeted_therapies": [
                {
                    "drug_name": "Trastuzumab Deruxtecan (Enhertu, T-DXd)",
                    "treatment_class": "HER2-Targeted Antibody-Drug Conjugate (ADC) with Topoisomerase I Inhibitor Payload",
                    "molecular_target": "Human Epidermal Growth Factor Receptor 2 (HER2 / ERBB2 / Neu)",
                    "target_gene": "ERBB2",
                    "target_biological_function": "Orphan receptor tyrosine kinase that heterodimerizes with other ErbB family members to amplify MAPK and PI3K/Akt pro-survival oncogenic signaling.",
                    "how_it_works": "Anti-HER2 humanized IgG1 antibody delivers a membrane-permeable exatecan derivative (topoisomerase I inhibitor) payload directly to HER2-expressing cells, generating DNA double-strand breaks and bystander killing of adjacent heterogeneous tumor cells.",
                    "why_relevant": "Unprecedented progression-free survival benefit in both HER2-positive (IHC 3+ or FISH+) and HER2-low (IHC 1+ or IHC 2+/FISH-) metastatic breast cancer.",
                    "required_genomic_alteration": "ERBB2 Amplification / Overexpression (IHC 3+ or FISH amplified) or HER2-Low Status (IHC 1+ or 2+/FISH-).",
                    "fda_status": "FDA Approved (HER2-positive & HER2-low Metastatic Breast Cancer)",
                    "nccn_evidence_tier": "NCCN Category 1 (Preferred 2nd-Line & Post-Endocrine)",
                    "evidence_source": "NCCN Guidelines Breast Cancer v1.2024; Cortés J et al., DESTINY-Breast03, N Engl J Med 2022; 386:1143-1154; Modi S et al., DESTINY-Breast04, N Engl J Med 2022; 387:9-20.",
                    "clinical_notes": "DESTINY-Breast03 trial demonstrated 72% reduction in risk of disease progression or death vs. standard T-DM1 (12-month PFS 75.8% vs. 34.1%)."
                },
                {
                    "drug_name": "Olaparib (Lynparza) / Talazoparib (Talzenna)",
                    "treatment_class": "Poly (ADP-ribose) Polymerase (PARP1/2) Catalytic Inhibitor & Trapper",
                    "molecular_target": "PARP1 and PARP2 DNA Single-Strand Break Repair Enzymes",
                    "target_gene": "BRCA1",
                    "target_biological_function": "Nuclear enzymes essential for Base Excision Repair (BER) of DNA single-strand breaks.",
                    "how_it_works": "Traps PARP-DNA complexes at single-strand breaks, converting them during DNA replication into lethal double-strand breaks that homologous recombination repair (HRR)-deficient BRCA-mutated cells cannot repair, leading to synthetic lethality.",
                    "why_relevant": "Standard-of-care in deleterious germline or somatic BRCA1/2-mutated HER2-negative metastatic breast cancer and high-risk early breast cancer adjuvant therapy.",
                    "required_genomic_alteration": "Deleterious Germline or Somatic BRCA1 or BRCA2 Inactivating DNA Mutation.",
                    "fda_status": "FDA Approved (gBRCAm HER2-negative Metastatic & Adjuvant High-Risk)",
                    "nccn_evidence_tier": "NCCN Category 1",
                    "evidence_source": "NCCN Guidelines Breast Cancer v1.2024; Robson M et al., OlympiAD Trial, N Engl J Med 2017; 377:523-533; Tutt ANJ et al., OlympiA Adjuvant Trial, N Engl J Med 2021; 384:2394-2405.",
                    "clinical_notes": "OlympiA trial demonstrated significant improvement in 3-year invasive disease-free survival (85.9% vs. 77.1%) and overall survival in high-risk early BRCA-mutated breast cancer."
                },
                {
                    "drug_name": "Ribociclib (Kisqali) / Abemaciclib (Verzenio) + Fulvestrant",
                    "treatment_class": "Cyclin-Dependent Kinase 4 and 6 (CDK4/6) Inhibitor + Selective Estrogen Receptor Degrader (SERD)",
                    "molecular_target": "Cyclin D1-CDK4/6 Complex and Estrogen Receptor Alpha (ERa / ESR1)",
                    "target_gene": "CDK4",
                    "target_biological_function": "CDK4/6 phosphorylates Retinoblastoma (Rb) protein, releasing E2F transcription factors to drive cell cycle transition from G1 to S phase.",
                    "how_it_works": "Prevents Rb phosphorylation, arresting ER-positive tumor cells in the G1 phase of the cell cycle and preventing uncontrolled proliferation.",
                    "why_relevant": "First-line and second-line standard of care for HR+/HER2- advanced breast cancer; Ribociclib shows statistically significant overall survival benefits in MONALEESA trials.",
                    "required_genomic_alteration": "Hormone Receptor Positive (ER/PR > 1% by IHC) & HER2-Negative.",
                    "fda_status": "FDA Approved (1st-line with Aromatase Inhibitor & 2nd-line with Fulvestrant)",
                    "nccn_evidence_tier": "NCCN Category 1 (Preferred 1st-Line HR+/HER2-)",
                    "evidence_source": "NCCN Guidelines Breast Cancer v1.2024; Slamon DJ et al., MONALEESA-3 OS, N Engl J Med 2020; 382:514-524; Hortobagyi GN et al., MONALEESA-2 OS, N Engl J Med 2022; 386:942-950.",
                    "clinical_notes": "Ribociclib added to endocrine therapy extended median overall survival to 63.9 months compared to 51.4 months with endocrine therapy alone."
                },
                {
                    "drug_name": "Alpelisib (Piqray) + Fulvestrant",
                    "treatment_class": "PI3K-alpha Catalytic Subunit (p110a) Specific Small Molecule Inhibitor",
                    "molecular_target": "Phosphatidylinositol 4,5-Bisphosphate 3-Kinase Catalytic Subunit Alpha (PIK3CA)",
                    "target_gene": "PIK3CA",
                    "target_biological_function": "Lipid kinase converting PIP2 to PIP3, initiating the canonical AKT/mTOR pro-survival and metabolic growth pathway.",
                    "how_it_works": "Selectively inhibits the mutated p110alpha isoform, shutting down AKT phosphorylation, suppressing tumor cellular glycolysis, and restoring endocrine sensitivity.",
                    "why_relevant": "Indicated in HR+/HER2- advanced breast cancer harboring activating PIK3CA hotspot mutations following progression on endocrine therapy.",
                    "required_genomic_alteration": "PIK3CA Somatic Activating Mutation (e.g., E542K, E545K, H1047R via ctDNA or tumor tissue).",
                    "fda_status": "FDA Approved (PIK3CA-mutated HR+/HER2- Advanced/Metastatic)",
                    "nccn_evidence_tier": "NCCN Category 1",
                    "evidence_source": "NCCN Guidelines Breast Cancer v1.2024; André F et al., SOLAR-1 Trial, N Engl J Med 2019; 380:1929-1940.",
                    "clinical_notes": "Nearly doubled median progression-free survival (11.0 vs. 5.7 months) in patients with confirmed PIK3CA mutations compared to placebo + fulvestrant."
                }
            ],
            "resistance_mechanisms": [
                "ESR1 ligand-independent activating mutations (Y537S/D538G) developing under aromatase inhibitor selection.",
                "Loss of Retinoblastoma (RB1) expression mediating CDK4/6 inhibitor resistance.",
                "Secondary BRCA1/2 reversion mutations restoring open reading frame and homologous recombination competence."
            ],
            "clinical_trials_criteria": [
                "NCT03778931 (EMERALD): Novel Oral SERD (Elacestrant) for ESR1-mutated metastatic disease.",
                "NCT03901339 (CAPItello-291): AKT Inhibitor (Capivasertib) + Fulvestrant in AKT1/PTEN/PIK3CA altered tumors.",
                "NCT04595565 (TROPiCS-02): TROP2-directed ADC (Sacituzumab Govitecan) in endocrine-resistant HR+/HER2- disease."
            ],
            "nutrition_and_metabolic_guidance": {
                "caloric_support": "Isoflavone-balanced, phytoestrogen-mindful whole plant nutrition.",
                "key_nutrients": [
                    "Dietary flaxseed lignans (enterolactone precursor with mild anti-estrogenic competitive binding)",
                    "Calcium (1,200 mg) & Vitamin D3 (2,000 IU) for bone density preservation during aromatase inhibitor therapy",
                    "Cruciferous indol-3-carbinol / DIM sources"
                ],
                "precautions": "Maintain regular glycemic control to avoid hyperinsulinemia-mediated activation of PI3K/AKT/mTOR pathways."
            }
        },
        "glioblastoma multiforme": {
            "disease_name": "Glioblastoma Multiforme (GBM)",
            "cancer_site": "Central Nervous System / Brain Subcortical White Matter",
            "subtype": "High-Grade Neuroepithelial Astrocytic Malignancy (WHO Grade 4)",
            "primary_biomarkers": ["EGFR", "MGMT", "IDH1", "IDH2", "CDKN2A", "PTEN", "TERT", "VEGFA"],
            "genomic_data_limitation_notice": "TCGA gene expression indicates high EGFR/GFAP expression and CDKN2A downregulation. Clinical therapeutic stratification requires quantitative MGMT promoter methylation assay (MS-PCR/pyrosequencing) and IDH1/2 R132H mutation sequencing.",
            "first_line_guideline": "NCCN Guidelines (Central Nervous System Cancers v1.2024): Maximal safe surgical resection followed by the Stupp Protocol (Concurrent Radiation Therapy 60 Gy + daily Temozolomide), followed by maintenance Temozolomide +/- Tumor Treating Fields (TTFields).",
            "targeted_therapies": [
                {
                    "drug_name": "Temozolomide (Temodar) + Concurrent Radiation",
                    "treatment_class": "Oral Alkylating / DNA Methylating Triazene Prodrug",
                    "molecular_target": "O6-Methylguanine Residues in Genomic DNA & MGMT Repair Enzyme",
                    "target_gene": "MGMT",
                    "target_biological_function": "O6-Methylguanine-DNA methyltransferase (MGMT) directly removes cytotoxic O6-alkyl lesions from DNA, conferring resistance to alkylating agents.",
                    "how_it_works": "Spontaneously converts at physiologic pH to active MTIC, transferring methyl groups to DNA (O6 and N7 guanine). Unrepaired O6-methylguanine leads to DNA mismatch repair-dependent double-strand breaks and G2/M cell cycle arrest.",
                    "why_relevant": "Global standard-of-care for newly diagnosed glioblastoma; efficacy is highly pronounced in tumors harboring epigenetic MGMT promoter methylation (epigenetic gene silencing).",
                    "required_genomic_alteration": "MGMT Promoter Hypermethylation (Pyrosequencing/MS-PCR threshold >= 9-10%).",
                    "fda_status": "FDA Approved (Standard 1st-line Newly Diagnosed GBM)",
                    "nccn_evidence_tier": "NCCN Category 1 (Standard-of-Care)",
                    "evidence_source": "NCCN Guidelines CNS v1.2024; Stupp R et al., Radiotherapy plus Temozolomide, N Engl J Med 2005; 352:987-996; Hegi ME et al., MGMT Gene Silencing, N Engl J Med 2005; 352:997-1003.",
                    "clinical_notes": "MGMT methylated glioblastoma patients achieved median overall survival of 21.7 months with TMZ+RT vs. 15.3 months with RT alone."
                },
                {
                    "drug_name": "Optune (Tumor Treating Fields / TTFields)",
                    "treatment_class": "Non-Invasive Biophysical Alternating Electric Field Medical Device",
                    "molecular_target": "Mitotic Spindle Tubulin Heterodimers and Septin Cellular Complexes",
                    "target_gene": "None",
                    "target_biological_function": "Microtubule polymerization and septin ring positioning required for mitotic spindle formation and cytokinesis.",
                    "how_it_works": "Delivers low-intensity (1-3 V/cm), intermediate frequency (200 kHz) alternating electric fields across the scalp, exerting dielectrophoretic forces on polar tubulin dimers, disrupting the mitotic spindle and inducing aneuploid cell death.",
                    "why_relevant": "Category 1 standard maintenance option combined with maintenance temozolomide for newly diagnosed supra-tentorial glioblastoma.",
                    "required_genomic_alteration": "Histopathologically Confirmed Supratentorial Glioblastoma Post-Resection.",
                    "fda_status": "FDA Approved (Newly Diagnosed & Recurrent Glioblastoma)",
                    "nccn_evidence_tier": "NCCN Category 1",
                    "evidence_source": "NCCN Guidelines CNS v1.2024; Stupp R et al., EF-14 Randomized Trial, JAMA 2017; 318(23):2306-2316.",
                    "clinical_notes": "EF-14 trial demonstrated significant improvement in 5-year overall survival (13% vs. 5%) and median OS extension from 16.0 to 20.9 months."
                },
                {
                    "drug_name": "Bevacizumab (Avastin)",
                    "treatment_class": "Recombinant Humanized Monoclonal Antibody targeting Vascular Endothelial Growth Factor (VEGF-A)",
                    "molecular_target": "Vascular Endothelial Growth Factor A (VEGF-A)",
                    "target_gene": "VEGFA",
                    "target_biological_function": "Secreted ligand stimulating VEGFR2 endothelial receptors to initiate pathologic tumor neo-angiogenesis and vascular permeability.",
                    "how_it_works": "Binds circulating VEGF-A, preventing interaction with VEGFR1/2, normalizing hyper-permeable tumor microvasculature, and reducing cerebral peritumoral vasogenic edema.",
                    "why_relevant": "Approved for recurrent glioblastoma to alleviate neurologic symptoms, reduce corticosteroid dependency, and improve progression-free survival.",
                    "required_genomic_alteration": "Recurrent / Progressive Glioblastoma with Significant Peritumoral Edema.",
                    "fda_status": "FDA Approved (Recurrent Glioblastoma)",
                    "nccn_evidence_tier": "NCCN Category 2A",
                    "evidence_source": "NCCN Guidelines CNS v1.2024; Friedman HS et al., Bevacizumab Alone and in Combination, J Clin Oncol 2009; 27:4733-4740; Wick W et al., EORTC 26101, Neuro-Oncol 2017.",
                    "clinical_notes": "Provides rapid symptom relief and reduces intracranial pressure, although overall survival benefit in randomized trials remains limited."
                }
            ],
            "resistance_mechanisms": [
                "Acquisition of MSH6 mismatch repair mutations inducing a hypermutator phenotype and secondary temozolomide resistance.",
                "Extensive intra-tumoral heterogeneity with heterogeneous EGFR amplification and EGFRvIII truncation loss."
            ],
            "clinical_trials_criteria": [
                "NCT03283631: CAR-T Cell therapy targeting EGFRvIII, IL13Ralpha2, and HER2.",
                "NCT03483441: Oncolytic viral therapy (DNX-2401) + Pembrolizumab.",
                "NCT05484622: Brain-penetrant EGFR TKIs and EGFR-targeted ADCs."
            ],
            "nutrition_and_metabolic_guidance": {
                "caloric_support": "Neuro-protective, low-glycemic anti-inflammatory dietary framework.",
                "key_nutrients": [
                    "Curcumin phytosome (anti-inflammatory NF-kB suppression)",
                    "Boswellic acids (Frankincense extract, studied for adjunctive cerebral edema reduction)",
                    "Magnesium L-threonate for blood-brain barrier neuroprotection"
                ],
                "precautions": "Avoid high-glycemic sugar spikes that stimulate anaerobic glycolytic metabolism in glioblastoma cells."
            }
        },
        "colon adenocarcinoma": {
            "disease_name": "Colon & Rectal Adenocarcinoma (CRC)",
            "cancer_site": "Colonic Epithelium / Large Intestine & Rectum",
            "subtype": "Colorectal Adenocarcinoma (Subtyped by MMR/MSI, RAS, BRAF, and HER2 status)",
            "primary_biomarkers": ["KRAS", "NRAS", "BRAF", "MSI", "MLH1", "MSH2", "CDX2", "ERBB2", "PIK3CA"],
            "genomic_data_limitation_notice": "TCGA gene expression matrix demonstrates CDX2/CEACAM5 markers. Clinical qualification for anti-EGFR therapy strictly requires confirmed RAS (KRAS/NRAS Exons 2, 3, 4) wild-type and BRAF V600E wild-type sequencing on tumor DNA.",
            "first_line_guideline": "NCCN Guidelines (Colon/Rectal Cancer v1.2024): Universal testing for Mismatch Repair / Microsatellite Instability (dMMR/MSI-H), expanded RAS (KRAS/NRAS), BRAF V600E, and HER2 amplification to direct targeted biologics vs. immunotherapy.",
            "targeted_therapies": [
                {
                    "drug_name": "Cetuximab (Erbitux) / Panitumumab (Vectibix)",
                    "treatment_class": "Anti-EGFR Recombinant Monoclonal Antibody",
                    "molecular_target": "Epidermal Growth Factor Receptor Extracellular Domain (EGFR Domain III)",
                    "target_gene": "EGFR",
                    "target_biological_function": "Cell-surface receptor driving intracellular RAS-RAF-MEK-ERK proliferative signals in colonic epithelial cells.",
                    "how_it_works": "Binds the extracellular domain of EGFR with high affinity, competitively blocking ligand binding (EGF, TGF-a), promoting receptor internalization, and recruiting antibody-dependent cellular cytotoxicity (ADCC).",
                    "why_relevant": "Standard 1st/2nd-line targeted therapy for metastatic colorectal cancer with left-sided primary tumors that are proven RAS (KRAS/NRAS) wild-type and BRAF wild-type.",
                    "required_genomic_alteration": "Confirmed RAS (KRAS & NRAS Exons 2, 3, 4) Wild-Type & BRAF V600E Wild-Type.",
                    "fda_status": "FDA Approved (RAS Wild-Type mCRC with FOLFIRI/FOLFOX)",
                    "nccn_evidence_tier": "NCCN Category 1 (Left-Sided RAS WT)",
                    "evidence_source": "NCCN Guidelines Colon Cancer v1.2024; Van Cutsem E et al., CRYSTAL Trial, J Clin Oncol 2011; 29:2011-2019; Heinemann V et al., FIRE-3, Lancet Oncol 2014; 15:1065-1075.",
                    "clinical_notes": "Strictly ineffective in RAS-mutated colorectal cancer because downstream mutated RAS remains constitutively active regardless of upstream EGFR blockade."
                },
                {
                    "drug_name": "Encorafenib (Braftovi) + Cetuximab (Erbitux)",
                    "treatment_class": "Targeted BRAF V600E Kinase Inhibitor + Anti-EGFR Monoclonal Antibody Combination",
                    "molecular_target": "BRAF V600E Mutant Kinase and EGFR Extracellular Domain",
                    "target_gene": "BRAF",
                    "target_biological_function": "Constitutively active BRAF V600E monomers driving hyperactive MAPK signaling in colorectal carcinoma.",
                    "how_it_works": "Encorafenib inhibits mutant BRAF kinase while Cetuximab suppresses the rapid EGFR-mediated adaptive feedback reactivation that normally blunts BRAF monotherapy in colorectal cancer.",
                    "why_relevant": "Proven 2nd-line standard-of-care specifically for BRAF V600E-mutated metastatic colorectal cancer.",
                    "required_genomic_alteration": "Confirmed Somatic BRAF V600E (c.1799T>A) Point Mutation.",
                    "fda_status": "FDA Approved (2nd-line BRAF V600E mCRC)",
                    "nccn_evidence_tier": "NCCN Category 1",
                    "evidence_source": "NCCN Guidelines Colon Cancer v1.2024; Kopetz S et al., BEACON CRC Trial, N Engl J Med 2019; 381:1632-1643.",
                    "clinical_notes": "BEACON CRC trial demonstrated significantly longer overall survival (9.3 vs. 5.9 months) and higher response rate (20% vs. 2%) compared with standard chemotherapy."
                },
                {
                    "drug_name": "Pembrolizumab (Keytruda) / Nivolumab + Ipilimumab",
                    "treatment_class": "Anti-PD-1 +/- Anti-CTLA-4 Immune Checkpoint Inhibitor Combination",
                    "molecular_target": "PD-1 (CD279) and CTLA-4 (CD152) Immune Regulators",
                    "target_gene": "MLH1",
                    "target_biological_function": "DNA mismatch repair complex (MLH1/MSH2/MSH6/PMS2) whose loss causes hypermutation and thousands of frameshift neoantigens.",
                    "how_it_works": "Releases negative inhibitory checkpoint signals on tumor-infiltrating T-cells, enabling robust immune eradication of high-neoantigen mismatch repair deficient tumors.",
                    "why_relevant": "Preferred 1st-line standard of care for metastatic colorectal cancer with microsatellite instability-high (MSI-H) or mismatch repair deficiency (dMMR).",
                    "required_genomic_alteration": "Microsatellite Instability-High (MSI-H) or Loss of MMR Proteins (dMMR by IHC).",
                    "fda_status": "FDA Approved (1st-line MSI-H/dMMR mCRC)",
                    "nccn_evidence_tier": "NCCN Category 1 (Preferred 1st-Line MSI-H)",
                    "evidence_source": "NCCN Guidelines Colon Cancer v1.2024; André T et al., KEYNOTE-177, N Engl J Med 2020; 383:2207-2218; Overman MJ et al., CheckMate 142, J Clin Oncol 2018.",
                    "clinical_notes": "KEYNOTE-177 trial showed doubling of median progression-free survival (16.5 vs. 8.2 months) and far lower treatment-related toxicity compared to standard cytotoxic chemotherapy."
                }
            ],
            "resistance_mechanisms": [
                "Acquisition of secondary KRAS, NRAS, or BRAF mutations or EGFR extracellular domain (ECD) S492R mutations under anti-EGFR pressure.",
                "HER2 (ERBB2) gene amplification or MET amplification bypassing EGFR inhibition."
            ],
            "clinical_trials_criteria": [
                "NCT04699188 (CodeBreaK 300): Sotorasib + Panitumumab for KRAS G12C mutated mCRC.",
                "NCT03365882 (MOUNTAINEER): Tucatinib + Trastuzumab for HER2-amplified RAS-wild type mCRC."
            ],
            "nutrition_and_metabolic_guidance": {
                "caloric_support": "High-fiber prebiotic, gut microbiome-supporting anti-inflammatory diet.",
                "key_nutrients": [
                    "Soluble and insoluble prebiotic fiber (boosting short-chain fatty acid butyrate synthesis)",
                    "Fermented foods (kefir, plain probiotic yogurt) supporting gut barrier integrity",
                    "Adequate dietary Selenium & Vitamin D3"
                ],
                "precautions": "Avoid processed red meats, excessive sodium nitrates, and heavily ultra-processed foods."
            }
        },
        "skin cutaneous melanoma": {
            "disease_name": "Skin Cutaneous Melanoma (SKCM)",
            "cancer_site": "Epidermal & Dermal Melanocytes / Cutaneous Skin",
            "subtype": "Cutaneous Melanoma (Subtyped by BRAF V600, NRAS, KIT, and NF1 mutational status)",
            "primary_biomarkers": ["BRAF", "NRAS", "KIT", "CD274", "PDCD1", "CTLA4", "CDKN2A"],
            "genomic_data_limitation_notice": "TCGA gene expression confirms high melanocytic lineage markers (MLANA, MITF). Treatment decision for targeted kinase inhibitors requires verified DNA codon 600 BRAF mutation sequencing (V600E or V600K).",
            "first_line_guideline": "NCCN Guidelines (Melanoma: Cutaneous v2.2024): Mandatory BRAF mutation testing on all Stage III/IV patients; front-line dual immunotherapy (Nivolumab + Relatlimab or Ipilimumab + Nivolumab) or targeted BRAF+MEK inhibition.",
            "targeted_therapies": [
                {
                    "drug_name": "Nivolumab + Relatlimab (Opdualag) / Ipilimumab + Nivolumab",
                    "treatment_class": "Dual Immune Checkpoint Inhibitor Combination (Anti-PD-1 + Anti-LAG-3 or Anti-CTLA-4)",
                    "molecular_target": "PD-1 (CD279), LAG-3 (CD223), and CTLA-4 (CD152)",
                    "target_gene": "PDCD1",
                    "target_biological_function": "Non-redundant immune checkpoint receptors on T-cells that mediate immune exhaustion in the tumor microenvironment.",
                    "how_it_works": "Simultaneously blocks two distinct immune inhibitory pathways, restoring exhausted effector T-cell cytolytic activity and producing durable anti-tumor immune responses.",
                    "why_relevant": "First-line standard of care for unresectable or metastatic melanoma regardless of BRAF status, providing high long-term survival rates.",
                    "required_genomic_alteration": "Unresectable or Metastatic Melanoma (PD-L1 / LAG-3 Expression Informative but not mandatory).",
                    "fda_status": "FDA Approved (1st-line Advanced/Metastatic Melanoma)",
                    "nccn_evidence_tier": "NCCN Category 1 (Preferred 1st-Line)",
                    "evidence_source": "NCCN Guidelines Melanoma v2.2024; Tawbi HA et al., RELATIVITY-047, N Engl J Med 2022; 386:24-34; Wolchok JD et al., CheckMate 067 7.5-Year OS, J Clin Oncol 2022.",
                    "clinical_notes": "CheckMate 067 trial achieved unprecedented 7.5-year median overall survival of 72.1 months in patients receiving dual checkpoint blockade."
                },
                {
                    "drug_name": "Dabrafenib + Trametinib / Encorafenib + Binimetinib",
                    "treatment_class": "Dual BRAF Inhibitor + MEK Inhibitor Targeted Combination",
                    "molecular_target": "Mutant BRAF V600 Kinase and MEK1/2 Kinases",
                    "target_gene": "BRAF",
                    "target_biological_function": "Hyperactive MAPK signaling driving rapid melanocytic proliferation and metabolic fitness.",
                    "how_it_works": "Dual kinase blockade suppresses the MAPK pathway while preventing the paradoxical MAPK activation and cutaneous secondary squamous neoplasms observed with BRAF monotherapy.",
                    "why_relevant": "Rapid objective response rates (>68%) and symptomatic relief in BRAF V600-mutated metastatic melanoma.",
                    "required_genomic_alteration": "Confirmed BRAF V600E or V600K Somatic Mutation (FDA-approved companion diagnostic).",
                    "fda_status": "FDA Approved (BRAF V600E/K Mutant Metastatic & Adjuvant Stage III)",
                    "nccn_evidence_tier": "NCCN Category 1",
                    "evidence_source": "NCCN Guidelines Melanoma v2.2024; Robert C et al., COMBI-v 5-Year OS, N Engl J Med 2019; 381:626-636; Dummer R et al., COLUMBUS Trial, Lancet Oncol 2018.",
                    "clinical_notes": "5-year pooled COMBI trial analysis showed 34% progression-free survival and 34% overall survival in BRAF-mutated metastatic melanoma."
                }
            ],
            "resistance_mechanisms": [
                "Acquired secondary NRAS mutations or alternative splicing of BRAF V600E.",
                "Loss of beta-2-microglobulin (B2M) or JAK1/2 mutations causing loss of antigen presentation and interferon-gamma resistance."
            ],
            "clinical_trials_criteria": [
                "NCT02360579 (C-144-01): Tumor-Infiltrating Lymphocyte (TIL) Cell Therapy (Lifileucel, Amtagvi).",
                "NCT03897881 (KEYNOTE-942): Personalized mRNA Neoantigen Vaccine (mRNA-4157 / V940) + Pembrolizumab."
            ],
            "nutrition_and_metabolic_guidance": {
                "caloric_support": "High-fiber, gut microbiome-enhancing anti-inflammatory diet.",
                "key_nutrients": [
                    "Diverse dietary fibers (proven in Spencer et al., Science 2021 to enhance anti-PD-1 response)",
                    "Polyphenol-rich blueberries, pomegranates, and green tea",
                    "Resveratrol"
                ],
                "precautions": "Avoid commercial high-dose isolated antioxidant supplements during active treatment without oncologist consultation."
            }
        },
        "kidney clear cell carcinoma": {
            "disease_name": "Kidney Renal Clear Cell Carcinoma (KIRC)",
            "cancer_site": "Renal Proximal Convoluted Tubules / Kidney",
            "subtype": "Clear Cell Renal Cell Carcinoma (ccRCC)",
            "primary_biomarkers": ["VHL", "VEGFA", "HIF1A", "PBRM1", "BAP1", "MET", "CD274"],
            "genomic_data_limitation_notice": "TCGA gene expression indicates severe VHL downregulation with CA9 and VEGFA overexpression. Treatment selection is guided by IMDC clinical risk criteria and molecular histology.",
            "first_line_guideline": "NCCN Guidelines (Kidney Cancer v1.2024): Risk stratification into favorable, intermediate, or poor risk using the IMDC criteria to select front-line IO/TKI doublet combinations.",
            "targeted_therapies": [
                {
                    "drug_name": "Belzutifan (Welireg)",
                    "treatment_class": "First-in-Class Hypoxia-Inducible Factor-2alpha (HIF-2a) Small Molecule Inhibitor",
                    "molecular_target": "Hypoxia-Inducible Factor 2 Alpha (HIF-2a / EPAS1 Transcription Factor)",
                    "target_gene": "HIF1A",
                    "target_biological_function": "Heterodimerizes with HIF-1b in the nucleus to drive transcription of pro-angiogenic, metabolic, and survival genes (VEGFA, CCND1, GLUT1).",
                    "how_it_works": "Binds the PAS-B domain of HIF-2alpha, allosterically preventing heterodimerization with HIF-1beta and halting the transcription of oncogenic hypoxia-driven target genes.",
                    "why_relevant": "Directly targets the foundational oncogenic driver resulting from biallelic VHL tumor-suppressor gene inactivation.",
                    "required_genomic_alteration": "Advanced Clear Cell RCC (following prior anti-PD-1 and VEGFR TKIs) or VHL Disease-Associated Tumors.",
                    "fda_status": "FDA Approved (Advanced ccRCC post-IO/TKI & VHL Disease)",
                    "nccn_evidence_tier": "NCCN Category 1",
                    "evidence_source": "NCCN Guidelines Kidney Cancer v1.2024; Choueiri TK et al., LITESPARK-005, N Engl J Med 2024; Jonasch E et al., LITESPARK-004, N Engl J Med 2021; 385:2036-2046.",
                    "clinical_notes": "LITESPARK-005 Phase III trial demonstrated significant progression-free survival benefit (HR 0.75) and higher objective response rate (22% vs. 4%) compared to everolimus."
                },
                {
                    "drug_name": "Cabozantinib (Cabometyx) + Nivolumab (Opdivo)",
                    "treatment_class": "Multi-Targeted Tyrosine Kinase Inhibitor (VEGFR2/MET/AXL) + Anti-PD-1 Immune Checkpoint Inhibitor",
                    "molecular_target": "VEGFR1-3, MET, AXL Receptor Tyrosine Kinases and PD-1",
                    "target_gene": "MET",
                    "target_biological_function": "Receptor tyrosine kinases mediating angiogenesis, tumor invasion, and immunosuppressive myeloid cell recruitment.",
                    "how_it_works": "Cabozantinib inhibits angiogenesis and overcomes MET/AXL-mediated resistance pathways while Nivolumab activates anti-tumor T-cell immunity.",
                    "why_relevant": "Preferred first-line standard of care across all IMDC risk groups in advanced clear cell renal cell carcinoma.",
                    "required_genomic_alteration": "Advanced / Metastatic Clear Cell Renal Cell Carcinoma.",
                    "fda_status": "FDA Approved (1st-line Advanced RCC)",
                    "nccn_evidence_tier": "NCCN Category 1 (Preferred 1st-Line)",
                    "evidence_source": "NCCN Guidelines Kidney Cancer v1.2024; Choueiri TK et al., CheckMate 9ER Final OS, Lancet Oncol 2022; 23:888-898.",
                    "clinical_notes": "CheckMate 9ER trial doubled median progression-free survival (16.6 vs. 8.3 months) and significantly prolonged overall survival compared with sunitinib."
                }
            ],
            "resistance_mechanisms": [
                "Upregulation of alternative pro-angiogenic growth factors (FGF, angiopoietins) bypassing VEGFR blockade.",
                "Epithelial-to-mesenchymal transition (EMT) driven by AXL and MET upregulation."
            ],
            "clinical_trials_criteria": [
                "NCT04736706: Phase III Triplet Regimen (Cabozantinib + Nivolumab + Ipilimumab).",
                "NCT04195750: HIF-2alpha Inhibitor (Belzutifan) in Combination with Lenvatinib."
            ],
            "nutrition_and_metabolic_guidance": {
                "caloric_support": "Renal-protective, moderate-protein Mediterranean nutrition.",
                "key_nutrients": [
                    "Adequate pure hydration (2-2.5 L/day unless restricted by fluid management)",
                    "Potassium-balanced plant vegetables",
                    "Flavonoid-rich green vegetables"
                ],
                "precautions": "Careful monitoring of sodium and phosphorus intake to avoid excess renal workload."
            }
        },
        "thyroid carcinoma": {
            "disease_name": "Thyroid Carcinoma (THCA)",
            "cancer_site": "Thyroid Follicular Epithelium / Thyroid Gland",
            "subtype": "Papillary / Follicular Differentiated Thyroid Carcinoma & Medullary Subtypes",
            "primary_biomarkers": ["TG", "TPO", "PAX8", "BRAF", "RET", "NTRK1", "RASGRP1"],
            "genomic_data_limitation_notice": "TCGA gene expression confirms thyroglobulin (TG) and PAX8 lineage. Targeted kinase inhibitor therapy for radioactive iodine (RAI)-refractory disease requires targeted sequencing for RET fusions/mutations, NTRK fusions, or BRAF V600E.",
            "first_line_guideline": "NCCN Guidelines (Thyroid Carcinoma v2.2024): Total thyroidectomy followed by risk-adapted Radioactive Iodine (RAI 131-I) ablation and TSH suppression; genomic biomarker panel for RAI-refractory recurrent or metastatic disease.",
            "targeted_therapies": [
                {
                    "drug_name": "Selpercatinib (Retevmo) / Pralsetinib (Gavreto)",
                    "treatment_class": "Highly Selective RET Kinase Small Molecule Inhibitor",
                    "molecular_target": "RET Receptor Tyrosine Kinase (Rearranged during Transfection)",
                    "target_gene": "RET",
                    "target_biological_function": "Receptor tyrosine kinase whose fusions (CCDC6-RET, NCOA4-RET in papillary thyroid) or point mutations (in medullary thyroid) cause ligand-independent constitutive kinase activation.",
                    "how_it_works": "Potently and selectively inhibits RET kinase catalytic activity with minimal off-target VEGFR2 activity, suppressing downstream MAPK and PI3K/Akt survival signaling.",
                    "why_relevant": "Preferred standard for RET fusion-positive differentiated thyroid cancer and RET-mutant medullary thyroid cancer.",
                    "required_genomic_alteration": "Confirmed RET Somatic Mutation or RET Gene Fusion (NGS / RT-PCR / FISH).",
                    "fda_status": "FDA Approved (RET-Mutant Medullary & RET Fusion-Positive Advanced Thyroid)",
                    "nccn_evidence_tier": "NCCN Category 1 (Preferred for RET+)",
                    "evidence_source": "NCCN Guidelines Thyroid Carcinoma v2.2024; Wirth LJ et al., LIBRETTO-001, N Engl J Med 2020; 383:825-835; Subbiah V et al., ARROW Trial, Lancet Diabetes Endocrinol 2021.",
                    "clinical_notes": "LIBRETTO-001 trial demonstrated 79% overall response rate in treatment-naive RET fusion-positive thyroid cancer and 69% in pretreated patients."
                },
                {
                    "drug_name": "Larotrectinib (Vitrakvi) / Entrectinib (Rozlytrek)",
                    "treatment_class": "Tissue-Agnostic Highly Selective Tropomyosin Receptor Kinase (TRK) Inhibitor",
                    "molecular_target": "TRKA, TRKB, and TRKC Neurotrophin Receptors (NTRK1, NTRK2, NTRK3 Fusions)",
                    "target_gene": "NTRK1",
                    "target_biological_function": "Neurotrophin receptors involved in neural development whose in-frame gene fusions act as potent oncogenic drivers.",
                    "how_it_works": "Competitively inhibits TRK kinase domains, switching off constitutive downstream intracellular survival cascades.",
                    "why_relevant": "High disease control rate across NTRK fusion-positive RAI-refractory thyroid carcinomas.",
                    "required_genomic_alteration": "NTRK1, NTRK2, or NTRK3 Chromosomal Gene Fusion.",
                    "fda_status": "FDA Approved (Tumor-Agnostic NTRK Fusion-Positive Solid Tumors)",
                    "nccn_evidence_tier": "NCCN Category 1",
                    "evidence_source": "NCCN Guidelines Thyroid Carcinoma v2.2024; Drilon A et al., Efficacy of Larotrectinib in TRK Fusion Cancer, N Engl J Med 2018; 378:731-739; Doebele RC et al., Lancet Oncol 2020.",
                    "clinical_notes": "Achieved overall response rate of 79% in TRK fusion-positive solid tumors with durable responses lasting beyond 35 months."
                }
            ],
            "resistance_mechanisms": [
                "RET solvent-front mutations (e.g., RET G810R/S) mediating resistance to selective RET inhibitors.",
                "Downregulation of the sodium-iodide symporter (NIS / SLC5A5) causing loss of radioactive iodine avidity."
            ],
            "clinical_trials_criteria": [
                "NCT04394013: Redifferentiation therapy with MEK/BRAF inhibitors to restore radioiodine uptake.",
                "NCT04268550: Next-generation selective RET inhibitors overcoming solvent-front resistance."
            ],
            "nutrition_and_metabolic_guidance": {
                "caloric_support": "Thyroid-harmonized, iodine-monitored balanced nutrition.",
                "key_nutrients": [
                    "Selenium (200 mcg/day, vital cofactor for iodothyronine deiodinase enzymes)",
                    "Zinc & Copper balance",
                    "Antioxidant-rich berry anthocyanins"
                ],
                "precautions": "Strict low-iodine diet strictly when preparing for diagnostic whole-body 131-I scans or therapeutic RAI ablation."
            }
        },
        "acute myeloid leukemia": {
            "disease_name": "Acute Myeloid Leukemia (LAML)",
            "cancer_site": "Bone Marrow & Peripheral Blood / Hematopoietic System",
            "subtype": "Acute Myeloid Leukemia (Subtyped by European LeukemiaNet ELN 2022 Risk Stratification)",
            "primary_biomarkers": ["MPO", "CD34", "FLT3", "NPM1", "DNMT3A", "IDH1", "IDH2", "BCL2", "KIT"],
            "genomic_data_limitation_notice": "TCGA gene expression indicates myeloid progenitor elevation (CD34, MPO). Clinical targeted therapy requires rapid molecular screening for FLT3-ITD/TKD, IDH1/2 hotspot mutations, and cytogenetic translocations.",
            "first_line_guideline": "NCCN Guidelines (Acute Myeloid Leukemia v1.2024): Immediate diagnostic workup including cytogenetics and rapid molecular panel (FLT3, IDH1, IDH2, NPM1, TP53); intensive 7+3 induction chemotherapy + targeted agent or Venetoclax + Azacitidine.",
            "targeted_therapies": [
                {
                    "drug_name": "Midostaurin (Rydapt) / Gilteritinib (Xospata) / Quizartinib (Vanflyta)",
                    "treatment_class": "FLT3 Receptor Tyrosine Kinase Small Molecule Inhibitor",
                    "molecular_target": "FMS-Like Tyrosine Kinase 3 (FLT3 Internal Tandem Duplications [ITD] & Tyrosine Kinase Domain [TKD])",
                    "target_gene": "FLT3",
                    "target_biological_function": "Cytokine receptor governing hematopoietic progenitor proliferation, survival, and differentiation.",
                    "how_it_works": "Selectively inhibits FLT3 kinase auto-phosphorylation, blocking STAT5, PI3K/Akt, and MAPK cascades and triggering leukemic blast apoptosis.",
                    "why_relevant": "Midostaurin/Quizartinib added to 7+3 induction improves overall survival in newly diagnosed FLT3-mutated AML; Gilteritinib is standard for relapsed/refractory FLT3+ AML.",
                    "required_genomic_alteration": "Confirmed FLT3-ITD or FLT3-TKD (D835) Mutation (Allelic ratio quantified).",
                    "fda_status": "FDA Approved (1st-line induction with chemo & Relapsed/Refractory monotherapy)",
                    "nccn_evidence_tier": "NCCN Category 1",
                    "evidence_source": "NCCN Guidelines AML v1.2024; Stone RM et al., RATIFY Trial, N Engl J Med 2017; 377:454-464; Perl AE et al., ADMIRAL Trial, N Engl J Med 2019; 381:1728-1740; Erba HP et al., QuANTUM-First, Lancet 2023.",
                    "clinical_notes": "RATIFY trial demonstrated a 22% reduction in the risk of death in patients receiving Midostaurin + standard chemotherapy vs. chemotherapy alone."
                },
                {
                    "drug_name": "Venetoclax (Venclexta) + Azacitidine (Vidaza)",
                    "treatment_class": "Selective B-Cell Lymphoma 2 (BCL-2) Inhibitor + DNA Methyltransferase Inhibitor (Hypomethylating Agent)",
                    "molecular_target": "B-Cell Lymphoma 2 (BCL-2) Anti-Apoptotic Protein",
                    "target_gene": "BCL2",
                    "target_biological_function": "Mitochondrial membrane protein sequestering pro-apoptotic BH3-only proteins (BIM, BAX, BAK) to block mitochondrial outer membrane permeabilization.",
                    "how_it_works": "Directly and selectively binds the hydrophobic groove of BCL-2, displacing pro-apoptotic BIM and triggering rapid Bax/Bak-mediated cytochrome c release and caspase-dependent apoptosis.",
                    "why_relevant": "Transformative first-line standard of care for adults >= 75 years or unfit for intensive induction chemotherapy.",
                    "required_genomic_alteration": "Newly Diagnosed AML in patients >= 75 years or with comorbidities precluding intensive chemotherapy.",
                    "fda_status": "FDA Approved (1st-line Unfit / Elderly AML)",
                    "nccn_evidence_tier": "NCCN Category 1 (Preferred 1st-Line for Unfit)",
                    "evidence_source": "NCCN Guidelines AML v1.2024; DiNardo CD et al., VIALE-A Trial, N Engl J Med 2020; 383:617-629.",
                    "clinical_notes": "VIALE-A Phase III trial showed significant overall survival improvement (14.7 vs. 9.6 months) and 66.4% composite complete remission rate compared to azacitidine alone."
                },
                {
                    "drug_name": "Ivosidenib (Tibsovo) / Enasidenib (Idhifa)",
                    "treatment_class": "Mutant Isocitrate Dehydrogenase 1 / 2 (IDH1 / IDH2) Allosteric Inhibitor",
                    "molecular_target": "Mutant Isocitrate Dehydrogenase Enzymes (IDH1 R132 / IDH2 R140/R172)",
                    "target_gene": "IDH1",
                    "target_biological_function": "Normal IDH converts isocitrate to a-ketoglutarate; mutant IDH acquires neomorphic activity producing the oncometabolite (R)-2-hydroxyglutarate (2-HG), causing DNA/histone hypermethylation and hematopoietic differentiation arrest.",
                    "how_it_works": "Allosterically inhibits mutant IDH1/2 homodimers, rapidly reducing intracellular 2-HG levels and releasing the epigenetic block on myeloid differentiation.",
                    "why_relevant": "Standard targeted therapy for IDH1/2-mutated AML as monotherapy or combined with azacitidine.",
                    "required_genomic_alteration": "Somatic IDH1 R132 or IDH2 R140/R172 Point Mutation.",
                    "fda_status": "FDA Approved (1st-line with Azacitidine & Relapsed/Refractory monotherapy)",
                    "nccn_evidence_tier": "NCCN Category 1",
                    "evidence_source": "NCCN Guidelines AML v1.2024; Montesinos P et al., AGILE Trial, N Engl J Med 2022; 386:1519-1531; DiNardo CD et al., N Engl J Med 2018; 378:2386-2398.",
                    "clinical_notes": "AGILE Phase III trial showed a tripling of median overall survival (24.0 vs. 7.9 months) when Ivosidenib was added to azacitidine in newly diagnosed IDH1-mutated AML."
                }
            ],
            "resistance_mechanisms": [
                "Emergence of secondary FLT3 kinase domain D835 mutations or gatekeeper F691L alterations.",
                "Upregulation of alternative anti-apoptotic proteins MCL-1 or BCL-XL conferring Venetoclax resistance."
            ],
            "clinical_trials_criteria": [
                "NCT04065399 (KURA-52): Menin-KMT2A Inhibitor (Ziftomenib) for NPM1-mutated and KMT2A-rearranged AML.",
                "NCT04251182 (AUGMENT-101): Menin Inhibitor (Revumenib) in Relapsed/Refractory AML."
            ],
            "nutrition_and_metabolic_guidance": {
                "caloric_support": "Neutropenic-safe, clean microbial food safety preparation.",
                "key_nutrients": [
                    "Thoroughly cooked foods",
                    "Adequate sterile hydration & electrolyte replenishment",
                    "Gentle digestive protein smoothies"
                ],
                "precautions": "Strictly avoid unpasteurized dairy, raw or undercooked meats/seafood, and unwashed raw produce during neutropenic phases."
            }
        }
    }

    GENERIC_PANCAN_GUIDANCE: Dict[str, Any] = {
        "disease_name": "Pan-Cancer Molecular Neoplasm",
        "cancer_site": "Tissue-Agnostic / Solid Tumor",
        "subtype": "Molecularly Profiled Advanced Solid Malignancy",
        "genomic_data_limitation_notice": "Genomic expression data represents RNA transcript abundance. Clinical targeted therapy selection requires broad-panel somatic DNA next-generation sequencing (NGS) and IHC biomarker validation.",
        "first_line_guideline": "NCCN Biomarker Compendium: Comprehensive Next-Generation Sequencing (NGS) to detect tissue-agnostic actionable alterations (MSI-H/dMMR, TMB >= 10 mut/Mb, NTRK fusions, RET fusions, BRAF V600E).",
        "targeted_therapies": [
            {
                "drug_name": "Pembrolizumab (Keytruda)",
                "treatment_class": "Tumor-Agnostic Anti-PD-1 Immune Checkpoint Inhibitor",
                "molecular_target": "Programmed Cell Death Protein 1 (PD-1 / CD279)",
                "target_gene": "CD274",
                "target_biological_function": "Immune checkpoint receptor mediating T-cell exhaustion across high-mutation solid neoplasms.",
                "how_it_works": "Blocks PD-1 interaction with PD-L1/PD-L2, releasing the brake on tumor-infiltrating lymphocytes to recognize high neoantigen burdens.",
                "why_relevant": "Tissue-agnostic FDA approval across all unresectable or metastatic solid tumors exhibiting high microsatellite instability (MSI-H), mismatch repair deficiency (dMMR), or tumor mutational burden (TMB >= 10 mut/Mb).",
                "required_genomic_alteration": "MSI-H / dMMR or High Tumor Mutational Burden (TMB >= 10 mutations/megabase).",
                "fda_status": "FDA Approved (Tumor-Agnostic MSI-H/dMMR & TMB-High)",
                "nccn_evidence_tier": "NCCN Category 1",
                "evidence_source": "NCCN Biomarkers Compendium 2024; FDA Accelerated Approval Keytruda; Marabelle A et al., KEYNOTE-158, Lancet Oncol 2020; 21:1353-1365.",
                "clinical_notes": "KEYNOTE-158 study established 29% objective response rate across 27 distinct solid tumor types in TMB-high patients."
            },
            {
                "drug_name": "Larotrectinib (Vitrakvi) / Entrectinib (Rozlytrek)",
                "treatment_class": "Tumor-Agnostic Highly Selective Pan-TRK Kinase Inhibitor",
                "molecular_target": "TRKA, TRKB, and TRKC (NTRK1/2/3 Fusions)",
                "target_gene": "NTRK1",
                "target_biological_function": "Chimeric neurotrophin receptor fusion proteins with constitutive oncogenic kinase activity.",
                "how_it_works": "Inhibits ATP binding within TRK kinase active sites, shutting down downstream oncogenic cascades.",
                "why_relevant": "First tissue-agnostic targeted kinase inhibitors approved for solid tumors harboring in-frame NTRK gene fusions without known resistance mutations.",
                "required_genomic_alteration": "Confirmed NTRK1, NTRK2, or NTRK3 In-Frame Gene Fusion (NGS / RNA-seq).",
                "fda_status": "FDA Approved (Tissue-Agnostic NTRK Fusions)",
                "nccn_evidence_tier": "NCCN Category 1",
                "evidence_source": "NCCN Guidelines Biomarkers 2024; Drilon A et al., N Engl J Med 2018; 378:731-739; Doebele RC et al., Lancet Oncol 2020; 21:271-282.",
                "clinical_notes": "Demonstrated 75-79% objective response rate across diverse pediatric and adult solid tumors harboring NTRK fusions."
            }
        ],
        "resistance_mechanisms": [
            "Secondary target kinase domain mutations (e.g., TRKA G595R solvent-front mutation) and bypass activation via MET or KRAS."
        ],
        "clinical_trials_criteria": [
            "NCT02465060 (NCI-MATCH): Molecular Analysis for Therapy Choice Master Protocol.",
            "NCT02693535 (TAPUR): Targeted Agent and Profiling Utilization Registry Study."
        ],
        "nutrition_and_metabolic_guidance": {
            "caloric_support": "Balanced, nutrient-dense Mediterranean anti-inflammatory dietary profile.",
            "key_nutrients": [
                "Sufficient lean protein (1.2-1.5 g/kg/day)",
                "Omega-3 fatty acids",
                "Diverse plant-based phytonutrients & adequate hydration"
            ],
            "precautions": "Individualized dietary consultation based on patient-specific treatment tolerance and gastrointestinal status."
        }
    }

    def get_treatment_intelligence(
        self,
        cancer_type: str,
        biomarkers: Optional[List[Dict[str, Any]]] = None,
        is_image_upload: bool = False,
        confirmed_alterations: Optional[List[str]] = None
    ) -> Dict[str, Any]:
        """
        Generates precision oncology treatment intelligence for a predicted cancer type and biomarker profile.
        
        Evaluates genomic biomarker inputs against clinical target genes, assigning explicit alteration
        classifications (CONFIRMED, SUPPORTED / INFERRED, NOT ESTABLISHED, NOT AVAILABLE) and eligibility
        statuses to strictly differentiate gene-expression findings from confirmed actionable DNA alterations.
        """
        clean_type = cancer_type.lower().strip()
        matched_kb = self.CANCER_TREATMENT_KNOWLEDGE.get(clean_type)
        
        if not matched_kb:
            for k, v in self.CANCER_TREATMENT_KNOWLEDGE.items():
                if k in clean_type or clean_type in k:
                    matched_kb = v
                    break
                    
        if not matched_kb:
            matched_kb = self.GENERIC_PANCAN_GUIDANCE.copy()
            matched_kb["disease_name"] = cancer_type.title()
            matched_kb["cancer_site"] = "Tissue-Agnostic / Unspecified Primary Site"
            matched_kb["subtype"] = f"Molecular Neoplasm ({cancer_type.title()})"

        # Clean confirmed alterations set
        confirmed_set = {str(a).strip().upper() for a in confirmed_alterations} if confirmed_alterations else set()

        # Match specific biomarkers from sample
        matched_therapies = []
        biomarker_genes = {}
        if biomarkers and not is_image_upload:
            for b in biomarkers:
                if isinstance(b, dict) and "gene" in b:
                    biomarker_genes[b["gene"].upper()] = b

        for therapy in matched_kb.get("targeted_therapies", []):
            t_gene = therapy.get("target_gene", "").upper()
            therapy_copy = dict(therapy)
            
            # Enrich with cancer context and clinical verification flag
            therapy_copy["cancer_type"] = cancer_type
            therapy_copy["cancer_site"] = matched_kb.get("cancer_site", "Unspecified Site")
            therapy_copy["clinical_verification_required"] = True
            if "source_url" not in therapy_copy:
                therapy_copy["source_url"] = "https://www.nccn.org"
            
            if is_image_upload:
                therapy_copy["biomarker_status"] = "Not available from medical image"
                therapy_copy["alteration_classification"] = "NOT AVAILABLE"
                therapy_copy["eligibility_status"] = "Genomic biomarker status not available from imaging scan. Histopathological biopsy and NGS profiling required."
                therapy_copy["sample_match"] = False
            elif t_gene and (t_gene in confirmed_set or any(t_gene in a for a in confirmed_set)):
                therapy_copy["biomarker_status"] = f"Confirmed Somatic Alteration ({t_gene})"
                therapy_copy["alteration_classification"] = "CONFIRMED"
                therapy_copy["eligibility_status"] = "Actionable alteration confirmed; meets clinical guideline criteria for biomarker-matched targeted therapy."
                therapy_copy["sample_match"] = True
            elif t_gene and t_gene in biomarker_genes:
                sample_b = biomarker_genes[t_gene]
                b_status = sample_b.get("status", "altered")
                z_val = sample_b.get("z_score_deviation")
                z_str = f" (Z-Score: {z_val:+.2f})" if isinstance(z_val, (int, float)) else ""
                
                therapy_copy["biomarker_status"] = f"Gene Expression Finding: {b_status.capitalize()}{z_str}"
                therapy_copy["alteration_classification"] = "SUPPORTED / INFERRED"
                therapy_copy["eligibility_status"] = "RNA expression finding detected; diagnostic DNA sequencing (NGS) required to establish actionable mutation eligibility."
                therapy_copy["sample_match"] = True
            else:
                therapy_copy["biomarker_status"] = f"{t_gene if t_gene else 'Biomarker'}: Not established from uploaded RNA expression"
                therapy_copy["alteration_classification"] = "NOT ESTABLISHED"
                therapy_copy["eligibility_status"] = "Insufficient genomic alteration data to establish treatment eligibility. Diagnostic NGS panel required."
                therapy_copy["sample_match"] = False
                
            matched_therapies.append(therapy_copy)

        biomarker_summary = (
            "Genomic biomarker status: Not available from this image. Molecular diagnostic testing required."
            if is_image_upload
            else "RNA expression profile analyzed. Actionable DNA mutations require diagnostic sequencing confirmation."
        )

        limitation_notice = (
            "Medical imaging identifies macroscopic radiological abnormalities and anatomical localization. It cannot detect DNA mutations or molecular receptor alterations. Molecular testing required."
            if is_image_upload
            else matched_kb.get(
                "genomic_data_limitation_notice",
                "RNA expression data does not by itself establish actionable DNA mutations. Additional molecular testing may be required."
            )
        )

        return {
            "success": True,
            "cancer_type": cancer_type,
            "disease_name": matched_kb.get("disease_name", cancer_type.title()),
            "cancer_site": matched_kb.get("cancer_site", "Tissue Site Unspecified"),
            "subtype": matched_kb.get("subtype", "Histological Subtype Unspecified"),
            "genomic_biomarker_status": biomarker_summary,
            "genomic_data_limitation_notice": limitation_notice,
            "first_line_guideline": matched_kb.get("first_line_guideline"),
            "targeted_therapies": matched_therapies,
            "resistance_mechanisms": matched_kb.get("resistance_mechanisms", []),
            "clinical_trials_criteria": matched_kb.get("clinical_trials_criteria", []),
            "nutrition_and_metabolic_guidance": matched_kb.get("nutrition_and_metabolic_guidance", {}),
            "disclaimer": "FOR INVESTIGATIONAL AND RESEARCH SUPPORT ONLY. NOT A CLINICAL PRESCRIPTION OR MEDICAL DIAGNOSIS. TREATMENT DECISIONS REQUIRE A LICENSED ONCOLOGIST AND CONFIRMATORY DIAGNOSTIC TESTING."
        }


# Singleton instance
treatment_service = TreatmentIntelligenceService()
