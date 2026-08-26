import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceStatus { present, late, absent }

class Attendance {
  final String id;
  final String employeeId;
  final String managerId;
  final DateTime date;
  final DateTime? checkIn;
  final AttendanceStatus status;
  final bool isSynced;

  const Attendance({
    required this.id,
    required this.employeeId,
    required this.managerId,
    required this.date,
    this.checkIn,
    required this.status,
    this.isSynced = true,
  });

  // ============================================================
  // COPY WITH
  // ============================================================

  Attendance copyWith({
    String? id,
    String? employeeId,
    String? managerId,
    DateTime? date,
    DateTime? checkIn,
    AttendanceStatus? status,
    bool? isSynced,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      managerId: managerId ?? this.managerId,
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      status: status ?? this.status,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  // ============================================================
  // FROM FIRESTORE
  // ============================================================

  factory Attendance.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    final dateValue = data['date'];
    final checkInValue = data['checkIn'];

    DateTime date;

    if (dateValue is Timestamp) {
      date = dateValue.toDate();
    } else if (dateValue is String) {
      date = DateTime.tryParse(dateValue) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }

    DateTime? checkIn;

    if (checkInValue is Timestamp) {
      checkIn = checkInValue.toDate();
    } else if (checkInValue is String) {
      checkIn = DateTime.tryParse(checkInValue);
    }

    return Attendance(
      id: document.id,
      employeeId: data['employeeId'] as String? ?? '',
      managerId: data['managerId'] as String? ?? '',
      date: date,
      checkIn: checkIn,
      status: AttendanceStatus.values.firstWhere(
        (value) => value.name == data['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      isSynced: data['isSynced'] as bool? ?? true,
    );
  }

  // ============================================================
  // TO FIRESTORE
  // ============================================================

  Map<String, dynamic> toFirestore() {
    return {
      'employeeId': employeeId,
      'managerId': managerId,
      'date': Timestamp.fromDate(date),
      'checkIn': checkIn == null ? null : Timestamp.fromDate(checkIn!),
      'status': status.name,
      'isSynced': isSynced,
    };
  }

  // ============================================================
  // TO STRING
  // ============================================================

  @override
  String toString() {
    return 'Attendance('
        'id: $id, '
        'employeeId: $employeeId, '
        'managerId: $managerId, '
        'date: $date, '
        'checkIn: $checkIn, '
        'status: $status, '
        'isSynced: $isSynced'
        ')';
  }
}
