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


class ProfileNameUpdated extends AuthEvent {
  final String name;

  const ProfileNameUpdated(this.name);

  @override
  String toString() {
    return 'ProfileNameUpdated(name: $name)';
  }
}


class ProfileImageChanged extends AuthEvent {
  final String imageUrl;

  const ProfileImageChanged(this.imageUrl);

  @override
  String toString() {
    return 'ProfileImageChanged(imageUrl: $imageUrl)';
  }
}

class ProfileImageRemoved extends AuthEvent {
  const ProfileImageRemoved();

  @override
  String toString() {
    return 'ProfileImageRemoved()';
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
