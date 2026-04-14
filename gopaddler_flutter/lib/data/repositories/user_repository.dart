import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../../utils/app_logger.dart';

class UserRepository {
  static const String _userKey = 'user_data';
  final SharedPreferences _prefs;

  UserRepository(this._prefs);

  /// Save user to local storage
  Future<void> saveUser(User user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _prefs.setString(_userKey, userJson);
      AppLogger.info('User saved: ${user.email}');
    } catch (e) {
      AppLogger.error('Error saving user: $e');
      rethrow;
    }
  }

  /// Load user from local storage
  Future<User?> getUser() async {
    try {
      final userJson = _prefs.getString(_userKey);
      if (userJson == null) {
        return null;
      }
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userData);
    } catch (e) {
      AppLogger.error('Error loading user: $e');
      return null;
    }
  }

  /// Update user
  Future<void> updateUser(User user) async {
    try {
      await saveUser(user.copyWith(updatedAt: DateTime.now()));
      AppLogger.info('User updated: ${user.email}');
    } catch (e) {
      AppLogger.error('Error updating user: $e');
      rethrow;
    }
  }

  /// Delete user (clear from local storage)
  Future<void> deleteUser() async {
    try {
      await _prefs.remove(_userKey);
      AppLogger.info('User deleted');
    } catch (e) {
      AppLogger.error('Error deleting user: $e');
      rethrow;
    }
  }

  /// Check if user exists
  Future<bool> hasUser() async {
    return _prefs.containsKey(_userKey);
  }

  /// Check if user is logged in (has minimal required data)
  Future<bool> isLoggedIn() async {
    final user = await getUser();
    return user != null && user.email.isNotEmpty;
  }
}
