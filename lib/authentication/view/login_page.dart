import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/widgets.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();

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
    _entranceController.dispose();

    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      context.read<AuthBloc>().add(EmailChanged(_emailController.text));

      return;
    }

    context.read<AuthBloc>().add(const LoginSubmitted());
  }

  Route<void> _signupRoute() {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SignupPage();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.98,
                end: 1,
              ).animate(curvedAnimation),
              child: child,
            ),
          ),
        );
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create: (_) => AuthBloc(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: colorScheme.tertiary,
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text('Welcome back! Mock login successful.'),
                      ),
                    ],
                  ),
                ),
              );
          }

          if (state.status == AuthStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: colorScheme.error,
                  content: Text(state.errorMessage ?? 'Something went wrong.'),
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
                                      'Welcome back 👋',
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

                              const SizedBox(height: 18),

                              _animatedSection(
                                animation: _buttonAnimation,
                                child: BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    return AuthButton(
                                      label: 'Continue',
                                      isLoading: state.isLoading,
                                      isSuccess: state.isSuccess,
                                      onPressed: _submit,
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 30),

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
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        Navigator.of(context)
                                            .push(_signupRoute());
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: colorScheme.primary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                      ),
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
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.65),
                                ),
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
      ),
    );
  }
}
