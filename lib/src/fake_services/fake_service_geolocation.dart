import 'dart:async';

import '../../jocaagura_domain.dart';

/// Fake in-memory implementation of [ServiceGeolocation] for development/testing.
///
/// - Simulates current location and real-time updates using a [BlocGeneral].
/// - Supports optional latency and error simulation.
/// - Provides `simulateLocation` to push new fake positions.
class FakeServiceGeolocation implements ServiceGeolocation {
  /// Creates the fake geolocation service.
  ///
  /// [latency] simulates response delays.
  /// [throwOnGet] simulates failures on `getCurrentLocation()`.
  FakeServiceGeolocation({
    this.latency = Duration.zero,
    this.throwOnGet = false,
  });
  static const Map<String, double> initialValue = <String, double>{
    'latitude': 0.0,
    'longitude': 0.0,
  };
  final BlocGeneral<Map<String, double>> _blocGeolocation =
      BlocGeneral<Map<String, double>>(initialValue);

  /// Artificial latency for operations (default: none).
  final Duration latency;

  /// When true, `getCurrentLocation` will throw a [StateError].
  final bool throwOnGet;

  bool _disposed = false;

  void _checkDisposed() {
    if (_disposed) {
      throw StateError('FakeServiceGeolocation has been disposed');
    }
  }

  @override
  Future<Map<String, double>> getCurrentLocation() async {
    _checkDisposed();
    if (throwOnGet) {
      throw StateError('Simulated getCurrentLocation error');
    }
    await Future<void>.delayed(latency);
    return _blocGeolocation.value;
  }

  @override
  Stream<Map<String, double>> locationStream() {
    _checkDisposed();
    return _blocGeolocation.stream;
  }

  /// Simulates a new location update.
  void simulateLocation({
    required double latitude,
    required double longitude,
  }) {
    _checkDisposed();
    _blocGeolocation.value = <String, double>{
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  void dispose() {
    _blocGeolocation.dispose();
    _disposed = true;
  }
}
