import 'dart:async';

import '../../jocaagura_domain.dart';

/// Fake in-memory implementation of [ServicePreferences] for dev/testing.
///
/// - Stores values in a [BlocGeneral] as a Map<String,dynamic>.
/// - Supports optional latency and error simulation.
/// - Emits the full map on every change.
class FakeServicePreferences implements ServicePreferences {
  /// Creates the fake preferences service.
  ///
  /// [latency] simulates response delays.
  /// [throwOnGet] simulates failures on read.
  /// [throwOnSet] simulates failures on write/remove/clear.
  FakeServicePreferences({
    this.latency = Duration.zero,
    this.throwOnGet = false,
    this.throwOnSet = false,
  }) : _bloc = BlocGeneral<Map<String, dynamic>>(<String, dynamic>{});

  /// Artificial latency for all operations (default: none).
  final Duration latency;

  /// When true, `getValue` will throw a [StateError].
  final bool throwOnGet;

  /// When true, `setValue`/`remove`/`clear` will throw a [StateError].
  final bool throwOnSet;

  final BlocGeneral<Map<String, dynamic>> _bloc;
  bool _disposed = false;

  void _checkDisposed() {
    if (_disposed) {
      throw StateError('FakeServicePreferences has been disposed');
    }
  }

  void _validateKey(String key) {
    if (key.isEmpty) {
      throw ArgumentError('key must not be empty');
    }
  }

  @override
  Future<void> setValue({
    required String key,
    required dynamic value,
  }) async {
    _checkDisposed();
    _validateKey(key);
    if (throwOnSet) {
      throw StateError('Simulated setValue error');
    }
    await Future<void>.delayed(latency);
    final Map<String, dynamic> current = _bloc.value;
    _bloc.value = <String, dynamic>{...current, key: value};
  }

  @override
  Future<dynamic> getValue({
    required String key,
  }) async {
    _checkDisposed();
    _validateKey(key);
    if (throwOnGet) {
      throw StateError('Simulated getValue error');
    }
    await Future<void>.delayed(latency);
    final Map<String, dynamic> map = _bloc.value;
    if (!map.containsKey(key)) {
      throw StateError('Preference not found');
    }
    return map[key];
  }

  @override
  Future<void> remove({
    required String key,
  }) async {
    _checkDisposed();
    _validateKey(key);
    if (throwOnSet) {
      throw StateError('Simulated remove error');
    }
    await Future<void>.delayed(latency);
    final Map<String, dynamic> updated = Map<String, dynamic>.from(_bloc.value)
      ..remove(key);
    _bloc.value = updated;
  }

  @override
  Future<void> clear() async {
    _checkDisposed();
    if (throwOnSet) {
      throw StateError('Simulated clear error');
    }
    await Future<void>.delayed(latency);
    _bloc.value = <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> getAll() async {
    _checkDisposed();
    if (throwOnGet) {
      throw StateError('Simulated getAll error');
    }
    await Future<void>.delayed(latency);
    return _bloc.value;
  }

  @override
  Stream<Map<String, dynamic>> allStream() {
    _checkDisposed();
    return _bloc.stream;
  }

  /// Restablece el estado interno (preferencias vacías).
  void reset() {
    _checkDisposed();
    _bloc.value = <String, dynamic>{};
  }

  @override
  void dispose() {
    _bloc.dispose();
    _disposed = true;
  }
}
