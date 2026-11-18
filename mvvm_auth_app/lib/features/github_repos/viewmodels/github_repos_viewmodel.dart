import 'package:flutter/material.dart';

import '../models/github_repo_model.dart';
import '../services/github_repo_service.dart';

class GithubReposViewModel extends ChangeNotifier {
  final GithubRepoService githubRepoService;

  GithubReposViewModel(this.githubRepoService);

  List<GithubRepoModel> repos = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchRepos({bool forceRefresh = false}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      repos = await githubRepoService.getRepos(forceRefresh: forceRefresh);
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
