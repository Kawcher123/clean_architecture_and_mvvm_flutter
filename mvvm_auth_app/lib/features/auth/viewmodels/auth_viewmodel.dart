import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// ViewModel: UI state + calls into AuthService (no use-case layer).
class AuthViewModel extends ChangeNotifier {
  final AuthService authService;

  AuthViewModel(this.authService);

  AuthStatus status = AuthStatus.initial;
  UserModel? user;
  String? errorMessage;

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  Future<void> checkAuth() async {
    status = AuthStatus.loading;
    notifyListeners();

    try {
      user = await authService.getCurrentUser();
      status =
          user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      user = await authService.login(email: email, password: password);
      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      user = await authService.register(
        name: name,
        email: email,
        password: password,
      );
      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGithub(String token) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      user = await authService.loginWithGithubToken(token.trim());
      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendForgotPassword(String email) async {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      await authService.forgotPassword(email);
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    status = AuthStatus.loading;
    notifyListeners();

    try {
      await authService.logout();
      user = null;
      errorMessage = null;
      status = AuthStatus.unauthenticated;
    } catch (e) {
      errorMessage = e.toString();
      status = AuthStatus.error;
    }

    notifyListeners();
  }
}
