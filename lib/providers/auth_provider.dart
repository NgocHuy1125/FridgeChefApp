// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:fridge_chef_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? _user;
  User? get user => _user;
  void setUser(User? newUser) {
    if (_user != newUser) {
      _user = newUser;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      setUser(response.user);
      return true;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await supabase.auth.signUp(email: email, password: password);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
    } catch (e) {
      _setLoading(false);
      throw Exception('Could not sign in with Google.');
    }
  }

  Future<void> signInWithFacebook() async {
    _setLoading(true);
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
    } catch (e) {
      _setLoading(false);
      throw Exception('Could not sign in with Facebook.');
    }
  }
}
