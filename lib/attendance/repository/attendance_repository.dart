import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/attendance.dart';

class AttendanceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AttendanceRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _attendanceCollection =>
      _firestore.collection('attendance');


  Future<List<Attendance>> getAllRecords() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception('No user is signed in.');
    }

    final userDocument = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!userDocument.exists) {
      throw Exception('User profile not found.');
    }

    final userData = userDocument.data();

    if (userData == null) {
      throw Exception('User profile data is empty.');
    }

    final role = userData['role'] as String? ?? 'employee';

    Query<Map<String, dynamic>> query;


    if (role == 'admin') {
      query = _attendanceCollection;
    }

    else if (role == 'manager') {
      final teamSnapshot = await _attendanceCollection
          .where('managerId', isEqualTo: firebaseUser.uid)
          .get();

      final ownSnapshot = await _attendanceCollection
          .where('employeeId', isEqualTo: firebaseUser.uid)
          .get();

      final seenIds = <String>{};
      final records = <Attendance>[];

      for (final doc in [...teamSnapshot.docs, ...ownSnapshot.docs]) {
        if (seenIds.add(doc.id)) {
          records.add(Attendance.fromFirestore(doc));
        }
      }

      records.sort((a, b) => b.date.compareTo(a.date));

      return records;
    }
    
    else {
      query = _attendanceCollection.where(
        'employeeId',
        isEqualTo: firebaseUser.uid,
      );
    }

    final snapshot = await query.get();

    final records = snapshot.docs
        .map((document) => Attendance.fromFirestore(document))
        .toList();

    records.sort((a, b) => b.date.compareTo(a.date));

    return records;
  }

  Future<List<Attendance>> getEmployeeRecords(String employeeId) async {
    final records = await getAllRecords();

    return records.where((record) => record.employeeId == employeeId).toList();
  }

  Future<Attendance?> getTodayAttendance(String employeeId) async {
    final records = await getEmployeeRecords(employeeId);

    final now = DateTime.now();

    for (final record in records) {
      if (_isSameDay(record.date, now)) {
        return record;
      }
    }

    return null;
  }


  AttendanceStatus? getEffectiveStatus(Attendance? record, DateTime now) {
    if (record != null) {
      return record.status;
    }

    final isWeekend =
        now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

    if (isWeekend) {
      return null;
    }

    final checkInEnd = DateTime(now.year, now.month, now.day, 17, 30);

    if (!now.isBefore(checkInEnd)) {
      return AttendanceStatus.absent;
    }

    return null;
  }


  Future<Attendance> checkIn({required String employeeId}) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception('No user is signed in.');
    }

    if (firebaseUser.uid != employeeId) {
      throw Exception('You can only check in yourself.');
    }

    final userDocument = await _firestore
        .collection('users')
        .doc(employeeId)
        .get();

    if (!userDocument.exists) {
      throw Exception('User profile not found.');
    }

    final userData = userDocument.data();

    if (userData == null) {
      throw Exception('User profile data is empty.');
    }

    final role = userData['role'] as String? ?? 'employee';

    String? managerId;

    if (role == 'employee') {
      managerId = userData['managerId'] as String?;

      if (managerId == null || managerId.isEmpty) {
        throw Exception('Manager is not assigned to this employee.');
      }
    }

    final existingRecords = await _attendanceCollection
        .where('employeeId', isEqualTo: employeeId)
        .get();

    final today = DateTime.now();

    for (final document in existingRecords.docs) {
      final existing = Attendance.fromFirestore(document);

      if (_isSameDay(existing.date, today)) {
        throw Exception('You have already checked in today.');
      }
    }

    final attendanceRef = _attendanceCollection.doc();

    await attendanceRef.set({
      'employeeId': employeeId,
      'managerId': managerId,

      'date': FieldValue.serverTimestamp(),

      'checkIn': FieldValue.serverTimestamp(),
      'status': AttendanceStatus.present.name,

      'isSynced': true,
    });

    final savedDocument = await attendanceRef.get();

    if (!savedDocument.exists) {
      throw Exception('Attendance was not saved to Firestore.');
    }

    final savedData = savedDocument.data();

    if (savedData == null) {
      throw Exception('Attendance data is empty.');
    }

    final serverCheckIn = savedData['checkIn'];

    if (serverCheckIn is! Timestamp) {
      throw Exception('Firestore did not return a valid server timestamp.');
    }

    final serverDate = serverCheckIn.toDate();

    final minutesSinceMidnight = serverDate.hour * 60 + serverDate.minute;

    const lateThreshold = 9 * 60 + 30;

    final AttendanceStatus status = minutesSinceMidnight >= lateThreshold
        ? AttendanceStatus.late
        : AttendanceStatus.present;

    await attendanceRef.update({'status': status.name});

    final finalDocument = await attendanceRef.get();

    if (!finalDocument.exists) {
      throw Exception('Attendance record was not found after saving.');
    }

    final attendance = Attendance.fromFirestore(finalDocument);

    return attendance;
  }

  Future<void> saveAttendance(Attendance attendance) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception('No user is signed in.');
    }

    if (attendance.employeeId != firebaseUser.uid) {
      throw Exception('You can only save your own attendance.');
    }

    await _attendanceCollection
        .doc(attendance.id)
        .set(attendance.toFirestore(), SetOptions(merge: true));

    final savedDocument = await _attendanceCollection.doc(attendance.id).get();

    if (!savedDocument.exists) {
      throw Exception('Attendance was not saved to Firestore.');
    }

    print('ATTENDANCE SAVED: ${attendance.id}');
  }

  Future<void> deleteAttendance(String attendanceId) async {
    await _attendanceCollection.doc(attendanceId).delete();
  }

  Future<void> clearAll() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception('No user is signed in.');
    }

    final userDocument = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    final role = userDocument.data()?['role'] as String? ?? 'employee';

    if (role != 'admin') {
      throw Exception('Only admin can clear attendance.');
    }

    final snapshot = await _attendanceCollection.get();

    final batch = _firestore.batch();

    for (final document in snapshot.docs) {
      batch.delete(document.reference);
    }

    await batch.commit();
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
