import '../entities/github_repo.dart';
import '../repositories/github_repo_repository.dart';

class GetGithubRepos {
  final GithubRepoRepository repository;

  GetGithubRepos(this.repository);

  Future<List<GithubRepo>> call({bool forceRefresh = false}) {
    return repository.getRepos(forceRefresh: forceRefresh);
  }
}
