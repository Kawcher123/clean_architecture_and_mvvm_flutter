import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> register({
    required String name,
    required String email,
    required String password,
  });

  Future<User> loginWithGithubToken(String token);

  Future<User?> getCurrentUser();

  Future<void> logout();

  Future<void> forgotPassword(String email);

  Future<String?> getGithubToken();
}
