import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../dashboard/view/dashboard_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/widgets.dart';
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

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      context.read<AuthBloc>().add(EmailChanged(_emailController.text));

      return;
    }

    context.read<AuthBloc>().add(SignupSubmitted(_nameController.text.trim()));
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
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const LoginPage();
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
              begin: const Offset(-0.08, 0),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.success) {
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
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                content: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.errorMessage ?? 'Unable to create your account.',
                      ),
                    ),
                  ],
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
                            // ------------------------------------------------
                            // ILLUSTRATION
                            // ------------------------------------------------

                            _animatedSection(
                              animation: _illustrationAnimation,
                              child: const AuthIllustration(),
                            ),

                            const SizedBox(height: 18),

                            // ------------------------------------------------
                            // HEADING
                            // ------------------------------------------------
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

                            // ------------------------------------------------
                            // NAME + EMAIL
                            // ------------------------------------------------
                            _animatedSection(
                              animation: _fieldAnimation,
                              child: Column(
                                children: [
                                  // NAME
                                  TextFormField(
                                    controller: _nameController,
                                    keyboardType: TextInputType.name,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      hintText: 'Full name',
                                      prefixIcon: Icon(
                                        Icons.person_outline_rounded,
                                      ),
                                    ),
                                    validator: (value) {
                                      final name = value?.trim() ?? '';

                                      if (name.isEmpty) {
                                        return 'Please enter your name';
                                      }

                                      if (name.length < 2) {
                                        return 'Name must be at least 2 characters';
                                      }

                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  // EMAIL
                                  BlocBuilder<AuthBloc, AuthState>(
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
                                        onSubmitted: () => _submit()
                                        ,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ------------------------------------------------
                            // CREATE ACCOUNT BUTTON
                            // ------------------------------------------------
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

                            // ------------------------------------------------
                            // LOGIN
                            // ------------------------------------------------
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
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();

                                      Navigator.of(context)
                                          .pushReplacement(_loginRoute());
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: colorScheme.primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                    ),
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
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.65,
                                ),
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
    );
  }
}
