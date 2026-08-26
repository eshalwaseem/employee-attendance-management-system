import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/employee.dart';
import '../../authentication/models/user.dart';

class EmployeeRepository {
  final FirebaseFirestore _firestore;

  EmployeeRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection {
    return _firestore.collection('users');
  }


  Future<List<Employee>> getEmployees(String currentUserId) async {
    final currentUser = await getEmployee(currentUserId);

    if (currentUser == null) {
      throw Exception('Current user profile could not be found.');
    }

    if (currentUser.isAdmin) {
      final snapshot = await _usersCollection.get();

      return snapshot.docs.map((document) {
        return Employee.fromMap(id: document.id, data: document.data());
      }).toList();
    }

    if (currentUser.isManager) {
      final snapshot = await _usersCollection
          .where('managerId', isEqualTo: currentUserId)
          .get();

      final employees = snapshot.docs.map((document) {
        return Employee.fromMap(id: document.id, data: document.data());
      }).toList();

      return [currentUser, ...employees];
    }

    final employee = await getEmployee(currentUserId);

    if (employee == null) {
      return [];
    }

    return [employee];
  }


  Future<Employee?> getEmployee(String employeeId) async {
    final document = await _usersCollection.doc(employeeId).get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    return Employee.fromMap(id: document.id, data: data);
  }

  Future<Employee> assignAuthority({
    required String employeeId,
    required UserRole role,
    required String? managerId,
    required List<UserPermission> permissions,
  }) async {
    if (managerId == employeeId) {
      throw Exception('An employee cannot be their own manager.');
    }

    final effectiveManagerId =
        role == UserRole.admin || role == UserRole.manager ? null : managerId;

    await _usersCollection.doc(employeeId).update({
      'role': role.value,
      'managerId': effectiveManagerId,
      'permissions': permissions.map((permission) => permission.value).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final updatedEmployee = await getEmployee(employeeId);

    if (updatedEmployee == null) {
      throw Exception('Employee was updated but could not be loaded again.');
    }

    return updatedEmployee;
  }


  Future<Employee> assignManager({
    required String employeeId,
    required String managerId,
  }) async {
    if (employeeId == managerId) {
      throw Exception('An employee cannot be their own manager.');
    }

    final manager = await getEmployee(managerId);

    if (manager == null) {
      throw Exception('The selected team lead does not exist.');
    }

    if (!manager.isManager && !manager.isAdmin) {
      throw Exception('The selected user is not a team lead.');
    }

    await _usersCollection.doc(employeeId).update({
      'managerId': managerId,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final updatedEmployee = await getEmployee(employeeId);

    if (updatedEmployee == null) {
      throw Exception('Employee could not be loaded after assigning manager.');
    }

    return updatedEmployee;
  }


  Future<Employee> removeManager(String employeeId) async {
    await _usersCollection.doc(employeeId).update({
      'managerId': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final updatedEmployee = await getEmployee(employeeId);

    if (updatedEmployee == null) {
      throw Exception('Employee could not be loaded after removing manager.');
    }

    return updatedEmployee;
  }


  Future<void> deleteEmployeeProfile(String employeeId) async {
    await _usersCollection.doc(employeeId).delete();
  }
}
