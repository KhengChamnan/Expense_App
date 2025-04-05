import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../models/user.dart';
import '../../network/api_constants.dart';
import '../../dto/user_dto.dart';
import '../auth_repository.dart';

/// Implementation of AuthRepository that uses REST API
class AuthApiRepository implements AuthRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _tokenKey = 'auth_token';
  final String _userKey = 'user_data';
  
  // HTTP timeout duration
  final Duration _timeout = const Duration(seconds: 10);

  @override
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.registerUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Save token and user data
        await _storage.write(key: _tokenKey, value: data['token']);
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));
        return {
          'success': true,
          'message': data['message'],
          'user': UserDTO.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().contains('timeout') 
            ? 'Connection timeout. Check if the backend server is running.' 
            : 'Network error: $e',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> login(String identifier, String password, {bool isEmail = false}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.loginUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          isEmail ? 'email' : 'username': identifier,
          'password': password,
          'isEmail': isEmail,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token and user data
        await _storage.write(key: _tokenKey, value: data['token']);
        await _storage.write(key: _userKey, value: jsonEncode(data['user']));
        return {
          'success': true,
          'message': data['message'],
          'user': UserDTO.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().contains('timeout') 
            ? 'Connection timeout. Check if the backend server is running.' 
            : 'Network error: $e',
      };
    }
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  @override
  Future<User?> getCurrentUser() async {
    final userData = await _storage.read(key: _userKey);
    if (userData != null) {
      return UserDTO.fromJson(jsonDecode(userData));
    }
    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null;
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http.get(
        Uri.parse(ApiConstants.profileUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Update stored user data
        await _storage.write(key: _userKey, value: jsonEncode(data));
        return {
          'success': true,
          'user': UserDTO.fromJson(data),
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}
