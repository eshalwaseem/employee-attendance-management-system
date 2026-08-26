import '../models/employee.dart';
import '../../authentication/models/user.dart';

enum EmployeeStatus { initial, loading, success, failure }

class EmployeeState {
  final EmployeeStatus status;
  final List<Employee> employees;
  final String? selectedEmployeeId;
  final String? errorMessage;

  const EmployeeState({
    this.status = EmployeeStatus.initial,
    this.employees = const [],
    this.selectedEmployeeId,
    this.errorMessage,
  });

  // ============================================================
  // CURRENT / SELECTED EMPLOYEE
  // ============================================================

  Employee? get currentEmployee {
    if (selectedEmployeeId == null) {
      return null;
    }

    return getById(selectedEmployeeId!);
  }

  Employee? get selectedEmployee {
    return currentEmployee;
  }

  // ============================================================
  // STATUS
  // ============================================================

  bool get isLoading {
    return status == EmployeeStatus.loading;
  }

  bool get hasError {
    return status == EmployeeStatus.failure;
  }

  bool get isSuccess {
    return status == EmployeeStatus.success;
  }

  // ============================================================
  // ROLE FILTERS
  // ============================================================

  List<Employee> get admins {
    return employees
        .where((employee) => employee.role == UserRole.admin)
        .toList();
  }

  List<Employee> get managers {
    return employees
        .where((employee) => employee.role == UserRole.manager)
        .toList();
  }

  List<Employee> get regularEmployees {
    return employees
        .where((employee) => employee.role == UserRole.employee)
        .toList();
  }

  // ============================================================
  // FIND EMPLOYEE
  // ============================================================

  Employee? getById(String employeeId) {
    for (final employee in employees) {
      if (employee.id == employeeId) {
        return employee;
      }
    }

    return null;
  }

  // ============================================================
  // DIRECT REPORTS
  // ============================================================

  List<Employee> getDirectReports(String managerId) {
    return employees
        .where((employee) => employee.managerId == managerId)
        .toList();
  }

  // ============================================================
  // ALL REPORTS
  // ============================================================

  List<Employee> getAllReports(String managerId) {
    final result = <Employee>[];
    final visited = <String>{};

    void findReports(String currentManagerId) {
      if (!visited.add(currentManagerId)) {
        return;
      }

      final directReports = getDirectReports(currentManagerId);

      for (final employee in directReports) {
        if (visited.contains(employee.id)) {
          continue;
        }

        result.add(employee);

        findReports(employee.id);
      }
    }

    findReports(managerId);

    return result;
  }

  // ============================================================
  // ACCESSIBLE EMPLOYEES
  // ============================================================

  List<Employee> getAccessibleEmployees(String employeeId) {
    final currentEmployee = getById(employeeId);

    if (currentEmployee == null) {
      return [];
    }

    // ==========================================================
    // ADMIN
    // ==========================================================
    // Admin can see everyone except themselves.
    if (currentEmployee.isAdmin) {
      return employees.where((employee) => employee.id != employeeId).toList();
    }

    // ==========================================================
    // MANAGER
    // ==========================================================
    // Manager can see employees assigned to them.
    if (currentEmployee.isManager) {
      return employees
          .where((employee) => employee.managerId == employeeId)
          .toList();
    }

    // ==========================================================
    // EMPLOYEE
    // ==========================================================
    // Employees cannot see other employees.
    return [];
  }

  // ============================================================
  // CHECK VIEW ACCESS
  // ============================================================

  bool canViewEmployee({required String viewerId, required String targetId}) {
    if (viewerId == targetId) {
      return true;
    }

    return employees.any((employee) => employee.id == targetId);
  }

  // ============================================================
  // UNASSIGNED EMPLOYEES
  // ============================================================

  List<Employee> get unassignedEmployees {
    return employees.where((employee) {
      return employee.role == UserRole.employee && employee.managerId == null;
    }).toList();
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  EmployeeState copyWith({
    EmployeeStatus? status,
    List<Employee>? employees,
    String? selectedEmployeeId,
    String? errorMessage,
    bool clearSelection = false,
    bool clearError = false,
  }) {
    return EmployeeState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      selectedEmployeeId: clearSelection
          ? null
          : selectedEmployeeId ?? this.selectedEmployeeId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'EmployeeState('
        'status: $status, '
        'employees: ${employees.length}, '
        'selectedEmployeeId: $selectedEmployeeId, '
        'errorMessage: $errorMessage'
        ')';
  }
}
