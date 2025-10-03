import '../../jocaagura_domain.dart';

/// Concrete `RepositoryAuth` that adapts JSON payloads from a `GatewayAuth`
/// into domain models (`UserModel`) and stabilizes failures with `Either`.
///
/// - **Mapping policy**
///   - Successful JSON payloads are parsed with `UserModel.fromJson`.
///   - If the payload encodes a business error (e.g. `{ok:false}`, `{error:{...}}`,
///     or `{code,message}`), the injected [ErrorMapper] returns an [ErrorItem]
///     and the repository yields `Left(ErrorItem)`.
///   - Any thrown exception (parse, shape mismatch, etc.) is caught and mapped
///     to `Left(ErrorItem)` via [ErrorMapper.fromException].
///
/// - **Ack policy**
///   - Operations that conceptually return an acknowledgement (e.g. recover,
///     logout) are converted to `Right(void)` when the payload is considered OK,
///     otherwise `Left(ErrorItem)`.
///
/// - **Auth state stream**
///   - `authStateChanges()` maps gateway emissions:
///     - `Right(null)` → signed out
///     - `Right(userJson)` → parsed to `Right(UserModel)`
///     - any error → `Left(ErrorItem)`
///
/// ### Notes
/// - Keep provider-specific quirks at the Gateway. Repository focuses on
///   domain parsing/validation and error normalization.
/// - The same [ErrorMapper] convention is used at Gateway and Repository to
///   preserve consistent error taxonomy across layers.
///
/// ### Example
/// ```dart
/// void main(){
/// final RepositoryAuth repo = RepositoryAuthImpl(
///   gateway: GatewayAuthImpl(FakeServiceSession()),
/// );
///
/// final Either<ErrorItem, UserModel> r =
///     await repo.logInUserAndPassword('john@doe.com', 'secret');
///
/// r.fold(
///   (err) => print('error: ${err.code}'),
///   (user) => print('hello ${user.email}'),
/// );
/// }
/// ```
class RepositoryAuthImpl implements RepositoryAuth {
  /// Creates a new [RepositoryAuthImpl].
  ///
  /// - [gateway]: underlying data source for auth calls.
  /// - [errorMapper]: optional error mapper; defaults to [DefaultErrorMapper].
  RepositoryAuthImpl({
    required GatewayAuth gateway,
    ErrorMapper? errorMapper,
  })  : _gateway = gateway,
        _err = errorMapper ?? const DefaultErrorMapper();

  final GatewayAuth _gateway;
  final ErrorMapper _err;

  /// Converts a successful JSON payload into a [UserModel] and then to an `R`.
  ///
  /// - If [ErrorMapper.fromPayload] detects a business error, returns `Left`.
  /// - If `UserModel.fromJson` throws, returns `Left` built from the exception.
  Either<ErrorItem, R> _mapUser<R>({
    required Map<String, dynamic> json,
    required R Function(UserModel user) onOk,
    required String location,
  }) {
    final ErrorItem? pe = _err.fromPayload(json, location: location);
    if (pe != null) {
      return Left<ErrorItem, R>(pe);
    }
    try {
      final UserModel user = UserModel.fromJson(json);
      return Right<ErrorItem, R>(onOk(user));
    } catch (e, s) {
      return Left<ErrorItem, R>(_err.fromException(e, s, location: location));
    }
  }

  /// Converts an acknowledgement-like JSON payload to `Right(void)` if OK,
  /// otherwise returns `Left(ErrorItem)` detected by the [ErrorMapper].
  Either<ErrorItem, void> ackToVoid(
    Map<String, dynamic> json, {
    required String location,
  }) {
    final ErrorItem? pe = _err.fromPayload(json, location: location);
    if (pe != null) {
      return Left<ErrorItem, void>(pe);
    }
    return Right<ErrorItem, void>(null);
  }

  @override
  Future<Either<ErrorItem, UserModel>> signInUserAndPassword(
    String email,
    String password,
  ) async {
    final Either<ErrorItem, Map<String, dynamic>> r =
        await _gateway.signInUserAndPassword(email, password);
    return r.fold(
      Left.new,
      (Map<String, dynamic> json) => _mapUser<UserModel>(
        json: json,
        onOk: (UserModel u) => u,
        location: 'RepositoryAuthImpl.signInUserAndPassword',
      ),
    );
  }

  @override
  Future<Either<ErrorItem, UserModel>> logInUserAndPassword(
    String email,
    String password,
  ) async {
    final Either<ErrorItem, Map<String, dynamic>> r =
        await _gateway.logInUserAndPassword(email, password);
    return r.fold(
      Left.new,
      (Map<String, dynamic> json) => _mapUser<UserModel>(
        json: json,
        onOk: (UserModel u) => u,
        location: 'RepositoryAuthImpl.logInUserAndPassword',
      ),
    );
  }

