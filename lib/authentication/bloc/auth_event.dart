abstract class AuthEvent {
  const AuthEvent();
}

class NameChanged extends AuthEvent {
  final String name;

  const NameChanged(this.name);

  @override
  String toString() => 'NameChanged(name: $name)';
}

class EmailChanged extends AuthEvent {
  final String email;

  const EmailChanged(this.email);

  @override
  String toString() => 'EmailChanged(email: $email)';
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted();

  @override
  String toString() => 'LoginSubmitted()';
}

class SignupSubmitted extends AuthEvent {
  final String name;

  const SignupSubmitted({
    required this.name,
  });

  @override
  String toString() => 'SignupSubmitted(name: $name)';
}

class AuthSessionRequested extends AuthEvent {
  const AuthSessionRequested();

  @override
  String toString() => 'AuthSessionRequested()';
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();

  @override
  String toString() => 'LogoutRequested()';
}