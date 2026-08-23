import 'package:flutter/material.dart';

import '../models/attendance.dart';

class AttendanceListItem extends StatelessWidget {
  final String employeeName;
  final Attendance attendance;

  const AttendanceListItem({
    super.key,
    required this.employeeName,
    required this.attendance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isLate = attendance.status == AttendanceStatus.late;

    final statusText = isLate ? 'Late' : 'Present';

    final statusColor = isLate
        ? theme.colorScheme.error
        : theme.colorScheme.tertiary;

    final checkIn = attendance.checkIn;

    final timeText = checkIn == null
        ? '--:--'
        : TimeOfDay.fromDateTime(checkIn).format(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              color: theme.colorScheme.primary,
              size: 25,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employeeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 15,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(timeText, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
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
