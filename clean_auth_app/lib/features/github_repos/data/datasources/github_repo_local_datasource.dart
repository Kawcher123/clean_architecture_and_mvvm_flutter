import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/app_exception.dart';
import '../models/github_repo_model.dart';

class GithubRepoLocalDataSource {
  final AppDatabase appDatabase;

  GithubRepoLocalDataSource(this.appDatabase);

  Future<void> cacheRepos(List<GithubRepoModel> repos) async {
    try {
      final db = await appDatabase.database;
      final batch = db.batch();
      batch.delete('github_repos');
      for (final repo in repos) {
        batch.insert(
          'github_repos',
          repo.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (_) {
      throw const CacheException('Failed to cache GitHub repositories');
    }
  }

  Future<List<GithubRepoModel>> getCachedRepos() async {
    try {
      final db = await appDatabase.database;
      final maps = await db.query(
        'github_repos',
        orderBy: 'updated_at DESC',
      );
      return maps.map(GithubRepoModel.fromMap).toList();
    } catch (_) {
      throw const CacheException('Failed to read cached GitHub repositories');
    }
  }

  Future<void> clearCache() async {
    final db = await appDatabase.database;
    await db.delete('github_repos');
  }
}
