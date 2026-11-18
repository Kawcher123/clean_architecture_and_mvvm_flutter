class User {
  final int id;
  final String name;
  final String email;
  final String? username;
  final String? phone;
  final String? website;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.phone,
    this.website,
  });
}
