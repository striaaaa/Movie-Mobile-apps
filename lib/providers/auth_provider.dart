import 'package:flutter/foundation.dart';
import 'package:movie_browser_app/services/api_services.dart';
// import '../models/user_model.dart';

import '../models/userModel.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  
  Future<User?> getUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      // final user = await _authService.getCurrentUser();
      final user = await _apiService.getCurrentUserLogin();
      if (user != null) {
        _currentUser = user; 
        print(user);
        notifyListeners();
        return _currentUser;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Get user error: $e');
      }
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    print('ini login prv');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _apiService.login(email, password);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register user dengan better error handling
  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _apiService.register(email, password, name);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _apiService.logout();
    _currentUser = null;
    notifyListeners();
  }

  // // Check if user is logged in on app start
  // Future<void> checkAuthStatus() async {
  //   _isLoading = true;
  //   notifyListeners();

  //   try {
  //     final user = await _authService.getCurrentUser();
  //     _currentUser = user;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Auth check error: $e');
  //     }
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
