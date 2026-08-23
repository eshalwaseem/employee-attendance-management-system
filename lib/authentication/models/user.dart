class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? managerId;
  final String? profileImagePath;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'employee',
    this.managerId,
    this.profileImagePath,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? managerId,
    String? profileImagePath,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      managerId: managerId ?? this.managerId,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'managerId': managerId,
      'profileImagePath': profileImagePath,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'employee',
      managerId: json['managerId'] as String?,
      profileImagePath: json['profileImagePath'] as String?,
    );
  }

  @override
  String toString() {
    return 'User('
        'id: $id, '
        'name: $name, '
        'email: $email, '
        'role: $role, '
        'managerId: $managerId'
        ')';
  }
}
