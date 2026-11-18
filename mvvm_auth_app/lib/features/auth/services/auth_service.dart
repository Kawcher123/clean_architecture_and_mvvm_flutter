import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../core/error/app_exception.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/network_info.dart';
import '../models/user_model.dart';

/// MVVM Service: owns remote + secure-storage details for auth.
class AuthService {
  static const _authTokenKey = 'auth_token';
  static const _githubTokenKey = 'github_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';

  final http.Client client;
  final FlutterSecureStorage secureStorage;
  final NetworkInfo networkInfo;
  final String baseUrl;
  final String githubBaseUrl;

  AuthService({
    required this.client,
    required this.secureStorage,
    required this.networkInfo,
    this.baseUrl = ApiConstants.authBaseUrl,
    this.githubBaseUrl = ApiConstants.githubBaseUrl,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await _ensureOnline();

    final response = await client
        .post(
          Uri.parse('$baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(ApiConstants.connectTimeout);

    if (response.statusCode != 200) {
      throw const AuthException('Invalid email or password');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final user = UserModel.fromAuthJson(body, email: email);
    if (user.accessToken.isEmpty) {
      throw const AuthException('Invalid login response');
    }

    await _persistSession(user);
    return user;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _ensureOnline();

    final response = await client
        .post(
          Uri.parse('$baseUrl/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(ApiConstants.connectTimeout);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw const AuthException('Registration failed');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final token = (body['token'] ?? body['accessToken'] ?? '').toString();
    final user = UserModel(
      id: _asInt(body['id']) != 0 ? _asInt(body['id']) : email.hashCode.abs(),
      name: name,
      email: email,
      accessToken: token.isNotEmpty ? token : 'demo_token_${email.hashCode}',
    );

    await _persistSession(user);
    return user;
  }

  Future<UserModel> loginWithGithubToken(String token) async {
    await _ensureOnline();

    final response = await client
        .get(
          Uri.parse('$githubBaseUrl/user'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
          },
        )
        .timeout(ApiConstants.connectTimeout);

    if (response.statusCode == 401) {
      throw const UnauthorizedException('Invalid GitHub token');
    }
    if (response.statusCode != 200) {
      throw const AuthException('Failed to authenticate with GitHub');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final user = UserModel.fromGithubJson(body, accessToken: token);
    await secureStorage.write(key: _authTokenKey, value: user.accessToken);
    await secureStorage.write(key: _githubTokenKey, value: token);
    await _saveUserProfile(user);
    return user;
  }

  Future<UserModel?> getCurrentUser() async {
    final token = await secureStorage.read(key: _authTokenKey);
    if (token == null) return null;

    final cached = await _readCachedUser(token);

    if (!await networkInfo.isConnected) {
      return cached;
    }

    try {
      final response = await client
          .get(
            Uri.parse('$githubBaseUrl/user'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/vnd.github+json',
              'X-GitHub-Api-Version': '2022-11-28',
            },
          )
          .timeout(ApiConstants.connectTimeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final user = UserModel.fromGithubJson(body, accessToken: token);
        await _saveUserProfile(user);
        return user;
      }
    } catch (_) {
      if (cached != null) return cached;
    }

    if (cached != null) return cached;
    await logout();
    return null;
  }

  Future<void> forgotPassword(String email) async {
    await _ensureOnline();

    final response = await client
        .post(
          Uri.parse('$baseUrl/forgot-password'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        )
        .timeout(ApiConstants.connectTimeout);

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204 ||
        response.statusCode == 404) {
      return;
    }

    throw const ServerException('Failed to send password reset email');
  }

  Future<void> logout() async {
    await secureStorage.delete(key: _authTokenKey);
    await secureStorage.delete(key: _githubTokenKey);
    await secureStorage.delete(key: _userIdKey);
    await secureStorage.delete(key: _userNameKey);
    await secureStorage.delete(key: _userEmailKey);
  }

  Future<String?> getGithubToken() async {
    return secureStorage.read(key: _githubTokenKey);
  }

  Future<String?> getAuthToken() async {
    return secureStorage.read(key: _authTokenKey);
  }

  Future<void> _persistSession(UserModel user) async {
    await secureStorage.write(key: _authTokenKey, value: user.accessToken);
    await _saveUserProfile(user);
  }

  Future<void> _saveUserProfile(UserModel user) async {
    await secureStorage.write(key: _userIdKey, value: user.id.toString());
    await secureStorage.write(key: _userNameKey, value: user.name);
    await secureStorage.write(key: _userEmailKey, value: user.email);
  }

  Future<UserModel?> _readCachedUser(String token) async {
    final id = await secureStorage.read(key: _userIdKey);
    final name = await secureStorage.read(key: _userNameKey);
    final email = await secureStorage.read(key: _userEmailKey);
    if (id == null || name == null || email == null) return null;

    return UserModel(
      id: int.tryParse(id) ?? 0,
      name: name,
      email: email,
      accessToken: token,
    );
  }

  Future<void> _ensureOnline() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException();
    }
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
