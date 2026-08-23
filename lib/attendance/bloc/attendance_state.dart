import '../models/attendance.dart';

enum AttendanceStatusState { initial, loading, success, failure }

class AttendanceState {
  final AttendanceStatusState status;
  final List<Attendance> records;
  final String? selectedEmployeeId;
  final String? errorMessage;

  const AttendanceState({
    this.status = AttendanceStatusState.initial,
    this.records = const [],
    this.selectedEmployeeId,
    this.errorMessage,
  });

  bool get isLoading => status == AttendanceStatusState.loading;

  bool get hasError => status == AttendanceStatusState.failure;

  AttendanceState copyWith({
    AttendanceStatusState? status,
    List<Attendance>? records,
    String? selectedEmployeeId,
    String? errorMessage,
    bool clearSelection = false,
    bool clearError = false,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      records: records ?? this.records,
      selectedEmployeeId: clearSelection
          ? null
          : selectedEmployeeId ?? this.selectedEmployeeId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'AttendanceState('
        'status: $status, '
        'records: ${records.length}, '
        'selectedEmployeeId: $selectedEmployeeId'
        ')';
  }
}
