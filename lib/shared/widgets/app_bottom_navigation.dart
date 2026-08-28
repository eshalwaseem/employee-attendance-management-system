import 'package:flutter/material.dart';
import '../../../app.dart';
import '../../../attendance/view/attendance_page.dart';
import '../../../dashboard/view/dashboard_page.dart';
import '../../profile/view/profile_page.dart';

class AppBottomNavigation extends StatelessWidget {
  final int selectedIndex;

  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
  });

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == selectedIndex) {
      return;
    }

    Widget page;

    switch (index) {
      case 0:
        page = const DashboardPage();
        break;

      case 1:
        page = const AttendancePage();
        break;

      case 2:
        page = const ProfilePage();
        break;

      default:
        return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return NavigationBar(
      selectedIndex: selectedIndex,

      onDestinationSelected: (index) {
        _onDestinationSelected(context, index);
      },

      backgroundColor: theme.colorScheme.surface,

      indicatorColor: isDark
          ? theme.colorScheme.primary.withValues(alpha: 0.18)
          : AppColors.primaryLight,

      elevation: 0,

      destinations: [
        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          selectedIcon: Icon(
            Icons.home_rounded,
            color: theme.colorScheme.primary,
          ),
          label: 'Home',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.calendar_month_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          selectedIcon: Icon(
            Icons.calendar_month_rounded,
            color: theme.colorScheme.primary,
          ),
          label: 'Attendance',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.person_outline_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          selectedIcon: Icon(
            Icons.person_rounded,
            color: theme.colorScheme.primary,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
