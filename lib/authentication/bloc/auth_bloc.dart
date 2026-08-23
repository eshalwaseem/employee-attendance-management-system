import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user.dart';
import '../repository/local_auth_repository.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LocalAuthRepository repository;

  AuthBloc({required this.repository}) : super(const AuthState()) {
    on<NameChanged>(_onNameChanged);
    on<EmailChanged>(_onEmailChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignupSubmitted>(_onSignupSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthSessionRequested>(_onAuthSessionRequested);
  }


  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
  }


  void _onNameChanged(NameChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(name: event.name, clearError: true));
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

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.isLoading) return;

    final name = event.name.trim();
    final email = state.email.trim();

    if (name.length < 2) {
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

    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final User user = await repository.signup(name: name, email: email);

      emit(
        state.copyWith(
          status: AuthStatus.success,
          user: user,
          name: user.name,
          email: user.email,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
        ),
      );

      addError(error, stackTrace);
    }
  }


  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.isLoading) return;

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
      final User? user = await repository.login(email);

      if (user == null) {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            errorMessage:
                'No account found with this email. Please sign up first.',
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          status: AuthStatus.success,
          user: user,
          name: user.name,
          email: user.email,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Unable to sign in. Please try again.',
        ),
      );

      addError(error, stackTrace);
    }
  }


  Future<void> _onAuthSessionRequested(
    AuthSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final user = await repository.getCurrentUser();

      if (user == null) {
        emit(const AuthState(status: AuthStatus.initial));

        return;
      }

      emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: user,
          name: user.name,
          email: user.email,
        ),
      );
    } catch (error, stackTrace) {
      emit(const AuthState(status: AuthStatus.initial));

      addError(error, stackTrace);
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await repository.logout();

    emit(const AuthState(status: AuthStatus.initial));
  }
}
