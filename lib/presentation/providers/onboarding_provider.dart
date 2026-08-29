import 'package:flutter/foundation.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/models/language_model.dart';

class OnboardingProvider extends ChangeNotifier {
  UserProfileModel _profile = const UserProfileModel(
    languageCode: 'en',
  );

  String _selectedLanguageCode = 'en';
  Gender? _selectedGender = Gender.male;

  UserProfileModel get profile => _profile;
  String get selectedLanguageCode => _selectedLanguageCode;
  Gender? get selectedGender => _selectedGender;

  LanguageModel get selectedLanguage {
    return LanguageModel.supportedLanguages.firstWhere(
      (lang) => lang.code == _selectedLanguageCode,
      orElse: () => LanguageModel.supportedLanguages.first,
    );
  }

  void selectLanguage(String code) {
    _selectedLanguageCode = code;
    _profile = _profile.copyWith(languageCode: code);
    notifyListeners();
  }

  void selectGender(Gender gender) {
    _selectedGender = gender;
    _profile = _profile.copyWith(gender: gender);
    notifyListeners();
  }

  void updateBasicInfo({
    required String name,
    required int? age,
    required double? heightCm,
    required double? weightKg,
    required String? bloodGroup,
  }) {
    _profile = _profile.copyWith(
      name: name,
      age: age,
      heightCm: heightCm,
      weightKg: weightKg,
      bloodGroup: bloodGroup,
    );
    notifyListeners();
  }
}
