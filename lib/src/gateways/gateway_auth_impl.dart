import '../../jocaagura_domain.dart';

/// Concrete `GatewayAuth` that wraps a `ServiceSession` and normalizes results
/// to `Either<ErrorItem, Map<String, dynamic>(?)>`.
///
/// - **Error policy**
///   - All exceptions from the underlying service are caught and converted to
///     `Left(ErrorItem)` via the injected [ErrorMapper].
///   - Successful payloads are inspected with [ErrorMapper.fromPayload]. If it
///     reports a domain error (e.g., `{ ok: false, code: ... }`), the result is
///     converted to `Left(ErrorItem)`; otherwise `Right(json)`.
///
/// - **Auth state stream**
///   - `authStateChanges()` maps the service stream to `Either`.
///   - **`Right(null)` means "signed out"**.
///   - `Right(userJson)` means "signed in".
///   - Any stream error is caught and emitted as `Left(ErrorItem)`.
///
/// ### Usage
/// ```dart
/// final GatewayAuth auth = GatewayAuthImpl(
///   FakeServiceSession(latency: const Duration(milliseconds: 50)),
/// );
///
/// final r = await auth.logInUserAndPassword('john@doe.com', 'secret');
/// r.fold(
///   (err) => print('error: ${err.message}'),
///   (user) => print('signed in as ${user['email']}'),
/// );
///
/// final sub = auth.authStateChanges().listen((e) {
///   e.fold(
///     (err) => print('stream error: ${err.code}'),
///     (user) => print(user == null ? 'SIGNED OUT' : 'SIGNED IN'),
///   );
/// });
/// // ... later:
/// await sub.cancel();
/// ```
///
/// ### Notes
/// - Provide a custom [ErrorMapper] when you need provider-specific decoding of
///   error payloads. By default, [DefaultErrorMapper] is used.
/// - This class intentionally keeps I/O at JSON/primitives level to preserve a
///   clean boundary; domain mapping should occur in repositories/use cases.
class GatewayAuthImpl implements GatewayAuth {
  /// Creates a new `GatewayAuthImpl`.
  ///
  /// - [_service]: concrete auth service to adapt.
  /// - [errorMapper]: optional mapper to translate exceptions and error-like
  ///   payloads into [ErrorItem]. Defaults to [DefaultErrorMapper].
  GatewayAuthImpl(
    this._service, {
    ErrorMapper? errorMapper,
  }) : _err = errorMapper ?? const DefaultErrorMapper();

  final ServiceSession _service;
  final ErrorMapper _err;

  /// Wraps a service operation, mapping exceptions and error-like payloads
  /// to `Left(ErrorItem)`. On success, returns `Right(json)`.
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

  /// See [GatewayAuth.signInUserAndPassword].
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> signInUserAndPassword(
    String email,
    String password,
  ) =>
      _guardJson(
        () => _service.signInUserAndPassword(email: email, password: password),
        location: 'GatewayAuthImpl.signInUserAndPassword',
      );

  /// See [GatewayAuth.logInUserAndPassword].
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> logInUserAndPassword(
    String email,
    String password,
  ) =>
      _guardJson(
        () => _service.logInUserAndPassword(email: email, password: password),
        location: 'GatewayAuthImpl.logInUserAndPassword',
      );

  /// See [GatewayAuth.logInWithGoogle].
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> logInWithGoogle() =>
      _guardJson(
        _service.logInWithGoogle,
        location: 'GatewayAuthImpl.logInWithGoogle',
      );

  /// See [GatewayAuth.logInSilently].
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> logInSilently(
    Map<String, dynamic> sessionJson,
  ) =>
      _guardJson(
        () => _service.logInSilently(sessionJson),
        location: 'GatewayAuthImpl.logInSilently',
      );

  /// See [GatewayAuth.refreshSession].
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> refreshSession(
    Map<String, dynamic> sessionJson,
  ) =>
      _guardJson(
        () => _service.refreshSession(sessionJson),
        location: 'GatewayAuthImpl.refreshSession',
      );

  /// See [GatewayAuth.recoverPassword].
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> recoverPassword(
    String email,
  ) =>
      _guardJson(
        () => _service.recoverPassword(email: email),
        location: 'GatewayAuthImpl.recoverPassword',
      );

  /// See [GatewayAuth.logOutUser].
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> logOutUser(
    Map<String, dynamic> sessionJson,
  ) =>
      _guardJson(
        () => _service.logOutUser(sessionJson),
        location: 'GatewayAuthImpl.logOutUser',
      );

  /// See [GatewayAuth.getCurrentUser].
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> getCurrentUser() =>
      _guardJson(
        _service.getCurrentUser,
        location: 'GatewayAuthImpl.getCurrentUser',
      );

  /// See [GatewayAuth.isSignedIn].
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> isSignedIn() => _guardJson(
        _service.isSignedIn,
        location: 'GatewayAuthImpl.isSignedIn',
      );

  /// Maps the underlying auth state stream to `Either`.
  ///
  /// Semantics:
  /// - `Right(null)` → signed out.
  /// - `Right(userJson)` → signed in.
  /// - `Left(ErrorItem)` → stream error or error-like payload detected by the mapper.
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
            ? Left<ErrorItem, Map<String, dynamic>?>(pe)
            : Right<ErrorItem, Map<String, dynamic>?>(e);
      }
    } catch (e, s) {
      yield Left<ErrorItem, Map<String, dynamic>?>(
        _err.fromException(e, s, location: 'GatewayAuthImpl.authStateChanges'),
      );
    }
  }
}
