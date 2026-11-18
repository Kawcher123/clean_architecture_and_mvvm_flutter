import '../../domain/entities/user.dart';

class AuthModel extends User {
  final String accessToken;

  const AuthModel({
    required super.id,
    required super.name,
    required super.email,
    required this.accessToken,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? json;
    return AuthModel(
      id: _asInt(user['id'] ?? json['id']),
      name: (user['name'] ?? user['full_name'] ?? 'User').toString(),
      email: (user['email'] ?? '').toString(),
      accessToken: (json['accessToken'] ?? json['token'] ?? json['access_token'] ?? '')
          .toString(),
    );
  }

  factory AuthModel.fromGithubJson(
    Map<String, dynamic> json, {
    required String accessToken,
  }) {
    return AuthModel(
      id: _asInt(json['id']),
      name: (json['name'] ?? json['login'] ?? 'GitHub User').toString(),
      email: (json['email'] ?? '${json['login']}@users.noreply.github.com').toString(),
      accessToken: accessToken,
    );
  }

  factory AuthModel.fromUserJson(Map<String, dynamic> json) {
    return AuthModel(
      id: _asInt(json['id']),
      name: (json['name'] ?? 'User').toString(),
      email: (json['email'] ?? '').toString(),
      accessToken: '',
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
