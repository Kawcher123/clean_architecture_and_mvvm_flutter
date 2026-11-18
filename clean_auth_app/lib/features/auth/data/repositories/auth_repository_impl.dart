import '../../../../core/error/app_exception.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    await _ensureOnline();

    final result = await remoteDataSource.login(email, password);
    await _persistSession(result);
    return result;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _ensureOnline();

    final result = await remoteDataSource.register(name, email, password);
    await _persistSession(result);
    return result;
  }

  @override
  Future<User> loginWithGithubToken(String token) async {
    await _ensureOnline();

    final result = await remoteDataSource.loginWithGithubToken(token);
    await localDataSource.saveToken(result.accessToken);
    await localDataSource.saveGithubToken(token);
    await localDataSource.saveUser(
      id: result.id,
      name: result.name,
      email: result.email,
    );
    return result;
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = await localDataSource.getToken();
    if (token == null) return null;

    final cached = await localDataSource.getCachedUser();
    final offlineUser = cached == null
        ? null
        : AuthModel(
            id: int.tryParse(cached['id']!) ?? 0,
            name: cached['name']!,
            email: cached['email']!,
            accessToken: token,
          );

    if (!await networkInfo.isConnected) {
      return offlineUser;
    }

    try {
      final remote = await remoteDataSource.getCurrentUser(token);
      await localDataSource.saveUser(
        id: remote.id,
        name: remote.name,
        email: remote.email,
      );
      return remote;
    } catch (_) {
      if (offlineUser != null) return offlineUser;
      await localDataSource.clear();
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await localDataSource.clear();
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _ensureOnline();
    await remoteDataSource.forgotPassword(email);
  }

  @override
  Future<String?> getGithubToken() {
    return localDataSource.getGithubToken();
  }

  Future<void> _persistSession(AuthModel result) async {
    await localDataSource.saveToken(result.accessToken);
    await localDataSource.saveUser(
      id: result.id,
      name: result.name,
      email: result.email,
    );
  }

  Future<void> _ensureOnline() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException();
    }
  }
}
