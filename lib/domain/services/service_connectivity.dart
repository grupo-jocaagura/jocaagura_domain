part of '../../jocaagura_domain.dart';

/// Provides low-level access to connectivity information.
///
/// This service abstracts platform/network details and exposes:
/// - Current connection type
/// - Measured internet speed (Mbps)
/// - A stream of [ConnectivityModel] updates
///
/// It is intentionally **imperative** and low-level. Higher layers
/// (Gateway/Repository/UseCases) add mapping, error handling and
/// domain-friendly APIs.
///
/// ### Example
/// ```dart
/// final ServiceConnectivity service = FakeServiceConnectivity();
/// final ConnectionTypeEnum type = await service.checkConnectivity();
/// final double speed = await service.checkInternetSpeed();
/// final StreamSubscription sub = service.connectivityStream().listen(print);
/// // ... later
/// await sub.cancel();
/// service.dispose();
/// ```
abstract class ServiceConnectivity {
  /// Returns the current [ConnectionTypeEnum].
  Future<ConnectionTypeEnum> checkConnectivity();

  /// Measures current internet speed (in Mbps). Implementations may use
  /// heuristics, synthetic downloads or cached values.
  Future<double> checkInternetSpeed();

  /// Emits a fresh [ConnectivityModel] whenever type or speed meaningfully
  /// changes.
  Stream<ConnectivityModel> connectivityStream();

  /// Returns the most recent snapshot known by the service.
  ConnectivityModel get current;

  /// Frees internal resources.
  void dispose();
}
