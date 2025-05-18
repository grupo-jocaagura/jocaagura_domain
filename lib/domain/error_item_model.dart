part of '../jocaagura_domain.dart';

/// Severity level of an error, determining how it should be handled in UI or logic.
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

/// Enum representing the fields of an [ErrorItem].
enum ErrorItemEnum { title, code, description, meta, errorLevel }

/// A model representing a structured error in the application domain.
///
/// Includes a title, a code, a human-readable description, and optional metadata.
@immutable
class ErrorItem implements Model {
  /// Creates a new immutable [ErrorItem] instance.
  const ErrorItem({
    required this.title,
    required this.code,
    required this.description,
    this.meta = const <String, dynamic>{},
    this.errorLevel = ErrorLevelEnum.systemInfo,
  });

  /// Factory constructor to create an [ErrorItem] from a JSON map.
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
        Utils.getStringFromDynamic(json['errorLevel']),
      ),
    );
  }

  /// Short title describing the type of error.
  final String title;

  /// Unique error code for programmatic identification.
  final String code;

  /// Detailed explanation of the error.
  final String description;

  /// Optional additional metadata related to the error context.
  final Map<String, dynamic> meta;

  /// Enum representing the severity and handling level of an error.
  ///
  /// This is useful for the UI to determine how to render the error:
  /// - [systemInfo]: Logged internally but not shown to the user.
  /// - [warning]: Minor issue, shows a toast.
  /// - [severe]: Needs attention, shows modal or overlay.
  /// - [danger]: Critical issue, replaces the screen (e.g. full error page).
  final ErrorLevelEnum errorLevel;

  /// Converts this [ErrorItem] instance into a JSON map.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ErrorItemEnum.title.name: title,
        ErrorItemEnum.code.name: code,
        ErrorItemEnum.description.name: description,
        ErrorItemEnum.meta.name: meta,
        ErrorItemEnum.errorLevel.name: errorLevel.name,
      };

  /// Returns a copy of this [ErrorItem] with updated fields.
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
      meta: meta ?? this.meta,
      errorLevel: errorLevel ?? this.errorLevel,
    );
  }

  /// Textual representation of the error for debugging purposes.
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
          errorLevel == other.errorLevel &&
          hashCode != other.hashCode;

  @override
  int get hashCode => Object.hash(
        title,
        code,
        description,
        Object.hashAll(meta.entries),
        errorLevel,
      );

  /// Returns the corresponding [ErrorLevelEnum] from a string.
  ///
  /// Defaults to [ErrorLevelEnum.systemInfo] if no match is found.
  static ErrorLevelEnum getErrorLevelFromString(String? level) {
    return ErrorLevelEnum.values.firstWhere(
      (ErrorLevelEnum e) => e.name == level,
      orElse: () => ErrorLevelEnum.systemInfo,
    );
  }
}
