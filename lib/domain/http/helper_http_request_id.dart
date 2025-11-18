part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Utility helper to generate deterministic HTTP request identifiers.
///
/// The generated [requestId] is:
/// - Stable for the same `(method, uri, metadata)` tuple.
/// - Optionally suffixed with a `retry` index to distinguish retries.
///
/// Typical usages:
/// ```dart
/// final String id1 = HelperHttpRequestId.build(
///   method: HttpMethodEnum.get,
///   uri: Uri.parse('https://api.example.com/v1/users'),
///   metadata: <String, Object?>{'feature': 'userList'},
/// );
///
/// final String idRetry = HelperHttpRequestId.buildFromConfig(
///   config,
///   retryIndex: 1,
/// );
/// ```
class HelperHttpRequestId {
  const HelperHttpRequestId._();

  /// Builds a deterministic request id from core HTTP parameters.
  ///
  /// - [method]: HTTP method (GET, POST, ...).
  /// - [uri]: Target URI.
  /// - [metadata]: Extra key/value pairs that influence the identity of the
  ///   request (e.g. `feature`, `operation`, tenant).
  /// - [retryIndex]: Optional retry index; when non-null, a `#retry=N` suffix
  ///   is appended.
  ///
  /// The returned id is stable as long as the inputs are stable.
  static String build({
    required HttpMethodEnum method,
    required Uri uri,
    Map<String, Object?> metadata = const <String, Object?>{},
    int? retryIndex,
  }) {
    final String base =
        _buildBaseId(method: method, uri: uri, metadata: metadata);
    if (retryIndex == null) {
      return base;
    }
    return '$base#retry=$retryIndex';
  }

  /// Builds a deterministic request id from a [ModelConfigHttpRequest].
  ///
  /// This is useful when reusing a previously created configuration object,
  /// for example when implementing retries.
  static String buildFromConfig(
    ModelConfigHttpRequest config, {
    int? retryIndex,
  }) {
    final String base = _buildBaseId(
      method: config.method,
      uri: config.uri,
      metadata: config.metadata,
    );
    if (retryIndex == null) {
      return base;
    }
    return '$base#retry=$retryIndex';
  }

  static String _buildBaseId({
    required HttpMethodEnum method,
    required Uri uri,
    required Map<String, Object?> metadata,
  }) {
    final String normalizedMethod = method.name.toUpperCase();
    final String normalizedUri = uri.toString();

    // Use a deep hash for metadata so that small changes in keys/values
    // produce a different id. The hash is encoded in hex to keep it compact.
    final int metaHash = Utils.deepHash(metadata);
    final String metaHex = metaHash.toRadixString(16);

    return '$normalizedMethod $normalizedUri @$metaHex';
  }
}
