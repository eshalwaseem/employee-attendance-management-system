import 'package:flutter/material.dart';

import '../models/attendance.dart';

class AttendanceListItem extends StatelessWidget {
  final String employeeName;
  final String? profileImagePath;

  final DateTime date;

  final Attendance? attendance;

  final bool showEmployeeName;

  const AttendanceListItem({
    super.key,
    required this.employeeName,
    required this.date,
    required this.attendance,
    this.profileImagePath,
    this.showEmployeeName = true,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasAttendance = attendance != null;
    final isLate = hasAttendance && attendance!.status == AttendanceStatus.late;

    final now = DateTime.now();
    final isToday = _isSameDay(date, now);
    final checkInEnd = DateTime(date.year, date.month, date.day, 17, 30);
    final windowClosed = isToday ? !now.isBefore(checkInEnd) : true;

    final statusText = hasAttendance
        ? (isLate ? 'Late' : 'Present')
        : (windowClosed ? 'Absent' : 'Not Checked In');

    final statusColor = hasAttendance
        ? (isLate ? theme.colorScheme.error : theme.colorScheme.tertiary)
        : (windowClosed
              ? theme.colorScheme.error
              : theme.colorScheme.onSurfaceVariant);

    final checkIn = attendance?.checkIn;

    final timeText = checkIn == null
        ? '--:--'
        : TimeOfDay.fromDateTime(checkIn).format(context);

    final subtitleText = hasAttendance
        ? 'Checked in at $timeText'
        : (windowClosed ? 'No check-in recorded' : 'Not checked in yet');

    final icon = hasAttendance
        ? (isLate ? Icons.schedule_rounded : Icons.check_rounded)
        : (windowClosed ? Icons.close_rounded : Icons.schedule_outlined);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEAEAEA),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: statusColor),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showEmployeeName) ...[
                  Text(
                    employeeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                Text(
                  _formatDate(date),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 3),

                Row(
                  children: [
                    Icon(
                      Icons.login_rounded,
                      size: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subtitleText,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
