import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/network_info.dart';
import '../../auth/services/auth_service.dart';
import '../models/github_repo_model.dart';

class GithubRepoService {
  final http.Client client;
  final AppDatabase appDatabase;
  final NetworkInfo networkInfo;
  final AuthService authService;
  final String baseUrl;

  GithubRepoService({
    required this.client,
    required this.appDatabase,
    required this.networkInfo,
    required this.authService,
    this.baseUrl = ApiConstants.githubBaseUrl,
  });

  Future<List<GithubRepoModel>> getRepos({bool forceRefresh = false}) async {
    final online = await networkInfo.isConnected;
    final token =
        await authService.getGithubToken() ?? await authService.getAuthToken();

    if (online && token != null && token.isNotEmpty) {
      try {
        final remote = await _fetchRemote(token);
        await _cacheRepos(remote);
        return remote;
      } on UnauthorizedException {
        rethrow;
      } catch (_) {
        final cached = await _getCachedRepos();
        if (cached.isNotEmpty) return cached;
        rethrow;
      }
    }

    final cached = await _getCachedRepos();
    if (cached.isNotEmpty) return cached;

    if (token == null || token.isEmpty) {
      throw const AuthException(
        'No GitHub token found. Login with a GitHub Personal Access Token.',
      );
    }

    throw const NetworkException(
      'No internet connection and no cached repositories available',
    );
  }

  Future<List<GithubRepoModel>> _fetchRemote(String token) async {
    final response = await client
        .get(
          Uri.parse('$baseUrl/user/repos?per_page=100&sort=updated'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
          },
        )
        .timeout(ApiConstants.connectTimeout);

    if (response.statusCode == 401) {
      throw const UnauthorizedException('GitHub token is invalid or expired');
    }
    if (response.statusCode != 200) {
      throw ServerException(
        'Failed to load GitHub repositories (${response.statusCode})',
      );
    }

    final list = List<Map<String, dynamic>>.from(
      jsonDecode(response.body) as List,
    );
    return list.map(GithubRepoModel.fromJson).toList();
  }

  Future<void> _cacheRepos(List<GithubRepoModel> repos) async {
    final db = await appDatabase.database;
    final batch = db.batch();
    batch.delete('github_repos');
    for (final repo in repos) {
      batch.insert(
        'github_repos',
        repo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<GithubRepoModel>> _getCachedRepos() async {
    final db = await appDatabase.database;
    final maps = await db.query('github_repos', orderBy: 'updated_at DESC');
    return maps.map(GithubRepoModel.fromMap).toList();
  }
}
