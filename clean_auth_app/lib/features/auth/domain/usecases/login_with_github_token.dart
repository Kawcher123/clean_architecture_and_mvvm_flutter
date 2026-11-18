import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginWithGithubToken {
  final AuthRepository repository;

  LoginWithGithubToken(this.repository);

  Future<User> call(String token) {
    return repository.loginWithGithubToken(token);
  }
}
