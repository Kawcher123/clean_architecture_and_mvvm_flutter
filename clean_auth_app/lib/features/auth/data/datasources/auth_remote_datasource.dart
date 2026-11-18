import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_constants.dart';
import '../models/auth_model.dart';

class AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String githubBaseUrl;

  AuthRemoteDataSource({
    required this.client,
    this.baseUrl = ApiConstants.authBaseUrl,
    this.githubBaseUrl = ApiConstants.githubBaseUrl,
  });

  Future<AuthModel> login(String email, String password) async {
    final response = await client
        .post(
          Uri.parse('$baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        )
        .timeout(ApiConstants.connectTimeout);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      // reqres returns { "token": "..." } — synthesize a user for the demo API
      final token = (body['token'] ?? body['accessToken'] ?? '').toString();
      if (token.isEmpty) {
        throw const AuthException('Invalid login response');
      }

      if (body['user'] != null) {
        return AuthModel.fromJson(body);
      }

      return AuthModel(
        id: email.hashCode.abs(),
        name: email.split('@').first,
        email: email,
        accessToken: token,
      );
    }

    throw const AuthException('Invalid email or password');
  }

  Future<AuthModel> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await client
        .post(
          Uri.parse('$baseUrl/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        )
        .timeout(ApiConstants.connectTimeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final token = (body['token'] ?? body['accessToken'] ?? '').toString();

      if (body['user'] != null) {
        return AuthModel.fromJson(body);
      }

      return AuthModel(
        id: _asInt(body['id']) != 0 ? _asInt(body['id']) : email.hashCode.abs(),
        name: name,
        email: email,
        accessToken: token.isNotEmpty ? token : 'demo_token_${email.hashCode}',
      );
    }

    throw const AuthException('Registration failed');
  }

  Future<AuthModel> loginWithGithubToken(String token) async {
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
      return AuthModel.fromGithubJson(body, accessToken: token);
    }

    if (response.statusCode == 401) {
      throw const UnauthorizedException('Invalid GitHub token');
    }

    throw const AuthException('Failed to authenticate with GitHub');
  }

  Future<AuthModel> getCurrentUser(String token) async {
    // Prefer GitHub identity when token looks like a PAT session
    final githubResponse = await client
        .get(
          Uri.parse('$githubBaseUrl/user'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
          },
        )
        .timeout(ApiConstants.connectTimeout);

    if (githubResponse.statusCode == 200) {
      final body = jsonDecode(githubResponse.body) as Map<String, dynamic>;
      return AuthModel.fromGithubJson(body, accessToken: token);
    }

    throw const UnauthorizedException();
  }

  Future<void> forgotPassword(String email) async {
    // Demo endpoint — many backends accept POST /auth/forgot-password
    final response = await client
        .post(
          Uri.parse('$baseUrl/forgot-password'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        )
        .timeout(ApiConstants.connectTimeout);

    // Treat 404 as soft-success for demo APIs that lack this route
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204 ||
        response.statusCode == 404) {
      return;
    }

    throw const ServerException('Failed to send password reset email');
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
