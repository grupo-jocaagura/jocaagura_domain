import 'dart:async';

import '../../jocaagura_domain.dart';

/// Fake in-memory implementation of [ServiceGyroscope] for development/testing.
///
/// - Simulates rotation data using a [BlocGeneral].
/// - Supports optional artificial latency and error simulation.
/// - Use [simulateRotation] to push new fake rotation rates.
class FakeServiceGyroscope implements ServiceGyroscope {
  /// Creates the fake gyroscope service.
  ///
  /// [latency] simulates response delays.
  /// [throwOnGet] simulates failures on `getCurrentRotation()`.
  FakeServiceGyroscope({
    this.latency = Duration.zero,
    this.throwOnGet = false,
  });

  /// Default rotation when nothing has been simulated.
  static const Map<String, double> initialValue = <String, double>{
    'x': 0.0,
    'y': 0.0,
    'z': 0.0,
  };

  /// Artificial latency for `getCurrentRotation` (default: none).
  final Duration latency;

  /// When true, `getCurrentRotation` throws a [StateError].
  final bool throwOnGet;

  final BlocGeneral<Map<String, double>> _bloc =
      BlocGeneral<Map<String, double>>(initialValue);
  bool _disposed = false;

  void _checkDisposed() {
    if (_disposed) {
      throw StateError('FakeServiceGyroscope has been disposed');
    }
  }

  @override
  Future<Map<String, double>> getCurrentRotation() async {
    _checkDisposed();
    if (throwOnGet) {
      throw StateError('Simulated getCurrentRotation error');
    }
    await Future<void>.delayed(latency);
    return _bloc.value;
  }

  @override
  Stream<Map<String, double>> rotationStream() {
    _checkDisposed();
    return _bloc.stream;
  }

  /// Simulates a new rotation reading.
  void simulateRotation({
    required double x,
    required double y,
    required double z,
  }) {
    _checkDisposed();
    _bloc.value = <String, double>{
      'x': x,
      'y': y,
      'z': z,
    };
  }

  void reset() {
    _checkDisposed();
    _bloc.value = initialValue;
  }

  @override
  void dispose() {
    _bloc.dispose();
    _disposed = true;
  }
}
