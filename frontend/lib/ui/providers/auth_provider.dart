import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/repository/api/auth_api_repository.dart';
import '../providers/async_value.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  
  AsyncValue<User?> _authState = AsyncValue.loading();
  String? _error;
  
  AuthProvider({AuthRepository? repository}) 
      : _repository = repository ?? AuthApiRepository();

  AsyncValue<User?> get authState => _authState;
  User? get user => _authState.data;
  bool get isLoading => _authState.state == AsyncValueState.loading;
  bool get isAuthenticated => _authState.data != null;
  String? get error => _error;

  Future<void> initAuthState() async {
    _authState = AsyncValue.loading();
    _error = null;
    notifyListeners();

    try {
      final isLoggedIn = await _repository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _repository.getCurrentUser();
        _authState = AsyncValue.success(user);
      } else {
        _authState = AsyncValue.success(null);
      }
    } catch (e) {
      _error = 'Failed to initialize auth state: $e';
      _authState = AsyncValue.error(e);
    }
    
    notifyListeners();
  }

  Future<bool> register(String username, String email, String password) async {
    _authState = AsyncValue.loading();
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.register(username, email, password);
      if (result['success']) {
        _authState = AsyncValue.success(result['user']);
        return true;
      } else {
        _error = result['message'];
        _authState = AsyncValue.error(_error ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _error = 'Registration failed: $e';
      _authState = AsyncValue.error(e);
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    return loginWithIdentifier(username, password, isEmail: false);
  }

  Future<bool> loginWithIdentifier(String identifier, String password, {bool isEmail = false}) async {
    _authState = AsyncValue.loading();
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.login(identifier, password, isEmail: isEmail);
      
      if (result['success']) {
        _authState = AsyncValue.success(result['user']);
        return true;
      } else {
        _error = result['message'];
        _authState = AsyncValue.error(_error ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _error = 'Login failed: $e';
      _authState = AsyncValue.error(e);
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
      _authState = AsyncValue.success(null);
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed: $e';
      notifyListeners();
    }
  }

  Future<void> getUserProfile() async {
    final currentUser = _authState.data;
    if (currentUser == null) return;

    _authState = AsyncValue.loading();
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getUserProfile();
      if (result['success']) {
        _authState = AsyncValue.success(result['user']);
      } else {
        _error = result['message'];
        _authState = AsyncValue.error(_error ?? 'Failed to get profile');
      }
    } catch (e) {
      _error = 'Failed to get profile: $e';
      _authState = AsyncValue.error(e);
    } finally {
      notifyListeners();
    }
  }
  
  // Refresh user profile without showing loading state
  Future<void> refreshUserProfileSilently() async {
    final currentUser = _authState.data;
    if (currentUser == null) return;
    
    try {
      final result = await _repository.getUserProfile();
      if (result['success']) {
        _authState = AsyncValue.success(result['user']);
        notifyListeners();
      }
    } catch (e) {
      // Silent failure - keep existing user data
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 