import 'package:flutter/material.dart';

import '../models/attendance.dart';
import 'attendance_list_item.dart';

class EmployeeAttendanceCard extends StatelessWidget {
  final String employeeName;
  final String? profileImagePath;
  final List<Attendance> records;

  const EmployeeAttendanceCard({
    super.key,
    required this.employeeName,
    required this.records,
    this.profileImagePath,
  });

  int get presentCount {
    return records
        .where((record) => record.status == AttendanceStatus.present)
        .length;
  }

  int get lateCount {
    return records
        .where((record) => record.status == AttendanceStatus.late)
        .length;
  }

  List<Attendance> get sortedRecords {
    final result = [...records];

    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          leading: _buildProfile(theme),

          title: Text(
            employeeName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                _SummaryItem(
                  label: 'Present',
                  value: presentCount,
                  color: theme.colorScheme.tertiary,
                ),

                const SizedBox(width: 12),

                _SummaryItem(
                  label: 'Late',
                  value: lateCount,
                  color: theme.colorScheme.error,
                ),

                const SizedBox(width: 12),

                _SummaryItem(
                  label: 'Total',
                  value: records.length,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),

          children: [
            if (records.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No attendance recorded.',
                  style: TextStyle(color: Color(0xFF777777), fontSize: 13),
                ),
              )
            else
              ...sortedRecords.map(
                (record) => AttendanceListItem(
                  employeeName: employeeName,
                  profileImagePath: profileImagePath,
                  attendance: record,
                  showEmployeeName: false,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(ThemeData theme) {
    final hasImage = profileImagePath != null && profileImagePath!.isNotEmpty;

    return CircleAvatar(
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
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF777777),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
