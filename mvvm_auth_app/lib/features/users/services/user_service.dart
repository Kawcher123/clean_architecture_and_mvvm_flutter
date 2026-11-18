import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/network_info.dart';
import '../models/user_model.dart';

class UserService {
  final http.Client client;
  final AppDatabase appDatabase;
  final NetworkInfo networkInfo;
  final String baseUrl;

  UserService({
    required this.client,
    required this.appDatabase,
    required this.networkInfo,
    this.baseUrl = ApiConstants.usersBaseUrl,
  });

  Future<List<UserModel>> getUsers({bool forceRefresh = false}) async {
    final online = await networkInfo.isConnected;

    if (online) {
      try {
        final remote = await _fetchRemote();
        await _cacheUsers(remote);
        return remote;
      } catch (_) {
        final cached = await _getCachedUsers();
        if (cached.isNotEmpty) return cached;
        rethrow;
      }
    }

    final cached = await _getCachedUsers();
    if (cached.isNotEmpty) return cached;

    throw const NetworkException(
      'No internet connection and no cached users available',
    );
  }

  Future<List<UserModel>> _fetchRemote() async {
    final response = await client
        .get(Uri.parse('$baseUrl/users'))
        .timeout(ApiConstants.connectTimeout);

    if (response.statusCode != 200) {
      throw const ServerException('Failed to load users');
    }

    final list = List<Map<String, dynamic>>.from(
      jsonDecode(response.body) as List,
    );
    return list.map(UserModel.fromJson).toList();
  }

  Future<void> _cacheUsers(List<UserModel> users) async {
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
  }

  Future<List<UserModel>> _getCachedUsers() async {
    final db = await appDatabase.database;
    final maps = await db.query('users', orderBy: 'id ASC');
    return maps.map(UserModel.fromMap).toList();
  }
}
