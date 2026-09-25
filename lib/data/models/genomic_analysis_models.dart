class ClassProbability {
  final String cancerType;
  final double probability;

  const ClassProbability({
    required this.cancerType,
    required this.probability,
  });

  double get percentage => (probability * 100);

  factory ClassProbability.fromJson(Map<String, dynamic> json) {
    return ClassProbability(
      cancerType: json['cancer_type']?.toString() ?? 'Unknown',
      probability: (json['probability'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'cancer_type': cancerType,
        'probability': probability,
      };
}

class BiomarkerAttribution {
  final String gene;
  final double? expressionValue;
  final double referenceMedian;
  final double zScoreDeviation;
  final String status;

  const BiomarkerAttribution({
    required this.gene,
    this.expressionValue,
    required this.referenceMedian,
    required this.zScoreDeviation,
    required this.status,
  });

  factory BiomarkerAttribution.fromJson(Map<String, dynamic> json) {
    return BiomarkerAttribution(
      gene: json['gene']?.toString() ?? 'Unknown',
      expressionValue: (json['expression_value'] as num?)?.toDouble(),
      referenceMedian: (json['reference_median'] as num?)?.toDouble() ?? 0.0,
      zScoreDeviation: (json['z_score_deviation'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'baseline',
    );
  }

  Map<String, dynamic> toJson() => {
        'gene': gene,
        'expression_value': expressionValue,
        'reference_median': referenceMedian,
        'z_score_deviation': zScoreDeviation,
        'status': status,
      };
}

class InputSummary {
  final int totalGenesProvided;
  final int selectedBiomarkersMatched;
  final int totalModelFeatures;
  final double biomarkerCoveragePct;

  const InputSummary({
    required this.totalGenesProvided,
    required this.selectedBiomarkersMatched,
    required this.totalModelFeatures,
    required this.biomarkerCoveragePct,
  });

  factory InputSummary.fromJson(Map<String, dynamic> json) {
    return InputSummary(
      totalGenesProvided: (json['total_genes_provided'] as num?)?.toInt() ?? 0,
      selectedBiomarkersMatched: (json['selected_biomarkers_matched'] as num?)?.toInt() ?? 0,
      totalModelFeatures: (json['total_model_features'] as num?)?.toInt() ?? 2000,
      biomarkerCoveragePct: (json['biomarker_coverage_pct'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class GenomicPredictionResult {
  final String cancerType;
  final double probability;
  final String modelVersion;
  final String modelName;
  final List<ClassProbability> topClasses;
  final Map<String, double> classProbabilities;
  final List<BiomarkerAttribution> topContributingBiomarkers;
  final InputSummary inputSummary;
  final String disclaimer;

  const GenomicPredictionResult({
    required this.cancerType,
    required this.probability,
    required this.modelVersion,
    required this.modelName,
    required this.topClasses,
    required this.classProbabilities,
    required this.topContributingBiomarkers,
    required this.inputSummary,
    required this.disclaimer,
  });

  double get confidencePct => (probability * 100);

  factory GenomicPredictionResult.fromJson(Map<String, dynamic> json) {
    final pred = json['prediction'] as Map<String, dynamic>? ?? {};
    
    final topList = (json['top_classes'] as List<dynamic>? ?? [])
        .map((e) => ClassProbability.fromJson(e as Map<String, dynamic>))
        .toList();

    final classProbs = <String, double>{};
    if (json['class_probabilities'] is Map) {
      (json['class_probabilities'] as Map).forEach((k, v) {
        classProbs[k.toString()] = (v as num?)?.toDouble() ?? 0.0;
      });
    }

    final bioList = (json['top_contributing_biomarkers'] as List<dynamic>? ?? [])
        .map((e) => BiomarkerAttribution.fromJson(e as Map<String, dynamic>))
        .toList();

    return GenomicPredictionResult(
      cancerType: pred['cancer_type']?.toString() ?? 'Unknown Cancer Type',
      probability: (pred['probability'] as num?)?.toDouble() ?? 0.0,
      modelVersion: pred['model_version']?.toString() ?? '1.0.0',
      modelName: pred['model_name']?.toString() ?? 'TCGA Genomic Classifier',
      topClasses: topList,
      classProbabilities: classProbs,
      topContributingBiomarkers: bioList,
      inputSummary: InputSummary.fromJson(json['input_summary'] as Map<String, dynamic>? ?? {}),
      disclaimer: json['disclaimer']?.toString() ??
          'FOR RESEARCH USE ONLY. NOT FOR CLINICAL DIAGNOSTIC DECISIONS.',
    );
  }
}

class TargetedTherapy {
  final String drugName;
  final String treatmentClass;
  final String cancerType;
  final String cancerSite;
  final String targetGene;
  final String molecularTarget;
  final String targetBiologicalFunction;
  final String howItWorks;
  final String whyRelevant;
  final String requiredGenomicAlteration;
  final String fdaStatus;
  final String nccnEvidenceTier;
  final String evidenceSource;
  final String sourceUrl;
  final String clinicalNotes;
  final bool sampleMatch;
  final String? biomarkerStatus;
  final String alterationClassification;
  final String eligibilityStatus;
  final bool clinicalVerificationRequired;

  const TargetedTherapy({
    required this.drugName,
    required this.treatmentClass,
    this.cancerType = '',
    this.cancerSite = '',
    required this.targetGene,
    required this.molecularTarget,
    required this.targetBiologicalFunction,
    required this.howItWorks,
    required this.whyRelevant,
    required this.requiredGenomicAlteration,
    required this.fdaStatus,
    required this.nccnEvidenceTier,
    required this.evidenceSource,
    this.sourceUrl = 'https://www.nccn.org',
    required this.clinicalNotes,
    this.sampleMatch = false,
    this.biomarkerStatus,
    this.alterationClassification = 'Not Established from Available Genomic Data',
    this.eligibilityStatus = 'Insufficient genomic alteration data to establish treatment eligibility.',
    this.clinicalVerificationRequired = true,
  });

  factory TargetedTherapy.fromJson(Map<String, dynamic> json) {
    return TargetedTherapy(
      drugName: json['drug_name']?.toString() ?? 'Targeted Agent',
      treatmentClass: json['treatment_class']?.toString() ?? 'Targeted Therapy',
      cancerType: json['cancer_type']?.toString() ?? '',
      cancerSite: json['cancer_site']?.toString() ?? '',
      targetGene: json['target_gene']?.toString() ?? '',
      molecularTarget: json['molecular_target']?.toString() ?? json['target_gene']?.toString() ?? 'Molecular Target',
      targetBiologicalFunction: json['target_biological_function']?.toString() ??
          'Cellular signaling kinase regulating proliferation, survival, and cell-cycle progression.',
      howItWorks: json['how_it_works']?.toString() ?? json['mechanism']?.toString() ?? 'Inhibits target oncogenic pathway.',
      whyRelevant: json['why_relevant']?.toString() ??
          'Evidence-based association with this tumor type and target alteration profile.',
      requiredGenomicAlteration: json['required_genomic_alteration']?.toString() ??
          'Target somatic mutation, gene amplification, or expression biomarker.',
      fdaStatus: json['fda_status']?.toString() ?? 'FDA Approved',
      nccnEvidenceTier: json['nccn_evidence_tier']?.toString() ?? 'Category 1',
      evidenceSource: json['evidence_source']?.toString() ?? 'NCCN Guidelines & FDA Package Insert',
      sourceUrl: json['source_url']?.toString() ?? 'https://www.nccn.org',
      clinicalNotes: json['clinical_notes']?.toString() ?? '',
      sampleMatch: json['sample_match'] == true,
      biomarkerStatus: json['biomarker_status']?.toString(),
      alterationClassification: json['alteration_classification']?.toString() ??
          (json['sample_match'] == true
              ? 'SUPPORTED / INFERRED'
              : 'NOT ESTABLISHED'),
      eligibilityStatus: json['eligibility_status']?.toString() ??
          (json['sample_match'] == true
              ? 'RNA expression finding detected; diagnostic DNA sequencing (NGS) required to establish actionable mutation eligibility.'
              : 'Insufficient genomic alteration data to establish treatment eligibility. Diagnostic NGS panel required.'),
      clinicalVerificationRequired: json['clinical_verification_required'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'drug_name': drugName,
        'treatment_class': treatmentClass,
        'cancer_type': cancerType,
        'cancer_site': cancerSite,
        'target_gene': targetGene,
        'molecular_target': molecularTarget,
        'target_biological_function': targetBiologicalFunction,
        'how_it_works': howItWorks,
        'why_relevant': whyRelevant,
        'required_genomic_alteration': requiredGenomicAlteration,
        'fda_status': fdaStatus,
        'nccn_evidence_tier': nccnEvidenceTier,
        'evidence_source': evidenceSource,
        'source_url': sourceUrl,
        'clinical_notes': clinicalNotes,
        'sample_match': sampleMatch,
        'biomarker_status': biomarkerStatus,
        'alteration_classification': alterationClassification,
        'eligibility_status': eligibilityStatus,
        'clinical_verification_required': clinicalVerificationRequired,
      };
}

class TreatmentIntelligence {
  final String cancerType;
  final String diseaseName;
  final String cancerSite;
  final String subtype;
  final String genomicBiomarkerStatus;
  final String genomicDataLimitationNotice;
  final String firstLineGuideline;
  final List<TargetedTherapy> targetedTherapies;
  final List<String> resistanceMechanisms;
  final List<String> clinicalTrialsCriteria;
  final Map<String, dynamic> nutritionGuidance;
  final String disclaimer;

  const TreatmentIntelligence({
    required this.cancerType,
    required this.diseaseName,
    this.cancerSite = 'Primary Anatomical Site',
    this.subtype = 'Histological Subtype',
    this.genomicBiomarkerStatus = 'RNA expression profile analyzed. DNA mutation testing required for clinical confirmation.',
    this.genomicDataLimitationNotice =
        'RNA expression data does not by itself establish actionable DNA mutations. Additional molecular testing may be required.',
    required this.firstLineGuideline,
    required this.targetedTherapies,
    required this.resistanceMechanisms,
    required this.clinicalTrialsCriteria,
    required this.nutritionGuidance,
    required this.disclaimer,
  });

  factory TreatmentIntelligence.fromJson(Map<String, dynamic> json) {
    final therapies = (json['targeted_therapies'] as List<dynamic>? ?? [])
        .map((e) => TargetedTherapy.fromJson(e as Map<String, dynamic>))
        .toList();

    final resList = (json['resistance_mechanisms'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    final trialList = (json['clinical_trials_criteria'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    final nutrition = json['nutrition_and_metabolic_guidance'] as Map<String, dynamic>? ?? {};

    return TreatmentIntelligence(
      cancerType: json['cancer_type']?.toString() ?? '',
      diseaseName: json['disease_name']?.toString() ?? '',
      cancerSite: json['cancer_site']?.toString() ?? 'Primary Anatomical Site',
      subtype: json['subtype']?.toString() ?? 'Histological Subtype',
      genomicBiomarkerStatus: json['genomic_biomarker_status']?.toString() ??
          'RNA expression profile analyzed. DNA mutation testing required for clinical confirmation.',
      genomicDataLimitationNotice: json['genomic_data_limitation_notice']?.toString() ??
          'RNA expression data does not by itself establish actionable DNA mutations. Additional molecular testing may be required.',
      firstLineGuideline: json['first_line_guideline']?.toString() ?? '',
      targetedTherapies: therapies,
      resistanceMechanisms: resList,
      clinicalTrialsCriteria: trialList,
      nutritionGuidance: nutrition,
      disclaimer: json['disclaimer']?.toString() ??
          'FOR RESEARCH AND INVESTIGATIONAL USE ONLY. TREATMENT DECISIONS REQUIRE A LICENSED ONCOLOGIST.',
    );
  }
}

class QuantumExperimentResult {
  final String experimentId;
  final String quantumFramework;
  final int qubitCount;
  final String featureMap;
  final String entanglement;
  final int circuitDepth;
  final Map<String, int> gateCounts;
  final int hilbertSpaceDimension;
  final Map<String, double> quantumKernelFidelity;
  final Map<String, double> classicalRbfKernel;
  final String topQuantumAlignedClass;
  final double quantumStateFidelity;
  final double quantumAdvantageMetric;
  final String qasmRepresentation;
  final String disclaimer;

  const QuantumExperimentResult({
    required this.experimentId,
    required this.quantumFramework,
    required this.qubitCount,
    required this.featureMap,
    required this.entanglement,
    required this.circuitDepth,
    required this.gateCounts,
    required this.hilbertSpaceDimension,
    required this.quantumKernelFidelity,
    required this.classicalRbfKernel,
    required this.topQuantumAlignedClass,
    required this.quantumStateFidelity,
    required this.quantumAdvantageMetric,
    required this.qasmRepresentation,
    required this.disclaimer,
  });

  factory QuantumExperimentResult.fromJson(Map<String, dynamic> json) {
    final circuit = json['circuit_specifications'] as Map<String, dynamic>? ?? {};
    final gates = <String, int>{};
    if (circuit['gate_counts'] is Map) {
      (circuit['gate_counts'] as Map).forEach((k, v) {
        gates[k.toString()] = (v as num?)?.toInt() ?? 0;
      });
    }

    final qKernel = <String, double>{};
    if (json['quantum_kernel_fidelity'] is Map) {
      (json['quantum_kernel_fidelity'] as Map).forEach((k, v) {
        qKernel[k.toString()] = (v as num?)?.toDouble() ?? 0.0;
      });
    }

    final cKernel = <String, double>{};
    if (json['classical_rbf_kernel'] is Map) {
      (json['classical_rbf_kernel'] as Map).forEach((k, v) {
        cKernel[k.toString()] = (v as num?)?.toDouble() ?? 0.0;
      });
    }

    final summary = json['quantum_analysis_summary'] as Map<String, dynamic>? ?? {};

    return QuantumExperimentResult(
      experimentId: json['experiment_id']?.toString() ?? 'QML-EXP-0001',
      quantumFramework: json['quantum_framework']?.toString() ?? 'Qiskit',
      qubitCount: (circuit['qubit_count'] as num?)?.toInt() ?? 4,
      featureMap: circuit['feature_map']?.toString() ?? 'ZZFeatureMap',
      entanglement: circuit['entanglement_topology']?.toString() ?? 'linear',
      circuitDepth: (circuit['circuit_depth'] as num?)?.toInt() ?? 10,
      gateCounts: gates,
      hilbertSpaceDimension: (circuit['hilbert_space_dimension'] as num?)?.toInt() ?? 16,
      quantumKernelFidelity: qKernel,
      classicalRbfKernel: cKernel,
      topQuantumAlignedClass: summary['top_quantum_aligned_class']?.toString() ?? 'lung adenocarcinoma',
      quantumStateFidelity: (summary['quantum_state_fidelity'] as num?)?.toDouble() ?? 0.85,
      quantumAdvantageMetric: (summary['quantum_advantage_metric'] as num?)?.toDouble() ?? 0.12,
      qasmRepresentation: json['qasm_representation']?.toString() ?? '',
      disclaimer: json['disclaimer']?.toString() ?? 'EXPERIMENTAL RESEARCH STUDY.',
    );
  }
}

class CuratedSampleModel {
  final String id;
  final String name;
  final String cancerType;
  final String description;
  final String tissueOrigin;
  final String sampleType;
  final List<String> biomarkerHighlights;
  final Map<String, double> expressionData;

  const CuratedSampleModel({
    required this.id,
    required this.name,
    required this.cancerType,
    required this.description,
    required this.tissueOrigin,
    required this.sampleType,
    required this.biomarkerHighlights,
    this.expressionData = const {},
  });

  factory CuratedSampleModel.fromJson(Map<String, dynamic> json) {
    final highlights = (json['biomarker_highlights'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    final expr = <String, double>{};
    if (json['expression_data'] is Map) {
      (json['expression_data'] as Map).forEach((k, v) {
        expr[k.toString()] = (v as num?)?.toDouble() ?? 0.0;
      });
    }

    return CuratedSampleModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      cancerType: json['cancer_type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      tissueOrigin: json['tissue_origin']?.toString() ?? '',
      sampleType: json['sample_type']?.toString() ?? '',
      biomarkerHighlights: highlights,
      expressionData: expr,
    );
  }
}

class MedicalImageResult {
  final String filename;
  final String scanModality;
  final String? detectedCancerType;
  final String primaryFinding;
  final double confidenceScore;
  final double confidencePct;
  final String riskTier;
  final String lesionDescription;
  final bool canDetermineReliably;
  final Map<String, double> classProbabilities;
  final String? gradcamDataUri;
  final TreatmentIntelligence? treatmentIntelligence;
  final String modelName;
  final String modelVersion;
  final String disclaimer;

  const MedicalImageResult({
    required this.filename,
    required this.scanModality,
    this.detectedCancerType,
    required this.primaryFinding,
    required this.confidenceScore,
    required this.confidencePct,
    required this.riskTier,
    required this.lesionDescription,
    this.canDetermineReliably = true,
    required this.classProbabilities,
    this.gradcamDataUri,
    this.treatmentIntelligence,
    this.modelName = 'Biomedical Multi-Modality Vision & Saliency Classifier',
    this.modelVersion = '1.0.0-biovision',
    required this.disclaimer,
  });

  factory MedicalImageResult.fromJson(Map<String, dynamic> json) {
    final cls = json['classification'] as Map<String, dynamic>? ?? {};
    final probs = <String, double>{};
    if (json['class_probabilities'] is Map) {
      (json['class_probabilities'] as Map).forEach((k, v) {
        probs[k.toString()] = (v as num?)?.toDouble() ?? 0.0;
      });
    }

    final gradcam = json['gradcam_saliency_heatmap'] as Map<String, dynamic>? ?? {};
    final meta = json['model_metadata'] as Map<String, dynamic>? ?? {};
    
    TreatmentIntelligence? treatment;
    if (json['treatment_intelligence'] is Map) {
      try {
        treatment = TreatmentIntelligence.fromJson(json['treatment_intelligence'] as Map<String, dynamic>);
      } catch (_) {}
    }

    final canDetermine = json['can_determine_reliably'] != false;
    final detectedType = json['detected_cancer_type']?.toString();

    return MedicalImageResult(
      filename: json['filename']?.toString() ?? 'scan.png',
      scanModality: json['scan_modality']?.toString() ?? 'Medical Scan',
      detectedCancerType: detectedType,
      primaryFinding: cls['primary_finding']?.toString() ?? (canDetermine ? 'Focal Abnormality' : 'Unable to determine reliably from this image.'),
      confidenceScore: (cls['confidence_score'] as num?)?.toDouble() ?? 0.85,
      confidencePct: (cls['confidence_pct'] as num?)?.toDouble() ?? 85.0,
      riskTier: cls['risk_tier']?.toString() ?? 'High Suspicion',
      lesionDescription: cls['lesion_description']?.toString() ?? '',
      canDetermineReliably: canDetermine,
      classProbabilities: probs,
      gradcamDataUri: gradcam['data_uri']?.toString(),
      treatmentIntelligence: treatment,
      modelName: meta['model_name']?.toString() ?? 'Biomedical Multi-Modality Vision & Saliency Classifier',
      modelVersion: meta['model_version']?.toString() ?? '1.0.0-biovision',
      disclaimer: json['disclaimer']?.toString() ?? 'INVESTIGATIONAL RESEARCH USE ONLY. DOES NOT CONSTITUTE A RADIOLOGICAL OR HISTOPATHOLOGICAL CLINICAL DIAGNOSIS.',
    );
  }
}

