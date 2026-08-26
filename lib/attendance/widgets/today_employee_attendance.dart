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
        ? '—'
        : TimeOfDay.fromDateTime(checkIn).format(context);

    final hasImage = profileImagePath != null && profileImagePath!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
            backgroundImage: hasImage ? NetworkImage(profileImagePath!) : null,
            child: !hasImage
                ? Icon(
                    Icons.person_rounded,
                    color: theme.colorScheme.primary,
                    size: 30,
                  )
                : null,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              employeeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 10),

          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: 30,
          ),
        ],
      ),
    );
  }
}
