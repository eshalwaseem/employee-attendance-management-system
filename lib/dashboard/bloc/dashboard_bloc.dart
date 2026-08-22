import 'package:flutter_bloc/flutter_bloc.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc()
      : super(const DashboardState()) {
    on<DashboardStarted>(_onDashboardStarted);
    on<CheckInRequested>(_onCheckInRequested);
  }

  Future<void> _onDashboardStarted(
    DashboardStarted event,
    Emitter<DashboardState> emit,
  ) async {
    emit(
      state.copyWith(
        status: DashboardStatus.loading,
      ),
    );

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    emit(
      state.copyWith(
        status: DashboardStatus.loaded,
        presentDays: 18,
        absentDays: 2,
        lateDays: 1,
      ),
    );
  }

  void _onCheckInRequested(
    CheckInRequested event,
    Emitter<DashboardState> emit,
  ) {
    final now = DateTime.now();

    final hour = now.hour > 12
        ? now.hour - 12
        : now.hour == 0
            ? 12
            : now.hour;

    final minute = now.minute.toString().padLeft(2, '0');

    final period = now.hour >= 12 ? 'PM' : 'AM';

    emit(
      state.copyWith(
        isCheckedIn: true,
        checkInTime: '$hour:$minute $period',
      ),
    );
  }
}
