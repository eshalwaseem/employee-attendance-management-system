import '../models/employee.dart';
import '../../authentication/models/user.dart';

abstract class EmployeeEvent {
  const EmployeeEvent();
}

// ============================================================
// LOAD ALL EMPLOYEES
// ============================================================

class EmployeesLoaded extends EmployeeEvent {
  const EmployeesLoaded();
}

// ============================================================
// LOAD CURRENT EMPLOYEE
// ============================================================
//
// Kept for compatibility with your existing application.

class EmployeeLoaded extends EmployeeEvent {
  final Employee employee;

  const EmployeeLoaded(this.employee);
}

// ============================================================
// RELOAD
// ============================================================

class EmployeesReloadRequested extends EmployeeEvent {
  const EmployeesReloadRequested();
}

// ============================================================
// CLEAR
// ============================================================

class EmployeeCleared extends EmployeeEvent {
  const EmployeeCleared();
}

// ============================================================
// SELECT EMPLOYEE
// ============================================================

class EmployeeSelected extends EmployeeEvent {
  final String employeeId;

  const EmployeeSelected(this.employeeId);
}

// ============================================================
// CLEAR SELECTION
// ============================================================

class EmployeeSelectionCleared extends EmployeeEvent {
  const EmployeeSelectionCleared();
}

// ============================================================
// REGISTERED
// ============================================================
//
// Kept for compatibility.

class EmployeeRegistered extends EmployeeEvent {
  final Employee employee;

  const EmployeeRegistered(this.employee);
}

// ============================================================
// ASSIGN AUTHORITY
// ============================================================

class EmployeeAuthorityAssigned extends EmployeeEvent {
  final String employeeId;
  final UserRole role;
  final String? managerId;
  final List<UserPermission> permissions;

  const EmployeeAuthorityAssigned({
    required this.employeeId,
    required this.role,
    required this.managerId,
    required this.permissions,
  });
}

// ============================================================
// ASSIGN MANAGER
// ============================================================

class EmployeeManagerAssigned extends EmployeeEvent {
  final String employeeId;
  final String managerId;

  const EmployeeManagerAssigned({
    required this.employeeId,
    required this.managerId,
  });
}

// ============================================================
// REMOVE MANAGER
// ============================================================

class EmployeeManagerRemoved extends EmployeeEvent {
  final String employeeId;

  const EmployeeManagerRemoved({
    required this.employeeId,
  });
}

// ============================================================
// DELETE FIRESTORE PROFILE
// ============================================================

class EmployeeDeleted extends EmployeeEvent {
  final String employeeId;

  const EmployeeDeleted({
    required this.employeeId,
  });
}