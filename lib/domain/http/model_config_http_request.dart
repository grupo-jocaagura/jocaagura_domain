part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enum keys used for [ModelConfigHttpRequest] JSON serialization.
///
/// Keys:
/// - [method]: HTTP verb, stored as [HttpMethodEnum.name].
/// - [uri]: Request URI as string.
/// - [headers]: Map of header names to values.
/// - [body]: JSON object payload (`Map<String, dynamic>`).
/// - [timeout]: Per-request timeout in **milliseconds**.
/// - [metadata]: Free-form key/value metadata for logging/telemetry.
enum ModelConfigHttpRequestEnum {
  method,
  uri,
  headers,
  body,
  timeout,
  metadata,
}

/// Immutable HTTP request configuration used across the domain HTTP layer.
///
/// Guarantees:
/// - All fields are `final`.
/// - JSON round-trip safety:
///   - `method` is serialized using [HttpMethodEnum.name] and restored via
///     a best-effort lookup; unknown values fall back to `HttpMethodEnum.values.first`.
///   - `uri` is stored as a string and parsed back with [Uri.parse].
///   - `timeout` is stored as **milliseconds** via [Utils.durationToJson] and
///     parsed with [Utils.durationFromJson].
///   - `headers`, `body` and `metadata` are preserved as JSON-like structures.
/// - Deep equality for `headers`, `body` and `metadata` via [Utils.deepEqualsDynamic].
///
/// Body contract:
/// - `body` is explicitly a `Map<String, dynamic>?` to represent a JSON object.
/// - For APIs that expect arrays or primitives, the adapter/gateway should wrap
///   them in an envelope or use a different model.
///
/// Typical usage:
/// ```dart
/// import 'dart:convert';
///
/// void main() {
///   // 1) Build an in-memory request configuration
///   final ModelConfigHttpRequest request = ModelConfigHttpRequest(
///     method: HttpMethodEnum.post,
///     uri: Uri.parse('https://api.example.com/users'),
///     headers: <String, String>{
///       'Authorization': 'Bearer token',
///       'Content-Type': 'application/json',
///     },
///     body: <String, dynamic>{
///       'name': 'John',
///       'active': true,
///     },
///     timeout: const Duration(seconds: 5),
///     metadata: <String, dynamic>{
///       'feature': 'createUser',
///       'retryPolicy': 'default',
///     },
///   );
///
///   // 2) Serialize to JSON
///   final Map<String, dynamic> jsonMap = request.toJson();
///   final String jsonStr = jsonEncode(jsonMap);
///
///   // 3) Deserialize (round-trip)
///   final ModelConfigHttpRequest same = ModelConfigHttpRequest.fromJson(
///     jsonDecode(jsonStr) as Map<String, dynamic>,
///   );
///
///   assert(same == request);
/// }
/// ```
///
/// Notes:
/// - `headers == null` can be interpreted by adapters as "use defaults",
///   while an empty map `<String, String>{}` means "explicitly no headers".
/// - `metadata` is for diagnostics/telemetry (tags, feature names, ids).
class ModelConfigHttpRequest extends Model {
  /// Creates a new immutable [ModelConfigHttpRequest] instance.
  const ModelConfigHttpRequest({
    required this.method,
    required this.uri,
    this.headers = const <String, String>{},
    this.body = const <String, dynamic>{},
    this.timeout,
    this.metadata = const <String, dynamic>{},
  });

  /// Recreates a [ModelConfigHttpRequest] from a JSON map.
  ///
  /// - `method` is read from [ModelConfigHttpRequestEnum.method] as a string
  ///   and converted using [_methodFromString].
  /// - `uri` is parsed from [ModelConfigHttpRequestEnum.uri] using [Uri.parse].
  /// - `headers` is normalized to `Map<String, String>` when present.
  /// - `body` is normalized to `Map<String, dynamic>` when present.
  /// - `timeout` is parsed with [Utils.durationFromJson] when present.
  /// - `metadata` is normalized via [Utils.mapFromDynamic]; invalid inputs
  ///   fall back to `{}`.
  factory ModelConfigHttpRequest.fromJson(Map<String, dynamic> json) {
    final String rawMethod = Utils.getStringFromDynamic(
      json[ModelConfigHttpRequestEnum.method.name],
    );
    final String rawUri = Utils.getStringFromDynamic(
      json[ModelConfigHttpRequestEnum.uri.name],
    );

    // headers (optional)
    Map<String, String>? headers;
    if (json.containsKey(ModelConfigHttpRequestEnum.headers.name) &&
        json[ModelConfigHttpRequestEnum.headers.name] != null) {
      final Map<String, dynamic> rawHeaders = Utils.mapFromDynamic(
        json[ModelConfigHttpRequestEnum.headers.name],
      );
      final Map<String, String> normalized = <String, String>{};
      rawHeaders.forEach((String key, dynamic value) {
        normalized[key] = Utils.getStringFromDynamic(value);
      });
      headers = normalized;
    }

    Map<String, dynamic>? body;
    if (json.containsKey(ModelConfigHttpRequestEnum.body.name) &&
        json[ModelConfigHttpRequestEnum.body.name] != null) {
      body = Utils.mapFromDynamic(
        json[ModelConfigHttpRequestEnum.body.name],
      );
    }

    // metadata (always normalized, never null)
    final Map<String, dynamic> rawMetadata = Utils.mapFromDynamic(
      json[ModelConfigHttpRequestEnum.metadata.name] ?? <String, dynamic>{},
    );

    // timeout (optional)
    Duration? timeout;
    if (json.containsKey(ModelConfigHttpRequestEnum.timeout.name) &&
        json[ModelConfigHttpRequestEnum.timeout.name] != null) {
      timeout = Utils.durationFromJson(
        json[ModelConfigHttpRequestEnum.timeout.name],
      );
    }

    return ModelConfigHttpRequest(
      method: _methodFromString(rawMethod),
      uri: Uri.parse(rawUri),
      headers: headers ?? const <String, String>{},
      body: body ?? const <String, dynamic>{},
      timeout: timeout,
      metadata: rawMetadata,
    );
  }

