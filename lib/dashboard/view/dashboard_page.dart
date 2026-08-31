import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../authentication/bloc/auth_state.dart';
import '../../attendance/bloc/attendance_bloc.dart';
import '../../attendance/bloc/attendance_event.dart';
import '../../attendance/bloc/attendance_state.dart';
import '../../attendance/models/attendance.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../widgets/widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AttendanceBloc>().add(const AttendanceLoaded());
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    }

    if (hour < 17) {
      return 'Good afternoon';
    }

    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final avatarBg = isDark
        ? theme.colorScheme.primary.withValues(alpha: 0.08)
        : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      bottomNavigationBar: const AppBottomNavigation(selectedIndex: 0),

      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final user = authState.user;

            final userName = user?.name.isNotEmpty == true
                ? user!.name
                : authState.name.isNotEmpty
                ? authState.name
                : 'Employee';

            final employeeId = user?.id;

            final profileImage = authState.profileImage;

            return BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, attendanceState) {
                
                final records = employeeId == null
                    ? <Attendance>[]
                    : attendanceState.records
                          .where((record) => record.employeeId == employeeId)
                          .toList();

                final todayRecords = records.where(_isToday).toList();

                final todayAttendance = todayRecords.isEmpty
                    ? null
                    : todayRecords.first;

                final isCheckedIn = todayAttendance != null;

                final checkInTime = todayAttendance?.checkIn;

                final presentDays = records
                    .where(
                      (record) => record.status == AttendanceStatus.present,
                    )
                    .length;

                final lateDays = records
                    .where((record) => record.status == AttendanceStatus.late)
                    .length;

                final now = DateTime.now();

                final checkInEnd = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  17,
                  30,
                );

                final absentDays = !now.isBefore(checkInEnd) && !isCheckedIn
                    ? 1
                    : 0;

                return RefreshIndicator(
                  color: theme.colorScheme.primary,

                  onRefresh: () async {
                    final bloc = context.read<AttendanceBloc>();

                    bloc.add(const AttendanceLoaded());

                    await bloc.stream.firstWhere(
                      (state) =>
                          state.status == AttendanceStatusState.success ||
                          state.status == AttendanceStatusState.failure,
                    );
                  },

                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),

                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    _getGreeting(),

                                    style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,

                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: avatarBg,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child:
                                  profileImage != null &&
                                      profileImage.isNotEmpty
                                  ? Image.network(
                                      profileImage,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person_rounded,
                                              color: theme.colorScheme.primary,
                                              size: 26,
                                            );
                                          },
                                    )
                                  : Icon(
                                      Icons.person_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 26,
                                    ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        Text(
                          "Today's Status",

                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 14),

                        CheckInCard(
                          isCheckedIn: isCheckedIn,

                          checkInTime: checkInTime == null
                              ? null
                              : TimeOfDay.fromDateTime(checkInTime)
                                    .format(context),
                        ),

                        const SizedBox(height: 14),

                        SwipeCheckButton(
                          isCheckedIn: isCheckedIn,

                          onCheckIn: employeeId == null || isCheckedIn
                              ? null
                              : () {
                                  context.read<AttendanceBloc>().add(
                                    CheckInRequested(employeeId: employeeId),
                                  );
                                },
                        ),

                        const SizedBox(height: 30),

                        if (attendanceState.hasError &&
                            attendanceState.errorMessage != null)
                          Container(
                            width: double.infinity,

                            margin: const EdgeInsets.only(bottom: 20),

                            padding: const EdgeInsets.all(14),

                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withValues(
                                alpha: 0.08,
                              ),

                              borderRadius: BorderRadius.circular(14),

                              border: Border.all(
                                color: theme.colorScheme.error.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                            ),

                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: theme.colorScheme.error,
                                  size: 20,
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    attendanceState.errorMessage!,
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        Text(
                          'Attendance Overview',

                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 14),

                        AttendanceSummary(
                          present: presentDays,
                          absent: absentDays,
                          late: lateDays,
                        ),

                        const SizedBox(height: 30),

                        Text(
                          'Recent Attendance',

                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 14),

                        if (records.isEmpty)
                          const _EmptyAttendance()
                        else
                          ..._buildRecentAttendance(context, records),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  bool _isToday(Attendance attendance) {
    final now = DateTime.now();

    return attendance.date.year == now.year &&
        attendance.date.month == now.month &&
        attendance.date.day == now.day;
  }

  List<Widget> _buildRecentAttendance(
    BuildContext context,
    List<Attendance> records,
  ) {
    final sortedRecords = [...records];

    sortedRecords.sort((a, b) => b.date.compareTo(a.date));

    final recentRecords = sortedRecords.take(5).toList();

    return recentRecords
        .map((attendance) => _RecentAttendanceCard(attendance: attendance))
        .toList();
  }
}

class _RecentAttendanceCard extends StatelessWidget {
  final Attendance attendance;

  const _RecentAttendanceCard({required this.attendance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isLate = attendance.status == AttendanceStatus.late;

    final statusColor = isLate
        ? theme.colorScheme.error
        : theme.colorScheme.tertiary;

    final statusText = isLate ? 'Late' : 'Present';

    final checkIn = attendance.checkIn;

    final time = checkIn == null
        ? '--:--'
        : TimeOfDay.fromDateTime(checkIn).format(context);

    final date = attendance.date;

    final dateText =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: theme.colorScheme.surface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: theme.colorScheme.outline),
      ),

      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,

            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),

            child: Icon(
              isLate ? Icons.access_time_rounded : Icons.check_rounded,

              color: statusColor,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  dateText,

                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(
                      Icons.login_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      'Checked in at $time',

                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
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

class _EmptyAttendance extends StatelessWidget {
  const _EmptyAttendance();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final iconBg = isDark
        ? theme.colorScheme.primary.withValues(alpha: 0.08)
        : AppColors.primaryLight;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),

      decoration: BoxDecoration(
        color: theme.colorScheme.surface,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: theme.colorScheme.outline),
      ),

      child: Column(
        children: [
          Container(
            height: 58,
            width: 58,

            decoration: BoxDecoration(
              color: iconBg,

              borderRadius: BorderRadius.circular(18),
            ),

            child: Icon(
              Icons.calendar_today_rounded,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'No attendance records yet',

            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Your attendance records will appear here after you check in.',

            textAlign: TextAlign.center,

            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
