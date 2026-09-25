import 'package:flutter/foundation.dart';
import '../../core/services/api_service.dart';
import '../../data/models/screening_record_model.dart';
import '../../data/models/user_medicine_model.dart';
import '../../data/models/notification_item_model.dart';
import '../../data/models/reminder_model.dart';
import '../../data/models/genomic_analysis_models.dart';

enum ScreeningInputType {
  genomicData,
  medicalImage,
}

class ScreeningProvider extends ChangeNotifier {
  int _currentDashboardTab = 0;

  // Active modality
  ScreeningInputType _activeInputType = ScreeningInputType.genomicData;

  // Curated Samples
  List<CuratedSampleModel> _curatedSamples = [];
  CuratedSampleModel? _selectedCuratedSample;
  bool _isLoadingSamples = false;

  // 1. Genomic Upload state
  String? _uploadedGenomicFileName;
  String? _uploadedGenomicFileSize;
  Uint8List? _uploadedGenomicFileBytes;
  Map<String, double>? _uploadedGenomicExpression;
  bool _hasUploadedGenomicFile = false;

  // 2. Medical Image / Scan Upload state
  String? _uploadedMedicalImageName;
  String? _uploadedMedicalImageSize;
  Uint8List? _uploadedMedicalImageBytes;
  bool _hasUploadedMedicalImage = false;

  // Analysis Progress & Stage
  bool _isAnalyzing = false;
  int _analysisProgress = 0;
  String _analysisStage = 'Initializing analysis pipeline...';
  String? _analysisError;

  // Active Result Models
  GenomicPredictionResult? _activeGenomicResult;
  TreatmentIntelligence? _activeTreatmentIntelligence;
  QuantumExperimentResult? _activeQuantumResult;
  MedicalImageResult? _activeImageResult;

  // Default active record
  ScreeningRecordModel _activeScreeningResult = ScreeningRecordModel(
    id: 'TCGA-REC-01',
    title: 'Lung Adenocarcinoma Screening',
    timestamp: DateTime.now(),
    riskLevel: ScreeningRiskLevel.highRisk,
    likelyCancerType: 'lung adenocarcinoma',
    confidenceScore: 94.8,
    fileName: 'tcga_lung_sample.csv',
  );

  // User-controlled medicines
  final List<UserMedicineModel> _userMedicines = [
    const UserMedicineModel(
      id: 'MED-01',
      medicineName: 'Doctor Prescribed Tablet (e.g. Vitamin D3)',
      time: '08:00 AM',
      reminderEnabled: true,
    ),
  ];

  // Smart Reminders
  final List<ReminderModel> _reminders = [
    const ReminderModel(
      id: 'REM-01',
      title: 'Medicine Reminder 💊',
      message: 'Take your prescribed medicine.',
      hour: 8,
      minute: 0,
      type: ReminderType.medicine,
      frequency: ReminderFrequency.daily,
      isEnabled: true,
    ),
    const ReminderModel(
      id: 'REM-02',
      title: 'Fiber-rich Nutrition 🥗',
      message: 'Consider including fiber-rich foods with your meal.',
      hour: 12,
      minute: 30,
      type: ReminderType.nutrition,
      frequency: ReminderFrequency.daily,
      isEnabled: true,
      isAiSuggested: true,
    ),
  ];

  // Active voice alert state
  NotificationItemModel _activeVoiceNotification = const NotificationItemModel(
    id: 'NOTIF-01',
    title: 'Medicine Reminder',
    message: "It's time to take your medicine.",
    time: '08:00 AM',
    type: NotificationType.medicine,
    isUpcoming: true,
  );

  // Historical screening records
  final List<ScreeningRecordModel> _records = [
    ScreeningRecordModel(
      id: 'REC-001',
      title: 'Lung Adenocarcinoma Screening',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      riskLevel: ScreeningRiskLevel.highRisk,
      likelyCancerType: 'lung adenocarcinoma',
      confidenceScore: 94.8,
      fileName: 'blood_biopsy_sample.csv',
    ),
    ScreeningRecordModel(
      id: 'REC-002',
      title: 'Breast Invasive Carcinoma Panel',
      timestamp: DateTime.now().subtract(const Duration(days: 12)),
      riskLevel: ScreeningRiskLevel.highRisk,
      likelyCancerType: 'breast invasive carcinoma',
      confidenceScore: 96.2,
      fileName: 'tissue_rna_seq.csv',
    ),
    ScreeningRecordModel(
      id: 'REC-003',
      title: 'Pan-Cancer Routine Panel',
      timestamp: DateTime.now().subtract(const Duration(days: 28)),
      riskLevel: ScreeningRiskLevel.noAbnormality,
      likelyCancerType: 'Baseline Normal Profile',
      confidenceScore: 98.1,
      fileName: 'plasma_cfdna_panel.csv',
    ),
  ];

