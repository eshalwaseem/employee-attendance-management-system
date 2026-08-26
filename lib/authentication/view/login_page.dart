import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/widgets.dart';

import '../../dashboard/view/dashboard_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final AnimationController _entranceController;

  late final Animation<double> _illustrationAnimation;
  late final Animation<double> _headingAnimation;
  late final Animation<double> _fieldAnimation;
  late final Animation<double> _buttonAnimation;
  late final Animation<double> _bottomAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _illustrationAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.28, curve: Curves.easeOutCubic),
    );

    _headingAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.12, 0.45, curve: Curves.easeOutCubic),
    );

    _fieldAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.28, 0.62, curve: Curves.easeOutCubic),
    );

    _buttonAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.45, 0.78, curve: Curves.easeOutCubic),
    );

    _bottomAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _entranceController.dispose();

    super.dispose();
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      context.read<AuthBloc>().add(const EmailChanged(''));

      return;
    }

    if (password.isEmpty) {
      context.read<AuthBloc>().add(const PasswordChanged(''));

      return;
    }

    context.read<AuthBloc>().add(EmailChanged(email));

    context.read<AuthBloc>().add(PasswordChanged(password));

    context.read<AuthBloc>().add(const LoginSubmitted());
  }

  // ============================================================
  // ANIMATION
  // ============================================================

  Widget _animatedSection({
    required Animation<double> animation,
    required Widget child,
    double distance = 0.08,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, distance),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  // ============================================================
  // SIGNUP ROUTE
  // ============================================================

  Route<void> _signupRoute() {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SignupPage();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // ------------------------------------------------------
        // LOGIN SUCCESS
        // ------------------------------------------------------

        if (state.status == AuthStatus.authenticated && state.user != null) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DashboardPage()),
            (route) => false,
          );
        }

        // ------------------------------------------------------
        // ERROR
        // ------------------------------------------------------

        if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: theme.colorScheme.error,
                content: Text(state.errorMessage ?? 'Unable to sign in.'),
              ),
            );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  MediaQuery.viewInsetsOf(context).bottom + 28,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _animatedSection(
                              animation: _illustrationAnimation,
                              child: const AuthIllustration(),
                            ),

                            const SizedBox(height: 18),

                            _animatedSection(
                              animation: _headingAnimation,
                              child: Column(
                                children: [
                                  Text(
                                    'Welcome back',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Sign in to continue',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // EMAIL
                            _animatedSection(
                              animation: _fieldAnimation,
                              child: BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  return EmailField(
                                    controller: _emailController,
                                    isValid: state.isEmailValid,
                                    hasError: state.hasError,
                                    errorText: state.errorMessage,
                                    onChanged: (email) {
                                      context.read<AuthBloc>().add(
                                        EmailChanged(email),
                                      );
                                    },
                                    onSubmitted: _submit,
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 16),

                            // PASSWORD
                            _animatedSection(
                              animation: _fieldAnimation,
                              child: BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  return PasswordField(
                                    controller: _passwordController,
                                    hasError: state.hasError,
                                    errorText: state.errorMessage,
                                    onChanged: (password) {
                                      context.read<AuthBloc>().add(
                                        PasswordChanged(password),
                                      );
                                    },
                                    onSubmitted: _submit,
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 18),

                            // LOGIN BUTTON
                            _animatedSection(
                              animation: _buttonAnimation,
                              child: BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  return AuthButton(
                                    label: 'Log in',
                                    isLoading: state.isLoading,
                                    isSuccess: state.isSuccess,
                                    onPressed: _submit,
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 30),

                            // SIGNUP
                            _animatedSection(
                              animation: _bottomAnimation,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account?",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(_signupRoute());
                                    },
                                    child: const Text(
                                      'Sign up',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              'Employee Attendance Management',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
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
