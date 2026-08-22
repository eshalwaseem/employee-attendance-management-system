abstract class AuthEvent {
  const AuthEvent();
}

class EmailChanged extends AuthEvent {
  final String email;

  const EmailChanged(this.email);

  @override
  String toString() => 'EmailChanged(email: $email)';
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted();
}

class SignupSubmitted extends AuthEvent {
  final String name;

  const SignupSubmitted(this.name);

  @override
  String toString() => 'SignupSubmitted(name: $name)';
}
