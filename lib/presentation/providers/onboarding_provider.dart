import 'package:flutter/foundation.dart';
import '../../core/services/user_display_name_helper.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/models/language_model.dart';

class OnboardingProvider extends ChangeNotifier {
  UserProfileModel _profile = const UserProfileModel(
    languageCode: 'en',
  );

  String _selectedLanguageCode = 'en';
  Gender? _selectedGender;
  String? _authEmail;
  String? _authDisplayName;
  String? _authPhotoUrl;
  bool _isAuthenticated = false;
  bool _isOnboardingCompleted = false;

  UserProfileModel get profile => _profile;
  String get selectedLanguageCode => _selectedLanguageCode;
  Gender? get selectedGender => _selectedGender;
  String? get authEmail => _authEmail;
  String? get authDisplayName => _authDisplayName;
  String? get authPhotoUrl => _authPhotoUrl;
  bool get isAuthenticated => _isAuthenticated;
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  /// Centralized Display Name:
  /// 1. Saved name from Basic Information / UserProfileModel
  /// 2. Authenticated Google/Firebase displayName
  /// 3. Email-derived fallback
  String get displayName => UserDisplayNameHelper.getCurrentUserDisplayName(
        profileName: _profile.name,
        authDisplayName: _authDisplayName,
        email: _authEmail,
      );

  /// Centralized Dynamic Time-based Greeting:
  String get dynamicGreeting => UserDisplayNameHelper.getPersonalizedGreeting(
        profileName: _profile.name,
        authDisplayName: _authDisplayName,
        email: _authEmail,
      );

  /// Salutation only (e.g. "Good Morning", "Good Afternoon")
  String get timeSalutation => UserDisplayNameHelper.getTimeBasedGreeting();

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
    required String? name,
    required int? age,
    required double? heightCm,
    required double? weightKg,
    required String? bloodGroup,
  }) {
    final cleanName = name?.trim();
    _profile = _profile.copyWith(
      name: cleanName != null && cleanName.isNotEmpty ? cleanName : null,
      age: age,
      heightCm: heightCm,
      weightKg: weightKg,
      bloodGroup: bloodGroup,
    );
    notifyListeners();
  }

  void setAuthUser({
    required String email,
    String? displayName,
    String? photoUrl,
  }) {
    _authEmail = email;
    _authDisplayName = displayName;
    _authPhotoUrl = photoUrl;
    _isAuthenticated = true;
    _isOnboardingCompleted = true;
    if (displayName != null && displayName.trim().isNotEmpty) {
      _profile = _profile.copyWith(name: displayName.trim());
    }
    notifyListeners();
  }

  void completeOnboarding() {
    _isOnboardingCompleted = true;
    notifyListeners();
  }

  /// Full reset on sign out to prevent cross-account data leaks
  void clearAuth() {
    _authEmail = null;
    _authDisplayName = null;
    _authPhotoUrl = null;
    _isAuthenticated = false;
    _isOnboardingCompleted = false;
    _selectedGender = null;
    _profile = const UserProfileModel(
      languageCode: 'en',
    );
    notifyListeners();
  }
}
