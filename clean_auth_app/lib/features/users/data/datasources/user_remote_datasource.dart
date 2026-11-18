import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_constants.dart';
import '../models/user_model.dart';

class UserRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  UserRemoteDataSource({
    required this.client,
    this.baseUrl = ApiConstants.usersBaseUrl,
  });

  Future<List<UserModel>> getUsers() async {
    final response = await client
        .get(Uri.parse('$baseUrl/users'))
        .timeout(ApiConstants.connectTimeout);

    if (response.statusCode == 200) {
      final list = List<Map<String, dynamic>>.from(
        jsonDecode(response.body) as List,
      );
      return list.map(UserModel.fromJson).toList();
    }

    throw const ServerException('Failed to load users');
  }
}
