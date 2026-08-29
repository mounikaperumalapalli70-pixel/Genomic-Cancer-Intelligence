class LanguageModel {
  final String code;
  final String name;
  final String nativeName;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  static const List<LanguageModel> supportedLanguages = [
    LanguageModel(code: 'en', name: 'English', nativeName: 'English'),
    LanguageModel(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
    LanguageModel(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
    LanguageModel(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    LanguageModel(code: 'hi', name: 'Hindi', nativeName: 'हिंदी'),
  ];
}
