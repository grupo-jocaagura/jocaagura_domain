part of '../../jocaagura_domain.dart';

/// Abstract service for local notifications.
///
/// - [requestPermission] pide permiso para mostrar notificaciones.
/// - [showNotification] crea una notificación inmediata.
/// - [cancelNotification] cancela una notificación por su [id].
/// - [cancelAllNotifications] cancela todas.
/// - [notificationsStream] emite la lista de notificaciones activas.
/// - [notificationTapStream] emite el payload de la notificación cuando el usuario la “toca”.
///
/// ⚠️ FOR DEVELOPMENT PURPOSES ONLY
abstract class ServiceNotifications {
  /// Solicita permiso para mostrar notificaciones.
  ///
  /// Retorna `true` si el permiso fue concedido.
  Future<bool> requestPermission();

  /// Muestra una notificación inmediata.
  ///
  /// - [id]: identificador único de la notificación.
  /// - [title]: título visible.
  /// - [body]: cuerpo del mensaje.
  /// - [payload]: datos arbitrarios que se emiten al tocarla.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  });

  /// Cancela la notificación con [id].
  Future<void> cancelNotification(int id);

  /// Cancela todas las notificaciones activas.
  Future<void> cancelAllNotifications();

  /// Emite la lista actual de notificaciones
  /// como mapas con claves `id`, `title`, `body`, `payload`.
  Stream<List<Map<String, dynamic>>> notificationsStream();

  /// Emite el `payload` cuando el usuario toca una notificación.
  Stream<Map<String, dynamic>> notificationTapStream();

  /// Libera recursos internos.
  void dispose();
}
