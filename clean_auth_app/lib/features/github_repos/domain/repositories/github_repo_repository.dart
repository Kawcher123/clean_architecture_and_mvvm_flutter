import '../entities/github_repo.dart';

abstract class GithubRepoRepository {
  Future<List<GithubRepo>> getRepos({bool forceRefresh = false});
}
