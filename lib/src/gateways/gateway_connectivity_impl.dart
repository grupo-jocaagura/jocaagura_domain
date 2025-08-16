import '../../jocaagura_domain.dart';

/// Concrete gateway that converts [ServiceConnectivity] into **raw payloads**
/// (JSON-like `Map<String, dynamic>`), deferring domain mapping to the
/// repository layer.
///
/// ### Error contract
/// - Any exception thrown by the underlying service is mapped to an [ErrorItem]
///   using the provided [ErrorMapper].
/// - The gateway **never throws**; it always returns `Either<ErrorItem, Map>`.
///
/// ### Example
/// ```dart
/// final gateway = GatewayConnectivityImpl(service, DefaultErrorMapper());
/// final either = await gateway.snapshot();
/// either.fold(
///   (err) => print('Gateway error: ${err.code} -> ${err.description}'),
///   (map) => print('Payload: $map'),
/// );
/// ```
class GatewayConnectivityImpl extends GatewayConnectivity {
  GatewayConnectivityImpl(this._service, this._errorMapper);

  final ServiceConnectivity _service;
  final ErrorMapper _errorMapper;

  Map<String, dynamic> _toMap(ConnectivityModel m) => m.toJson();

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> snapshot() async {
    try {
      final ConnectionTypeEnum type = await _service.checkConnectivity();
      final double speed = await _service.checkInternetSpeed();
      final ConnectivityModel model = _service.current.copyWith(
        connectionType: type,
        internetSpeed: speed,
      );
      return Right<ErrorItem, Map<String, dynamic>>(_toMap(model));
    } catch (e, s) {
      return Left<ErrorItem, Map<String, dynamic>>(
        _errorMapper.fromException(
          e,
          s,
          location: 'GatewayConnectivityImpl.snapshot',
        ),
      );
    }
  }

  @override
  Stream<Either<ErrorItem, Map<String, dynamic>>> watch() async* {
    try {
      await for (final ConnectivityModel m in _service.connectivityStream()) {
        yield Right<ErrorItem, Map<String, dynamic>>(_toMap(m));
      }
    } catch (e, s) {
      yield Left<ErrorItem, Map<String, dynamic>>(
        _errorMapper.fromException(
          e,
          s,
          location: 'GatewayConnectivityImpl.watch',
        ),
      );
    }
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> checkType() async {
    try {
      final ConnectionTypeEnum t = await _service.checkConnectivity();
      return Right<ErrorItem, Map<String, dynamic>>(<String, dynamic>{
        ConnectivityModelEnum.connectionType.name: t.name,
      });
    } catch (e, s) {
      return Left<ErrorItem, Map<String, dynamic>>(
        _errorMapper.fromException(
          e,
          s,
          location: 'GatewayConnectivityImpl.checkType',
        ),
      );
    }
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> checkSpeed() async {
    try {
      final double s = await _service.checkInternetSpeed();
      return Right<ErrorItem, Map<String, dynamic>>(<String, dynamic>{
        ConnectivityModelEnum.internetSpeed.name: s,
      });
    } catch (e, s) {
      return Left<ErrorItem, Map<String, dynamic>>(
        _errorMapper.fromException(
          e,
          s,
          location: 'GatewayConnectivityImpl.checkSpeed',
        ),
      );
    }
  }

  @override
  Map<String, dynamic> current() => _toMap(_service.current);
}
