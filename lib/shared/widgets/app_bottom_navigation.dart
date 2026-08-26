import 'package:flutter/material.dart';

import '../../../app.dart';
import '../../../attendance/view/attendance_page.dart';
import '../../../dashboard/view/dashboard_page.dart';
import '../../profile/view/profile_page.dart';

class AppBottomNavigation extends StatelessWidget {
  final int selectedIndex;

  const AppBottomNavigation({super.key, required this.selectedIndex});

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
        page=
        const ProfilePage();

      default:
        return;
    }

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        _onDestinationSelected(context, index);
      },
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primaryLight,
      elevation: 0,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
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
          selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
          label: 'Profile',
        ),
      ],
    );
  }
}
