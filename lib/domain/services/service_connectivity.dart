part of '../../jocaagura_domain.dart';

/// Abstract service for network connectivity status.
///
/// - [isConnected] devuelve el estado actual (online/offline).
/// - [connectivityStream] emite cambios de estado en tiempo real.
/// - [dispose] libera recursos internos.
abstract class ServiceConnectivity {
  /// Retorna `true` si hay conexión de red.
  Future<bool> isConnected();

  /// Stream que emite `true`/`false` al cambiar el estado de conexión.
  Stream<bool> connectivityStream();

  /// Libera recursos internos.
  void dispose();
}
