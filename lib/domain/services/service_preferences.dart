part of '../../jocaagura_domain.dart';

/// Abstract service for simple key/value preferences storage.
///
/// Allows storing and retrieving arbitrary JSON‐serializable values.
/// All values are represented as `dynamic` but should be JSON types
/// (String, num, bool, List, Map).
///
/// Example:
/// ```dart
/// final ServicePreferences prefs = FakeServicePreferences();
/// await prefs.setValue(key: 'darkMode', value: true);
/// final bool enabled = await prefs.getValue(key: 'darkMode') as bool;
/// prefs.allStream().listen((map) => print('Prefs changed: $map'));
/// ```
abstract class ServicePreferences {
  /// Stores a [value] under the given [key].
  ///
  /// Throws [ArgumentError] if [key] is empty.
  Future<void> setValue({
    required String key,
    required dynamic value,
  });

  /// Retrieves the value for [key].
  ///
  /// Throws [ArgumentError] if [key] is empty.
  /// Throws [StateError] if no value is found.
  Future<dynamic> getValue({
    required String key,
  });

  /// Removes the entry for [key].
  ///
  /// Throws [ArgumentError] if [key] is empty.
  Future<void> remove({
    required String key,
  });

  /// Clears all preferences.
  Future<void> clear();

  /// Returns a snapshot of all stored key/value pairs.
  Future<Map<String, dynamic>> getAll();

  /// Streams the full map of preferences whenever it changes.
  Stream<Map<String, dynamic>> allStream();

  /// Disposes internal resources.
  void dispose();
}
