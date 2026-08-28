import 'package:cloud_firestore/cloud_firestore.dart';

import '../../authentication/models/user.dart';

class Employee {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? managerId;
  final String? profileImagePath;
  final List<UserPermission> permissions;

  final DateTime createdAt;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.employee,
    this.managerId,
    this.profileImagePath,
    this.permissions = const [],
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;

  bool get isManager => role == UserRole.manager;

  bool get isEmployee => role == UserRole.employee;

  bool hasPermission(UserPermission permission) {
    if (isAdmin) {
      return true;
    }

    return permissions.contains(permission);
  }

  factory Employee.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final permissions = <UserPermission>[];

    final permissionData = data['permissions'];

    if (permissionData is List) {
      for (final value in permissionData) {
        final permission = UserPermission.fromString(value.toString());

        if (permission != null) {
          permissions.add(permission);
        }
      }
    }

    return Employee(
      id: id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: UserRole.fromString(data['role'] as String?),
      managerId: data['managerId'] as String?,
      profileImagePath: data['profileImagePath'] as String?,
      permissions: permissions,
      createdAt: _parseCreatedAt(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.value,
      'managerId': managerId,
      'profileImagePath': profileImagePath,
      'permissions': permissions.map((permission) => permission.value).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Employee.fromUser(User user) {
    return Employee(
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      managerId: user.managerId,
      profileImagePath: user.profileImagePath,
      permissions: user.permissions,
      createdAt: user.createdAt,
    );
  }

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? managerId,
    String? profileImagePath,
    List<UserPermission>? permissions,
    DateTime? createdAt,
    bool clearManagerId = false,
    bool clearProfileImagePath = false,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      managerId: clearManagerId ? null : managerId ?? this.managerId,
      profileImagePath: clearProfileImagePath
          ? null
          : profileImagePath ?? this.profileImagePath,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Employee('
        'id: $id, '
        'name: $name, '
        'email: $email, '
        'role: ${role.value}, '
        'managerId: $managerId, '
        'createdAt: $createdAt'
        ')';
  }

  static DateTime _parseCreatedAt(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime(2000);
    }

    return DateTime(2000);
  }
}
