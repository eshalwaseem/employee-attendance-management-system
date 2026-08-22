import '../models/user.dart';

enum AuthStatus { initial, invalid, valid, loading, success, failure }

class AuthState {
  final String name;
  final String email;
  final AuthStatus status;
  final String? errorMessage;
  final User? user;

  const AuthState({
    this.name = '',
    this.email = '',
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.user,
  });

  bool get isEmailValid => status == AuthStatus.valid;

  bool get isLoading => status == AuthStatus.loading;

  bool get isSuccess => status == AuthStatus.success;

  bool get hasError =>
      status == AuthStatus.invalid || status == AuthStatus.failure;

  AuthState copyWith({
    String? name,
    String? email,
    AuthStatus? status,
    String? errorMessage,
    User? user,
    bool clearError = false,
  }) {
    return AuthState(
      name: name ?? this.name,
      email: email ?? this.email,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }

  @override
  String toString() {
    return 'AuthState('
        'name: $name, '
        'email: $email, '
        'status: $status, '
        'errorMessage: $errorMessage, '
        'user: $user'
        ')';
  }
}
