import '../../jocaagura_domain.dart';

class RepositoryAuthImpl implements RepositoryAuth {
  RepositoryAuthImpl({
    required GatewayAuth gateway,
    ErrorMapper? errorMapper,
  })  : _gateway = gateway,
        _err = errorMapper ?? DefaultErrorMapper();

  final GatewayAuth _gateway;
  final ErrorMapper _err;

  Either<ErrorItem, R> _mapUser<R>({
    required Map<String, dynamic> json,
    required R Function(UserModel user) onOk,
    required String location,
  }) {
    // Business error encoded in payload?
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

  Either<ErrorItem, void> _ackToVoid(
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
      (Map<String, dynamic> json) => _ackToVoid(
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
      (Map<String, dynamic> json) => _ackToVoid(
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
