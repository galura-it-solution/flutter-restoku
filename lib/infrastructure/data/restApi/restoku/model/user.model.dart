class UserModel {
  final int id;
  final String name;
  final String? email;
  final String? role;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '').toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
    );
  }
}
