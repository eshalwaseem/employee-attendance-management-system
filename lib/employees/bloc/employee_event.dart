import '../models/employee.dart';

abstract class EmployeeEvent {
  const EmployeeEvent();
}

class EmployeesLoaded extends EmployeeEvent {
  const EmployeesLoaded();
}

class EmployeeSelected extends EmployeeEvent {
  final String employeeId;

  const EmployeeSelected(this.employeeId);
}

class EmployeeSelectionCleared extends EmployeeEvent {
  const EmployeeSelectionCleared();
}

class EmployeeRegistered extends EmployeeEvent {
  final Employee employee;
  const EmployeeRegistered(this.employee);
}
