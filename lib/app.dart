import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'attendance/bloc/attendance_bloc.dart';
import 'attendance/bloc/attendance_event.dart';
import 'attendance/repository/attendance_repository.dart';

import 'authentication/bloc/auth_bloc.dart';
import 'authentication/bloc/auth_event.dart';
import 'authentication/bloc/auth_state.dart';
import 'authentication/repository/firebase_auth_repository.dart';

import 'employees/bloc/employee_bloc.dart';
import 'employees/bloc/employee_event.dart';
import 'employees/repository/employee_repository.dart';

import 'splash/view/view.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFC8102E);
  static const Color primaryDark = Color(0xFF9E0B22);
  static const Color primaryLight = Color(0xFFFDECEF);

  static const Color background = Color(0xFFF8F8F8);
  static const Color surface = Colors.white;

  static const Color text = Color(0xFF1A1A1A);
  static const Color secondaryText = Color(0xFF6B6B6B);

  static const Color success = Color(0xFF22A447);
  static const Color error = Color(0xFFD32F2F);

  static const Color border = Color(0xFFE5E5E5);
  static const Color white = Colors.white;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.primaryDark,
          onSecondary: Colors.white,
          surface: AppColors.surface,
          onSurface: AppColors.text,
          error: AppColors.error,
          onError: Colors.white,
          tertiary: AppColors.success,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',

      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          color: AppColors.text,
        ),
        headlineSmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
          color: AppColors.text,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.text),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.secondaryText),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),

        hintStyle: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 15,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
       

        BlocProvider<AuthBloc>(
          create: (_) =>
              AuthBloc(repository: FirebaseAuthRepository())
                ..add(const AuthSessionRequested()),
        ),

      
        BlocProvider<EmployeeBloc>(
          create: (_) => EmployeeBloc(repository: EmployeeRepository()),
        ),

        
        BlocProvider<AttendanceBloc>(
          create: (_) => AttendanceBloc(repository: AttendanceRepository()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          final user = authState.user;

          

          if (user != null) {
            print('======================================');
            print('USER AUTHENTICATED');
            print('User ID: ${user.id}');
            print('User Name: ${user.name}');
            print('Role: ${user.role.value}');
            print('======================================');

      
            context.read<EmployeeBloc>().add(const EmployeesLoaded());

            context.read<AttendanceBloc>().add(const AttendanceLoaded());
          }
        },

        child: MaterialApp(
          title: 'Employee Attendance',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const SplashPage(),
        ),
      ),
    );
  }
}
