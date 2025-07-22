import 'dart:async';

import '../../jocaagura_domain.dart';

/// Fake in-memory implementation of [ServiceNotifications] for dev/testing.
///
/// - Simula permiso, creación, cancelación y taps de notificaciones.
/// - Emite estados via [BlocGeneral].
class FakeServiceNotifications implements ServiceNotifications {
  /// Crea el fake.
  ///
  /// [latency]: retardo opcional.
  /// [throwOnPermission]: simula fallo en permiso.
  /// [throwOnNotification]: simula fallo en show/cancel.
  FakeServiceNotifications({
    this.latency = Duration.zero,
    this.throwOnPermission = false,
    this.throwOnNotification = false,
  })  : _notificationsBloc =
            BlocGeneral<List<Map<String, dynamic>>>(<Map<String, dynamic>>[]),
        _tapBloc = BlocGeneral<Map<String, dynamic>>(<String, dynamic>{});

  /// Simulated latency para todas las operaciones.
  final Duration latency;

  /// Cuando es `true`, `requestPermission()` arroja [StateError].
  final bool throwOnPermission;

  /// Cuando es `true`, `showNotification` / `cancelNotification` arrojan [StateError].
  final bool throwOnNotification;

  final BlocGeneral<List<Map<String, dynamic>>> _notificationsBloc;
  final BlocGeneral<Map<String, dynamic>> _tapBloc;
  bool _disposed = false;

  void _checkDisposed() {
    if (_disposed) {
      throw StateError('FakeServiceNotifications has been disposed');
    }
  }

  @override
  Future<bool> requestPermission() async {
    _checkDisposed();
    if (throwOnPermission) {
      throw StateError('Simulated permission error');
    }
    await Future<void>.delayed(latency);
    return true;
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    _checkDisposed();
    if (throwOnNotification) {
      throw StateError('Simulated show error');
    }
    await Future<void>.delayed(latency);
    final List<Map<String, dynamic>> current = _notificationsBloc.value;
    final Map<String, Object> notif = <String, Object>{
      'id': id,
      'title': title,
      'body': body,
      'payload': payload ?? <String, dynamic>{},
    };
    _notificationsBloc.value = <Map<String, dynamic>>[...current, notif];
  }

  @override
  Future<void> cancelNotification(int id) async {
    _checkDisposed();
    if (throwOnNotification) {
      throw StateError('Simulated cancel error');
    }
    await Future<void>.delayed(latency);
    final List<Map<String, dynamic>> updated = _notificationsBloc.value
        .where((Map<String, dynamic> n) => n['id'] != id)
        .toList();
    _notificationsBloc.value = updated;
  }

  @override
  Future<void> cancelAllNotifications() async {
    if (throwOnNotification) {
      throw StateError('Simulated cancel all error');
    }
    _checkDisposed();
    await Future<void>.delayed(latency);
    _notificationsBloc.value = <Map<String, dynamic>>[];
  }

  @override
  Stream<List<Map<String, dynamic>>> notificationsStream() {
    _checkDisposed();
    return _notificationsBloc.stream;
  }

  @override
  Stream<Map<String, dynamic>> notificationTapStream() {
    _checkDisposed();
    return _tapBloc.stream;
  }

  /// Simula que el usuario toca una notificación,
  /// emitiendo su `payload`.
  void simulateTap(Map<String, dynamic> payload) {
    _checkDisposed();
    _tapBloc.value = payload;
  }

  /// Restablece el estado interno (vacía notificaciones y tap).
  void reset() {
    _checkDisposed();
    _notificationsBloc.value = <Map<String, dynamic>>[];
    _tapBloc.value = <String, dynamic>{};
  }

  @override
  void dispose() {
    _notificationsBloc.dispose();
    _tapBloc.dispose();
    _disposed = true;
  }
}
