import 'package:flutter/foundation.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/screening_record_model.dart';
import '../../data/models/user_medicine_model.dart';
import '../../data/models/notification_item_model.dart';
import '../../data/models/reminder_model.dart';

enum ScreeningInputType {
  genomicData,
  medicalImage,
}

class ScreeningProvider extends ChangeNotifier {
  int _currentDashboardTab = 0;

  // Active modality
  ScreeningInputType _activeInputType = ScreeningInputType.genomicData;

  // 1. Genomic Upload state - initially empty
  String? _uploadedGenomicFileName;
  String? _uploadedGenomicFileSize;
  bool _hasUploadedGenomicFile = false;

  // 2. Medical Image / Scan Upload state - initially empty
  String? _uploadedMedicalImageName;
  String? _uploadedMedicalImageSize;
  bool _hasUploadedMedicalImage = false;

  // Active result state (defaults to Demo high risk lung cancer for reference)
  ScreeningRecordModel _activeScreeningResult = ScreeningRecordModel(
    id: 'DEMO-REC-01',
    title: 'Lung Cancer Screening',
    timestamp: DateTime(2026, 8, 24, 14, 30),
    riskLevel: ScreeningRiskLevel.highRisk,
    likelyCancerType: 'Lung Cancer',
    confidenceScore: 87.6,
    fileName: 'blood_biopsy_sample.csv',
  );

  // User-controlled medicines (Doctor prescribed)
  final List<UserMedicineModel> _userMedicines = [
    const UserMedicineModel(
      id: 'MED-01',
      medicineName: 'Doctor Prescribed Tablet (e.g. Vitamin D3)',
      time: '08:00 AM',
      reminderEnabled: true,
    ),
  ];

