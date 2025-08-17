import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('GatewayConnectivityImpl', () {
    test('snapshot returns Right payload', () async {
      final FakeServiceConnectivity svc = FakeServiceConnectivity(
        initial: const ConnectivityModel(
          connectionType: ConnectionTypeEnum.wifi,
          internetSpeed: 40,
        ),
      );
      final GatewayConnectivityImpl gw =
          GatewayConnectivityImpl(svc, DefaultErrorMapper());
      final Either<ErrorItem, Map<String, dynamic>> res = await gw.snapshot();
      expect(res.isRight, isTrue);
      final Map<String, dynamic> map =
          (res as Right<ErrorItem, Map<String, dynamic>>).value;
      expect(map['connectionType'], 'wifi');
      expect(map['internetSpeed'], 40.0);
      svc.dispose();
    });

    test('checkType / checkSpeed return partial payloads', () async {
      final FakeServiceConnectivity svc = FakeServiceConnectivity();
      final GatewayConnectivityImpl gw =
          GatewayConnectivityImpl(svc, DefaultErrorMapper());

      svc.simulateConnection(ConnectionTypeEnum.mobile);
      final Either<ErrorItem, Map<String, dynamic>> t = await gw.checkType();
      expect(t.isRight, isTrue);
      expect(
        (t as Right<ErrorItem, Map<String, dynamic>>).value['connectionType'],
        'mobile',
      );

      svc.simulateSpeed(55.0);
      final Either<ErrorItem, Map<String, dynamic>> s = await gw.checkSpeed();
      expect(s.isRight, isTrue);
      expect(
        (s as Right<ErrorItem, Map<String, dynamic>>).value['internetSpeed'],
        55.0,
      );
      svc.dispose();
    });

    test('watch emits Right and yields Left on stream error', () async {
      final FakeServiceConnectivity svc = FakeServiceConnectivity();
      final GatewayConnectivityImpl gw =
          GatewayConnectivityImpl(svc, DefaultErrorMapper());
      final List<Either<ErrorItem, Map<String, dynamic>>> items =
          <Either<ErrorItem, Map<String, dynamic>>>[];
      final StreamSubscription<Either<ErrorItem, Map<String, dynamic>>> sub =
          gw.watch().listen(items.add);

      svc.simulateSpeed(10);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(items.isNotEmpty && items.last.isRight, isTrue);

      svc.simulateStreamErrorOnce();
      svc.simulateSpeed(11); // trigger error path
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(
        items.any((Either<ErrorItem, Map<String, dynamic>> e) => e.isLeft),
        isTrue,
      );

      await sub.cancel();
      svc.dispose();
    });

    test('snapshot maps thrown errors to Left', () async {
      final FakeServiceConnectivity svc = FakeServiceConnectivity();
      final GatewayConnectivityImpl gw =
          GatewayConnectivityImpl(svc, DefaultErrorMapper());
      svc.simulateErrorOnCheckConnectivityOnce();
      final Either<ErrorItem, Map<String, dynamic>> res = await gw.snapshot();
      expect(res.isLeft, isTrue);
      svc.dispose();
    });
  });
}
