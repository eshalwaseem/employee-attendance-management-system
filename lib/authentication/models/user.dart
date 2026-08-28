import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin,
  manager,
  employee;

  static UserRole fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;

      case 'manager':
      case 'teamlead':
      case 'team_lead':
        return UserRole.manager;

      case 'employee':
      default:
        return UserRole.employee;
    }
  }

  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';

      case UserRole.manager:
        return 'manager';

      case UserRole.employee:
        return 'employee';
    }
  }
}

enum UserPermission {
  viewOwnAttendance,
  viewTeamAttendance,
  viewAllEmployees,
  manageEmployees,
  manageRoles,
  manageAttendance;

  String get value {
    switch (this) {
      case UserPermission.viewOwnAttendance:
        return 'viewOwnAttendance';

      case UserPermission.viewTeamAttendance:
        return 'viewTeamAttendance';

      case UserPermission.viewAllEmployees:
        return 'viewAllEmployees';

      case UserPermission.manageEmployees:
        return 'manageEmployees';

      case UserPermission.manageRoles:
        return 'manageRoles';

      case UserPermission.manageAttendance:
        return 'manageAttendance';
    }
  }

  static UserPermission? fromString(String? value) {
    for (final permission in UserPermission.values) {
      if (permission.value == value) {
        return permission;
      }
    }

    return null;
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? managerId;
  final String? profileImagePath;
  final List<UserPermission> permissions;

  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.employee,
    this.managerId,
    this.profileImagePath,
    this.permissions = const [],
    required this.createdAt,
  });

  bool hasPermission(UserPermission permission) {
    if (role == UserRole.admin) {
      return true;
    }

    return permissions.contains(permission);
  }

  bool get isAdmin => role == UserRole.admin;

  bool get isManager => role == UserRole.manager;

  bool get isEmployee => role == UserRole.employee;

  bool get canViewTeam {
    if (isAdmin || isManager) {
      return true;
    }

    return hasPermission(UserPermission.viewTeamAttendance);
  }

  Map<String, dynamic> toJson() {
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

  factory User.fromJson(Map<String, dynamic> json) {
    final permissionsJson = json['permissions'];
    final permissions = <UserPermission>[];

    if (permissionsJson is List) {
      for (final value in permissionsJson) {
        final permission = UserPermission.fromString(value?.toString());

        if (permission != null) {
          permissions.add(permission);
        }
      }
    }

    return User(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      managerId: json['managerId'] as String?,
      profileImagePath: json['profileImagePath'] as String?,
      permissions: permissions,
      createdAt: _parseCreatedAt(json['createdAt']),
    );
  }

  User copyWith({
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
    return User(
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
    return 'User('
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
