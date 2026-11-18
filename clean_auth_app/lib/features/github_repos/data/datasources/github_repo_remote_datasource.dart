import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_constants.dart';
import '../models/github_repo_model.dart';

class GithubRepoRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  GithubRepoRemoteDataSource({
    required this.client,
    this.baseUrl = ApiConstants.githubBaseUrl,
  });

  Future<List<GithubRepoModel>> getRepos(String token) async {
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

    if (response.statusCode == 200) {
      final list = List<Map<String, dynamic>>.from(
        jsonDecode(response.body) as List,
      );
      return list.map(GithubRepoModel.fromJson).toList();
    }

    if (response.statusCode == 401) {
      throw const UnauthorizedException('GitHub token is invalid or expired');
    }

    throw ServerException('Failed to load GitHub repositories (${response.statusCode})');
  }
}
