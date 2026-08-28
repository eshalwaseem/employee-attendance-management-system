import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          onSurfaceVariant: const Color(0xFF777777),
          outline: const Color(0xFFE8E8E8),
          surfaceContainerHighest: const Color(0xFFEFEFEF),
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

class AppDarkColors {
  AppDarkColors._();

  static const Color primary = Color(0xFFC8102E); 
  static const Color primaryDark = Color(0xFF9E0B22);

  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);

  static const Color text = Color(0xFFF2F2F2);
  static const Color secondaryText = Color(0xFFA0A0A0);

  static const Color success = Color(0xFF22A447);
  static const Color error = Color(0xFFEF5350);

  static const Color border = Color(0xFF2C2C2C);
}

extension AppThemeDark on AppTheme {
  static ThemeData get dark {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppDarkColors.primary,
      onPrimary: Colors.white,
      secondary: AppDarkColors.primaryDark,
      onSecondary: Colors.white,
      surface: AppDarkColors.surface,
      onSurface: AppDarkColors.text,
      error: AppDarkColors.error,
      onError: Colors.white,
      tertiary: AppDarkColors.success,
      surfaceContainerHighest: const Color(0xFF262626),
      outline: AppDarkColors.border,
      onSurfaceVariant: AppDarkColors.secondaryText,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppDarkColors.background,
      fontFamily: 'Roboto',

      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          color: AppDarkColors.text,
        ),
        headlineSmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
          color: AppDarkColors.text,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppDarkColors.text,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: AppDarkColors.text),
        bodyMedium: TextStyle(fontSize: 14, color: AppDarkColors.secondaryText),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppDarkColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        hintStyle: const TextStyle(
          color: AppDarkColors.secondaryText,
          fontSize: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppDarkColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppDarkColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class ProfileThemeScope extends InheritedWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const ProfileThemeScope({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required super.child,
  });

  static ProfileThemeScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ProfileThemeScope>();
    assert(scope != null, 'ProfileThemeScope not found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(ProfileThemeScope oldWidget) =>
      isDarkMode != oldWidget.isDarkMode;
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static const _darkModePrefKey = 'isDarkMode';

  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_darkModePrefKey);

    debugPrint('[theme] loaded saved value: $saved');

    if (saved != null && mounted && saved != _isDarkMode) {
      setState(() {
        _isDarkMode = saved;
      });
    }
  }

  Future<void> _handleThemeChanged(bool value) async {
    setState(() {
      _isDarkMode = value;
    });

    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setBool(_darkModePrefKey, value);

    debugPrint('[theme] saved $value -> success: $ok');
  }

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
            context.read<EmployeeBloc>().add(const EmployeesLoaded());
            context.read<AttendanceBloc>().add(const AttendanceLoaded());
          }
        },
        child: ProfileThemeScope(
          isDarkMode: _isDarkMode,
          onThemeChanged: _handleThemeChanged,
          child: MaterialApp(
            title: 'Employee Attendance',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light, 
            darkTheme: AppThemeDark.dark, 
            themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashPage(),
          ),
        ),
      ),
    );
  }
}