  // Smart Reminders (User-created and AI-suggested nutrition/wellness reminders)
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
      message: 'Consider including fiber-rich foods (oats, whole grains, beans, vegetables, fruits) with your meal.',
      hour: 12,
      minute: 30,
      type: ReminderType.nutrition,
      frequency: ReminderFrequency.daily,
      isEnabled: true,
      isAiSuggested: true,
    ),
    const ReminderModel(
      id: 'REM-03',
      title: 'Hydration Reminder 💧',
      message: 'Remember to drink a glass of fresh water and stay hydrated.',
      hour: 15,
      minute: 30,
      type: ReminderType.water,
      frequency: ReminderFrequency.daily,
      isEnabled: true,
      isAiSuggested: true,
    ),
    const ReminderModel(
      id: 'REM-04',
      title: 'Balanced Dinner 🍽️',
      message: 'Consider having a wholesome, balanced meal for dinner.',
      hour: 19,
      minute: 30,
      type: ReminderType.dinner,
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

  // Pre-populated demo screening records matching reference image (Screens 12 & 13)
  final List<ScreeningRecordModel> _records = [
    ScreeningRecordModel(
      id: 'REC-001',
      title: 'Lung Cancer Screening',
      timestamp: DateTime(2026, 8, 24, 14, 30),
      riskLevel: ScreeningRiskLevel.highRisk,
      likelyCancerType: 'Lung Cancer',
      confidenceScore: 87.6,
      fileName: 'blood_biopsy_sample.csv',
    ),
    ScreeningRecordModel(
      id: 'REC-002',
      title: 'Breast Cancer Screening',
      timestamp: DateTime(2026, 8, 18, 10, 15),
      riskLevel: ScreeningRiskLevel.noAbnormality,
      likelyCancerType: 'Breast Tissue Panel',
      confidenceScore: 94.2,
      fileName: 'blood_biopsy_panel.csv',
    ),
    ScreeningRecordModel(
      id: 'REC-003',
      title: 'Colon Cancer Screening',
      timestamp: DateTime(2026, 8, 5, 9, 20),
      riskLevel: ScreeningRiskLevel.lowRisk,
      likelyCancerType: 'Colorectal Marker',
      confidenceScore: 78.4,
      fileName: 'plasma_cfdna_seq.csv',
    ),
    ScreeningRecordModel(
      id: 'REC-004',
      title: 'Liver Cancer Screening',
      timestamp: DateTime(2026, 7, 20, 11, 00),
      riskLevel: ScreeningRiskLevel.noAbnormality,
      likelyCancerType: 'Hepatic Biomarker',
      confidenceScore: 96.1,
      fileName: 'methylation_markers.csv',
    ),
  ];

  // System Notifications (ALWAYS IN ENGLISH AS REQUIRED)
  final List<NotificationItemModel> _notifications = [
    const NotificationItemModel(
      id: 'N-01',
      title: 'Medicine Reminder',
      message: 'Take your prescribed medicine.',
      time: '08:00 AM',
      type: NotificationType.medicine,
      isUpcoming: true,
      isRead: false,
    ),
    const NotificationItemModel(
      id: 'N-02',
      title: 'Screening Reminder',
      message: 'Your scheduled screening reminder.',
      time: '09:00 AM',
      type: NotificationType.screeningReminder,
      isUpcoming: true,
      isRead: false,
    ),
    const NotificationItemModel(
      id: 'N-03',
      title: 'Health Reminder',
      message: 'Remember to follow your personalized health guidance.',
      time: '10:30 AM',
      type: NotificationType.healthReminder,
      isUpcoming: true,
      isRead: false,
    ),
    const NotificationItemModel(
      id: 'N-04',
      title: 'Food Guidance',
      message: 'Your personalized food guidance is ready.',
      time: '11:00 AM',
      type: NotificationType.foodGuidance,
      isUpcoming: true,
      isRead: false,
    ),
    const NotificationItemModel(
      id: 'N-05',
      title: 'Healthy Meal',
      message: "It's time for your lunch.",
      time: '01:30 PM',
      type: NotificationType.healthyMeal,
      isUpcoming: true,
      isRead: true,
    ),
    const NotificationItemModel(
      id: 'N-06',
      title: 'Water Hydration',
      message: 'Time to drink water and stay hydrated.',
      time: '03:30 PM',
      type: NotificationType.water,
      isUpcoming: true,
      isRead: true,
    ),
    const NotificationItemModel(
      id: 'N-07',
      title: 'Screening Completed',
      message: 'Your genomic screening has been completed.',
      time: 'Yesterday',
      type: NotificationType.screeningCompleted,
      isUpcoming: false,
      isRead: true,
    ),
  ];

  // Getters
  int get currentDashboardTab => _currentDashboardTab;
  ScreeningInputType get activeInputType => _activeInputType;

  // Genomic getters
  String? get uploadedGenomicFileName => _uploadedGenomicFileName;
  String? get uploadedGenomicFileSize => _uploadedGenomicFileSize;
  bool get hasUploadedGenomicFile => _hasUploadedGenomicFile;

  // Legacy/shared getters for backward compatibility
  String? get uploadedFileName => _activeInputType == ScreeningInputType.genomicData
      ? _uploadedGenomicFileName
      : _uploadedMedicalImageName;
  String? get uploadedFileSize => _activeInputType == ScreeningInputType.genomicData
      ? _uploadedGenomicFileSize
      : _uploadedMedicalImageSize;
  bool get hasUploadedFile => _activeInputType == ScreeningInputType.genomicData
      ? _hasUploadedGenomicFile
      : _hasUploadedMedicalImage;

  // Medical Image getters
  String? get uploadedMedicalImageName => _uploadedMedicalImageName;
  String? get uploadedMedicalImageSize => _uploadedMedicalImageSize;
  bool get hasUploadedMedicalImage => _hasUploadedMedicalImage;

  ScreeningRecordModel get activeScreeningResult => _activeScreeningResult;
  List<ScreeningRecordModel> get records => List.unmodifiable(_records);
  ScreeningRecordModel? get latestRecord => _records.isNotEmpty ? _records.first : null;
  List<UserMedicineModel> get userMedicines => List.unmodifiable(_userMedicines);
  List<NotificationItemModel> get notifications => List.unmodifiable(_notifications);
  NotificationItemModel get activeVoiceNotification => _activeVoiceNotification;

  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;
  bool get hasUnreadNotifications =>
      _notifications.any((n) => !n.isRead);

  void setDashboardTab(int index) {
    _currentDashboardTab = index;
    notifyListeners();
  }

  void setActiveInputType(ScreeningInputType type) {
    _activeInputType = type;
    notifyListeners();
  }

  // Notification Management Methods
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void addNotification(NotificationItemModel item) {
    _notifications.insert(0, item);
    notifyListeners();
  }

  // Genomic File methods
  void setUploadedGenomicFile({required String name, required String size}) {
    _uploadedGenomicFileName = name;
    _uploadedGenomicFileSize = size;
    _hasUploadedGenomicFile = true;
    _activeInputType = ScreeningInputType.genomicData;
    notifyListeners();
  }

  void removeUploadedGenomicFile() {
    _uploadedGenomicFileName = null;
    _uploadedGenomicFileSize = null;
    _hasUploadedGenomicFile = false;
    notifyListeners();
  }

  // Medical Image methods
  void setUploadedMedicalImage({required String name, required String size}) {
    _uploadedMedicalImageName = name;
    _uploadedMedicalImageSize = size;
    _hasUploadedMedicalImage = true;
    _activeInputType = ScreeningInputType.medicalImage;
    notifyListeners();
  }

  void removeUploadedMedicalImage() {
    _uploadedMedicalImageName = null;
    _uploadedMedicalImageSize = null;
    _hasUploadedMedicalImage = false;
    notifyListeners();
  }

  // Shared backward compatibility methods
  void setUploadedFile({required String name, required String size}) {
    setUploadedGenomicFile(name: name, size: size);
  }

  void removeUploadedFile() {
    if (_activeInputType == ScreeningInputType.genomicData) {
      removeUploadedGenomicFile();
    } else {
      removeUploadedMedicalImage();
    }
  }

  void setActiveScreeningResult(ScreeningRecordModel result) {
    _activeScreeningResult = result;
    notifyListeners();
  }

  void setActiveVoiceNotification(NotificationItemModel item) {
    _activeVoiceNotification = item;
    notifyListeners();
  }

  void addUserMedicine({
    required String medicineName,
    required String time,
    bool reminderEnabled = true,
  }) {
    final newId = 'MED-${DateTime.now().millisecondsSinceEpoch}';
    _userMedicines.add(
      UserMedicineModel(
        id: newId,
        medicineName: medicineName,
        time: time,
        reminderEnabled: reminderEnabled,
      ),
    );
    notifyListeners();
  }

  void toggleMedicineReminder(String id) {
    final index = _userMedicines.indexWhere((m) => m.id == id);
    if (index != -1) {
      final current = _userMedicines[index];
      _userMedicines[index] = current.copyWith(
        reminderEnabled: !current.reminderEnabled,
      );
      notifyListeners();
    }
  }

  List<ReminderModel> get reminders => List.unmodifiable(_reminders);

  void addReminder(ReminderModel reminder) {
    _reminders.add(reminder);
    if (reminder.isEnabled) {
      _scheduleReminderNotification(reminder);
    }
    notifyListeners();
  }

  void updateReminder(ReminderModel reminder) {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _cancelReminderNotification(_reminders[index]);
      _reminders[index] = reminder;
      if (reminder.isEnabled) {
        _scheduleReminderNotification(reminder);
      }
      notifyListeners();
    }
  }

  void toggleReminder(String id) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final current = _reminders[index];
      final updated = current.copyWith(isEnabled: !current.isEnabled);
      _reminders[index] = updated;
      if (updated.isEnabled) {
        _scheduleReminderNotification(updated);
      } else {
        _cancelReminderNotification(current);
      }
      notifyListeners();
    }
  }

  void deleteReminder(String id) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _cancelReminderNotification(_reminders[index]);
      _reminders.removeAt(index);
      notifyListeners();
    }
  }

  void _scheduleReminderNotification(ReminderModel reminder) {
    final notifId = reminder.id.hashCode.abs() % 100000;
    final notificationService = NotificationService();

    if (reminder.frequency == ReminderFrequency.daily) {
      notificationService.scheduleRepeatingDailyNotification(
        id: notifId,
        title: reminder.title,
        body: reminder.message,
        hour: reminder.hour,
        minute: reminder.minute,
      );
    } else if (reminder.frequency == ReminderFrequency.weekly) {
      notificationService.scheduleRepeatingWeeklyNotification(
        id: notifId,
        title: reminder.title,
        body: reminder.message,
        dayOfWeek: DateTime.now().weekday,
        hour: reminder.hour,
        minute: reminder.minute,
      );
    } else {
      final now = DateTime.now();
      var scheduledDate = reminder.scheduledDate ??
          DateTime(now.year, now.month, now.day, reminder.hour, reminder.minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      notificationService.scheduleNotification(
        id: notifId,
        title: reminder.title,
        body: reminder.message,
        scheduledDate: scheduledDate,
      );
    }
  }

  void _cancelReminderNotification(ReminderModel reminder) {
    final notifId = reminder.id.hashCode.abs() % 100000;
    NotificationService().cancelNotification(notifId);
  }

  void removeUserMedicine(String id) {
    _userMedicines.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}
