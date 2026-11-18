import '../../../../core/error/app_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_datasource.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<User>> getUsers({bool forceRefresh = false}) async {
    final online = await networkInfo.isConnected;

    if (online) {
      try {
        final remote = await remoteDataSource.getUsers();
        await localDataSource.cacheUsers(remote);
        return remote;
      } catch (e) {
        final cached = await localDataSource.getCachedUsers();
        if (cached.isNotEmpty) return cached;
        rethrow;
      }
    }

    final cached = await localDataSource.getCachedUsers();
    if (cached.isNotEmpty) return cached;

    throw const NetworkException(
      'No internet connection and no cached users available',
    );
  }
}
