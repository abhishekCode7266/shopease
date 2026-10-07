import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  bool _isDeveloperMode = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;

  AuthProvider() {
    _initAuthListener();
  }

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isDeveloperMode => _isDeveloperMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _initAuthListener() {
    _authSubscription = _authService.authStateChanges.listen((firebaseUser) async {
      if (_isDeveloperMode) return;
      if (firebaseUser != null) {
        _user = await _authService.getUserProfile(firebaseUser.uid) ??
            UserModel(
              uid: firebaseUser.uid,
              name: firebaseUser.displayName ?? 'Shopper',
              email: firebaseUser.email ?? '',
              createdAt: DateTime.now(),
            );
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  // Developer Bypass Mode (Exclusive access for Abhishek / Developer)
  void activateDeveloperBypass({
    String name = 'Abhishek (Lead Developer)',
    String email = 'abhishekCode7266@shopease.app',
    String uid = 'dev_abhishek_7266',
  }) {
    _isDeveloperMode = true;
    _user = UserModel(
      uid: uid,
      name: name,
      email: email,
      createdAt: DateTime.now(),
      phoneNumber: '+91 9876543210',
      address: 'Developer Suite, Test Lab, New Delhi - 110001',
    );
    _errorMessage = null;
    notifyListeners();
  }

  void exitDeveloperMode() {
    _isDeveloperMode = false;
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sign Up
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign In
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _user = await _authService.signIn(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      if (_isDeveloperMode) {
        _isDeveloperMode = false;
        _user = null;
      } else {
        await _authService.signOut();
        _user = null;
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Send Password Reset
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.sendPasswordReset(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update Profile Name
  Future<bool> updateProfileName(String newName) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.updateProfileName(newName);
      if (_user != null) {
        _user = _user!.copyWith(name: newName);
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