  // Notifications
  final List<NotificationItemModel> _notifications = [
    const NotificationItemModel(
      id: 'N-01',
      title: 'Medicine Reminder',
      message: "It's time to take your morning medication.",
      time: '08:00 AM',
      type: NotificationType.medicine,
    ),
  ];

  ScreeningProvider() {
    loadCuratedSamples();
  }

  // --- Getters ---
  int get currentDashboardTab => _currentDashboardTab;
  ScreeningInputType get activeInputType => _activeInputType;
  List<CuratedSampleModel> get curatedSamples => _curatedSamples;
  CuratedSampleModel? get selectedCuratedSample => _selectedCuratedSample;
  bool get isLoadingSamples => _isLoadingSamples;

  String? get uploadedGenomicFileName => _uploadedGenomicFileName;
  String? get uploadedGenomicFileSize => _uploadedGenomicFileSize;
  Uint8List? get uploadedGenomicFileBytes => _uploadedGenomicFileBytes;
  Map<String, double>? get uploadedGenomicExpression => _uploadedGenomicExpression;
  bool get hasUploadedGenomicFile => _hasUploadedGenomicFile;

  String? get uploadedMedicalImageName => _uploadedMedicalImageName;
  String? get uploadedMedicalImageSize => _uploadedMedicalImageSize;
  Uint8List? get uploadedMedicalImageBytes => _uploadedMedicalImageBytes;
  bool get hasUploadedMedicalImage => _hasUploadedMedicalImage;

  bool get isAnalyzing => _isAnalyzing;
  int get analysisProgress => _analysisProgress;
  String get analysisStage => _analysisStage;
  String? get analysisError => _analysisError;

  GenomicPredictionResult? get activeGenomicResult => _activeGenomicResult;
  TreatmentIntelligence? get activeTreatmentIntelligence => _activeTreatmentIntelligence;
  QuantumExperimentResult? get activeQuantumResult => _activeQuantumResult;
  MedicalImageResult? get activeImageResult => _activeImageResult;
  ScreeningRecordModel get activeScreeningResult => _activeScreeningResult;

  List<UserMedicineModel> get userMedicines => _userMedicines;
  List<ReminderModel> get reminders => _reminders;
  List<ScreeningRecordModel> get records => _records;
  List<NotificationItemModel> get notifications => _notifications;
  NotificationItemModel get activeVoiceNotification => _activeVoiceNotification;

  // --- Actions ---

  void setDashboardTab(int index) {
    _currentDashboardTab = index;
    notifyListeners();
  }

  void setActiveInputType(ScreeningInputType type) {
    _activeInputType = type;
    notifyListeners();
  }

  Future<void> loadCuratedSamples() async {
    _isLoadingSamples = true;
    notifyListeners();
    try {
      _curatedSamples = await apiService.fetchCuratedSamples();
    } catch (e) {
      debugPrint('Error loading curated samples: $e');
    } finally {
      _isLoadingSamples = false;
      notifyListeners();
    }
  }

  void selectCuratedSample(CuratedSampleModel sample) {
    _selectedCuratedSample = sample;
    _uploadedGenomicFileName = sample.name;
    _uploadedGenomicFileSize = '${sample.biomarkerHighlights.length} Biomarkers';
    _uploadedGenomicExpression = Map<String, double>.from(sample.expressionData);
    _uploadedGenomicFileBytes = null;
    _hasUploadedGenomicFile = true;
    notifyListeners();
  }

  void setUploadedGenomicFile({
    required String name,
    required String size,
    Uint8List? bytes,
    Map<String, double>? expressionData,
  }) {
    _uploadedGenomicFileName = name;
    _uploadedGenomicFileSize = size;
    _uploadedGenomicFileBytes = bytes;
    _uploadedGenomicExpression = expressionData;
    _selectedCuratedSample = null;
    _hasUploadedGenomicFile = true;
    notifyListeners();
  }

  void clearUploadedGenomicFile() {
    _uploadedGenomicFileName = null;
    _uploadedGenomicFileSize = null;
    _uploadedGenomicFileBytes = null;
    _uploadedGenomicExpression = null;
    _selectedCuratedSample = null;
    _hasUploadedGenomicFile = false;
    notifyListeners();
  }

  void setUploadedMedicalImage({
    required String name,
    required String size,
    Uint8List? bytes,
  }) {
    _uploadedMedicalImageName = name;
    _uploadedMedicalImageSize = size;
    _uploadedMedicalImageBytes = bytes;
    _hasUploadedMedicalImage = true;
    notifyListeners();
  }

