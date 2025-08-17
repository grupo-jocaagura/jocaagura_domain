import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('FakeServiceConnectivity', () {
    test('initial snapshot', () {
      final FakeServiceConnectivity svc = FakeServiceConnectivity(
        initial: const ConnectivityModel(
          connectionType: ConnectionTypeEnum.wifi,
          internetSpeed: 40,
        ),
      );
      expect(svc.current.connectionType, ConnectionTypeEnum.wifi);
      expect(svc.current.internetSpeed, 40.0);
      svc.dispose();
    });

    test('simulateConnection / simulateSpeed emits', () async {
      final FakeServiceConnectivity svc = FakeServiceConnectivity();
      final List<ConnectivityModel> events = <ConnectivityModel>[];
      final StreamSubscription<ConnectivityModel> sub =
          svc.connectivityStream().listen(events.add);

      svc.simulateConnection(ConnectionTypeEnum.mobile);
      svc.simulateSpeed(12.5);
      await Future<void>.delayed(const Duration(milliseconds: 5));

      expect(events, isNotEmpty);
      expect(svc.current.connectionType, ConnectionTypeEnum.mobile);
      expect(svc.current.internetSpeed, 12.5);

      await sub.cancel();
      svc.dispose();
    });

    test('error once on checkConnectivity', () async {
      final FakeServiceConnectivity svc = FakeServiceConnectivity();
      svc.simulateErrorOnCheckConnectivityOnce();
      expectLater(svc.checkConnectivity(), throwsA(isA<StateError>()));
      // next call should not throw
      await Future<void>.delayed(const Duration(milliseconds: 1));
      await svc.checkConnectivity();
      svc.dispose();
    });

    test('stream error injection', () async {
      final FakeServiceConnectivity svc = FakeServiceConnectivity();
      Object? capturedError;
      final StreamSubscription<ConnectivityModel> sub =
          svc.connectivityStream().listen(
                (_) {},
                onError: (Object e, _) => capturedError = e,
              );
      svc.simulateStreamErrorOnce();
      svc.simulateSpeed(1); // trigger next event
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(capturedError, isNotNull);
      await sub.cancel();
      svc.dispose();
    });
  });
}
