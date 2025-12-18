import 'dart:convert';

import '../models/userModel.dart';
import 'shared_prefs_service.dart';

class AuthService {
  static const String _usersKey = 'users_data';
  static const String _currentUserKey = 'currentUser';
 

  // Get current logged in user
  // Future<User?> getCurrentUser() async {
  //   try {
  //     final userJson = await SharedPrefsService.getString(_currentUserKey);
  //     if (userJson != null) {
  //       final userData = json.decode(userJson);
  //       return User.fromJson(userData);
  //     }
  //     return null;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // Helper methods
  Future<Map<String, User>> _getAllUsers() async {
    final usersJson = await SharedPrefsService.getString(_usersKey);

    if (usersJson == null) {
      // Default demo user
      final defaultUsers = <String, User>{};
      final demoUserKey = _simpleHash('demos@demo.com' + 'password');
      final demoUser = User(
        id: int.tryParse(demoUserKey) ?? 0,
        email: 'demos@demo.com',
        name: 'Demo User',
        createdAt: DateTime.now(),
      );
      defaultUsers[demoUserKey] = demoUser;
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
