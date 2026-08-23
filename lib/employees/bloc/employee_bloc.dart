import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/employee.dart';
import 'employee_event.dart';
import 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  EmployeeBloc() : super(const EmployeeState()) {
    on<EmployeesLoaded>(_onEmployeesLoaded);
    on<EmployeeSelected>(_onEmployeeSelected);
    on<EmployeeSelectionCleared>(_onEmployeeSelectionCleared);
        on<EmployeeRegistered>(_onEmployeeRegistered);

  }

  Future<void> _onEmployeesLoaded(
    EmployeesLoaded event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(status: EmployeeStatus.loading, clearError: true));

    try {
      

      const employees = [
        Employee(
          id: '001',
          name: 'Team Lead',
          email: 'lead@company.com',
          managerId: null,
        ),

        Employee(
          id: '002',
          name: 'Employee A',
          email: 'employee.a@company.com',
          managerId: '001',
        ),

        Employee(
          id: '003',
          name: 'Employee B',
          email: 'employee.b@company.com',
          managerId: '001',
        ),

        Employee(
          id: '004',
          name: 'Sara Khan',
          email: 'sara@company.com',
          managerId: '002',
        ),

        Employee(
          id: '005',
          name: 'Ali Raza',
          email: 'ali@company.com',
          managerId: '002',
        ),

        Employee(
          id: '006',
          name: 'Hamza Ahmed',
          email: 'hamza@company.com',
          managerId: '003',
        ),

        Employee(
          id: '007',
          name: 'Iqra Siddiqui',
          email: 'iqra@company.com',
          managerId: '003',
        ),
      ];

      await Future<void>.delayed(const Duration(milliseconds: 300));

      emit(
        state.copyWith(
          status: EmployeeStatus.success,
          employees: employees,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: EmployeeStatus.failure,
          errorMessage: 'Unable to load employees.',
        ),
      );

      addError(error, StackTrace.current);
    }
  }

  void _onEmployeeSelected(
    EmployeeSelected event,
    Emitter<EmployeeState> emit,
  ) {
    emit(state.copyWith(selectedEmployeeId: event.employeeId));
  }

  void _onEmployeeSelectionCleared(
    EmployeeSelectionCleared event,
    Emitter<EmployeeState> emit,
  ) {
    emit(state.copyWith(clearSelection: true));
  }
  void _onEmployeeRegistered(
    EmployeeRegistered event,
    Emitter<EmployeeState> emit,
  ) {
    final employees = [...state.employees];

    final existingIndex = employees.indexWhere(
      (employee) => employee.id == event.employee.id,
    );

    if (existingIndex != -1) {
      employees[existingIndex] = event.employee;
    } else {
      employees.add(event.employee);
    }

    emit(state.copyWith(employees: employees));
  }
  List<Employee> getDirectReports(String managerId) {
    return state.employees
        .where((employee) => employee.managerId == managerId)
        .toList();
  }

  
  List<Employee> getAllReports(String managerId) {
    final result = <Employee>[];

    void findReports(String currentManagerId) {
      final directReports = getDirectReports(currentManagerId);

      for (final employee in directReports) {
        result.add(employee);
        findReports(employee.id);
      }
    }

    findReports(managerId);

    return result;
  }

  
  List<Employee> getAccessibleEmployees(String employeeId) {
    final currentEmployee = state.employees.cast<Employee?>().firstWhere(
      (employee) => employee?.id == employeeId,
      orElse: () => null,
    );

    if (currentEmployee == null) {
      return [];
    }

    return getAllReports(currentEmployee.id);
  }

  bool canViewEmployee({required String viewerId, required String targetId}) {
    if (viewerId == targetId) {
      return true;
    }

    final accessibleEmployees = getAccessibleEmployees(viewerId);

    return accessibleEmployees.any((employee) => employee.id == targetId);
  }
}
