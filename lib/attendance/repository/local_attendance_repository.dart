import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/attendance.dart';

class LocalAttendanceRepository {
  static const String _attendanceKey = 'attendance_records';

  
  Future<List<Attendance>> getAllRecords() async {
    final preferences = await SharedPreferences.getInstance();

    final jsonString = preferences.getString(_attendanceKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .map(
            (item) =>
                Attendance.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ----------------------------------------------------------
  // GET EMPLOYEE RECORDS
  // ----------------------------------------------------------

  Future<List<Attendance>> getEmployeeRecords(String employeeId) async {
    final records = await getAllRecords();

    return records.where((record) => record.employeeId == employeeId).toList();
  }

  // ----------------------------------------------------------
  // GET TODAY'S RECORD
  // ----------------------------------------------------------

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

  // ----------------------------------------------------------
  // SAVE RECORD
  // ----------------------------------------------------------

  Future<void> saveAttendance(Attendance attendance) async {
    final records = await getAllRecords();

    // Prevent duplicate attendance for the same employee/day.
    final existingIndex = records.indexWhere(
      (record) =>
          record.employeeId == attendance.employeeId &&
          _isSameDay(record.date, attendance.date),
    );

    if (existingIndex != -1) {
      records[existingIndex] = attendance;
    } else {
      records.add(attendance);
    }

    await _saveRecords(records);
  }

  // ----------------------------------------------------------
  // DELETE RECORD
  // ----------------------------------------------------------

  Future<void> deleteAttendance(String attendanceId) async {
    final records = await getAllRecords();

    records.removeWhere((record) => record.id == attendanceId);

    await _saveRecords(records);
  }

  // ----------------------------------------------------------
  // CLEAR ALL
  // ----------------------------------------------------------

  Future<void> clearAll() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_attendanceKey);
  }

  // ----------------------------------------------------------
  // PRIVATE SAVE
  // ----------------------------------------------------------

  Future<void> _saveRecords(List<Attendance> records) async {
    final preferences = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(
      records.map((record) => record.toJson()).toList(),
    );

    await preferences.setString(_attendanceKey, jsonString);
  }

  // ----------------------------------------------------------
  // SAME DAY
  // ----------------------------------------------------------

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
