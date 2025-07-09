part of '../../jocaagura_domain.dart';

/// Abstract service for gyroscope sensor readings.
///
/// Provides methods to get the current rotation rates and to listen to
/// continuous updates. Rotation values are JSON maps with keys
/// `x`, `y` and `z`, representing angular velocity in radians per second.
///
/// Example:
/// ```dart
/// final ServiceGyroscope gyro = FakeServiceGyroscope();
/// final rot = await gyro.getCurrentRotation();
/// print('Rotation X: ${rot['x']}, Y: ${rot['y']}, Z: ${rot['z']}');
/// gyro.rotationStream().listen((r) {
///   print('Updated → X: ${r['x']}, Y: ${r['y']}, Z: ${r['z']}');
/// });
/// ```
abstract class ServiceGyroscope {
  /// Returns the current rotation rates.
  Future<Map<String, double>> getCurrentRotation();

  /// Streams continuous rotation updates.
  Stream<Map<String, double>> rotationStream();

  /// Disposes any internal resources.
  void dispose();
}
