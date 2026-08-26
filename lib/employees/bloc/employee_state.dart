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



  Employee? get currentEmployee {
    if (selectedEmployeeId == null) {
      return null;
    }

    return getById(selectedEmployeeId!);
  }

  Employee? get selectedEmployee {
    return currentEmployee;
  }



  bool get isLoading {
    return status == EmployeeStatus.loading;
  }

  bool get hasError {
    return status == EmployeeStatus.failure;
  }

  bool get isSuccess {
    return status == EmployeeStatus.success;
  }



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



  Employee? getById(String employeeId) {
    for (final employee in employees) {
      if (employee.id == employeeId) {
        return employee;
      }
    }

    return null;
  }


  List<Employee> getDirectReports(String managerId) {
    return employees
        .where((employee) => employee.managerId == managerId)
        .toList();
  }


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


  List<Employee> getAccessibleEmployees(String employeeId) {
    final currentEmployee = getById(employeeId);

    if (currentEmployee == null) {
      return [];
    }

    if (currentEmployee.isAdmin) {
      return employees.where((employee) => employee.id != employeeId).toList();
    }


    if (currentEmployee.isManager) {
      return employees
          .where((employee) => employee.managerId == employeeId)
          .toList();
    }

  
    return [];
  }


  bool canViewEmployee({required String viewerId, required String targetId}) {
    if (viewerId == targetId) {
      return true;
    }

    return employees.any((employee) => employee.id == targetId);
  }


  List<Employee> get unassignedEmployees {
    return employees.where((employee) {
      return employee.role == UserRole.employee && employee.managerId == null;
    }).toList();
  }


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
