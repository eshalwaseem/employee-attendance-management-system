import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/widgets.dart';

import '../../dashboard/view/dashboard_page.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();

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
    _nameController.dispose();
    _emailController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Please enter your name.'),
          ),
        );

      return;
    }

    final valid = _formKey.currentState?.validate() ?? false;

    if (!valid) {
      context.read<AuthBloc>().add(EmailChanged(email));

      return;
    }

    context.read<AuthBloc>().add(NameChanged(name));

    context.read<AuthBloc>().add(EmailChanged(email));

    context.read<AuthBloc>().add(SignupSubmitted(name: name));
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


  Route<void> _loginRoute() {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const LoginPage();
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
              begin: const Offset(-0.08, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // SIGNUP SUCCESS
        if (state.status == AuthStatus.success && state.user != null) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DashboardPage()),
            (route) => false,
          );
        }

        if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: colorScheme.error,
                content: Text(
                  state.errorMessage ?? 'Unable to create your account.',
                ),
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
                                    'Create your account',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Let's get you started",
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            _animatedSection(
                              animation: _fieldAnimation,
                              child: BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  final name = _nameController.text.trim();

                                  return NameField(
                                    controller: _nameController,
                                    isValid: name.length >= 2,
                                    hasError: state.hasError && name.isEmpty,
                                    errorText: name.isEmpty
                                        ? state.errorMessage
                                        : null,
                                    onChanged: (name) {
                                      context.read<AuthBloc>().add(
                                        NameChanged(name),
                                      );
                                    },
                                    onSubmitted: () {
                                      FocusScope.of(context).nextFocus();
                                    },
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 16),

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

                            // BUTTON
                            _animatedSection(
                              animation: _buttonAnimation,
                              child: BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  return AuthButton(
                                    label: 'Create account',
                                    isLoading: state.isLoading,
                                    isSuccess: state.isSuccess,
                                    onPressed: _submit,
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 30),

                            // LOGIN
                            _animatedSection(
                              animation: _bottomAnimation,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account?',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushReplacement(_loginRoute());
                                    },
                                    child: const Text(
                                      'Log in',
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
