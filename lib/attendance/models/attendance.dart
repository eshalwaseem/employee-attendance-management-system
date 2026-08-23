enum AttendanceStatus { present, late, absent }

class Attendance {
  final String id;
  final String employeeId;
  final DateTime date;
  final DateTime? checkIn;
  final AttendanceStatus status;
  final bool isSynced;

  const Attendance({
    required this.id,
    required this.employeeId,
    required this.date,
    this.checkIn,
    required this.status,
    this.isSynced = true,
  });

  Attendance copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    DateTime? checkIn,
    AttendanceStatus? status,
    bool? isSynced,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      status: status ?? this.status,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      date: DateTime.parse(json['date'] as String),
      checkIn: json['checkIn'] == null
          ? null
          : DateTime.parse(json['checkIn'] as String),
      status: AttendanceStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      isSynced: json['isSynced'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      'checkIn': checkIn?.toIso8601String(),
      'status': status.name,
      'isSynced': isSynced,
    };
  }

  @override
  String toString() {
    return 'Attendance('
        'id: $id, '
        'employeeId: $employeeId, '
        'date: $date, '
        'checkIn: $checkIn, '
        'status: $status, '
        'isSynced: $isSynced'
        ')';
  }
}
