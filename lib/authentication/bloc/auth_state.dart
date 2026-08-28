import '../models/user.dart';

enum AuthStatus { initial, loading, valid, invalid, authenticated, failure }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String name;
  final String email;
  final String password;
  final String? profileImage;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.name = '',
    this.email = '',
    this.password = '',
    this.profileImage,
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

  bool get hasProfileImage {
    return profileImage != null && profileImage!.isNotEmpty;
  }

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? name,
    String? email,
    String? password,
    String? profileImage,
    String? errorMessage,
    bool clearUser = false,
    bool clearProfileImage = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      profileImage: clearProfileImage
          ? null
          : profileImage ?? this.profileImage,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.name == name &&
        other.email == email &&
        other.password == password &&
        other.profileImage == profileImage &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      user,
      name,
      email,
      password,
      profileImage,
      errorMessage,
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
        'profileImage: $profileImage, '
        'errorMessage: $errorMessage'
        ')';
  }
}
