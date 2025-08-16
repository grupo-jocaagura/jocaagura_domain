import '../../jocaagura_domain.dart';

/// Default implementation of [GatewayConnectivity].
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
