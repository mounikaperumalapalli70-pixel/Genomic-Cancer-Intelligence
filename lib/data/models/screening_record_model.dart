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

  const ScreeningRecordModel({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.riskLevel,
    this.likelyCancerType,
    this.confidenceScore,
    this.fileFormat = 'CSV',
    this.fileName = 'sample_data.csv',
  });
}
