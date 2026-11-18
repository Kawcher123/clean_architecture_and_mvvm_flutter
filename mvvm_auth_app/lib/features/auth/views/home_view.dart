import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../github_repos/views/github_repos_view.dart';
import '../../native_device/views/native_device_view.dart';
import '../../users/views/users_view.dart';
import '../viewmodels/auth_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home (MVVM)'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => context.read<AuthViewModel>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome ${user?.name ?? ''}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(user?.email ?? ''),
                    const SizedBox(height: 8),
                    const Text('You are logged in!'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Features', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('GitHub Repositories'),
              subtitle: const Text('Online + SQLite offline cache'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GithubReposView()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Users (JSONPlaceholder)'),
              subtitle: const Text('MVVM sample feature'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UsersView()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Native Device'),
              subtitle: const Text('Java / Swift MethodChannel'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NativeDeviceView()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
