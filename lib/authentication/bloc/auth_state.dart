import '../models/user.dart';

enum AuthStatus {
  initial,
  invalid,
  valid,
  loading,
  success,
  authenticated,
  failure,
}

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

  bool get isEmailValid =>
      status == AuthStatus.valid ||
      status == AuthStatus.loading ||
      status == AuthStatus.success ||
      status == AuthStatus.authenticated;

  bool get isLoading =>
      status == AuthStatus.loading;

  bool get isSuccess =>
      status == AuthStatus.success;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated ||
      status == AuthStatus.success;

  bool get hasError =>
      status == AuthStatus.invalid ||
      status == AuthStatus.failure;

  AuthState copyWith({
    String? name,
    String? email,
    AuthStatus? status,
    String? errorMessage,
    User? user,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      name: name ?? this.name,
      email: email ?? this.email,
      status: status ?? this.status,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      user: clearUser
          ? null
          : user ?? this.user,
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