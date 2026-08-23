import '../models/employee.dart';

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

  Employee? get selectedEmployee {
    if (selectedEmployeeId == null) {
      return null;
    }

    for (final employee in employees) {
      if (employee.id == selectedEmployeeId) {
        return employee;
      }
    }

    return null;
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
        'selectedEmployeeId: $selectedEmployeeId'
        ')';
  }
}
