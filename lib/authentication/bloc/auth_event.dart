abstract class AuthEvent {
  const AuthEvent();
}

class NameChanged extends AuthEvent {
  final String name;

  const NameChanged(this.name);

  @override
  String toString() {
    return 'NameChanged(name: $name)';
  }
}

class EmailChanged extends AuthEvent {
  final String email;

  const EmailChanged(this.email);

  @override
  String toString() {
    return 'EmailChanged(email: $email)';
  }
}


class PasswordChanged extends AuthEvent {
  final String password;

  const PasswordChanged(this.password);

  @override
  String toString() {
    return 'PasswordChanged(password: ***hidden***)';
  }
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted();

  @override
  String toString() {
    return 'LoginSubmitted()';
  }
}


class SignupSubmitted extends AuthEvent {
  final String name;

  const SignupSubmitted({required this.name});

  @override
  String toString() {
    return 'SignupSubmitted(name: $name)';
  }
}

class AuthSessionRequested extends AuthEvent {
  const AuthSessionRequested();

  @override
  String toString() {
    return 'AuthSessionRequested()';
  }
}


class LogoutRequested extends AuthEvent {
  const LogoutRequested();

  @override
  String toString() {
    return 'LogoutRequested()';
  }
}
