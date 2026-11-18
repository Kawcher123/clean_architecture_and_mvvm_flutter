import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../viewmodels/github_repos_viewmodel.dart';

class GithubReposView extends StatefulWidget {
  const GithubReposView({super.key});

  @override
  State<GithubReposView> createState() => _GithubReposViewState();
}

class _GithubReposViewState extends State<GithubReposView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GithubReposViewModel>().fetchRepos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Repos'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => context
                .read<GithubReposViewModel>()
                .fetchRepos(forceRefresh: true),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<GithubReposViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.repos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null && vm.repos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(vm.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => vm.fetchRepos(forceRefresh: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              if (vm.error != null && vm.repos.isNotEmpty)
                MaterialBanner(
                  content: Text('Offline / cached data. ${vm.error}'),
                  leading: const Icon(Icons.cloud_off),
                  actions: [
                    TextButton(
                      onPressed: () => vm.fetchRepos(forceRefresh: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => vm.fetchRepos(forceRefresh: true),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: vm.repos.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final repo = vm.repos[index];
                      return ListTile(
                        title: Text(repo.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (repo.description != null &&
                                repo.description!.isNotEmpty)
                              Text(
                                repo.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 4),
                            Text(
                              [
                                if (repo.language != null) repo.language!,
                                '★ ${repo.stargazersCount}',
                                '⑂ ${repo.forksCount}',
                                dateFormat.format(repo.updatedAt),
                                if (repo.private) 'private',
                              ].join(' · '),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
