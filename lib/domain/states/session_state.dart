part of '../../jocaagura_domain.dart';

sealed class SessionState {
  const SessionState();
}

class Unauthenticated extends SessionState {
  const Unauthenticated();
}

class Authenticating extends SessionState {
  const Authenticating();
}

class Authenticated extends SessionState {
  const Authenticated(this.user);
  final UserModel user;
}

class Refreshing extends SessionState {
  const Refreshing(this.previous);
  final Authenticated previous;
}

class SessionError extends SessionState {
  const SessionError(this.message);
  final ErrorItem message;
}
