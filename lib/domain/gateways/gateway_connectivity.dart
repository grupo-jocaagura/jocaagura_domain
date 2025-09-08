part of '../../../jocaagura_domain.dart';

/// Low-level connectivity gateway. It exposes **raw JSON-like payloads**
/// json and wraps failures as [ErrorItem].
///
/// Mapping to domain models is **NOT** this layer's responsibility.
abstract class GatewayConnectivity {
  /// Instant snapshot combining connection type and speed as raw payload.
  Future<Either<ErrorItem, Map<String, dynamic>>> snapshot();

  /// Emits connectivity updates as raw payloads.
  Stream<Either<ErrorItem, Map<String, dynamic>>> watch();

  /// Returns only the connection type as raw payload,
  /// e.g. {'connectionType': 'wifi'}
  Future<Either<ErrorItem, Map<String, dynamic>>> checkType();

  /// Returns only the internet speed as raw payload,
  /// e.g. {'internetSpeed': 42.0}
  Future<Either<ErrorItem, Map<String, dynamic>>> checkSpeed();

  /// Returns the last known snapshot as raw payload without I/O.
  Map<String, dynamic> current();
}
