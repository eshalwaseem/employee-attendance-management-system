abstract class AttendanceEvent {
  const AttendanceEvent();
}

class AttendanceLoaded extends AttendanceEvent {
  const AttendanceLoaded();
}

class CheckInRequested extends AttendanceEvent {
  final String employeeId;

  const CheckInRequested({required this.employeeId});
}

class AttendanceEmployeeSelected extends AttendanceEvent {
  final String employeeId;

  const AttendanceEmployeeSelected({required this.employeeId});
}

class AttendanceEmployeeCleared extends AttendanceEvent {
  const AttendanceEmployeeCleared();
}
