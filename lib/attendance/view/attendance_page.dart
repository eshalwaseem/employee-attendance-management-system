import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/today_employee_attendance.dart';
import '../models/attendance.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../../employees/models/employee.dart';
import '../../employees/bloc/employee_bloc.dart';
import '../../employees/bloc/employee_event.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../widgets/widgets.dart';

enum AttendancePeriod { today, thisWeek, thisMonth }

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  int _selectedTab = 0;
  AttendancePeriod _selectedPeriod = AttendancePeriod.today;

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (!mounted) return;

      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // IMPORTANT:
      // Load ALL users from Firestore.
      context.read<EmployeeBloc>().add(const EmployeesLoaded());

      // Load attendance records.
      context.read<AttendanceBloc>().add(const AttendanceLoaded());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInSelectedPeriod(DateTime date) {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case AttendancePeriod.today:
        return _sameDay(date, now);

      case AttendancePeriod.thisWeek:
        final today = DateTime(now.year, now.month, now.day);

        final monday = today.subtract(Duration(days: today.weekday - 1));

        final sunday = monday.add(const Duration(days: 6));

        final checkDate = DateTime(date.year, date.month, date.day);

        return !checkDate.isBefore(monday) && !checkDate.isAfter(sunday);

      case AttendancePeriod.thisMonth:
        return date.year == now.year && date.month == now.month;
    }
  }

  String _emptyPeriodMessage() {
    switch (_selectedPeriod) {
      case AttendancePeriod.today:
        return 'No attendance recorded today.';

      case AttendancePeriod.thisWeek:
        return 'No attendance recorded this week.';

      case AttendancePeriod.thisMonth:
        return 'No attendance recorded this month.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUser = authState.user;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('No user is logged in.')));
    }

    final currentEmployee = Employee(
      id: currentUser.id,
      name: currentUser.name,
      email: currentUser.email,
      role: currentUser.role,
      managerId: currentUser.managerId,
      profileImagePath: currentUser.profileImagePath,
      permissions: currentUser.permissions,
    );

    final employeeState = context.watch<EmployeeBloc>().state;

    /*
     * IMPORTANT:
     *
     * EmployeeState must contain ALL users from Firestore.
     * getAccessibleEmployees() then determines which ones
     * this particular user can see.
     */
    final accessibleEmployees = employeeState.getAccessibleEmployees(
      currentEmployee.id,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Attendance',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
      ),

      bottomNavigationBar: const AppBottomNavigation(selectedIndex: 1),

      body: SafeArea(
        child: Column(
          children: [
            _buildTabs(),
            _buildPeriodSelector(),

            Expanded(
              child: _selectedTab == 0
                  ? _buildMyAttendance(currentEmployee)
                  : _buildPeopleYouCanView(
                      currentEmployee,
                      accessibleEmployees,
                    ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(child: _tabButton(title: 'My Attendance', index: 0)),
            Expanded(child: _tabButton(title: 'People I Can View', index: 1)),
          ],
        ),
      ),
    );
  }

  Widget _tabButton({required String title, required int index}) {
    final selected = _selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;

          if (index == 0) {
            _searchController.clear();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? Theme.of(context).colorScheme.primary
                : const Color(0xFF777777),
          ),
        ),
      ),
    );
  }


  Widget _buildMyAttendance(Employee employee) {
    return _buildAttendanceContent(
      employees: [employee],
      sectionTitle: 'My Attendance',
      showSearch: false,
      showEmployeeName: false,
    );
  }


  Widget _buildPeopleYouCanView(
    Employee currentEmployee,
    List<Employee> accessibleEmployees,
  ) {
    final employeeState = context.watch<EmployeeBloc>().state;

    if (employeeState.isLoading && employeeState.employees.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (employeeState.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            employeeState.errorMessage ?? 'Unable to load employees.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (accessibleEmployees.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
        children: [
          Text(
            'People I Can View',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontSize: 22),
          ),

          const SizedBox(height: 8),

          Text(
            currentEmployee.isAdmin
                ? 'No other employees are available.'
                : 'You have no one reporting to you yet.',
          ),

          const SizedBox(height: 30),

          _buildEmptyState(message: 'No other employees available.'),
        ],
      );
    }

    return _buildAttendanceContent(
      employees: accessibleEmployees,
      sectionTitle: 'People I Can View',
      showSearch: true,
      showEmployeeName: true,
    );
  }


  Widget _buildAttendanceContent({
    required List<Employee> employees,
    required String sectionTitle,
    required bool showSearch,
    required bool showEmployeeName,
  }) {
    final employeesById = {
      for (final employee in employees) employee.id: employee,
    };

    final visibleEmployees = employees.where((employee) {
      if (!showSearch || _searchQuery.isEmpty) {
        return true;
      }

      return employee.name.toLowerCase().contains(_searchQuery);
    }).toList();

    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        if (state.isLoading && state.records.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredRecords = state.records.where((record) {
          return employeesById.containsKey(record.employeeId) &&
              _isInSelectedPeriod(record.date);
        }).toList();



        if (!showSearch) {
          final myRecords = filteredRecords;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<EmployeeBloc>().add(const EmployeesLoaded());

              context.read<AttendanceBloc>().add(const AttendanceLoaded());
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              children: [
                const SizedBox(height: 12),

                Text(
                  sectionTitle,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 12),

                if (myRecords.isEmpty)
                  _buildEmptyState(message: _emptyPeriodMessage())
                else
                  ...myRecords.map(
                    (record) => AttendanceListItem(
                      employeeName: employees.first.name,
                      attendance: record,
                      profileImagePath: employees.first.profileImagePath,
                      showEmployeeName: false,
                    ),
                  ),
              ],
            ),
          );
        }

      

        final groupedRecords = <String, List<Attendance>>{};

        for (final employee in visibleEmployees) {
          groupedRecords[employee.id] = [];
        }

        for (final record in filteredRecords) {
          if (groupedRecords.containsKey(record.employeeId)) {
            groupedRecords[record.employeeId]!.add(record);
          }
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<EmployeeBloc>().add(const EmployeesLoaded());

            context.read<AttendanceBloc>().add(const AttendanceLoaded());
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            children: [
              if (showSearch) ...[
                const SizedBox(height: 12),

                _buildSearchField(),

                const SizedBox(height: 20),
              ],

              Row(
                children: [
                  Expanded(
                    child: Text(
                      sectionTitle,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),

                  Text(
                    '${visibleEmployees.length} employees',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF777777),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (visibleEmployees.isEmpty)
                _buildEmptyState(message: 'No employees found.')
              else
                ...visibleEmployees.map((employee) {
                  final employeeRecords = groupedRecords[employee.id] ?? [];

                  // TODAY → Screenshot-style employee tiles
                  if (_selectedPeriod == AttendancePeriod.today) {
                    final todayAttendance = employeeRecords.isEmpty
                        ? null
                        : employeeRecords.first;

                    return TodayEmployeeAttendanceTile(
                      employeeName: employee.name,
                      profileImagePath: employee.profileImagePath,
                      attendance: todayAttendance,
                    );
                  }

                  return EmployeeAttendanceCard(
                    employeeName: employee.name,
                    profileImagePath: employee.profileImagePath,
                    records: employeeRecords,
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // PERIOD SELECTOR
  // ============================================================

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Expanded(
              child: _periodButton(
                title: 'Today',
                period: AttendancePeriod.today,
              ),
            ),

            const SizedBox(width: 4),

            Expanded(
              child: _periodButton(
                title: 'This Week',
                period: AttendancePeriod.thisWeek,
              ),
            ),

            const SizedBox(width: 4),

            Expanded(
              child: _periodButton(
                title: 'This Month',
                period: AttendancePeriod.thisMonth,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodButton({
    required String title,
    required AttendancePeriod period,
  }) {
    final selected = _selectedPeriod == period;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? Theme.of(context).colorScheme.primary
                : const Color(0xFF777777),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search employee',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                },
                icon: const Icon(Icons.close_rounded),
              )
            : null,
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState({String message = 'No attendance recorded.'}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 52,
            color: Theme.of(context).colorScheme.primary
                .withValues(alpha: 0.35),
          ),

          const SizedBox(height: 14),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// EMPLOYEE ATTENDANCE PAGE
// ================================================================

class EmployeeAttendancePage extends StatelessWidget {
  final Employee employee;

  const EmployeeAttendancePage({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return _EmployeeAttendanceView(employee: employee);
  }
}

class _EmployeeAttendanceView extends StatefulWidget {
  final Employee employee;

  const _EmployeeAttendanceView({required this.employee});

  @override
  State<_EmployeeAttendanceView> createState() =>
      _EmployeeAttendanceViewState();
}

class _EmployeeAttendanceViewState extends State<_EmployeeAttendanceView> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AttendanceBloc>().add(const AttendanceLoaded());
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee.name),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          final records = state.records.where((record) {
            return record.employeeId == widget.employee.id &&
                _sameDay(record.date, selectedDate);
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.primary
                        .withValues(alpha: 0.08),
                    child: Icon(
                      Icons.person_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.employee.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontSize: 18),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          widget.employee.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE7E7E7)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedDate = selectedDate.subtract(
                            const Duration(days: 1),
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),

                    Expanded(
                      child: Text(
                        _formatDate(selectedDate),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedDate = selectedDate.add(
                            const Duration(days: 1),
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              Text(
                'Attendance',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 12),

              if (records.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Center(child: Text('No attendance recorded.')),
                )
              else
                ...records.map(
                  (record) => AttendanceListItem(
                    employeeName: widget.employee.name,
                    attendance: record,
                    showEmployeeName: true,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
