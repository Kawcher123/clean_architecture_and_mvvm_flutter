import '../../../../core/error/app_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/github_repo.dart';
import '../../domain/repositories/github_repo_repository.dart';
import '../datasources/github_repo_local_datasource.dart';
import '../datasources/github_repo_remote_datasource.dart';

class GithubRepoRepositoryImpl implements GithubRepoRepository {
  final GithubRepoRemoteDataSource remoteDataSource;
  final GithubRepoLocalDataSource localDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final NetworkInfo networkInfo;

  GithubRepoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authLocalDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<GithubRepo>> getRepos({bool forceRefresh = false}) async {
    final online = await networkInfo.isConnected;
    final token = await authLocalDataSource.getGithubToken() ??
        await authLocalDataSource.getToken();

    if (online && token != null && token.isNotEmpty) {
      try {
        final remote = await remoteDataSource.getRepos(token);
        await localDataSource.cacheRepos(remote);
        return remote;
      } on UnauthorizedException {
        rethrow;
      } catch (_) {
        final cached = await localDataSource.getCachedRepos();
        if (cached.isNotEmpty) return cached;
        rethrow;
      }
    }

    final cached = await localDataSource.getCachedRepos();
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
}
