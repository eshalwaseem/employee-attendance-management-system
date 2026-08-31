import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/attendance_repository.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository _repository;
  final FirebaseAuth _auth;

  AttendanceBloc({required AttendanceRepository repository, FirebaseAuth? auth})
    : _repository = repository,
      _auth = auth ?? FirebaseAuth.instance,
      super(const AttendanceState()) {
    on<AttendanceLoaded>(_onAttendanceLoaded);
    on<CheckInRequested>(_onCheckInRequested);
    on<AttendanceEmployeeSelected>(_onEmployeeSelected);
    on<AttendanceEmployeeCleared>(_onEmployeeCleared);
  }

  Future<void> _onAttendanceLoaded(
    AttendanceLoaded event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(
      state.copyWith(status: AttendanceStatusState.loading, clearError: true),
    );

    try {
      final records = await _repository.getAllRecords();

      emit(
        state.copyWith(
          status: AttendanceStatusState.success,
          records: records,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: AttendanceStatusState.failure,
          errorMessage: 'Unable to load attendance.',
        ),
      );

      addError(error, stackTrace);
    }
  }

  Future<void> _onCheckInRequested(
    CheckInRequested event,
    Emitter<AttendanceState> emit,
  ) async {

    if (state.isLoading) {
      return;
    }

    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      emit(
        state.copyWith(
          status: AttendanceStatusState.failure,
          errorMessage: 'You must be signed in to check in.',
        ),
      );

      return;
    }

    if (event.employeeId != firebaseUser.uid) {
      emit(
        state.copyWith(
          status: AttendanceStatusState.failure,
          errorMessage: 'You can only check in for yourself.',
        ),
      );

      return;
    }

    emit(
      state.copyWith(status: AttendanceStatusState.loading, clearError: true),
    );

    try {

      final attendance = await _repository.checkIn(
        employeeId: firebaseUser.uid,
      );

      final updatedRecords = [
        attendance,
        ...state.records.where((record) => record.id != attendance.id),
      ];

      updatedRecords.sort((a, b) => b.date.compareTo(a.date));

      emit(
        state.copyWith(
          status: AttendanceStatusState.success,
          records: updatedRecords,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {

      final message = error.toString().replaceFirst('Exception: ', '');

      emit(
        state.copyWith(
          status: AttendanceStatusState.failure,
          errorMessage: message.isEmpty
              ? 'Unable to mark attendance.'
              : message,
        ),
      );

      addError(error, stackTrace);
    }
  }

  void _onEmployeeSelected(
    AttendanceEmployeeSelected event,
    Emitter<AttendanceState> emit,
  ) {
    emit(state.copyWith(selectedEmployeeId: event.employeeId));
  }

  void _onEmployeeCleared(
    AttendanceEmployeeCleared event,
    Emitter<AttendanceState> emit,
  ) {
    emit(state.copyWith(clearSelection: true));
  }
}
