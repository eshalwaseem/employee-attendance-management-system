import '../models/user.dart';

enum AuthStatus { initial, loading, valid, invalid, authenticated, failure }

class AuthState {
  final AuthStatus status;

  final User? user;

  final String name;
  final String email;
  final String password;

  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.name = '',
    this.email = '',
    this.password = '',
    this.errorMessage,
  });


  bool get isNameValid {
    return name.trim().length >= 2;
  }

  bool get isEmailValid {
    final value = email.trim();

    if (value.isEmpty) {
      return false;
    }

    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  bool get isPasswordValid {
    return password.length >= 6;
  }



  bool get isLoading {
    return status == AuthStatus.loading;
  }

  bool get hasError {
    return status == AuthStatus.invalid || status == AuthStatus.failure;
  }

  bool get isSuccess {
    return status == AuthStatus.authenticated;
  }

  bool get isAuthenticated {
    return status == AuthStatus.authenticated && user != null;
  }



  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? name,
    String? email,
    String? password,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }



  @override
  String toString() {
    return 'AuthState('
        'status: $status, '
        'user: $user, '
        'name: $name, '
        'email: $email, '
        'passwordLength: ${password.length}, '
        'errorMessage: $errorMessage'
        ')';
  }
}
