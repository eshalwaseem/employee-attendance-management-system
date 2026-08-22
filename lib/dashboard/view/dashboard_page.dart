import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../authentication/bloc/auth_state.dart';
import '../../app.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
    return BlocProvider(
      create: (_) => DashboardBloc()
        ..add(const DashboardStarted()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: const _BottomNavigation(),
        body: SafeArea(
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state.status == DashboardStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context
                      .read<DashboardBloc>()
                      .add(const DashboardStarted());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: const TextStyle(
                                    color:
                                        AppColors.secondaryText,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, authState) {
                                    return Text(
                                      authState.user?.name ?? 'Employee',
                                      style: const TextStyle(
                                        color: AppColors.text,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primaryLight,
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppColors.primary,
                              size: 26,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        "Today's Status",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),

                      const SizedBox(height: 14),

                      CheckInCard(
                        isCheckedIn: state.isCheckedIn,
                        checkInTime: state.checkInTime,
                      ),

                      const SizedBox(height: 14),

                      SwipeCheckButton(
                        isCheckedIn: state.isCheckedIn,
                        onCheckIn: () {
                          context
                              .read<DashboardBloc>()
                              .add(const CheckInRequested());
                        },
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        'Attendance Overview',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),

                      const SizedBox(height: 14),

                      AttendanceSummary(
                        present: state.presentDays,
                        absent: state.absentDays,
                        late: state.lateDays,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primaryLight,
      elevation: 0,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(
            Icons.home_rounded,
            color: AppColors.primary,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(
            Icons.calendar_month_rounded,
            color: AppColors.primary,
          ),
          label: 'Attendance',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(
            Icons.person_rounded,
            color: AppColors.primary,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
