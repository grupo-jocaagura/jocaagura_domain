import 'dart:async';

import '../../jocaagura_domain.dart';

/// Fake in-memory [ServiceConnectivity] for development and tests.
///
/// Features:
/// - Manually simulate connection type and speed.
/// - Optional latency and error injection on checks.
/// - Continuous stream of [ConnectivityModel] via an internal [BlocGeneral].
/// - Optional speed jitter (periodic randomization) to test UI reactivity.
///
/// No external packages are used.
///
/// ### Example
/// ```dart
/// final FakeServiceConnectivity svc = FakeServiceConnectivity(
///   latencyConnectivity: const Duration(milliseconds: 120),
///   latencySpeed: const Duration(milliseconds: 220),
/// );
/// await svc.checkConnectivity(); // uses current simulated type
/// await svc.checkInternetSpeed();
/// svc.simulateConnection(ConnectionTypeEnum.wifi);
/// svc.simulateSpeed(85.3);
/// final StreamSubscription sub = svc.connectivityStream().listen((m) {
///   debugPrint('Connectivity => ${m.connectionType} @ ${m.internetSpeed} Mbps');
/// });
/// // ...
/// await sub.cancel();
/// svc.dispose();
/// ```
/// Fake in-memory [ServiceConnectivity] for development and tests.
///
/// Features:
/// - Manually simulate connection type and speed.
/// - Optional latency and error injection on checks.
/// - Continuous stream of [ConnectivityModel] via an internal [BlocGeneral].
/// - Optional speed jitter (periodic randomization) to test UI reactivity.
///
/// No external packages are used.
///
/// ### Example
/// ```dart
/// final FakeServiceConnectivity svc = FakeServiceConnectivity(
///   latencyConnectivity: const Duration(milliseconds: 120),
///   latencySpeed: const Duration(milliseconds: 220),
/// );
/// await svc.checkConnectivity(); // uses current simulated type
/// await svc.checkInternetSpeed();
/// svc.simulateConnection(ConnectionTypeEnum.wifi);
/// svc.simulateSpeed(85.3);
/// final StreamSubscription sub = svc.connectivityStream().listen((m) {
///   debugPrint('Connectivity => ${m.connectionType} @ ${m.internetSpeed} Mbps');
/// });
/// // ...
/// await sub.cancel();
/// svc.dispose();
/// ```
class FakeServiceConnectivity implements ServiceConnectivity {
  FakeServiceConnectivity({
    this.latencyConnectivity = Duration.zero,
    this.latencySpeed = Duration.zero,
    this.throwOnCheckConnectivity = false,
    this.throwOnCheckSpeed = false,
    ConnectivityModel initial = defaultConnectivityModel,
  }) : _bloc = BlocGeneral<ConnectivityModel>(initial) {
    _snapshot = initial;
  }

  /// Artificial latency for [checkConnectivity].
  final Duration latencyConnectivity;

  /// Artificial latency for [checkInternetSpeed].
  final Duration latencySpeed;

  /// If `true`, [checkConnectivity] throws a [StateError].
  final bool throwOnCheckConnectivity;

  /// If `true`, [checkInternetSpeed] throws a [StateError].
  final bool throwOnCheckSpeed;

  final BlocGeneral<ConnectivityModel> _bloc;
  ConnectivityModel _snapshot = defaultConnectivityModel;
  bool _disposed = false;
  Timer? _jitterTimer;

  void _ensureAlive() {
    if (_disposed) {
      throw StateError('FakeServiceConnectivity has been disposed');
    }
  }

  @override
  ConnectivityModel get current => _snapshot;

  @override
  Stream<ConnectivityModel> connectivityStream() {
    _ensureAlive();
    return _bloc.stream;
  }

  @override
  Future<ConnectionTypeEnum> checkConnectivity() async {
    _ensureAlive();
    if (throwOnCheckConnectivity) {
      throw StateError('Simulated connectivity check failure');
    }
    await Future<void>.delayed(latencyConnectivity);
    return _snapshot.connectionType;
  }

  @override
  Future<double> checkInternetSpeed() async {
    _ensureAlive();
    if (throwOnCheckSpeed) {
      throw StateError('Simulated speed check failure');
    }
    await Future<void>.delayed(latencySpeed);
    return _snapshot.internetSpeed;
  }

  /// Simulates a new [ConnectionTypeEnum]. Emits a fresh [ConnectivityModel].
  void simulateConnection(ConnectionTypeEnum type) {
    _ensureAlive();
    _snapshot = _snapshot.copyWith(connectionType: type);
    _bloc.value = _snapshot;
  }

  /// Simulates a new speed (Mbps). Emits a fresh [ConnectivityModel].
  void simulateSpeed(double mbps) {
    _ensureAlive();
    final double v = mbps < 0 ? 0 : mbps;
    _snapshot = _snapshot.copyWith(internetSpeed: v);
    _bloc.value = _snapshot;
  }

  /// Convenience to set offline.
  void simulateOffline() => simulateConnection(ConnectionTypeEnum.none);

  /// Resets to [defaultConnectivityModel].
  void reset() {
    _ensureAlive();
    _snapshot = defaultConnectivityModel;
    _bloc.value = _snapshot;
  }

  /// Starts a periodic speed jitter to stress-test UI.
  ///
  /// [period] controls frequency. [minMbps]/[maxMbps] delimit the range.
  void startSpeedJitter({
    Duration period = const Duration(seconds: 2),
    double minMbps = 5,
    double maxMbps = 120,
  }) {
    _ensureAlive();
    _jitterTimer?.cancel();
    _jitterTimer = Timer.periodic(period, (_) {
      // Simple deterministic variation to avoid importing `dart:math`.
      final int t = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final double span = (maxMbps - minMbps).clamp(0, double.maxFinite);
      final double wave = (t % 10) / 10.0;
      simulateSpeed(minMbps + span * wave);
    });
  }

  /// Stops the speed jitter if running.
  void stopSpeedJitter() {
    _jitterTimer?.cancel();
    _jitterTimer = null;
  }

  @override
  void dispose() {
    _jitterTimer?.cancel();
    _jitterTimer = null;
    _disposed = true;
    _bloc.dispose();
  }
}
