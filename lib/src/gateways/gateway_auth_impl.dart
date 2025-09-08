import '../../jocaagura_domain.dart';

class GatewayAuthImpl implements GatewayAuth {
  GatewayAuthImpl(
    this._service, {
    ErrorMapper? errorMapper,
  }) : _err = errorMapper ?? const DefaultErrorMapper();

  final ServiceSession _service;
  final ErrorMapper _err;

  Future<Either<ErrorItem, Map<String, dynamic>>> _guardJson(
    Future<Map<String, dynamic>> Function() op, {
    required String location,
  }) async {
    try {
      final Map<String, dynamic> json = await op();
      final ErrorItem? pe = _err.fromPayload(json, location: location);
      return pe != null
          ? Left<ErrorItem, Map<String, dynamic>>(pe)
          : Right<ErrorItem, Map<String, dynamic>>(json);
    } catch (e, s) {
      return Left<ErrorItem, Map<String, dynamic>>(
        _err.fromException(e, s, location: location),
      );
    }
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> signInUserAndPassword(
    String email,
    String password,
  ) =>
      _guardJson(
        () => _service.signInUserAndPassword(email: email, password: password),
        location: 'GatewayAuthImpl.signInUserAndPassword',
      );

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> logInUserAndPassword(
    String email,
    String password,
  ) =>
      _guardJson(
        () => _service.logInUserAndPassword(email: email, password: password),
        location: 'GatewayAuthImpl.logInUserAndPassword',
      );

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> logInWithGoogle() =>
      _guardJson(
        _service.logInWithGoogle,
        location: 'GatewayAuthImpl.logInWithGoogle',
      );

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> logInSilently(
    Map<String, dynamic> sessionJson,
  ) =>
      _guardJson(
        () => _service.logInSilently(sessionJson),
        location: 'GatewayAuthImpl.logInSilently',
      );

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> refreshSession(
    Map<String, dynamic> sessionJson,
  ) =>
      _guardJson(
        () => _service.refreshSession(sessionJson),
        location: 'GatewayAuthImpl.refreshSession',
      );

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> recoverPassword(
    String email,
  ) =>
      _guardJson(
        () => _service.recoverPassword(email: email),
        location: 'GatewayAuthImpl.recoverPassword',
      );

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> logOutUser(
    Map<String, dynamic> sessionJson,
  ) =>
      _guardJson(
        () => _service.logOutUser(sessionJson),
        location: 'GatewayAuthImpl.logOutUser',
      );

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> getCurrentUser() =>
      _guardJson(
        _service.getCurrentUser,
        location: 'GatewayAuthImpl.getCurrentUser',
      );

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> isSignedIn() => _guardJson(
        _service.isSignedIn,
        location: 'GatewayAuthImpl.isSignedIn',
      );

  @override
  Stream<Either<ErrorItem, Map<String, dynamic>?>> authStateChanges() async* {
    try {
      await for (final Map<String, dynamic>? e in _service.authStateChanges()) {
        if (e == null) {
          yield Right<ErrorItem, Map<String, dynamic>?>(null);
          continue;
        }
        final ErrorItem? pe =
            _err.fromPayload(e, location: 'GatewayAuthImpl.authStateChanges');
        yield pe != null
            ? Left<ErrorItem, Map<String, dynamic>>(pe)
            : Right<ErrorItem, Map<String, dynamic>>(e);
      }
    } catch (e, s) {
      yield Left<ErrorItem, Map<String, dynamic>>(
        _err.fromException(e, s, location: 'GatewayAuthImpl.authStateChanges'),
      );
    }
  }
}
