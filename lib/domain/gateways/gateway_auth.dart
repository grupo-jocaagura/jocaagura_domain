part of '../../../jocaagura_domain.dart';

/// Map raw auth service operations to domain-safe results (`Either`) and
/// forward JSON payloads.
///
/// - **I/O**: primitives and JSON-like `Map<String, dynamic>` only; no domain
///   models at this boundary.
/// - **Error policy**: implementations must **catch all errors** and return
///   `Left(ErrorItem)`; no exceptions should escape through this interface.
/// - **Auth state**: `authStateChanges()` emits `Right(userJson)` when signed in
///   and **`Right(null)` when signed out**. Errors must be emitted as `Left`.
///
/// ### Behavioral contracts
/// - All methods return `Future<Either<ErrorItem, Map<String, dynamic>>>`,
///   except `authStateChanges()` which returns
///   `Stream<Either<ErrorItem, Map<String, dynamic>?>>`.
/// - `logInSilently(sessionJson)` and `refreshSession(sessionJson)` expect a
///   session-like JSON object (shape is implementation-defined, but must be
///   documented by the concrete class).
/// - `getCurrentUser()` resolves to `Right(userJson)` iff an active session
///   exists; otherwise `Left(ErrorItem)` (no exceptions).
///
/// ### Minimal usage (fake impl)
/// ```dart
/// class GatewayAuthFake implements GatewayAuth {
///   GatewayAuthFake(this._svc);
///   final ServiceSession _svc; // any concrete service (fake or real)
///
///   @override
///   Future<Either<ErrorItem, Map<String, dynamic>>> signInUserAndPassword(
///     String email,
///     String password,
///   ) async {
///     try {
///       final Map<String, dynamic> u = await _svc.signInUserAndPassword(
///         email: email,
///         password: password,
///       );
///       return Right(u);
///     } catch (e, s) {
///       return Left(ErrorItem.fromException(e, stackTrace: s));
///     }
///   }
///
///   // ...apply same catch/Left mapping for the remaining methods...
///
///   @override
///   Stream<Either<ErrorItem, Map<String, dynamic>?>> authStateChanges() {
///     return _svc.authStateChanges().map((e) => Right(e)).handleError((e, s) {
///       // If the underlying service can error, map it:
///       // return Left(ErrorItem.fromException(e, stackTrace: s));
///     });
///   }
///
///   // Other methods elided for brevity.
/// }
///
/// void main() async {
///   final GatewayAuth auth = GatewayAuthFake(FakeServiceSession());
///   final Either<ErrorItem, Map<String, dynamic>> r =
///       await auth.logInUserAndPassword('john@doe.com', 'secret');
///   r.fold(
///     (err) => print('error: ${err.message}'),
///     (user) => print('signed in: ${user['email']}'),
///   );
/// }
/// ```
///
/// ### Notes
/// - Keep this interface free of domain models to preserve a clean boundary.
/// - Implementations should normalize provider-specific errors into a stable
///   `ErrorItem` taxonomy (e.g., network, backend, mapping).
abstract class GatewayAuth {
  /// Sign up or sign in with email & password; return user JSON on success.
  ///
  /// **Preconditions**
  /// - [email] and [password] must be non-empty at implementation level.
  ///
  /// **Returns**
  /// - `Right(userJson)` on success; `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, Map<String, dynamic>>> signInUserAndPassword(
    String email,
    String password,
  );

  /// Log in with email & password; return user JSON on success.
  ///
  /// **Returns**
  /// - `Right(userJson)` on success; `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, Map<String, dynamic>>> logInUserAndPassword(
    String email,
    String password,
  );

  /// Log in with the provider's Google flow.
  ///
  /// **Returns**
  /// - `Right(userJson)` on success; `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, Map<String, dynamic>>> logInWithGoogle();

  /// Consider an existing session payload valid and log in silently.
  ///
  /// **Contract**
  /// - [sessionJson] must be a session-like JSON map (shape defined by impl).
  ///
  /// **Returns**
  /// - `Right(userJson)` on success; `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, Map<String, dynamic>>> logInSilently(
    Map<String, dynamic> sessionJson,
  );

  /// Refresh token metadata for the provided session payload.
  ///
  /// **Contract**
  /// - [sessionJson] must include the token block expected by the impl (e.g. `jwt`).
  ///
  /// **Returns**
  /// - `Right(updatedSessionJson)` on success; `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, Map<String, dynamic>>> refreshSession(
    Map<String, dynamic> sessionJson,
  );

  /// Trigger a password recovery flow for the given email.
  ///
  /// **Returns**
  /// - `Right(ackJson)` on success; `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, Map<String, dynamic>>> recoverPassword(
    String email,
  );

  /// Log out the current user.
  ///
  /// **Returns**
  /// - `Right(ackJson)` on success (may include `{ok: true}`); `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, Map<String, dynamic>>> logOutUser(
    Map<String, dynamic> sessionJson,
  );

  /// Get the current user JSON if signed in.
  ///
  /// **Returns**
  /// - `Right(userJson)` when a session is active; `Left(ErrorItem)` otherwise.
  Future<Either<ErrorItem, Map<String, dynamic>>> getCurrentUser();

  /// Tell whether a session is active.
  ///
  /// **Returns**
  /// - `Right({'isSignedIn': true|false})` on success; `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, Map<String, dynamic>>> isSignedIn();

  /// Emit auth state changes as `Either`.
  ///
  /// **Semantics**
  /// - `Right(userJson)` when signed in.
  /// - `Right(null)` when signed out.
  /// - `Left(ErrorItem)` for streamable errors.
  Stream<Either<ErrorItem, Map<String, dynamic>?>> authStateChanges();
}
