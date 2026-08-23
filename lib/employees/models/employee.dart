class Employee {
  final String id;
  final String name;
  final String email;
  final String? managerId;
  final String? profileImagePath;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    this.managerId,
    this.profileImagePath,
  });

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? managerId,
    String? profileImagePath,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      managerId: managerId ?? this.managerId,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  @override
  String toString() {
    return 'Employee('
        'id: $id, '
        'name: $name, '
        'email: $email, '
        'managerId: $managerId'
        ')';
  }
}
