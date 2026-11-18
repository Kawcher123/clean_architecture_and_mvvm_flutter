import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/auth/views/home_view.dart';
import 'features/auth/views/login_view.dart';
import 'service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ServiceLocator.createAuthViewModel()..checkAuth(),
        ),
        ChangeNotifierProvider(
          create: (_) => ServiceLocator.createUsersViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ServiceLocator.createGithubReposViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ServiceLocator.createNativeDeviceViewModel(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MVVM Auth App',
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, vm, child) {
        if (vm.status == AuthStatus.initial ||
            vm.status == AuthStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (vm.isAuthenticated) {
          return const HomeView();
        }

        return const LoginView();
      },
    );
  }
}
