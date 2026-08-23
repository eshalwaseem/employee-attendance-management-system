import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../authentication/bloc/auth_bloc.dart';
import '../../employees/bloc/employee_bloc.dart';
import '../../employees/models/employee.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../widgets/widgets.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  int _selectedTab = 0;

  DateTime _selectedDate = DateTime.now();

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    final currentUser = authState.user;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('No user is logged in.')));
    }

    final employeeBloc = context.watch<EmployeeBloc>();

    final currentEmployee = employeeBloc.state.employees
        .where((employee) => employee.id == currentUser.id)
        .firstOrNull;

    if (currentEmployee == null) {
      return const Scaffold(
        body: Center(child: Text('Employee profile not found.')),
      );
    }

    final accessibleEmployees = employeeBloc.getAccessibleEmployees(
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

      body: SafeArea(
        child: Column(
          children: [
            _buildTabs(accessibleEmployees.isNotEmpty),

            Expanded(
              child: _selectedTab == 0
                  ? _buildMyAttendance(currentEmployee)
                  : _buildPeopleYouCanView(accessibleEmployees),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(bool hasAccessibleEmployees) {
    if (!hasAccessibleEmployees) {
      return const SizedBox(height: 16);
    }

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
      employeeIds: [employee.id],
      title: employee.name,
    );
  }

  Widget _buildAttendanceContent({
    required List<String> employeeIds,
    required String title,
  }) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        if (state.isLoading && state.records.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final records = state.records
            .where((record) {
              return employeeIds.contains(record.employeeId) &&
                  _sameDay(record.date, _selectedDate);
            })
            .where((record) {
              if (_searchQuery.isEmpty) {
                return true;
              }

              return title.toLowerCase().contains(_searchQuery);
            })
            .toList();

        return RefreshIndicator(
          onRefresh: () async {
            context.read<AttendanceBloc>().add(const AttendanceLoaded());
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            children: [
              _buildPeriodSelector(),

              const SizedBox(height: 18),

              _buildDateSelector(),

              const SizedBox(height: 18),

              _buildSearchField(),

              const SizedBox(height: 20),

              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 12),

              if (records.isEmpty)
                _buildEmptyState()
              else
                ...records.map(
                  (record) => AttendanceListItem(
                    employeeName: title,
                    attendance: record,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeopleYouCanView(List<Employee> employees) {
    final filteredEmployees = employees.where((employee) {
      if (_searchQuery.isEmpty) {
        return true;
      }

      return employee.name.toLowerCase().contains(_searchQuery) ||
          employee.email.toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        Text(
          'People you can view',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontSize: 22),
        ),

        const SizedBox(height: 6),

        Text(
          'Select a person to view their attendance.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),

        const SizedBox(height: 18),

        _buildSearchField(),

        const SizedBox(height: 18),

        if (filteredEmployees.isEmpty)
          _buildEmptyState(message: 'No employees found.')
        else
          ...filteredEmployees.map((employee) => _buildEmployeeCard(employee)),
      ],
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),

        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.primary
              .withValues(alpha: 0.08),
          child: Icon(
            Icons.person_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        title: Text(
          employee.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),

        subtitle: Text(employee.email),

        trailing: const Icon(Icons.chevron_right_rounded),

        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EmployeeAttendancePage(employee: employee),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        Expanded(child: _periodButton('Daily', true)),
        const SizedBox(width: 8),
        Expanded(child: _periodButton('Monthly', false)),
        const SizedBox(width: 8),
        Expanded(child: _periodButton('Custom', false)),
      ],
    );
  }

  Widget _periodButton(String title, bool selected) {
    return Container(
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? Theme.of(context).colorScheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : const Color(0xFFE5E5E5),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : const Color(0xFF666666),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousDay,
            icon: const Icon(Icons.chevron_left_rounded),
          ),

          Expanded(
            child: Text(
              _formatDate(_selectedDate),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),

          IconButton(
            onPressed: _nextDay,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
