import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('FakeServiceNotifications', () {
    late FakeServiceNotifications svc;

    setUp(() {
      svc = FakeServiceNotifications();
    });
    tearDown(() {
      svc.dispose();
    });

    test('requestPermission retorna true por defecto', () async {
      final bool ok = await svc.requestPermission();
      expect(ok, isTrue);
    });

    test('permissionsStream inicial vacío y error simulado', () async {
      final FakeServiceNotifications svcErr =
          FakeServiceNotifications(throwOnPermission: true);
      expect(() => svcErr.requestPermission(), throwsA(isA<StateError>()));
      svcErr.dispose();
    });

    test('notificationsStream emite lista inicial vacía', () async {
      final List<List<Map<String, dynamic>>> events =
          <List<Map<String, dynamic>>>[];
      final StreamSubscription<List<Map<String, dynamic>>> sub =
          svc.notificationsStream().listen(events.add);
      await Future<void>.delayed(Duration.zero);
      expect(events.first, isEmpty);
      await sub.cancel();
    });

    test('showNotification agrega y emite notificación', () async {
      final List<List<Map<String, dynamic>>> events =
          <List<Map<String, dynamic>>>[];
      final StreamSubscription<List<Map<String, dynamic>>> sub =
          svc.notificationsStream().listen(events.add);
      await svc.showNotification(id: 1, title: 'T', body: 'B');
      await Future<void>.delayed(Duration.zero);
      expect(events.last.length, 1);
      final Map<String, dynamic> notif = events.last.first;
      expect(notif['id'], 1);
      expect(notif['title'], 'T');
      expect(notif['body'], 'B');
      expect(notif['payload'], isEmpty);
      await sub.cancel();
    });

    test('cancelNotification elimina correctamente', () async {
      await svc.showNotification(id: 2, title: 'x', body: 'y');
      final List<List<Map<String, dynamic>>> events =
          <List<Map<String, dynamic>>>[];
      final StreamSubscription<List<Map<String, dynamic>>> sub =
          svc.notificationsStream().listen(events.add);
      await svc.cancelNotification(2);
      await Future<void>.delayed(Duration.zero);
      expect(events.last, isEmpty);
      await sub.cancel();
    });

    test('cancelAllNotifications limpia todo', () async {
      await svc.showNotification(id: 3, title: 'a', body: 'b');
      final List<List<Map<String, dynamic>>> events =
          <List<Map<String, dynamic>>>[];
      final StreamSubscription<List<Map<String, dynamic>>> sub =
          svc.notificationsStream().listen(events.add);
      await svc.cancelAllNotifications();
      await Future<void>.delayed(Duration.zero);
      expect(events.last, isEmpty);
      await sub.cancel();
    });

    test('notificationTapStream emite payload simulado', () async {
      final List<Map<String, dynamic>> events = <Map<String, dynamic>>[];
      final StreamSubscription<Map<String, dynamic>> sub =
          svc.notificationTapStream().listen(events.add);
      svc.simulateTap(<String, dynamic>{'foo': 'bar'});
      await Future<void>.delayed(Duration.zero);
      expect(events.last, <String, String>{'foo': 'bar'});
      await sub.cancel();
    });

    test('multiple listeners reciben mismos eventos', () async {
      final List<List<Map<String, dynamic>>> e1 =
          <List<Map<String, dynamic>>>[];
      final List<List<Map<String, dynamic>>> e2 =
          <List<Map<String, dynamic>>>[];
      final StreamSubscription<List<Map<String, dynamic>>> s1 =
          svc.notificationsStream().listen(e1.add);
      final StreamSubscription<List<Map<String, dynamic>>> s2 =
          svc.notificationsStream().listen(e2.add);
      await svc.showNotification(id: 4, title: 'T4', body: 'B4');
      await Future<void>.delayed(Duration.zero);
      expect(e1, equals(e2));
      await s1.cancel();
      await s2.cancel();
    });

    test('métodos throw tras dispose', () {
      svc.dispose();
      expect(
        () => svc.showNotification(id: 1, title: '', body: ''),
        throwsA(isA<StateError>()),
      );
      expect(() => svc.cancelNotification(1), throwsA(isA<StateError>()));
      expect(() => svc.cancelAllNotifications(), throwsA(isA<StateError>()));
      expect(() => svc.notificationsStream(), throwsA(isA<StateError>()));
      expect(
        () => svc.simulateTap(<String, dynamic>{}),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('Continuous showNotification emissions', () {
    test('Multiples showNotification emiten en orden correcto', () async {
      final FakeServiceNotifications svc = FakeServiceNotifications();
      final List<List<Map<String, dynamic>>> events =
          <List<Map<String, dynamic>>>[];
      final StreamSubscription<List<Map<String, dynamic>>> sub =
          svc.notificationsStream().listen(events.add);
      final List<Map<String, Object>> entries = <Map<String, Object>>[
        <String, Object>{
          'id': 1,
          'title': 'A',
          'body': 'a',
        },
        <String, Object>{
          'id': 2,
          'title': 'B',
          'body': 'b',
        },
        <String, Object>{
          'id': 3,
          'title': 'C',
          'body': 'c',
        },
      ];
      for (final Map<String, Object> e in entries) {
        await svc.showNotification(
          id: Utils.getIntegerFromDynamic(e['id']),
          title: Utils.getStringFromDynamic(e['title']),
          body: Utils.getStringFromDynamic(e['body']),
        );
        await Future<void>.delayed(Duration.zero);
      }
      expect(events.first, isEmpty);
      // comparamos listas ignorando campo payload vacío
      final List<List<Map<String, dynamic>>> recs = events
          .sublist(1)
          .map(
            (List<Map<String, dynamic>> lst) => lst
                .map(
                  (Map<String, dynamic> n) => <String, dynamic>{
                    'id': n['id'],
                    'title': n['title'],
                    'body': n['body'],
                  },
                )
                .toList(),
          )
          .toList();
      expect(
        recs,
        equals(<List<Map<String, Object>>>[
          <Map<String, Object>>[entries[0]],
          <Map<String, Object>>[entries[0], entries[1]],
          <Map<String, Object>>[entries[0], entries[1], entries[2]],
        ]),
      );
      await sub.cancel();
    });
  });

  group('reset()', () {
    test('limpia lista de notificaciones y tap', () async {
      final FakeServiceNotifications svc = FakeServiceNotifications();
      final List<List<Map<String, dynamic>>> notifEvents =
          <List<Map<String, dynamic>>>[];
      final List<Map<String, dynamic>> tapEvents = <Map<String, dynamic>>[];

      final StreamSubscription<List<Map<String, dynamic>>> sub1 =
          svc.notificationsStream().listen(notifEvents.add);
      final StreamSubscription<Map<String, dynamic>> sub2 =
          svc.notificationTapStream().listen(tapEvents.add);

      await svc.showNotification(id: 1, title: 'A', body: 'B');
      svc.simulateTap(<String, dynamic>{'from': 'test'});
      await Future<void>.delayed(Duration.zero);

      svc.reset();
      await Future<void>.delayed(Duration.zero);

      expect(notifEvents.last, isEmpty);
      expect(tapEvents.last, isEmpty);

      await sub1.cancel();
      await sub2.cancel();
      svc.dispose();
    });

    test('reset lanza error si fue dispose', () {
      final FakeServiceNotifications svc = FakeServiceNotifications()
        ..dispose();
      expect(() => svc.reset(), throwsStateError);
    });
  });
  // Añade este grupo al final de fake_service_notifications_test.dart

  group('throwOnNotification error cases', () {
    test('showNotification lanza StateError cuando throwOnNotification es true',
        () async {
      final FakeServiceNotifications svc =
          FakeServiceNotifications(throwOnNotification: true);
      expect(
        () => svc.showNotification(id: 1, title: 'T', body: 'B'),
        throwsA(isA<StateError>()),
      );
      svc.dispose();
    });

    test(
        'cancelNotification lanza StateError cuando throwOnNotification es true',
        () async {
      final FakeServiceNotifications svc =
          FakeServiceNotifications(throwOnNotification: true);
      expect(
        () => svc.cancelNotification(1),
        throwsA(isA<StateError>()),
      );
      svc.dispose();
    });

    test(
        'cancelAllNotifications lanza StateError cuando throwOnNotification es true',
        () async {
      final FakeServiceNotifications svc =
          FakeServiceNotifications(throwOnNotification: true);
      expect(
        () => svc.cancelAllNotifications(),
        throwsA(isA<StateError>()),
      );
      svc.dispose();
    });
  });
}
