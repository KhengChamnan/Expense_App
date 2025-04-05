import '../../models/user.dart';

abstract class AuthRepository {
  /// Register a new user
  Future<Map<String, dynamic>> register(String username, String email, String password);
  
  /// Login user
  Future<Map<String, dynamic>> login(String identifier, String password, {bool isEmail});
  
  /// Logout user
  Future<void> logout();
  
  /// Get current user
  Future<User?> getCurrentUser();
  
  /// Check if user is logged in
  Future<bool> isLoggedIn();
  
  /// Get authentication token
  Future<String?> getToken();
  
  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile();
}
