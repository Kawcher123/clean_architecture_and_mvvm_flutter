import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/github_repo_provider.dart';

class GithubReposScreen extends StatefulWidget {
  const GithubReposScreen({super.key});

  @override
  State<GithubReposScreen> createState() => _GithubReposScreenState();
}

class _GithubReposScreenState extends State<GithubReposScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GithubRepoProvider>().fetchRepos();
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
            onPressed: () {
              context.read<GithubRepoProvider>().fetchRepos(forceRefresh: true);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<GithubRepoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.repos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.repos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(provider.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          provider.fetchRepos(forceRefresh: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              if (provider.error != null && provider.repos.isNotEmpty)
                MaterialBanner(
                  content: Text('Offline / cached data. ${provider.error}'),
                  leading: const Icon(Icons.cloud_off),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          provider.fetchRepos(forceRefresh: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchRepos(forceRefresh: true),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.repos.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final repo = provider.repos[index];
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