  void clearUploadedMedicalImage() {
    _uploadedMedicalImageName = null;
    _uploadedMedicalImageSize = null;
    _uploadedMedicalImageBytes = null;
    _hasUploadedMedicalImage = false;
    notifyListeners();
  }

  // --- Real End-to-End Analysis Pipeline Execution ---

  Future<bool> executeGenomicAnalysis() async {
    _isAnalyzing = true;
    _analysisProgress = 15;
    _analysisStage = 'Stage 1/4: Ingesting & Normalizing Gene Expression Matrix...';
    _analysisError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      _analysisProgress = 40;
      _analysisStage = 'Stage 2/4: Selecting Top 2,000 TCGA Biomarker Genes...';
      notifyListeners();

      GenomicPredictionResult genResult;
      if (_uploadedGenomicFileBytes != null && _uploadedGenomicFileName != null) {
        genResult = await apiService.analyzeGenomicFile(
          filename: _uploadedGenomicFileName!,
          fileBytes: _uploadedGenomicFileBytes!,
        );
      } else if (_uploadedGenomicExpression != null && _uploadedGenomicExpression!.isNotEmpty) {
        genResult = await apiService.analyzeGenomicExpression(
          expressionData: _uploadedGenomicExpression!,
        );
      } else {
        // Use default curated Lung sample expression
        final samples = _curatedSamples.isNotEmpty
            ? _curatedSamples
            : await apiService.fetchCuratedSamples();
        final defaultSample = samples.firstWhere(
          (s) => s.expressionData.isNotEmpty,
          orElse: () => samples.first,
        );
        final expr = defaultSample.expressionData.isNotEmpty
            ? defaultSample.expressionData
            : (await apiService.fetchCuratedSampleDetail(defaultSample.id)).expressionData;
        genResult = await apiService.analyzeGenomicExpression(
          expressionData: expr,
        );
      }

      await Future.delayed(const Duration(milliseconds: 500));
      _analysisProgress = 70;
      _analysisStage = 'Stage 3/4: Multiclass Calibrated Model Inference...';
      notifyListeners();

      // Fetch Treatment Intelligence & Quantum Simulation in parallel
      final treatmentFuture = apiService.fetchTreatmentIntelligence(
        cancerType: genResult.cancerType,
        biomarkers: genResult.topContributingBiomarkers,
      );

      final quantumFuture = apiService.runQuantumExperiment(
        expressionData: _uploadedGenomicExpression ??
            {for (var b in genResult.topContributingBiomarkers) b.gene: b.expressionValue ?? 10.0},
        cancerTypeHypothesis: genResult.cancerType,
      );

      final results = await Future.wait([treatmentFuture, quantumFuture]);
      final treatmentResult = results[0] as TreatmentIntelligence;
      final quantumResult = results[1] as QuantumExperimentResult;

      await Future.delayed(const Duration(milliseconds: 400));
      _analysisProgress = 100;
      _analysisStage = 'Stage 4/4: Cancer Intelligence Synthesis Complete!';
      notifyListeners();

      _activeGenomicResult = genResult;
      _activeTreatmentIntelligence = treatmentResult;
      _activeQuantumResult = quantumResult;
      _activeImageResult = null;

      final riskLevel = genResult.probability > 0.5
          ? ScreeningRiskLevel.highRisk
          : ScreeningRiskLevel.lowRisk;

      _activeScreeningResult = ScreeningRecordModel(
        id: 'TCGA-REC-${DateTime.now().millisecondsSinceEpoch % 10000}',
        title: '${genResult.cancerType.toUpperCase()} Screening',
        timestamp: DateTime.now(),
        riskLevel: riskLevel,
        likelyCancerType: genResult.cancerType,
        confidenceScore: double.parse((genResult.probability * 100).toStringAsFixed(1)),
        fileName: _uploadedGenomicFileName ?? 'curated_sample.csv',
        genomicResult: genResult,
        treatmentIntelligence: treatmentResult,
        quantumResult: quantumResult,
      );

      _records.insert(0, _activeScreeningResult);
      _isAnalyzing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _analysisError = e.toString();
      _isAnalyzing = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> executeMedicalImageAnalysis() async {
    _isAnalyzing = true;
    _analysisProgress = 20;
    _analysisStage = 'Stage 1/3: Reading Medical Scan & Preprocessing Tensors...';
    _analysisError = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      _analysisProgress = 60;
      _analysisStage = 'Stage 2/3: Neural Lesion Detection & Grad-CAM Heatmap Generation...';
      notifyListeners();

      MedicalImageResult imgResult;
      if (_uploadedMedicalImageBytes != null && _uploadedMedicalImageName != null) {
        imgResult = await apiService.analyzeMedicalImage(
          filename: _uploadedMedicalImageName!,
          imageBytes: _uploadedMedicalImageBytes!,
        );
      } else {
        imgResult = await apiService.analyzeMedicalImage(
          filename: 'chest_ct_scan.png',
          imageBytes: Uint8List(0),
        );
      }

      await Future.delayed(const Duration(milliseconds: 400));
      _analysisProgress = 100;
      _analysisStage = 'Stage 3/3: Diagnostic Vision Analysis Complete!';
      notifyListeners();

      _activeImageResult = imgResult;
      _activeGenomicResult = null;
      _activeTreatmentIntelligence = imgResult.treatmentIntelligence;
      _activeQuantumResult = null;

      _activeScreeningResult = ScreeningRecordModel(
        id: 'SCAN-REC-${DateTime.now().millisecondsSinceEpoch % 10000}',
        title: '${imgResult.scanModality} Analysis',
        timestamp: DateTime.now(),
        riskLevel: (imgResult.canDetermineReliably && imgResult.confidenceScore >= 0.65)
            ? ScreeningRiskLevel.highRisk
            : ScreeningRiskLevel.lowRisk,
        likelyCancerType: imgResult.canDetermineReliably ? (imgResult.detectedCancerType ?? imgResult.primaryFinding) : null,
        confidenceScore: imgResult.confidencePct,
        fileName: _uploadedMedicalImageName ?? 'medical_scan.png',
        imageResult: imgResult,
        treatmentIntelligence: imgResult.treatmentIntelligence,
      );

      _records.insert(0, _activeScreeningResult);
      _isAnalyzing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _analysisError = e.toString();
      _isAnalyzing = false;
      notifyListeners();
      return false;
    }
  }

