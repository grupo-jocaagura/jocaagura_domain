import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

class _StubGatewayOk implements GatewayConnectivity {
  _StubGatewayOk(this._curr);
  final ConnectivityModel _curr;
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> snapshot() async =>
      Right<ErrorItem, Map<String, dynamic>>(_curr.toJson());
  @override
  Stream<Either<ErrorItem, Map<String, dynamic>>> watch() async* {
    yield Right<ErrorItem, Map<String, dynamic>>(_curr.toJson());
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> checkType() async =>
      Right<ErrorItem, Map<String, dynamic>>(
        <String, dynamic>{'connectionType': _curr.connectionType.name},
      );
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> checkSpeed() async =>
      Right<ErrorItem, Map<String, dynamic>>(
        <String, dynamic>{'internetSpeed': _curr.internetSpeed},
      );
  @override
  Map<String, dynamic> current() => _curr.toJson();
}

class _StubGatewayPayloadError implements GatewayConnectivity {
  _StubGatewayPayloadError(this._curr);
  final ConnectivityModel _curr;
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> snapshot() async =>
      Right<ErrorItem, Map<String, dynamic>>(const <String, dynamic>{
        'error': <String, String>{'code': 'MY_ERR', 'message': 'bad'},
      });
  @override
  Stream<Either<ErrorItem, Map<String, dynamic>>> watch() async* {
    yield Right<ErrorItem, Map<String, dynamic>>(const <String, dynamic>{
      'error': <String, String>{'code': 'MY_ERR', 'message': 'bad'},
    });
  }

  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> checkType() async =>
      Right<ErrorItem, Map<String, dynamic>>(const <String, dynamic>{
        'error': <String, String>{'code': 'MY_ERR', 'message': 'bad'},
      });
  @override
  Future<Either<ErrorItem, Map<String, dynamic>>> checkSpeed() async =>
      Right<ErrorItem, Map<String, dynamic>>(const <String, dynamic>{
        'error': <String, String>{'code': 'MY_ERR', 'message': 'bad'},
      });
  @override
  Map<String, dynamic> current() => _curr.toJson();
}

void main() {
  group('RepositoryConnectivityImpl', () {
    test('snapshot maps payload → ConnectivityModel', () async {
      final _StubGatewayOk gw = _StubGatewayOk(
        const ConnectivityModel(
          connectionType: ConnectionTypeEnum.wifi,
          internetSpeed: 40,
        ),
      );
      final RepositoryConnectivityImpl repo = RepositoryConnectivityImpl(
        gw,
        errorMapper: const DefaultErrorMapper(),
      );
      final Either<ErrorItem, ConnectivityModel> res = await repo.snapshot();
      expect(res.isRight, isTrue);
      final ConnectivityModel model =
          (res as Right<ErrorItem, ConnectivityModel>).value;
      expect(model.connectionType, ConnectionTypeEnum.wifi);
      expect(model.internetSpeed, 40.0);
    });

    test('payload with business error → Left', () async {
      final _StubGatewayPayloadError gw = _StubGatewayPayloadError(
        const ConnectivityModel(
          connectionType: ConnectionTypeEnum.mobile,
          internetSpeed: 10,
        ),
      );
      final RepositoryConnectivityImpl repo = RepositoryConnectivityImpl(
        gw,
        errorMapper: const DefaultErrorMapper(),
      );
      final Either<ErrorItem, ConnectivityModel> res = await repo.snapshot();
      expect(res.isLeft, isTrue);
      final ErrorItem err = (res as Left<ErrorItem, ConnectivityModel>).value;
      expect(err.code, 'MY_ERR');
    });

    test('watch maps stream payload → model', () async {
      const ConnectivityModel curr = ConnectivityModel(
        connectionType: ConnectionTypeEnum.ethernet,
        internetSpeed: 80,
      );
      final _StubGatewayOk gw = _StubGatewayOk(curr);
      final RepositoryConnectivityImpl repo = RepositoryConnectivityImpl(
        gw,
        errorMapper: const DefaultErrorMapper(),
      );
      final Either<ErrorItem, ConnectivityModel> first =
          await repo.watch().first;
      expect(first.isRight, isTrue);
      final ConnectivityModel model =
          (first as Right<ErrorItem, ConnectivityModel>).value;
      expect(model.connectionType, curr.connectionType);
      expect(model.internetSpeed, curr.internetSpeed);
    });
  });
}
