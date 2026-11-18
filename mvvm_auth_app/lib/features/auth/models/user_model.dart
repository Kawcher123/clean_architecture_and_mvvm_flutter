class UserModel {
  final int id;
  final String name;
  final String email;
  final String accessToken;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.accessToken = '',
  });

  factory UserModel.fromAuthJson(Map<String, dynamic> json, {String? email}) {
    final user = json['user'] as Map<String, dynamic>? ?? json;
    final token =
        (json['accessToken'] ?? json['token'] ?? json['access_token'] ?? '')
            .toString();

    return UserModel(
      id: _asInt(user['id'] ?? json['id']),
      name: (user['name'] ?? user['full_name'] ?? email?.split('@').first ?? 'User')
          .toString(),
      email: (user['email'] ?? email ?? '').toString(),
      accessToken: token,
    );
  }

  factory UserModel.fromGithubJson(
    Map<String, dynamic> json, {
    required String accessToken,
  }) {
    return UserModel(
      id: _asInt(json['id']),
      name: (json['name'] ?? json['login'] ?? 'GitHub User').toString(),
      email: (json['email'] ?? '${json['login']}@users.noreply.github.com')
          .toString(),
      accessToken: accessToken,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
