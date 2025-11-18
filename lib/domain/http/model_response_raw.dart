part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enum keys used for [ModelResponseHttpRaw] JSON serialization.
///
/// Keys:
/// - [statusCode]: Numeric HTTP status code.
/// - [headers]: Map of header names to values.
/// - [body]: Raw payload as string.
enum ModelResponseHttpRawEnum {
  statusCode,
  headers,
  body,
}

/// Minimal normalized HTTP response used across adapters.
///
/// This model represents the raw HTTP response returned by an underlying client,
/// after normalizing:
/// - `statusCode` as an `int`.
/// - `headers` as `Map<String, String>`.
/// - `body` as a raw `String` payload.
///
/// It is intended as a low-level building block that can be wrapped or mapped
/// into higher-level response models.
///
/// ### Functional example (JSON round-trip)
/// ```dart
/// import 'dart:convert';
///
/// void main() {
///   // 1) Build a raw HTTP response
///   final ModelResponseHttpRaw raw = ModelResponseHttpRaw(
///     statusCode: 200,
///     headers: <String, String>{'content-type': 'application/json'},
///     body: '{"id":1,"name":"Alice"}',
///   );
///
///   // 2) Serialize to JSON (e.g., for logging/telemetry)
///   final Map<String, dynamic> jsonMap = raw.toJson();
///   final String jsonStr = jsonEncode(jsonMap);
///
///   // 3) Deserialize (round-trip)
///   final ModelResponseHttpRaw same = ModelResponseHttpRaw.fromJson(
///     jsonDecode(jsonStr) as Map<String, dynamic>,
///   );
///
///   assert(same == raw);
/// }
/// ```
class ModelResponseHttpRaw extends Model {
  /// Creates a new immutable [ModelResponseHttpRaw] instance.
  const ModelResponseHttpRaw({
    required this.statusCode,
    required this.headers,
    required this.body,
  });

  /// Recreates a [ModelResponseHttpRaw] from a JSON map.
  ///
  /// Normalization rules:
  /// - `statusCode` is parsed with [Utils.getIntegerFromDynamic].
  /// - `headers` is normalized via [Utils.mapFromDynamic] and stringified values.
  /// - `body` is obtained via [Utils.getStringFromDynamic].
  factory ModelResponseHttpRaw.fromJson(Map<String, dynamic> json) {
    // statusCode
    final int statusCode = Utils.getIntegerFromDynamic(
      json[ModelResponseHttpRawEnum.statusCode.name],
    );

    // headers
    final Map<String, dynamic> rawHeaders = Utils.mapFromDynamic(
      json[ModelResponseHttpRawEnum.headers.name] ?? <String, dynamic>{},
    );
    final Map<String, String> headers = <String, String>{};
    rawHeaders.forEach((String key, dynamic value) {
      headers[key] = Utils.getStringFromDynamic(value);
    });

    // body
    final String body = Utils.getStringFromDynamic(
      json[ModelResponseHttpRawEnum.body.name],
    );

    return ModelResponseHttpRaw(
      statusCode: statusCode,
      headers: headers,
      body: body,
    );
  }

  /// Numeric HTTP status code (e.g., 200, 404, 500).
  final int statusCode;

  /// Normalized HTTP headers.
  ///
  /// Header names are preserved as provided by the underlying client, and values
  /// are stringified using [Utils.getStringFromDynamic].
  final Map<String, String> headers;

  /// Raw body as returned by the underlying client.
  ///
  /// Implementations may choose to always normalize to UTF-8 strings.
  /// Higher-level layers can parse this string as JSON, HTML, etc.
  final String body;

  /// Serializes this response to JSON.
  ///
  /// Example schema:
  /// ```json
  /// {
  ///   "statusCode": 200,
  ///   "headers": { "content-type": "application/json" },
  ///   "body": "{\"id\":1,\"name\":\"Alice\"}"
  /// }
  /// ```
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelResponseHttpRawEnum.statusCode.name: statusCode,
        ModelResponseHttpRawEnum.headers.name: headers,
        ModelResponseHttpRawEnum.body.name: body,
      };

  /// Returns a copy with selected fields replaced.
  @override
  ModelResponseHttpRaw copyWith({
    int? statusCode,
    Map<String, String>? headers,
    String? body,
  }) {
    return ModelResponseHttpRaw(
      statusCode: statusCode ?? this.statusCode,
      headers: headers ?? this.headers,
      body: body ?? this.body,
    );
  }

  /// Human-friendly string for debugging/logging.
  @override
  String toString() {
    return 'ModelResponseHttpRaw('
        'statusCode: $statusCode, '
        'headers: $headers, '
        'body: $body'
        ')';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelResponseHttpRaw &&
          runtimeType == other.runtimeType &&
          statusCode == other.statusCode &&
          Utils.deepEqualsDynamic(headers, other.headers) &&
          body == other.body;

  @override
  int get hashCode => Object.hash(
        statusCode,
        Utils.deepHash(headers),
        body,
      );
}
