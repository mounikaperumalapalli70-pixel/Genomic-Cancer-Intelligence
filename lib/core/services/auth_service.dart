import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_display_name_helper.dart';

class AuthUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;

  const AuthUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
  });

  String get resolvedDisplayName => UserDisplayNameHelper.getCurrentUserDisplayName(
        authDisplayName: displayName,
        email: email,
      );
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _authError;

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get authError => _authError;

  /// Sign In with Email & Password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      final cleanEmail = email.trim().toLowerCase();
      if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
        throw Exception('Please enter a valid email address.');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters.');
      }

      await Future.delayed(const Duration(milliseconds: 400));

      _currentUser = AuthUser(
        uid: 'USR-${cleanEmail.hashCode.abs()}',
        email: cleanEmail,
        displayName: null,
        createdAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _authError = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign Up / Register with Email, Password, and optional Display Name
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      final cleanEmail = email.trim().toLowerCase();
      if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
        throw Exception('Please enter a valid email address.');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters.');
      }

      await Future.delayed(const Duration(milliseconds: 400));

      final explicitName = displayName?.trim();

      _currentUser = AuthUser(
        uid: 'USR-${cleanEmail.hashCode.abs()}',
        email: cleanEmail,
        displayName: explicitName != null && explicitName.isNotEmpty ? explicitName : null,
        createdAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _authError = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Real Google Sign-In with Account Selection
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      // Disconnect/signOut first to ensure the real Google account chooser always appears
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        // User dismissed the account selection dialog
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final realEmail = account.email.trim();
      final realDisplayName = account.displayName?.trim();
      final realPhotoUrl = account.photoUrl;

      _currentUser = AuthUser(
        uid: account.id.isNotEmpty ? account.id : 'GOOGLE-${realEmail.hashCode.abs()}',
        email: realEmail,
        displayName: realDisplayName != null && realDisplayName.isNotEmpty ? realDisplayName : null,
        photoUrl: realPhotoUrl,
        createdAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _authError = 'Google Sign-In: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Forgot Password Request
  Future<bool> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      _authError = 'Please enter a valid email address.';
      notifyListeners();
      return false;
    }
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    _currentUser = null;
    _authError = null;
    notifyListeners();
  }
}

final authService = AuthService();
