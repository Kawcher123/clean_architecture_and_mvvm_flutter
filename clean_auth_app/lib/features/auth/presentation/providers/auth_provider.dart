import 'package:flutter/material.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/login_with_github_token.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final Login loginUseCase;
  final Register registerUseCase;
  final Logout logoutUseCase;
  final GetCurrentUser getCurrentUserUseCase;
  final ForgotPassword forgotPasswordUseCase;
  final LoginWithGithubToken loginWithGithubTokenUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.forgotPasswordUseCase,
    required this.loginWithGithubTokenUseCase,
  });

  AuthStatus status = AuthStatus.initial;
  User? user;
  String? errorMessage;

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  Future<void> checkAuth() async {
    status = AuthStatus.loading;
    notifyListeners();

    try {
      user = await getCurrentUserUseCase();
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
      user = await loginUseCase(email: email, password: password);
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
      user = await registerUseCase(
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
      user = await loginWithGithubTokenUseCase(token.trim());
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
      await forgotPasswordUseCase(email);
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
      await logoutUseCase();
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
