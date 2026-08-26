import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance.dart';
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

  // ============================================================
  // LOAD ATTENDANCE
  // ============================================================

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

  // ============================================================
  // CHECK IN
  // ============================================================

Future<void> _onCheckInRequested(
    CheckInRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    if (state.isLoading) {
      return;
    }

    final firebaseUser = _auth.currentUser;

    // ------------------------------------------------------------
    // USER MUST BE LOGGED IN
    // ------------------------------------------------------------

    if (firebaseUser == null) {
      emit(
        state.copyWith(
          status: AttendanceStatusState.failure,
          errorMessage: 'You must be signed in to check in.',
        ),
      );
      return;
    }

    // ------------------------------------------------------------
    // EMPLOYEE CAN ONLY CHECK THEMSELVES IN
    // ------------------------------------------------------------

    if (event.employeeId != firebaseUser.uid) {
      emit(
        state.copyWith(
          status: AttendanceStatusState.failure,
          errorMessage: 'You can only check in for yourself.',
        ),
      );
      return;
    }

    try {
      // ----------------------------------------------------------
      // GET EMPLOYEE PROFILE
      // ----------------------------------------------------------

      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDocument.exists) {
        emit(
          state.copyWith(
            status: AttendanceStatusState.failure,
            errorMessage: 'User profile not found.',
          ),
        );
        return;
      }

      final userData = userDocument.data()!;

      final role = userData['role'] as String? ?? 'employee';

      final managerId = userData['managerId'] as String?;

      // ----------------------------------------------------------
      // EMPLOYEE MUST HAVE A MANAGER
      // ----------------------------------------------------------

      if (role == 'employee' && (managerId == null || managerId.isEmpty)) {
        emit(
          state.copyWith(
            status: AttendanceStatusState.failure,
            errorMessage: 'No manager has been assigned to you.',
          ),
        );
        return;
      }

      final now = DateTime.now();

      // ----------------------------------------------------------
      // CHECK-IN WINDOW
      // ----------------------------------------------------------

      final checkInStart = DateTime(now.year, now.month, now.day, 8, 30);

      final checkInEnd = DateTime(now.year, now.month, now.day, 17, 0);

      // ----------------------------------------------------------
      // BEFORE 8:30 AM
      // ----------------------------------------------------------

      if (now.isBefore(checkInStart)) {
        emit(
          state.copyWith(
            status: AttendanceStatusState.failure,
            errorMessage:
                'Check-in is not available yet. Check-in starts at 8:30 AM.',
          ),
        );
        return;
      }

      // ----------------------------------------------------------
      // AFTER 5 PM
      // ----------------------------------------------------------

      if (!now.isBefore(checkInEnd)) {
        emit(
          state.copyWith(
            status: AttendanceStatusState.failure,
            errorMessage:
                'Check-in is closed. Check-in is only available until 5:00 PM.',
          ),
        );
        return;
      }

      // ----------------------------------------------------------
      // PREVENT DUPLICATE CHECK-IN
      // ----------------------------------------------------------

      final alreadyCheckedIn = state.records.any(
        (record) =>
            record.employeeId == firebaseUser.uid &&
            _isSameDay(record.date, now),
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

      // ----------------------------------------------------------
      // SAVE TO FIRESTORE
      // ----------------------------------------------------------

      emit(
        state.copyWith(status: AttendanceStatusState.loading, clearError: true),
      );

      final attendance = Attendance(
        id: 'attendance-${now.millisecondsSinceEpoch}',
        employeeId: firebaseUser.uid,
        managerId: managerId ?? '',
        date: now,
        checkIn: now,
        status: _getAttendanceStatus(now),
        isSynced: true,
      );

      await _repository.saveAttendance(attendance);

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

  // ============================================================
  // DETERMINE ATTENDANCE STATUS
  // ============================================================

  AttendanceStatus _getAttendanceStatus(DateTime checkIn) {
    final lateTime = DateTime(checkIn.year, checkIn.month, checkIn.day, 9, 15);

    if (checkIn.isAfter(lateTime)) {
      return AttendanceStatus.late;
    }

    return AttendanceStatus.present;
  }

  // ============================================================
  // SAME DAY
  // ============================================================

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  // ============================================================
  // EMPLOYEE SELECTION
  // ============================================================

  void _onEmployeeSelected(
    AttendanceEmployeeSelected event,
    Emitter<AttendanceState> emit,
  ) {
    emit(state.copyWith(selectedEmployeeId: event.employeeId));
  }

  // ============================================================
  // CLEAR EMPLOYEE SELECTION
  // ============================================================

  void _onEmployeeCleared(
    AttendanceEmployeeCleared event,
    Emitter<AttendanceState> emit,
  ) {
    emit(state.copyWith(clearSelection: true));
  }
}
