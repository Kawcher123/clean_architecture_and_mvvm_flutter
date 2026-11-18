class UserModel {
  final int id;
  final String name;
  final String email;
  final String? username;
  final String? phone;
  final String? website;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.phone,
    this.website,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      username: map['username'] as String?,
      phone: map['phone'] as String?,
      website: map['website'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
      'website': website,
      'cached_at': DateTime.now().toIso8601String(),
    };
  }
}
