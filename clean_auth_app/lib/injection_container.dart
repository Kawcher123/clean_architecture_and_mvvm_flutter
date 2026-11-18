import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'core/database/app_database.dart';
import 'core/network/network_info.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/forgot_password.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/login_with_github_token.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/domain/usecases/register.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/github_repos/data/datasources/github_repo_local_datasource.dart';
import 'features/github_repos/data/datasources/github_repo_remote_datasource.dart';
import 'features/github_repos/data/repositories/github_repo_repository_impl.dart';
import 'features/github_repos/domain/repositories/github_repo_repository.dart';
import 'features/github_repos/domain/usecases/get_github_repos.dart';
import 'features/github_repos/presentation/providers/github_repo_provider.dart';
import 'features/native_device/data/datasources/native_device_datasource.dart';
import 'features/native_device/data/repositories/native_device_repository_impl.dart';
import 'features/native_device/domain/repositories/native_device_repository.dart';
import 'features/native_device/domain/usecases/get_device_info.dart';
import 'features/native_device/domain/usecases/show_native_message.dart';
import 'features/native_device/presentation/providers/native_device_provider.dart';
import 'features/users/data/datasources/user_local_datasource.dart';
import 'features/users/data/datasources/user_remote_datasource.dart';
import 'features/users/data/repositories/user_repository_impl.dart';
import 'features/users/domain/repositories/user_repository.dart';
import 'features/users/domain/usecases/get_users.dart';
import 'features/users/presentation/providers/user_provider.dart';

class InjectionContainer {
  InjectionContainer._();

  static final http.Client _client = http.Client();
  static final Connectivity _connectivity = Connectivity();
  static final AppDatabase _appDatabase = AppDatabase();

  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static final NetworkInfo _networkInfo = NetworkInfoImpl(_connectivity);

  static final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource(
    secureStorage: _secureStorage,
  );

  static final AuthRemoteDataSource _authRemoteDataSource =
      AuthRemoteDataSource(client: _client);

  static final AuthRepository _authRepository = AuthRepositoryImpl(
    remoteDataSource: _authRemoteDataSource,
    localDataSource: _authLocalDataSource,
    networkInfo: _networkInfo,
  );

  static final UserRemoteDataSource _userRemoteDataSource =
      UserRemoteDataSource(client: _client);

  static final UserLocalDataSource _userLocalDataSource =
      UserLocalDataSource(_appDatabase);

  static final UserRepository _userRepository = UserRepositoryImpl(
    remoteDataSource: _userRemoteDataSource,
    localDataSource: _userLocalDataSource,
    networkInfo: _networkInfo,
  );

  static final GithubRepoRemoteDataSource _githubRemoteDataSource =
      GithubRepoRemoteDataSource(client: _client);

  static final GithubRepoLocalDataSource _githubLocalDataSource =
      GithubRepoLocalDataSource(_appDatabase);

  static final GithubRepoRepository _githubRepoRepository =
      GithubRepoRepositoryImpl(
    remoteDataSource: _githubRemoteDataSource,
    localDataSource: _githubLocalDataSource,
    authLocalDataSource: _authLocalDataSource,
    networkInfo: _networkInfo,
  );

  static final NativeDeviceDataSource _nativeDeviceDataSource =
      NativeDeviceDataSource();

  static final NativeDeviceRepository _nativeDeviceRepository =
      NativeDeviceRepositoryImpl(_nativeDeviceDataSource);

  static AuthProvider createAuthProvider() {
    return AuthProvider(
      loginUseCase: Login(_authRepository),
      registerUseCase: Register(_authRepository),
      logoutUseCase: Logout(_authRepository),
      getCurrentUserUseCase: GetCurrentUser(_authRepository),
      forgotPasswordUseCase: ForgotPassword(_authRepository),
      loginWithGithubTokenUseCase: LoginWithGithubToken(_authRepository),
    );
  }

  static UserProvider createUserProvider() {
    return UserProvider(GetUsers(_userRepository));
  }

  static GithubRepoProvider createGithubRepoProvider() {
    return GithubRepoProvider(GetGithubRepos(_githubRepoRepository));
  }

  static NativeDeviceProvider createNativeDeviceProvider() {
    return NativeDeviceProvider(
      getDeviceInfoUseCase: GetDeviceInfo(_nativeDeviceRepository),
      showNativeMessageUseCase: ShowNativeMessage(_nativeDeviceRepository),
    );
  }
}
