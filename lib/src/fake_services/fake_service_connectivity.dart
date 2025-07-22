import 'dart:async';

import '../../jocaagura_domain.dart';

/// Fake in-memory implementation of [ServiceConnectivity] para dev/testing.
///
/// - Simula estado de conexión usando un [BlocGeneral].
/// - Permite inyectar latencia y errores en `isConnected()`.
/// - Usa `simulateConnectivity` para cambiar el estado en caliente.
class FakeServiceConnectivity implements ServiceConnectivity {
  /// Crea el fake.
  ///
  /// [latency]: retardo opcional.
  /// [throwOnGet]: simula fallo en consulta de estado.
  FakeServiceConnectivity({
    this.latency = Duration.zero,
    this.throwOnGet = false,
  }) : _bloc = BlocGeneral<bool>(initialValue);

  /// Valor inicial de conectividad (default: true).
  static const bool initialValue = true;

  /// Latencia artificial en `isConnected()` (default: none).
  final Duration latency;

  /// Cuando es `true`, `isConnected()` arroja [StateError].
  final bool throwOnGet;

  final BlocGeneral<bool> _bloc;
  bool _disposed = false;

  void _checkDisposed() {
    if (_disposed) {
      throw StateError('FakeServiceConnectivity has been disposed');
    }
  }

  @override
  Future<bool> isConnected() async {
    _checkDisposed();
    if (throwOnGet) {
      throw StateError('Simulated connectivity error');
    }
    await Future<void>.delayed(latency);
    return _bloc.value;
  }

  @override
  Stream<bool> connectivityStream() {
    _checkDisposed();
    return _bloc.stream;
  }

  /// Simula cambio de estado de conectividad.
  void simulateConnectivity(bool status) {
    _checkDisposed();
    _bloc.value = status;
  }

  /// Restablece el estado a [initialValue].
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
