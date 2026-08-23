import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/attendance.dart';
import '../repository/local_attendance_repository.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final LocalAttendanceRepository repository;

  AttendanceBloc({required this.repository}) : super(const AttendanceState()) {
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
      final records = await repository.getAllRecords();

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

    final alreadyCheckedIn = state.records.any(
      (record) =>
          record.employeeId == event.employeeId &&
          _isSameDay(record.date, DateTime.now()),
    );

    if (alreadyCheckedIn) {
      emit(
        state.copyWith(
          status: AttendanceStatusState.failure,
          errorMessage: 'You have already checked in today.',
        ),
      );

      return;
    }

    emit(
      state.copyWith(status: AttendanceStatusState.loading, clearError: true),
    );

    try {
      final now = DateTime.now();

      final attendance = Attendance(
        id: 'attendance-${now.millisecondsSinceEpoch}',
        employeeId: event.employeeId,
        date: now,
        checkIn: now,
        status: _getAttendanceStatus(now),
        isSynced: false,
      );

      await repository.saveAttendance(attendance);

      final updatedRecords = [attendance, ...state.records];

      emit(
        state.copyWith(
          status: AttendanceStatusState.success,
          records: updatedRecords,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: AttendanceStatusState.failure,
          errorMessage: 'Unable to mark attendance.',
        ),
      );

      addError(error, stackTrace);
    }
  }

  AttendanceStatus _getAttendanceStatus(DateTime checkIn) {
    final lateTime = DateTime(checkIn.year, checkIn.month, checkIn.day, 9, 15);

    if (checkIn.isAfter(lateTime)) {
      return AttendanceStatus.late;
    }

    return AttendanceStatus.present;
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
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
