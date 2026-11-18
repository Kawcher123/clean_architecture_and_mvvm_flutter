import 'package:flutter/material.dart';

import '../../domain/entities/github_repo.dart';
import '../../domain/usecases/get_github_repos.dart';

class GithubRepoProvider extends ChangeNotifier {
  final GetGithubRepos getGithubRepos;

  GithubRepoProvider(this.getGithubRepos);

  List<GithubRepo> repos = [];
  bool isLoading = false;
  bool isFromCache = false;
  String? error;

  Future<void> fetchRepos({bool forceRefresh = false}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      repos = await getGithubRepos(forceRefresh: forceRefresh);
      isFromCache = false;
      error = null;
    } catch (e) {
      final message = e.toString();
      error = message;
      if (message.toLowerCase().contains('internet') ||
          message.toLowerCase().contains('network') ||
          message.toLowerCase().contains('cached')) {
        isFromCache = repos.isNotEmpty;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
