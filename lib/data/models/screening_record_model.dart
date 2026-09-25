import 'genomic_analysis_models.dart';

enum ScreeningRiskLevel {
  highRisk,
  lowRisk,
  noAbnormality,
}

class ScreeningRecordModel {
  final String id;
  final String title;
  final DateTime timestamp;
  final ScreeningRiskLevel riskLevel;
  final String? likelyCancerType;
  final double? confidenceScore;
  final String fileFormat;
  final String fileName;
  final GenomicPredictionResult? genomicResult;
  final TreatmentIntelligence? treatmentIntelligence;
  final QuantumExperimentResult? quantumResult;
  final MedicalImageResult? imageResult;

  const ScreeningRecordModel({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.riskLevel,
    this.likelyCancerType,
    this.confidenceScore,
    this.fileFormat = 'CSV',
    this.fileName = 'sample_data.csv',
    this.genomicResult,
    this.treatmentIntelligence,
    this.quantumResult,
    this.imageResult,
  });
}
