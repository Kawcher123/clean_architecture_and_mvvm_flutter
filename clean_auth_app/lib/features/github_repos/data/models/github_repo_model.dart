import '../../domain/entities/github_repo.dart';

class GithubRepoModel extends GithubRepo {
  const GithubRepoModel({
    required super.id,
    required super.name,
    required super.fullName,
    required super.description,
    required super.htmlUrl,
    required super.language,
    required super.stargazersCount,
    required super.forksCount,
    required super.private,
    required super.updatedAt,
    required super.ownerLogin,
  });

  factory GithubRepoModel.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>? ?? {};
    return GithubRepoModel(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      description: json['description'] as String?,
      htmlUrl: json['html_url'] as String,
      language: json['language'] as String?,
      stargazersCount: (json['stargazers_count'] as num?)?.toInt() ?? 0,
      forksCount: (json['forks_count'] as num?)?.toInt() ?? 0,
      private: json['private'] == true,
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      ownerLogin: (owner['login'] ?? '').toString(),
    );
  }

  factory GithubRepoModel.fromMap(Map<String, dynamic> map) {
    return GithubRepoModel(
      id: map['id'] as int,
      name: map['name'] as String,
      fullName: map['full_name'] as String,
      description: map['description'] as String?,
      htmlUrl: map['html_url'] as String,
      language: map['language'] as String?,
      stargazersCount: map['stargazers_count'] as int? ?? 0,
      forksCount: map['forks_count'] as int? ?? 0,
      private: (map['private'] as int? ?? 0) == 1,
      updatedAt: DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      ownerLogin: map['owner_login'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'description': description,
      'html_url': htmlUrl,
      'language': language,
      'stargazers_count': stargazersCount,
      'forks_count': forksCount,
      'private': private ? 1 : 0,
      'updated_at': updatedAt.toIso8601String(),
      'owner_login': ownerLogin,
      'cached_at': DateTime.now().toIso8601String(),
    };
  }
}
