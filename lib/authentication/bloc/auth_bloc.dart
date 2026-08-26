import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/firebase_auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthRepository _repository;

  AuthBloc({required FirebaseAuthRepository repository})
    : _repository = repository,
      super(const AuthState()) {
    on<NameChanged>(_onNameChanged);
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);

    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignupSubmitted>(_onSignupSubmitted);

    on<AuthSessionRequested>(_onAuthSessionRequested);
    on<LogoutRequested>(_onLogoutRequested);
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

  void _onPasswordChanged(PasswordChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(password: event.password, clearError: true));
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.isLoading) {
      return;
    }

    final email = state.email.trim();
    final password = state.password;

    if (!_isValidEmail(email)) {
      emit(
        state.copyWith(
          status: AuthStatus.invalid,
          errorMessage: 'Please enter a valid email address.',
        ),
      );

      return;
    }

    if (password.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.invalid,
          errorMessage: 'Please enter your password.',
        ),
      );

      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final user = await _repository.login(email: email, password: password);

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
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

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state.isLoading) {
      return;
    }

    final name = event.name.trim();
    final email = state.email.trim();
    final password = state.password;

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

    if (password.length < 6) {
      emit(
        state.copyWith(
          status: AuthStatus.invalid,
          errorMessage: 'Password must be at least 6 characters.',
        ),
      );

      return;
    }

    emit(
      state.copyWith(status: AuthStatus.loading, name: name, clearError: true),
    );

    try {
      final user = await _repository.signup(
        name: name,
        email: email,
        password: password,
      );

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
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

  Future<void> _onAuthSessionRequested(
    AuthSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      final user = await _repository.getCurrentUser();

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
    try {
      await _repository.logout();

      emit(const AuthState(status: AuthStatus.initial));
    } catch (error, stackTrace) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Unable to log out. Please try again.',
        ),
      );

      addError(error, stackTrace);
    }
  }
}
