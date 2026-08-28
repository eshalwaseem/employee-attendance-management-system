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

String _formatMonth(DateTime date) {
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

  return '${months[date.month - 1]} ${date.year}';
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  int _selectedTab = 0;
  AttendancePeriod _selectedPeriod = AttendancePeriod.today;
  DateTime _selectedMonth = DateTime.now();
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

      context.read<EmployeeBloc>().add(const EmployeesLoaded());

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
        return date.year == _selectedMonth.year &&
            date.month == _selectedMonth.month;
    }
  }

  
  List<DateTime> _datesForSelectedPeriod(DateTime accountCreatedAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final joined = DateTime(
      accountCreatedAt.year,
      accountCreatedAt.month,
      accountCreatedAt.day,
    );

    switch (_selectedPeriod) {
      case AttendancePeriod.today:
        
        return joined.isAfter(today) ? [] : [today];

      case AttendancePeriod.thisWeek:
        final monday = today.subtract(Duration(days: today.weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        final lastDay = today.isBefore(sunday) ? today : sunday;

      
        final firstDay = joined.isAfter(monday) ? joined : monday;
        if (firstDay.isAfter(lastDay)) return [];

        final days = <DateTime>[];
        for (
          var day = firstDay;
          !day.isAfter(lastDay);
          day = day.add(const Duration(days: 1))
        ) {
          days.add(day);
        }
        return days.reversed.toList();

      case AttendancePeriod.thisMonth:
        final firstOfMonth = DateTime(
          _selectedMonth.year,
          _selectedMonth.month,
          1,
        );

        if (firstOfMonth.isAfter(today)) {
          return [];
        }

        final firstOfNextMonth = DateTime(
          _selectedMonth.year,
          _selectedMonth.month + 1,
          1,
        );
        final lastOfMonth = firstOfNextMonth.subtract(const Duration(days: 1));
        final lastDay = lastOfMonth.isAfter(today) ? today : lastOfMonth;
        final firstDay = joined.isAfter(firstOfMonth) ? joined : firstOfMonth;
        if (firstDay.isAfter(lastDay)) return [];

        final days = <DateTime>[];
        for (
          var day = firstDay;
          !day.isAfter(lastDay);
          day = day.add(const Duration(days: 1))
        ) {
          days.add(day);
        }
        return days.reversed.toList();
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
      
      createdAt: currentUser.createdAt,
    );

    final employeeState = context.watch<EmployeeBloc>().state;

   
    final accessibleEmployees = employeeState.getAccessibleEmployees(
      currentEmployee.id,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
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
            _buildPeriodSelector(currentEmployee.createdAt),

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
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
    final theme = Theme.of(context);

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
          color: selected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: selected && theme.brightness == Brightness.light
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
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
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
          final periodDates = _datesForSelectedPeriod(
            employees.first.createdAt,
          );

          final recordByDay = <String, Attendance>{};
          for (final record in filteredRecords) {
            final key =
                '${record.date.year}-${record.date.month}-${record.date.day}';
            recordByDay[key] = record;
          }

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

                if (periodDates.isEmpty)
                  _buildEmptyState(message: _emptyPeriodMessage())
                else
                  ...periodDates.map((date) {
                    final key = '${date.year}-${date.month}-${date.day}';
                    final record = recordByDay[key];

                    return AttendanceListItem(
                      employeeName: employees.first.name,
                      date: date,
                      attendance: record,
                      profileImagePath: employees.first.profileImagePath,
                      showEmployeeName: false,
                    );
                  }),
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
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    createdAt: employee.createdAt,
                    records: employeeRecords,
                  );
                }),
            ],
          ),
        );
      },
    );
  }



  Widget _buildPeriodSelector(DateTime accountCreatedAt) {
    final joinedMonth = DateTime(accountCreatedAt.year, accountCreatedAt.month);
    final canGoToPreviousMonth =
        DateTime(
          _selectedMonth.year,
          _selectedMonth.month - 1,
        ).isAfter(joinedMonth) ||
        DateTime(_selectedMonth.year, _selectedMonth.month - 1) == joinedMonth;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                    title: 'Monthly',
                    period: AttendancePeriod.thisMonth,
                  ),
                ),
              ],
            ),
          ),

          
          if (_selectedPeriod == AttendancePeriod.thisMonth)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  IconButton(
                    
                    onPressed: !canGoToPreviousMonth
                        ? null
                        : () {
                            setState(() {
                              _selectedMonth = DateTime(
                                _selectedMonth.year,
                                _selectedMonth.month - 1,
                              );
                            });
                          },
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),

                  Expanded(
                    child: Center(
                      child: Text(
                        _formatMonth(_selectedMonth),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month + 1,
                        );
                      });
                    },
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _periodButton({
    required String title,
    required AttendancePeriod period,
  }) {
    final selected = _selectedPeriod == period;
    final theme = Theme.of(context);

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
          color: selected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected && theme.brightness == Brightness.light
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
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }


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
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}



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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee.name),
        backgroundColor: theme.colorScheme.surface,
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
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.08,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: theme.colorScheme.primary,
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          widget.employee.email,
                          style: theme.textTheme.bodyMedium,
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
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.colorScheme.outline),
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
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              AttendanceListItem(
                employeeName: widget.employee.name,
                date: selectedDate,
                attendance: records.isEmpty ? null : records.first,
                showEmployeeName: true,
              ),
            ],
          );
        },
      ),
    );
  }
}
