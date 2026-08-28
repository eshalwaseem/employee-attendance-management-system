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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is DashboardState &&
        other.status == status &&
        other.isCheckedIn == isCheckedIn &&
        other.checkInTime == checkInTime &&
        other.presentDays == presentDays &&
        other.absentDays == absentDays &&
        other.lateDays == lateDays;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      isCheckedIn,
      checkInTime,
      presentDays,
      absentDays,
      lateDays,
    );
  }

  @override
  String toString() {
    return 'DashboardState('
        'status: $status, '
        'isCheckedIn: $isCheckedIn, '
        'checkInTime: $checkInTime, '
        'presentDays: $presentDays, '
        'absentDays: $absentDays, '
        'lateDays: $lateDays'
        ')';
  }
}
