class User {
  final int id;
  final String username;
  final String email;
  final String? createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.createdAt,
  });
} 