  @override
  Future<Either<ErrorItem, UserModel>> logInWithGoogle() async {
    final Either<ErrorItem, Map<String, dynamic>> r =
        await _gateway.logInWithGoogle();
    return r.fold(
      Left.new,
      (Map<String, dynamic> json) => _mapUser<UserModel>(
        json: json,
        onOk: (UserModel u) => u,
        location: 'RepositoryAuthImpl.logInWithGoogle',
      ),
    );
  }

  @override
  Future<Either<ErrorItem, UserModel>> logInSilently(
    UserModel currentUser,
  ) async {
    final Either<ErrorItem, Map<String, dynamic>> r =
        await _gateway.logInSilently(currentUser.toJson());
    return r.fold(
      Left.new,
      (Map<String, dynamic> json) => _mapUser<UserModel>(
        json: json,
        onOk: (UserModel u) => u,
        location: 'RepositoryAuthImpl.logInSilently',
      ),
    );
  }

  @override
  Future<Either<ErrorItem, UserModel>> refreshSession(
    UserModel currentUser,
  ) async {
    final Either<ErrorItem, Map<String, dynamic>> r =
        await _gateway.refreshSession(currentUser.toJson());
    return r.fold(
      Left.new,
      (Map<String, dynamic> json) => _mapUser<UserModel>(
        json: json,
        onOk: (UserModel u) => u,
        location: 'RepositoryAuthImpl.refreshSession',
      ),
    );
  }

  @override
  Future<Either<ErrorItem, void>> recoverPassword(String email) async {
    final Either<ErrorItem, Map<String, dynamic>> r =
        await _gateway.recoverPassword(email);
    return r.fold(
      Left.new,
      (Map<String, dynamic> json) => ackToVoid(
        json,
        location: 'RepositoryAuthImpl.recoverPassword',
      ),
    );
  }

  @override
  Future<Either<ErrorItem, void>> logOutUser(UserModel user) async {
    final Either<ErrorItem, Map<String, dynamic>> r =
        await _gateway.logOutUser(user.toJson());
    return r.fold(
      Left.new,
      (Map<String, dynamic> json) => ackToVoid(
        json,
        location: 'RepositoryAuthImpl.logOutUser',
      ),
    );
  }

  @override
  Future<Either<ErrorItem, UserModel>> getCurrentUser() async {
    final Either<ErrorItem, Map<String, dynamic>> r =
        await _gateway.getCurrentUser();
    return r.fold(
      Left.new,
      (Map<String, dynamic> json) => _mapUser<UserModel>(
        json: json,
        onOk: (UserModel u) => u,
        location: 'RepositoryAuthImpl.getCurrentUser',
      ),
    );
  }

  @override
  Future<Either<ErrorItem, bool>> isSignedIn() async {
    final Either<ErrorItem, Map<String, dynamic>> r =
        await _gateway.isSignedIn();
    return r.fold(
      Left.new,
      (Map<String, dynamic> json) {
        final ErrorItem? pe =
            _err.fromPayload(json, location: 'RepositoryAuthImpl.isSignedIn');
        if (pe != null) {
          return Left<ErrorItem, bool>(pe);
        }
        try {
          final bool signed = Utils.getBoolFromDynamic(json['isSignedIn']);
          return Right<ErrorItem, bool>(signed);
        } catch (e, s) {
          return Left<ErrorItem, bool>(
            _err.fromException(e, s, location: 'RepositoryAuthImpl.isSignedIn'),
          );
        }
      },
    );
  }

  @override
  Stream<Either<ErrorItem, UserModel?>> authStateChanges() async* {
    await for (final Either<ErrorItem, Map<String, dynamic>?> e
        in _gateway.authStateChanges()) {
      yield await e.fold(
        (ErrorItem err) async => Left<ErrorItem, UserModel?>(err),
        (Map<String, dynamic>? json) async {
          if (json == null) {
            return Right<ErrorItem, UserModel?>(null);
          }
          final ErrorItem? pe = _err.fromPayload(
            json,
            location: 'RepositoryAuthImpl.authStateChanges',
          );
          if (pe != null) {
            return Left<ErrorItem, UserModel?>(pe);
          }
          try {
            return Right<ErrorItem, UserModel?>(UserModel.fromJson(json));
          } catch (ex, st) {
            return Left<ErrorItem, UserModel?>(
              _err.fromException(
                ex,
                st,
                location: 'RepositoryAuthImpl.authStateChanges',
              ),
            );
          }
        },
      );
    }
  }
}
