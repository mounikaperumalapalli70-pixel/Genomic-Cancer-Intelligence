class AppRoutes {
  AppRoutes._();

  // Screen 01 to 06
  static const String splash = '/';
  static const String languageSelection = '/language-selection';
  static const String genderSelection = '/gender-selection';
  static const String basicInfo = '/basic-info';
  static const String howItWorks = '/how-it-works';
  static const String dashboard = '/dashboard';

  // Screen 07 to 16
  static const String cancerScreening = '/cancer-screening';
  static const String genomicDataUpload = '/genomic-data-upload';
  static const String medicalImageUpload = '/medical-image-upload';
  static const String aiAnalysis = '/ai-analysis';
  static const String highRiskResult = '/high-risk-result';
  static const String noHighRiskResult = '/no-high-risk-result';
  static const String reports = '/reports';
  static const String screeningHistory = '/screening-history';
  static const String notifications = '/notifications';
  static const String foodGuidance = '/food-guidance';
  static const String voiceAssistant = '/voice-assistant';

  // Backwards compatibility aliases
  static const String resultDetected = highRiskResult;
  static const String resultClear = noHighRiskResult;
  static const String addReminder = foodGuidance;
  static const String voiceAlert = voiceAssistant;
}
