import 'dart:convert';
import '../models/user_model.dart';
import 'shared_prefs_service.dart';

class AuthService {
  static const String _usersKey = 'users_data';
  static const String _currentUserKey = 'currentUser';

  // Login user - FIXED
  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final users = await _getAllUsers();

      // Cari user dengan email
      final userEntry = users.entries.firstWhere(
        (entry) => entry.value.email == email,
        orElse: () => MapEntry(
            '', User(id: '', email: '', name: '', createdAt: DateTime.now())),
      );

      if (userEntry.key.isEmpty) {
        throw Exception('User not found');
      }

      final user = userEntry.value;

      // Verify password (sederhana untuk demo)
      final expectedPasswordHash =
          userEntry.key; // ID = password hash untuk demo
      final inputPasswordHash = _simpleHash(email + password);

      if (inputPasswordHash == expectedPasswordHash) {
        // Save current user
        await SharedPrefsService.setString(
            _currentUserKey, json.encode(user.toJson()));
        return user;
      } else {
        throw Exception('Invalid password');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Register user - FIXED
  Future<User?> register(String email, String password, String name) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final users = await _getAllUsers();

      // Check if email already exists
      if (users.values.any((user) => user.email == email)) {
        throw Exception('Email already exists');
      }

      // Create consistent ID/password hash
      final userId = _simpleHash(email + password);

      final newUser = User(
        id: userId,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      // Save user dengan ID sebagai key
      users[userId] = newUser;
      await _saveAllUsers(users);

      // Auto login after registration
      await SharedPrefsService.setString(
          _currentUserKey, json.encode(newUser.toJson()));

      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await SharedPrefsService.remove(_currentUserKey);
  }

  // Get current logged in user - FIXED
  Future<User?> getCurrentUser() async {
    try {
      final userJson = await SharedPrefsService.getString(_currentUserKey);
      if (userJson != null) {
        final userData = json.decode(userJson);
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Helper methods - FIXED
  Future<Map<String, User>> _getAllUsers() async {
    final usersJson = await SharedPrefsService.getString(_usersKey);

    if (usersJson == null) {
      // Create default demo user
      final defaultUsers = <String, User>{};
      final demoUserId = _simpleHash('demo@demo.com' 'password');
      final demoUser = User(
        id: demoUserId,
        email: 'demo@demo.com',
        name: 'Demo User',
        createdAt: DateTime.now(),
      );
      defaultUsers[demoUserId] = demoUser;
      await _saveAllUsers(defaultUsers);
      return defaultUsers;
    }

    try {
      final usersMap = <String, User>{};
      final usersData = json.decode(usersJson);

      usersData.forEach((key, value) {
        usersMap[key] = User.fromJson(value);
      });

      return usersMap;
    } catch (e) {
      return {};
    }
  }

  Future<void> _saveAllUsers(Map<String, User> users) async {
    final usersData = <String, dynamic>{};
    users.forEach((key, value) {
      usersData[key] = value.toJson();
    });
    await SharedPrefsService.setString(_usersKey, json.encode(usersData));
  }

  // Simple consistent hash function
  String _simpleHash(String input) {
    var hash = 0;
    for (var i = 0; i < input.length; i++) {
      hash = (hash << 5) - hash + input.codeUnitAt(i);
      hash = hash & hash; // Convert to 32bit integer
    }
    return hash.abs().toString();
  }
}
