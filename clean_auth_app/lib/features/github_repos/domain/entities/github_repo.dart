class GithubRepo {
  final int id;
  final String name;
  final String fullName;
  final String? description;
  final String htmlUrl;
  final String? language;
  final int stargazersCount;
  final int forksCount;
  final bool private;
  final DateTime updatedAt;
  final String ownerLogin;

  const GithubRepo({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.htmlUrl,
    required this.language,
    required this.stargazersCount,
    required this.forksCount,
    required this.private,
    required this.updatedAt,
    required this.ownerLogin,
  });
}
