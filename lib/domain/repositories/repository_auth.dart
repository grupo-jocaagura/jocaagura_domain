part of '../../../jocaagura_domain.dart';

/// Repository boundary for authentication: converts JSON payloads from
/// Gateways into **domain models** (`UserModel`) and stabilizes failures
/// using `Either<ErrorItem, T>`.
///
/// - **Mapping**: Implementations must parse and validate JSON into
///   `UserModel` (no raw maps should escape this layer).
/// - **Error policy**: No exceptions should leak. All failures must be
///   represented as `Left(ErrorItem)` with meaningful `code/message`.
/// - **Auth state**:
///   - `authStateChanges()` emits `Right(user)` when signed in,
///     **`Right(null)` when signed out**, and `Left(ErrorItem)` on errors.
///
/// ### Behavioral contracts
/// - Methods returning a `UserModel` must:
///   1) delegate to a Gateway (or data source),
///   2) map the resulting JSON into a valid `UserModel`,
///   3) return `Right(user)` on success or `Left(ErrorItem)` on failure.
/// - `logInSilently(currentUser)` / `refreshSession(currentUser)`:
///   `currentUser` must contain enough data (e.g., tokens/ids) required by
///   the underlying provider; implementations must document these needs.
/// - `recoverPassword(email)` and `logOutUser(user)` return `Right(void)` on
///   success (ack semantics) and `Left(ErrorItem)` otherwise.
/// - `isSignedIn()` returns `Right(true|false)` or `Left(ErrorItem)` on failure.
///
/// ### Minimal usage example
/// ```dart
/// void main() async {
///   final RepositoryAuth repo = MyRepositoryAuthImpl(
///     gateway: MyGatewayAuthImpl(...),
///     mapper: MyUserMapper(), // JSON -> UserModel
///   );
///
///   final Either<ErrorItem, UserModel> r =
///       await repo.logInUserAndPassword('john@doe.com', 'secret');
///
///   r.fold(
///     (err) => print('error: ${err.code} ${err.message}'),
///     (user) => print('hello ${user.email}'),
///   );
///
///   final sub = repo.authStateChanges().listen((e) {
///     e.fold(
///       (err) => print('stream error: ${err.code}'),
///       (user) => print(user == null ? 'SIGNED OUT' : 'SIGNED IN'),
///     );
///   });
///
///   // ... later:
///   await sub.cancel();
/// }
/// ```
///
/// ### Notes
/// - Keep this boundary model-centric: parsing, validation, and invariants
///   belong here. Provider-specific quirks should be handled in Gateways,
///   then normalized and mapped by the Repository.
abstract class RepositoryAuth {
  /// Sign up or sign in with email & password and return a `UserModel`.
  ///
  /// **Returns**
  /// - `Right(UserModel)` on success; `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, UserModel>> signInUserAndPassword(
    String email,
    String password,
  );

  /// Log in with email & password and return a `UserModel`.
  ///
  /// **Returns**
  /// - `Right(UserModel)` on success; `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, UserModel>> logInUserAndPassword(
    String email,
    String password,
  );

  /// Log in using the provider's Google flow.
  ///
  /// **Returns**
  /// - `Right(UserModel)` on success; `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, UserModel>> logInWithGoogle();

  /// Consider the provided user/session valid and complete the sign-in.
  ///
  /// **Contract**
  /// - [currentUser] must contain the fields required by the provider to
  ///   validate/restore the session (documented by the impl).
  ///
  /// **Returns**
  /// - `Right(UserModel)` on success; `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, UserModel>> logInSilently(UserModel currentUser);

  /// Refresh session/token data for the given user.
  ///
  /// **Returns**
  /// - `Right(UserModel)` with updated token/session fields on success;
  ///   `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, UserModel>> refreshSession(UserModel currentUser);

  /// Trigger a password recovery flow for [email].
  ///
  /// **Returns**
  /// - `Right(void)` on success; `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, void>> recoverPassword(String email);

  /// Log out the given [user].
  ///
  /// **Returns**
  /// - `Right(void)` on success; `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, void>> logOutUser(UserModel user);

  /// Get the current user if signed in.
  ///
  /// **Returns**
  /// - `Right(UserModel)` when a session is active; `Left(ErrorItem)` otherwise.
  Future<Either<ErrorItem, UserModel>> getCurrentUser();

  /// Tell whether a session is active.
  ///
  /// **Returns**
  /// - `Right(true|false)` on success; `Left(ErrorItem)` on failure.
  Future<Either<ErrorItem, bool>> isSignedIn();

  /// Emit auth state changes as `Either`.
  ///
  /// **Semantics**
  /// - `Right(UserModel)` → signed in.
  /// - `Right(null)` → signed out.
  /// - `Left(ErrorItem)` → stream error.
  Stream<Either<ErrorItem, UserModel?>> authStateChanges();
}
