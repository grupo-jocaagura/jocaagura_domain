part of '../../jocaagura_domain.dart';

/// Abstract service for geolocation operations.
///
/// Provides methods to get the current position and listen to ongoing
/// location updates. Positions are represented as JSON maps with keys
/// 'latitude' and 'longitude'.
///
/// Example:
/// ```dart
/// final ServiceGeolocation geo = FakeServiceGeolocation();
/// final pos = await geo.getCurrentLocation();
/// print('Current: ${pos['latitude']}, ${pos['longitude']}');
/// geo.locationStream().listen((p) {
///   print('Updated: ${p['latitude']}, ${p['longitude']}');
/// });
/// ```
abstract class ServiceGeolocation {
  /// Returns the current location as JSON map:
  /// `{ 'latitude': double, 'longitude': double }`.
  Future<Map<String, double>> getCurrentLocation();

  /// Streams real-time location updates as JSON maps.
  Stream<Map<String, double>> locationStream();

  /// Disposes any internal resources.
  void dispose();
}
