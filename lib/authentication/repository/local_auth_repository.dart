import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class LocalAuthRepository {
  static const String _userKey = 'local_user';

 
  Future<void> saveUser(User user) async {
    final preferences = await SharedPreferences.getInstance();

    final userJson = {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'role': user.role,
      'managerId': user.managerId,
      'profileImagePath': user.profileImagePath,
    };

    await preferences.setString(_userKey, jsonEncode(userJson));
  }


  Future<User?> getUser() async {
    final preferences = await SharedPreferences.getInstance();

    final userString = preferences.getString(_userKey);

    if (userString == null || userString.isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> data =
          jsonDecode(userString) as Map<String, dynamic>;

      return User(
        id: data['id'] as String,
        name: data['name'] as String,
        email: data['email'] as String,
        role: data['role'] as String? ?? 'employee',
        managerId: data['managerId'] as String?,
        profileImagePath: data['profileImagePath'] as String?,
      );
    } catch (_) {
      return null;
    }
  }


  Future<User> signup({required String name, required String email}) async {
    final user = User(
      id: 'LOCAL_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      role: 'employee',
      managerId: '001',
      profileImagePath: null,
    );

    await saveUser(user);

    return user;
  }


  Future<User?> login(String email) async {
    final user = await getUser();

    if (user == null) {
      return null;
    }

    if (user.email.trim().toLowerCase() != email.trim().toLowerCase()) {
      return null;
    }

    return user;
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_userKey);
  }

  Future<User?> getCurrentUser() async {
    return getUser();
  }

  Future<bool> hasUser() async {
    final user = await getUser();

    return user != null;
  }
}
