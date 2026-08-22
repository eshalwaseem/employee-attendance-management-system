import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<EmailChanged>(_onEmailChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignupSubmitted>(_onSignupSubmitted);
  }

  bool _isValidEmail(String email) {
    final trimmedEmail = email.trim();

    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmedEmail);
  }

  void _onEmailChanged(EmailChanged event, Emitter<AuthState> emit) {
    final email = event.email.trim();

    if (email.isEmpty) {
      emit(
        state.copyWith(
          email: event.email,
          status: AuthStatus.initial,
          clearError: true,
        ),
      );

      return;
    }

    final valid = _isValidEmail(email);

    emit(
      state.copyWith(
        email: event.email,
        status: valid ? AuthStatus.valid : AuthStatus.invalid,
        errorMessage: valid ? null : 'Please enter a valid email address.',
        clearError: valid,
      ),
    );
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.isLoading) {
      return;
    }

    final email = state.email.trim();

    if (!_isValidEmail(email)) {
      emit(
        state.copyWith(
          status: AuthStatus.invalid,
          errorMessage: 'Please enter a valid email address.',
        ),
      );

      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      await Future<void>.delayed(const Duration(milliseconds: 900));

      const mockUserId = 'mock-user-001';

      emit(
        state.copyWith(
          status: AuthStatus.success,
          user: User(id: mockUserId, name: state.name, email: email),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );

      addError(error, StackTrace.current);
    }
  }

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.isLoading) {
      return;
    }

    final name = event.name.trim();
    final email = state.email.trim();

    if (name.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.invalid,
          errorMessage: 'Please enter your name.',
        ),
      );

      return;
    }

    if (!_isValidEmail(email)) {
      emit(
        state.copyWith(
          status: AuthStatus.invalid,
          errorMessage: 'Please enter a valid email address.',
        ),
      );

      return;
    }

    emit(
      state.copyWith(name: name, status: AuthStatus.loading, clearError: true),
    );

    try {
      await Future<void>.delayed(const Duration(milliseconds: 1000));

      const mockUserId = 'mock-user-002';

      emit(
        state.copyWith(
          name: name,
          status: AuthStatus.success,
          user: User(id: mockUserId, name: name, email: email),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Unable to create your account.',
        ),
      );

      addError(error, StackTrace.current);
    }
  }
}
