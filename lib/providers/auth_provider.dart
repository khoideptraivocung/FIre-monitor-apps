import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  
  User? _user;
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _errorMessage;
  
  String _savedEmail = '';
  String _savedPassword = '';

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;
  String? get errorMessage => _errorMessage;
  String get savedEmail => _savedEmail;
  String get savedPassword => _savedPassword;

  AuthProvider() {
    _authService.authStateChanges.listen((User? newUser) {
      _user = newUser;
      notifyListeners();
    });
    _loadPreferences();
  }

  /// Load Remember Me configurations
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool('remember_me') ?? false;
    if (_rememberMe) {
      _savedEmail = prefs.getString('saved_email') ?? '';
      _savedPassword = prefs.getString('saved_password') ?? '';
    }
    notifyListeners();
  }

  /// Toggle and save Remember Me setting
  Future<void> setRememberMe(bool value) async {
    _rememberMe = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', value);
    if (!value) {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      _savedEmail = '';
      _savedPassword = '';
    }
    notifyListeners();
  }

  /// Sign in user (with automatic sign-up fallback if account doesn't exist)
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      try {
        await _authService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        // Fallback: If user is not found, automatically register them!
        // We catch both 'user-not-found' and 'invalid-credential' (returned by newer Firebase versions to prevent enumeration)
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          try {
            await _authService.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
          } catch (_) {
            // Re-throw the original sign-in error if registration fails (e.g. weak password)
            rethrow;
          }
        } else {
          rethrow;
        }
      }

      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', email);
        await prefs.setString('saved_password', password);
        _savedEmail = email;
        _savedPassword = password;
      }
      
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Authentication failed.';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _setLoading(false);
      return false;
    }
  }

  /// Log out user
  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _setLoading(false);
  }

  /// Password reset request
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Password reset failed.';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
