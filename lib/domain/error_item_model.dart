part of '../jocaagura_domain.dart';

/// Classifies how an error should be handled across the application.
///
/// UI guidelines:
/// - `systemInfo`: only logged, no UI feedback.
/// - `warning`: non-blocking hint (e.g., toast/banner).
/// - `severe`: blocking but recoverable (e.g., modal).
/// - `danger`: critical, requires a recovery/full-screen error.
enum ErrorLevelEnum {
  /// Used for internal logs. No UI feedback.
  systemInfo,

  /// Minor issue, handled as non-blocking feedback (e.g., toast or banner).
  warning,

  /// Blocking but recoverable error (e.g., modal).
  severe,

  /// Blocking and critical. Requires full page or recovery screen.
  danger,
}

/// Default instance of [ErrorItem] representing a generic unknown error.
const ErrorItem defaultErrorItem = ErrorItem(
  title: 'Unknown Error',
  code: 'ERR_UNKNOWN',
  description: 'An unspecified error has occurred.',
  meta: <String, dynamic>{'severity': 'low'},
);

/// Enum keys used for [ErrorItem] JSON serialization.
enum ErrorItemEnum { title, code, description, meta, errorLevel }

/// Represents a structured domain error.
///
/// Holds a short `title`, a programmatic `code`, a human-readable `description`,
/// optional `meta` information and an `errorLevel` hint for UI handling.
///
/// Functional example:
/// ```dart
/// import 'dart:convert';
///
/// void main() {
///   // Create
///   final ErrorItem item = ErrorItem(
///     title: 'Network timeout',
///     code: 'NET_TIMEOUT',
///     description: 'The request took too long to complete.',
///     meta: <String, Object?>{'retryAfterMs': 1500},
///     errorLevel: ErrorLevelEnum.severe,
///   );
///
///   // Serialize
///   final Map<String, dynamic> jsonMap = item.toJson();
///   final String jsonStr = jsonEncode(jsonMap);
///   print(jsonStr);
///
///   // Deserialize (round-trip)
///   final ErrorItem same = ErrorItem.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
///   assert(same == item);
/// }
/// ```
///
/// Notes:
/// - Prefer stable `code` values for analytics/telemetry.
/// - `meta` is for context (e.g., ids, timestamps). Avoid storing large payloads.
/// - UI can inspect `errorLevel` to choose between banner, toast, modal or full page.
///
/// Throws: never.
class ErrorItem extends Model {
  /// Creates a new immutable [ErrorItem] instance.
  const ErrorItem({
    required this.title,
    required this.code,
    required this.description,
    this.meta = const <String, dynamic>{},
    this.errorLevel = ErrorLevelEnum.systemInfo,
  });

  /// Recreates an [ErrorItem] from a JSON map.
  ///
  /// Unknown values for `errorLevel` fallback to [ErrorLevelEnum.systemInfo].
  factory ErrorItem.fromJson(Map<String, dynamic> json) {
    return ErrorItem(
      title: Utils.getStringFromDynamic(json[ErrorItemEnum.title.name]),
      code: Utils.getStringFromDynamic(json[ErrorItemEnum.code.name]),
      description:
          Utils.getStringFromDynamic(json[ErrorItemEnum.description.name]),
      meta: Utils.mapFromDynamic(
        json[ErrorItemEnum.meta.name] ?? <String, dynamic>{},
      ),
      errorLevel: getErrorLevelFromString(
        Utils.getStringFromDynamic(json[ErrorItemEnum.errorLevel.name]),
      ),
    );
  }

  /// Short title describing the error type.
  final String title;

  /// Stable programmatic error code.
  final String code;

  /// Human-readable description for logs and support.
  final String description;

  /// Additional context for diagnostics (ids, flags, metrics).
  final Map<String, dynamic> meta;

  /// Enum representing the severity and handling level of an error.
  ///
  /// This is useful for the UI to determine how to render the error:
  /// - [systemInfo]: Logged internally but not shown to the user.
  /// - [warning]: Minor issue, shows a toast.
  /// - [severe]: Needs attention, shows modal or overlay.
  /// - [danger]: Critical issue, replaces the screen (e.g. full error page).
  final ErrorLevelEnum errorLevel;

  /// Serializes this error to JSON.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ErrorItemEnum.title.name: title,
        ErrorItemEnum.code.name: code,
        ErrorItemEnum.description.name: description,
        ErrorItemEnum.meta.name: meta,
        ErrorItemEnum.errorLevel.name: errorLevel.name,
      };

  /// Returns a copy with selected fields replaced.
  @override
  ErrorItem copyWith({
    String? title,
    String? code,
    String? description,
    Map<String, dynamic>? meta,
    ErrorLevelEnum? errorLevel,
  }) {
    return ErrorItem(
      title: title ?? this.title,
      code: code ?? this.code,
      description: description ?? this.description,
      meta: Map<String, dynamic>.unmodifiable(meta ?? this.meta),
      errorLevel: errorLevel ?? this.errorLevel,
    );
  }

  /// Human-friendly string for debugging.
  @override
  String toString() {
    final String metaString = meta.isNotEmpty ? ' | Meta: $meta' : '';
    return '$title ($code): $description$metaString | Level: ${errorLevel.name}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorItem &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          code == other.code &&
          description == other.description &&
          mapEquals(meta, other.meta) &&
          errorLevel == other.errorLevel;

  @override
  int get hashCode {
    final Iterable<int> metaEntryHashes = meta.entries.map(
      (MapEntry<String, dynamic> e) => Object.hash(e.key, e.value),
    );
    return Object.hash(
      title,
      code,
      description,
      Object.hashAllUnordered(metaEntryHashes),
      errorLevel,
    );
  }

  /// Parses [ErrorLevelEnum] from its string `name`.
  ///
  /// Unknown or `null` values return [ErrorLevelEnum.systemInfo].
  static ErrorLevelEnum getErrorLevelFromString(String? level) {
    return ErrorLevelEnum.values.firstWhere(
      (ErrorLevelEnum e) => e.name == level,
      orElse: () => ErrorLevelEnum.systemInfo,
    );
  }
}
