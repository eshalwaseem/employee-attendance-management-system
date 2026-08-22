enum DashboardStatus {
  initial,
  loading,
  loaded,
  error,
}

class DashboardState {
  final DashboardStatus status;
  final bool isCheckedIn;
  final String? checkInTime;
  final int presentDays;
  final int absentDays;
  final int lateDays;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.isCheckedIn = false,
    this.checkInTime,
    this.presentDays = 0,
    this.absentDays = 0,
    this.lateDays = 0,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    bool? isCheckedIn,
    String? checkInTime,
    int? presentDays,
    int? absentDays,
    int? lateDays,
  }) {
    return DashboardState(
      status: status ?? this.status,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      checkInTime: checkInTime ?? this.checkInTime,
      presentDays: presentDays ?? this.presentDays,
      absentDays: absentDays ?? this.absentDays,
      lateDays: lateDays ?? this.lateDays,
    );
  }
}
