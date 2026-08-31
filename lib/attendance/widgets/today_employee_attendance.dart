import 'package:flutter/material.dart';
import '../models/attendance.dart';

class TodayEmployeeAttendanceTile extends StatelessWidget {
  final String employeeName;
  final String? profileImagePath;
  final Attendance? attendance;

  const TodayEmployeeAttendanceTile({
    super.key,
    required this.employeeName,
    required this.attendance,
    this.profileImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasAttendance = attendance != null;

    final isLate = hasAttendance &&
        attendance!.status == AttendanceStatus.late;

   
    final now = DateTime.now();

    final checkInEnd = DateTime(
      now.year,
      now.month,
      now.day,
      17,
      30,
    );

    final isWeekend =
        now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;

    final windowClosed = !isWeekend && !now.isBefore(checkInEnd);

    final statusText = hasAttendance
        ? (isLate ? 'Late' : 'Present')
        : (windowClosed ? 'Absent' : 'Not Checked In');

    final statusColor = hasAttendance
        ? (isLate
            ? theme.colorScheme.error
            : theme.colorScheme.tertiary)
        : (windowClosed
            ? theme.colorScheme.error
            : theme.colorScheme.onSurfaceVariant);

    final checkIn = attendance?.checkIn;

    final timeText = checkIn == null
        ? 'Not checked in'
        : 'Checked in at ${TimeOfDay.fromDateTime(checkIn).format(context)}';

    final hasImage =
        profileImagePath != null && profileImagePath!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color:
                  theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? Image.network(
                    profileImagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Icon(
                        Icons.person_rounded,
                        color: theme.colorScheme.primary,
                        size: 25,
                      );
                    },
                  )
                : Icon(
                    Icons.person_rounded,
                    color: theme.colorScheme.primary,
                    size: 25,
                  ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employeeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  timeText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}