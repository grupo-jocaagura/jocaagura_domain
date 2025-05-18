part of '../../jocaagura_domain.dart';

/// Common Network-related error definitions used across the domain layer.
///
/// These errors represent connectivity issues typically encountered when
/// performing network operations such as REST or socket calls.
///
/// Based on: https://api.flutter.dev/flutter/dart-io/SocketException-class.html
abstract class NetworkErrorItems {
  /// Key used in the meta field to indicate the error source.
  static const String sourceKey = 'source';

  /// Value representing network errors as the source.
  static const String sourceValue = 'Network';

  /// Error when no internet connection is detected.
  static const ErrorItem noInternet = ErrorItem(
    title: 'No Internet Connection',
    code: 'NET_NO_INTERNET',
    description: 'You are currently offline.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.danger,
  );

  /// Error when a network timeout occurs.
  static const ErrorItem timeout = ErrorItem(
    title: 'Network Timeout',
    code: 'NET_TIMEOUT',
    description: 'The request took too long to complete.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.warning,
  );

  /// Error when the target server is unreachable.
  static const ErrorItem unreachable = ErrorItem(
    title: 'Server Unreachable',
    code: 'NET_UNREACHABLE',
    description: 'Unable to reach the server.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.severe,
  );

  /// Returns a predefined [ErrorItem] based on the network error code.
  /// If the code is not recognized, returns [unknown].
  static ErrorItem fromCode(String code) {
    switch (code) {
      case 'NET_NO_INTERNET':
        return noInternet;
      case 'NET_TIMEOUT':
        return timeout;
      case 'NET_UNREACHABLE':
        return unreachable;
      default:
        return unknown('Unrecognized network error code: $code');
    }
  }

  /// Fallback for undefined network error cases.
  static ErrorItem unknown([String? reason]) => ErrorItem(
        title: 'Unknown Network Error',
        code: 'NET_UNKNOWN',
        description: reason ?? 'An unknown network error has occurred.',
        meta: const <String, dynamic>{sourceKey: sourceValue},
      );
}
