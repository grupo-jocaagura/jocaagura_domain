import '../../jocaagura_domain.dart';

/// Default repository that **maps raw payloads to domain** ([ConnectivityModel])
/// and enforces error semantics using an [ErrorMapper].
///
/// ### Error contract
/// - `fromPayload(...)` detects business errors *encoded in payloads* and
///   returns `Left(ErrorItem)`.
/// - If mapping fails (`fromJson` throws), the repository converts it into
///   `Left(ErrorItem)` via `fromException(...)`.
/// - Repository **never throws**; it always returns `Either<ErrorItem, ConnectivityModel>`.
///
/// ### Example
/// ```dart
/// final repo = RepositoryConnectivityImpl(gateway, errorMapper: DefaultErrorMapper());
/// final res = await repo.snapshot();
/// res.fold(
///   (err) => print('Repo error: ${err.code}'),
///   (model) => print('Speed: ${model.internetSpeed}'),
/// );
/// ```
class RepositoryConnectivityImpl extends RepositoryConnectivity {
  RepositoryConnectivityImpl(
    GatewayConnectivity gateway, {
    ErrorMapper? errorMapper,
  })  : _gateway = gateway,
        _err = errorMapper ?? DefaultErrorMapper();

  final GatewayConnectivity _gateway;
  final ErrorMapper _err;

  Map<String, dynamic> _mergeWithCurrent(Map<String, dynamic> raw) {
    final Map<String, dynamic> base =
        Map<String, dynamic>.from(_gateway.current());
    base.addAll(raw);
    return base;
  }

  Either<ErrorItem, ConnectivityModel> _mapPayload(
    Map<String, dynamic> payload,
  ) {
    final ErrorItem? pe =
        _err.fromPayload(payload, location: 'RepositoryConnectivityImpl');
    if (pe != null) {
      return Left<ErrorItem, ConnectivityModel>(pe);
    }
    try {
      return Right<ErrorItem, ConnectivityModel>(
        ConnectivityModel.fromJson(payload),
      );
    } catch (e, s) {
      return Left<ErrorItem, ConnectivityModel>(
        _err.fromException(
          e,
          s,
          location: 'RepositoryConnectivityImpl.mapPayload',
        ),
      );
    }
  }

  Either<ErrorItem, ConnectivityModel> flatMap(
    Either<ErrorItem, Map<String, dynamic>> either,
  ) {
    return either.fold<Either<ErrorItem, ConnectivityModel>>(
      (ErrorItem e) => Left<ErrorItem, ConnectivityModel>(e),
      (Map<String, dynamic> p) => _mapPayload(_mergeWithCurrent(p)),
    );
  }

  @override
  Future<Either<ErrorItem, ConnectivityModel>> snapshot() async {
    final Either<ErrorItem, Map<String, dynamic>> res =
        await _gateway.snapshot();
    return res.fold<Either<ErrorItem, ConnectivityModel>>(
      (ErrorItem e) => Left<ErrorItem, ConnectivityModel>(e),
      (Map<String, dynamic> p) => _mapPayload(_mergeWithCurrent(p)),
    );
  }

  @override
  Stream<Either<ErrorItem, ConnectivityModel>> watch() {
    return _gateway.watch().map((Either<ErrorItem, Map<String, dynamic>> e) {
      return flatMap(e);
    });
  }

  @override
  Future<Either<ErrorItem, ConnectivityModel>> checkType() async {
    final Either<ErrorItem, Map<String, dynamic>> res =
        await _gateway.checkType();
    return flatMap(res);
  }

  @override
  Future<Either<ErrorItem, ConnectivityModel>> checkSpeed() async {
    final Either<ErrorItem, Map<String, dynamic>> res =
        await _gateway.checkSpeed();
    return flatMap(res);
  }

  @override
  ConnectivityModel current() => ConnectivityModel.fromJson(_gateway.current());
}