  // Active Screening Result Setter
  void setActiveScreeningResult(ScreeningRecordModel record) {
    _activeScreeningResult = record;
    if (record.genomicResult != null) {
      _activeGenomicResult = record.genomicResult;
      _activeTreatmentIntelligence = record.treatmentIntelligence;
      _activeQuantumResult = record.quantumResult;
      _activeImageResult = null;
      _activeInputType = ScreeningInputType.genomicData;
    } else if (record.imageResult != null) {
      _activeImageResult = record.imageResult;
      _activeGenomicResult = null;
      _activeTreatmentIntelligence = record.treatmentIntelligence ?? record.imageResult?.treatmentIntelligence;
      _activeQuantumResult = null;
      _activeInputType = ScreeningInputType.medicalImage;
    }
    notifyListeners();
  }

  // Medicines, Reminders, and Voice Methods
  void addMedicine({
    required String name,
    required String time,
    required bool reminderEnabled,
  }) {
    final id = 'MED-${DateTime.now().millisecondsSinceEpoch % 10000}';
    _userMedicines.add(UserMedicineModel(
      id: id,
      medicineName: name,
      time: time,
      reminderEnabled: reminderEnabled,
    ));
    notifyListeners();
  }

  void addUserMedicine({
    String? name,
    String? medicineName,
    required String time,
    bool reminderEnabled = true,
  }) {
    final medName = medicineName ?? name ?? 'Prescribed Medicine';
    addMedicine(name: medName, time: time, reminderEnabled: reminderEnabled);
  }

  void removeMedicine(String id) {
    _userMedicines.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void removeUserMedicine(String id) {
    removeMedicine(id);
  }

  void toggleMedicineReminder(String id) {
    final index = _userMedicines.indexWhere((m) => m.id == id);
    if (index != -1) {
      final m = _userMedicines[index];
      _userMedicines[index] = m.copyWith(reminderEnabled: !m.reminderEnabled);
      notifyListeners();
    }
  }

  void addReminder(ReminderModel reminder) {
    _reminders.add(reminder);
    notifyListeners();
  }

  void updateReminder(ReminderModel reminder) {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
      notifyListeners();
    }
  }

  void toggleReminder(String id) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final r = _reminders[index];
      _reminders[index] = r.copyWith(isEnabled: !r.isEnabled);
      notifyListeners();
    }
  }

  void deleteReminder(String id) {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void addNotification(NotificationItemModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final item = _notifications[index];
      _notifications[index] = item.copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  bool get hasUnreadNotifications => _notifications.any((n) => !n.isRead);

  void triggerVoiceNotification(NotificationItemModel item) {
    _activeVoiceNotification = item;
    notifyListeners();
  }

  void setActiveVoiceNotification(NotificationItemModel item) {
    _activeVoiceNotification = item;
    notifyListeners();
  }
}
