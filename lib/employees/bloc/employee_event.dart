import '../models/employee.dart';
import '../../authentication/models/user.dart';

abstract class EmployeeEvent {
  const EmployeeEvent();
}


class EmployeesLoaded extends EmployeeEvent {
  const EmployeesLoaded();
}



class EmployeeLoaded extends EmployeeEvent {
  final Employee employee;

  const EmployeeLoaded(this.employee);
}


class EmployeesReloadRequested extends EmployeeEvent {
  const EmployeesReloadRequested();
}


class EmployeeCleared extends EmployeeEvent {
  const EmployeeCleared();
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


class EmployeeManagerAssigned extends EmployeeEvent {
  final String employeeId;
  final String managerId;

  const EmployeeManagerAssigned({
    required this.employeeId,
    required this.managerId,
  });
}



class EmployeeManagerRemoved extends EmployeeEvent {
  final String employeeId;

  const EmployeeManagerRemoved({
    required this.employeeId,
  });
}


class EmployeeDeleted extends EmployeeEvent {
  final String employeeId;

  const EmployeeDeleted({
    required this.employeeId,
  });
}