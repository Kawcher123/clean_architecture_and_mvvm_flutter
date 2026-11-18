import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/app_exception.dart';
import '../models/user_model.dart';

class UserLocalDataSource {
  final AppDatabase appDatabase;

  UserLocalDataSource(this.appDatabase);

  Future<void> cacheUsers(List<UserModel> users) async {
    try {
      final db = await appDatabase.database;
      final batch = db.batch();
      batch.delete('users');
      for (final user in users) {
        batch.insert(
          'users',
          user.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (_) {
      throw const CacheException('Failed to cache users');
    }
  }

  Future<List<UserModel>> getCachedUsers() async {
    try {
      final db = await appDatabase.database;
      final maps = await db.query('users', orderBy: 'id ASC');
      return maps.map(UserModel.fromMap).toList();
    } catch (_) {
      throw const CacheException('Failed to read cached users');
    }
  }
}
