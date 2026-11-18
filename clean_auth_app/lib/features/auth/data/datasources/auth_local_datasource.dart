import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure token storage using platform keychain / Keystore.
class AuthLocalDataSource {
  static const _authTokenKey = 'auth_token';
  static const _githubTokenKey = 'github_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';

  final FlutterSecureStorage secureStorage;

  AuthLocalDataSource({required this.secureStorage});

  Future<void> saveToken(String token) async {
    await secureStorage.write(key: _authTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return secureStorage.read(key: _authTokenKey);
  }

  Future<void> saveGithubToken(String token) async {
    await secureStorage.write(key: _githubTokenKey, value: token);
  }

  Future<String?> getGithubToken() async {
    return secureStorage.read(key: _githubTokenKey);
  }

  Future<void> saveUser({
    required int id,
    required String name,
    required String email,
  }) async {
    await secureStorage.write(key: _userIdKey, value: id.toString());
    await secureStorage.write(key: _userNameKey, value: name);
    await secureStorage.write(key: _userEmailKey, value: email);
  }

  Future<Map<String, String>?> getCachedUser() async {
    final id = await secureStorage.read(key: _userIdKey);
    final name = await secureStorage.read(key: _userNameKey);
    final email = await secureStorage.read(key: _userEmailKey);

    if (id == null || name == null || email == null) return null;

    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  Future<void> clear() async {
    await secureStorage.delete(key: _authTokenKey);
    await secureStorage.delete(key: _githubTokenKey);
    await secureStorage.delete(key: _userIdKey);
    await secureStorage.delete(key: _userNameKey);
    await secureStorage.delete(key: _userEmailKey);
  }
}
