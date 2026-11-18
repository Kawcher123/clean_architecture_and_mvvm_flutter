import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'core/database/app_database.dart';
import 'core/network/network_info.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/github_repos/services/github_repo_service.dart';
import 'features/github_repos/viewmodels/github_repos_viewmodel.dart';
import 'features/native_device/services/native_device_service.dart';
import 'features/native_device/viewmodels/native_device_viewmodel.dart';
import 'features/users/services/user_service.dart';
import 'features/users/viewmodels/users_viewmodel.dart';

/// Manual DI for MVVM: Services → ViewModels.
class ServiceLocator {
  ServiceLocator._();

  static final http.Client _client = http.Client();
  static final Connectivity _connectivity = Connectivity();
  static final AppDatabase _appDatabase = AppDatabase();
  static final NetworkInfo _networkInfo = NetworkInfo(_connectivity);

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static final AuthService _authService = AuthService(
    client: _client,
    secureStorage: _secureStorage,
    networkInfo: _networkInfo,
  );

  static final UserService _userService = UserService(
    client: _client,
    appDatabase: _appDatabase,
    networkInfo: _networkInfo,
  );

  static final GithubRepoService _githubRepoService = GithubRepoService(
    client: _client,
    appDatabase: _appDatabase,
    networkInfo: _networkInfo,
    authService: _authService,
  );

  static final NativeDeviceService _nativeDeviceService = NativeDeviceService();

  static AuthViewModel createAuthViewModel() => AuthViewModel(_authService);

  static UsersViewModel createUsersViewModel() => UsersViewModel(_userService);

  static GithubReposViewModel createGithubReposViewModel() =>
      GithubReposViewModel(_githubRepoService);

  static NativeDeviceViewModel createNativeDeviceViewModel() =>
      NativeDeviceViewModel(_nativeDeviceService);
}
