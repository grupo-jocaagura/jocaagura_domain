part of 'jocaagura_domain.dart';

/// Utility class for handling common date and time operations.
///
/// This class provides methods to safely parse, format, and manipulate date
/// and time values, ensuring compatibility with various input types.
class DateUtils {
  /// Converts a dynamic value into a [DateTime] instance.
  ///
  /// This method handles multiple input types, including:
  /// - [DateTime]: Returns the value directly.
  /// - [String]: Attempts to parse the string into a [DateTime] object.
  ///   If parsing fails, the current date and time are returned.
  /// - [int]: Treats the value as a timestamp in milliseconds since the epoch.
  /// - [Duration]: Adds the duration to the current date and time.
  ///
  /// If none of these conditions are met, the method returns the current
  /// date and time by default.
  ///
  /// Example:
  /// ```dart
  /// final DateTime fromString = DateUtils.dateTimeFromDynamic('2024-07-15T12:00:00Z');
  /// final DateTime fromTimestamp = DateUtils.dateTimeFromDynamic(1698765600000);
  /// final DateTime fromDuration = DateUtils.dateTimeFromDynamic(Duration(days: 1));
  /// final DateTime fallback = DateUtils.dateTimeFromDynamic(null);
  /// ```
  ///
  /// - [value]: The dynamic value to be converted into a [DateTime].
  /// - Returns: A [DateTime] instance.
  static DateTime dateTimeFromDynamic(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      // Attempt to parse the string as a date
      return DateTime.tryParse(value) ?? DateTime.now();
    } else if (value is int) {
      // Treat the value as a timestamp in milliseconds
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is Duration) {
      // Treat the value as a duration, adding it to the current date
      return DateTime.now().add(value);
    }
    // Default value: current date and time
    return DateTime.now();
  }

  /// Converts a [DateTime] object into a standardized string format.
  ///
  /// The format used is ISO 8601, which is compatible with most systems
  /// and provides a universally recognizable representation of date and time.
  ///
  /// Example:
  /// ```dart
  /// final String formatted = DateUtils.dateTimeToString(DateTime(2024, 07, 15));
  /// print(formatted); // Output: 2024-07-15T00:00:00.000
  /// ```
  ///
  /// - [dateTime]: The [DateTime] object to be formatted.
  /// - Returns: A [String] representing the formatted date and time.
  static String dateTimeToString(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
}
