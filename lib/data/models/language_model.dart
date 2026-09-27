class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final String? script;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    this.script,
  });

  static const List<LanguageModel> supportedLanguages = [
    LanguageModel(code: 'en', name: 'English', nativeName: 'English'),
    LanguageModel(code: 'hi', name: 'Hindi', nativeName: 'हिंदी'),
    LanguageModel(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
    LanguageModel(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
    LanguageModel(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    LanguageModel(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം'),
    LanguageModel(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
    LanguageModel(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી'),
    LanguageModel(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
    LanguageModel(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ'),
    LanguageModel(code: 'or', name: 'Odia', nativeName: 'ଓଡ଼ିଆ'),
    LanguageModel(code: 'as', name: 'Assamese', nativeName: 'অসমীয়া'),
    LanguageModel(code: 'ur', name: 'Urdu', nativeName: 'اردو'),
  ];
}