  /// HTTP verb of the request (GET, POST, PUT, etc).
  final HttpMethodEnum method;

  /// Target URI of the request.
  ///
  /// This may be an absolute URL (`https://api.example.com/...`) or a relative
  /// path, depending on how the underlying adapter resolves it.
  final Uri uri;

  /// Optional HTTP headers for the request.
  ///
  /// Semantics:
  /// - At JSON level, the `headers` entry may be missing or `null`.
  /// - At model level, this field is never `null`; absence is represented
  ///   as an empty map.
  /// Adapters may interpret an empty map as "no extra headers".
  final Map<String, String> headers;

  /// Optional HTTP body as a JSON object.
  ///
  /// Semantics:
  /// - At JSON level, the `body` entry may be missing or `null`.
  /// - At model level, this field is never `null`; absence is represented
  ///   as an empty map.
  final Map<String, dynamic> body;

  /// Optional per-request timeout.
  ///
  /// When `null`, the adapter's default timeout applies. When present, it is
  /// serialized as **milliseconds** using [Utils.durationToJson].
  final Duration? timeout;

  /// Free-form metadata for logging, telemetry or feature flags.
  ///
  /// Examples:
  /// - `'feature': 'login'`
  /// - `'retryPolicy': 'idempotent'`
  /// - `'trackingId': 'abc-123'`
  final Map<String, dynamic> metadata;

  /// Serializes this configuration to JSON.
  ///
  /// Schema:
  /// ```json
  /// {
  ///   "method": "post",
  ///   "uri": "https://api.example.com/users",
  ///   "headers": { "Authorization": "Bearer token" },
  ///   "body": { "name": "John", "active": true },
  ///   "timeout": 5000,
  ///   "metadata": { "feature": "createUser" }
  /// }
  /// ```
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelConfigHttpRequestEnum.method.name: method.name,
        ModelConfigHttpRequestEnum.uri.name: uri.toString(),
        ModelConfigHttpRequestEnum.headers.name: headers,
        ModelConfigHttpRequestEnum.body.name: body,
        ModelConfigHttpRequestEnum.timeout.name:
            timeout != null ? Utils.durationToJson(timeout!) : null,
        ModelConfigHttpRequestEnum.metadata.name: metadata,
      };

  /// Returns a copy with selected fields replaced.
  ///
  /// Notes:
  /// - Passing `null` as a parameter means "keep current value"; to create
  ///   an instance with `body == null` or `timeout == null`, construct a new
  ///   [ModelConfigHttpRequest] directly.
  @override
  ModelConfigHttpRequest copyWith({
    HttpMethodEnum? method,
    Uri? uri,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Duration? timeout,
    Map<String, dynamic>? metadata,
  }) {
    return ModelConfigHttpRequest(
      method: method ?? this.method,
      uri: uri ?? this.uri,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      timeout: timeout ?? this.timeout,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Human-friendly string for debugging/logging.
  @override
  String toString() {
    return 'ModelConfigHttpRequest('
        'method: ${method.name}, '
        'uri: $uri, '
        'headers: $headers, '
        'body: $body, '
        'timeout: $timeout, '
        'metadata: $metadata'
        ')';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelConfigHttpRequest &&
          runtimeType == other.runtimeType &&
          method == other.method &&
          uri == other.uri &&
          Utils.deepEqualsDynamic(headers, other.headers) &&
          Utils.deepEqualsDynamic(body, other.body) &&
          timeout == other.timeout &&
          Utils.deepEqualsDynamic(metadata, other.metadata);

  @override
  int get hashCode => Object.hash(
        method,
        uri,
        Utils.deepHash(headers),
        Utils.deepHash(body),
        timeout,
        Utils.deepHash(metadata),
      );

  /// Parses [HttpMethodEnum] from its string `name`.
  ///
  /// Unknown or `null` values fall back to [HttpMethodEnum.values.first].
  static HttpMethodEnum _methodFromString(String? value) {
    return HttpMethodEnum.values.firstWhere(
      (HttpMethodEnum e) => e.name == value,
      orElse: () => HttpMethodEnum.values.first,
    );
  }
}
