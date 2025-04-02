import '../../models/user.dart';

/// Data Transfer Object for User model
class UserDTO {
  /// Convert a JSON map to a User object
  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      createdAt: json['createdAt'],
    );
  }

  /// Convert a User object to a JSON map
  static Map<String, dynamic> toJson(User user) {
    return {
      'id': user.id,
      'username': user.username,
      'email': user.email,
      'createdAt': user.createdAt,
    };
  }
} 