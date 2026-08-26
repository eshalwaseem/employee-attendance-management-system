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

  // ============================================================
  // GET ALL RECORDS
  // ============================================================

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

    // ==========================================================
    // ADMIN
    // ==========================================================

    if (role == 'admin') {
      query = _attendanceCollection;
    }
    // ==========================================================
    // MANAGER
    // ==========================================================
    else if (role == 'manager') {
      query = _attendanceCollection.where(
        'managerId',
        isEqualTo: firebaseUser.uid,
      );
    }
    // ==========================================================
    // EMPLOYEE
    // ==========================================================
    else {
      query = _attendanceCollection.where(
        'employeeId',
        isEqualTo: firebaseUser.uid,
      );
    }

    // ==========================================================
    // GET FIRESTORE DATA
    // ==========================================================

    final snapshot = await query.get();

    final records = snapshot.docs
        .map((document) => Attendance.fromFirestore(document))
        .toList();

    // ==========================================================
    // SORT LOCALLY
    // ==========================================================

    records.sort((a, b) => b.date.compareTo(a.date));

    return records;
  }

  // ============================================================
  // GET EMPLOYEE RECORDS
  // ============================================================

  Future<List<Attendance>> getEmployeeRecords(String employeeId) async {
    final records = await getAllRecords();

    return records.where((record) => record.employeeId == employeeId).toList();
  }

  // ============================================================
  // GET TODAY ATTENDANCE
  // ============================================================

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

  // ============================================================
  // SAVE ATTENDANCE
  // ============================================================

  Future<void> saveAttendance(Attendance attendance) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception('No user is signed in.');
    }

    // Employee can only create their own attendance.
    if (attendance.employeeId != firebaseUser.uid) {
      throw Exception('You can only save your own attendance.');
    }

    await _attendanceCollection
        .doc(attendance.id)
        .set(attendance.toFirestore());
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteAttendance(String attendanceId) async {
    await _attendanceCollection.doc(attendanceId).delete();
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

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

  // ============================================================
  // SAME DAY
  // ============================================================

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
