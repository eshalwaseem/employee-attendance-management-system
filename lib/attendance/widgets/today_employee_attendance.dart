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
    final isLate = hasAttendance && attendance!.status == AttendanceStatus.late;

    final statusText = !hasAttendance
        ? 'Absent'
        : isLate
        ? 'Late'
        : 'Present';

    final statusColor = !hasAttendance
        ? theme.colorScheme.error
        : isLate
        ? theme.colorScheme.error
        : theme.colorScheme.tertiary;

    final checkIn = attendance?.checkIn;

    final timeText = checkIn == null
        ? 'Not checked in'
        : 'Checked in at ${TimeOfDay.fromDateTime(checkIn).format(context)}';

    final hasImage = profileImagePath != null && profileImagePath!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
            backgroundImage: hasImage ? NetworkImage(profileImagePath!) : null,
            child: !hasImage
                ? Icon(
                    Icons.person_rounded,
                    color: theme.colorScheme.primary,
                    size: 25,
                  )
                : null,
          ),

          const SizedBox(width: 14),

          // Name + time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
 