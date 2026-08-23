import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _userIdKey = 'user_id';
  static const String _nameKey = 'user_name';
  static const String _emailKey = 'user_email';
  static const String _roleKey = 'user_role';
  static const String _managerIdKey = 'manager_id';
  static const String _loggedInKey = 'is_logged_in';

  Future<void> saveUser({
    required String id,
    required String name,
    required String email,
    String role = 'employee',
    String? managerId,
  }) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_userIdKey, id);
    await preferences.setString(_nameKey, name);
    await preferences.setString(_emailKey, email);
    await preferences.setString(_roleKey, role);
    await preferences.setBool(_loggedInKey, true);

    if (managerId != null) {
      await preferences.setString(_managerIdKey, managerId);
    } else {
      await preferences.remove(_managerIdKey);
    }
  }

  Future<Map<String, String?>?> getUser() async {
    final preferences = await SharedPreferences.getInstance();

    final loggedIn = preferences.getBool(_loggedInKey) ?? false;

    if (!loggedIn) {
      return null;
    }

    return {
      'id': preferences.getString(_userIdKey),
      'name': preferences.getString(_nameKey),
      'email': preferences.getString(_emailKey),
      'role': preferences.getString(_roleKey),
      'managerId': preferences.getString(_managerIdKey),
    };
  }

  Future<bool> isLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getBool(_loggedInKey) ?? false;
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_userIdKey);
    await preferences.remove(_nameKey);
    await preferences.remove(_emailKey);
    await preferences.remove(_roleKey);
    await preferences.remove(_managerIdKey);
    await preferences.setBool(_loggedInKey, false);
  }
}
