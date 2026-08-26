import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/employee_repository.dart';
import '../models/employee.dart';
import 'employee_event.dart';
import 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository _repository;
  final FirebaseAuth _auth;

  EmployeeBloc({required EmployeeRepository repository, FirebaseAuth? auth})
    : _repository = repository,
      _auth = auth ?? FirebaseAuth.instance,
      super(const EmployeeState()) {
    on<EmployeesLoaded>(_onEmployeesLoaded);
    on<EmployeesReloadRequested>(_onEmployeesReloadRequested);

    on<EmployeeLoaded>(_onEmployeeLoaded);
    on<EmployeeCleared>(_onEmployeeCleared);

    on<EmployeeSelected>(_onEmployeeSelected);
    on<EmployeeSelectionCleared>(_onEmployeeSelectionCleared);

    on<EmployeeRegistered>(_onEmployeeRegistered);

    on<EmployeeAuthorityAssigned>(_onEmployeeAuthorityAssigned);

    on<EmployeeManagerAssigned>(_onEmployeeManagerAssigned);

    on<EmployeeManagerRemoved>(_onEmployeeManagerRemoved);

    on<EmployeeDeleted>(_onEmployeeDeleted);
  }

  // ============================================================
  // LOAD ALL EMPLOYEES
  // ============================================================

  Future<void> _onEmployeesLoaded(
    EmployeesLoaded event,
    Emitter<EmployeeState> emit,
  ) async {
    await _loadEmployees(emit);
  }

  // ============================================================
  // RELOAD
  // ============================================================

  Future<void> _onEmployeesReloadRequested(
    EmployeesReloadRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    await _loadEmployees(emit);
  }

  Future<void> _loadEmployees(Emitter<EmployeeState> emit) async {
    emit(state.copyWith(status: EmployeeStatus.loading, clearError: true));

    try {
      final firebaseUser = _auth.currentUser;

      if (firebaseUser == null) {
        throw Exception('You must be signed in.');
      }

      final employees = await _repository.getEmployees(firebaseUser.uid);

      String? selectedId = state.selectedEmployeeId;

      if (selectedId != null &&
          !employees.any((employee) => employee.id == selectedId)) {
        selectedId = null;
      }

      emit(
        EmployeeState(
          status: EmployeeStatus.success,
          employees: employees,
          selectedEmployeeId: selectedId,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: EmployeeStatus.failure,
          errorMessage: _cleanError(error),
        ),
      );

      addError(error, stackTrace);
    }
  }
  // ============================================================
  // CURRENT EMPLOYEE LOADED
  // ============================================================

  void _onEmployeeLoaded(EmployeeLoaded event, Emitter<EmployeeState> emit) {
    final employees = [...state.employees];

    final existingIndex = employees.indexWhere(
      (employee) => employee.id == event.employee.id,
    );

    if (existingIndex == -1) {
      employees.add(event.employee);
    } else {
      employees[existingIndex] = event.employee;
    }

    emit(
      state.copyWith(
        status: EmployeeStatus.success,
        employees: employees,
        selectedEmployeeId: event.employee.id,
        clearError: true,
      ),
    );
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void _onEmployeeCleared(EmployeeCleared event, Emitter<EmployeeState> emit) {
    emit(const EmployeeState());
  }

  // ============================================================
  // SELECT
  // ============================================================

  void _onEmployeeSelected(
    EmployeeSelected event,
    Emitter<EmployeeState> emit,
  ) {
    final exists = state.employees.any(
      (employee) => employee.id == event.employeeId,
    );

    if (!exists) {
      return;
    }

    emit(state.copyWith(selectedEmployeeId: event.employeeId));
  }

  // ============================================================
  // CLEAR SELECTION
  // ============================================================

  void _onEmployeeSelectionCleared(
    EmployeeSelectionCleared event,
    Emitter<EmployeeState> emit,
  ) {
    emit(state.copyWith(clearSelection: true));
  }

  // ============================================================
  // REGISTERED
  // ============================================================

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

    emit(
      state.copyWith(
        status: EmployeeStatus.success,
        employees: employees,
        selectedEmployeeId: event.employee.id,
        clearError: true,
      ),
    );
  }

  // ============================================================
  // ASSIGN AUTHORITY
  // ============================================================

  Future<void> _onEmployeeAuthorityAssigned(
    EmployeeAuthorityAssigned event,
    Emitter<EmployeeState> emit,
  ) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      emit(
        state.copyWith(
          status: EmployeeStatus.failure,
          errorMessage: 'You must be signed in to assign a role.',
        ),
      );
      return;
    }

    final actingEmployee = state.getById(firebaseUser.uid);

    if (actingEmployee == null || !actingEmployee.isAdmin) {
      emit(
        state.copyWith(
          status: EmployeeStatus.failure,
          errorMessage: 'Only an admin can assign roles.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: EmployeeStatus.loading, clearError: true));

    try {
      final updatedEmployee = await _repository.assignAuthority(
        employeeId: event.employeeId,
        role: event.role,
        managerId: event.managerId,
        permissions: event.permissions,
      );

      final employees = _replaceEmployee(state.employees, updatedEmployee);

      emit(
        state.copyWith(
          status: EmployeeStatus.success,
          employees: employees,
          selectedEmployeeId: updatedEmployee.id,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: EmployeeStatus.failure,
          errorMessage: _cleanError(error),
        ),
      );

      addError(error, stackTrace);
    }
  }

  // ============================================================
  // ASSIGN MANAGER
  // ============================================================

  Future<void> _onEmployeeManagerAssigned(
    EmployeeManagerAssigned event,
    Emitter<EmployeeState> emit,
  ) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      emit(
        state.copyWith(
          status: EmployeeStatus.failure,
          errorMessage: 'You must be signed in to assign a manager.',
        ),
      );
      return;
    }

    final actingEmployee = state.getById(firebaseUser.uid);

    if (actingEmployee == null || !actingEmployee.isAdmin) {
      emit(
        state.copyWith(
          status: EmployeeStatus.failure,
          errorMessage: 'Only an admin can assign a manager.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: EmployeeStatus.loading, clearError: true));

    try {
      final updatedEmployee = await _repository.assignManager(
        employeeId: event.employeeId,
        managerId: event.managerId,
      );

      final employees = _replaceEmployee(state.employees, updatedEmployee);

      emit(
        state.copyWith(
          status: EmployeeStatus.success,
          employees: employees,
          selectedEmployeeId: updatedEmployee.id,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: EmployeeStatus.failure,
          errorMessage: _cleanError(error),
        ),
      );

      addError(error, stackTrace);
    }
  }

  // ============================================================
  // REMOVE MANAGER
  // ============================================================

  Future<void> _onEmployeeManagerRemoved(
    EmployeeManagerRemoved event,
    Emitter<EmployeeState> emit,
  ) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      emit(
        state.copyWith(
          status: EmployeeStatus.failure,
          errorMessage: 'You must be signed in to remove a manager.',
        ),
      );
      return;
    }

    final actingEmployee = state.getById(firebaseUser.uid);

    final target = state.getById(event.employeeId);

    if (target == null) {
      emit(
        state.copyWith(
          status: EmployeeStatus.failure,
          errorMessage: 'Employee not found.',
        ),
      );
      return;
    }

    final isAdmin = actingEmployee?.isAdmin ?? false;

    final isSelfManaged =
        actingEmployee != null && target.managerId == actingEmployee.id;

    if (!isAdmin && !isSelfManaged) {
      emit(
        state.copyWith(
          status: EmployeeStatus.failure,
          errorMessage: 'You do not have permission to remove this manager.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: EmployeeStatus.loading, clearError: true));

    try {
      final updatedEmployee = await _repository.removeManager(event.employeeId);

      final employees = _replaceEmployee(state.employees, updatedEmployee);

      emit(
        state.copyWith(
          status: EmployeeStatus.success,
          employees: employees,
          selectedEmployeeId: updatedEmployee.id,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: EmployeeStatus.failure,
          errorMessage: _cleanError(error),
        ),
      );

      addError(error, stackTrace);
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _onEmployeeDeleted(
    EmployeeDeleted event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(status: EmployeeStatus.loading, clearError: true));

    try {
      await _repository.deleteEmployeeProfile(event.employeeId);

      final employees = state.employees
          .where((employee) => employee.id != event.employeeId)
          .toList();

      final clearSelection = state.selectedEmployeeId == event.employeeId;

      emit(
        state.copyWith(
          status: EmployeeStatus.success,
          employees: employees,
          clearSelection: clearSelection,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: EmployeeStatus.failure,
          errorMessage: _cleanError(error),
        ),
      );

      addError(error, stackTrace);
    }
  }

  // ============================================================
  // REPLACE EMPLOYEE
  // ============================================================

  List<Employee> _replaceEmployee(
    List<Employee> employees,
    Employee updatedEmployee,
  ) {
    final result = [...employees];

    final index = result.indexWhere(
      (employee) => employee.id == updatedEmployee.id,
    );

    if (index == -1) {
      result.add(updatedEmployee);
    } else {
      result[index] = updatedEmployee;
    }

    return result;
  }

  // ============================================================
  // CLEAN ERROR
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }
}
