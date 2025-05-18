part of '../../jocaagura_domain.dart';

/// Common WebSocket-related error definitions used across the domain layer.
///
/// Reference: https://developer.mozilla.org/en-US/docs/Web/API/WebSocket .
/// These errors are mapped using [ErrorItem] and represent connection,
/// transmission, and protocol issues typically found in WebSocket communication.
abstract class WebSocketErrorItems {
  /// Key used in the meta field to indicate the error source.
  static const String sourceKey = 'source';

  /// Value representing WebSocket as the error source.
  static const String sourceValue = 'WebSocket';

  /// Error when the WebSocket cannot connect to the server.
  static const ErrorItem connectionFailed = ErrorItem(
    title: 'WebSocket Connection Failed',
    code: 'WS_CONN_FAILED',
    description: 'Unable to establish a connection with the WebSocket server.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.danger,
  );

  /// Error when the WebSocket connection closes unexpectedly.
  static const ErrorItem connectionClosedUnexpectedly = ErrorItem(
    title: 'WebSocket Disconnected',
    code: 'WS_CONN_LOST',
    description: 'The WebSocket connection was closed unexpectedly.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.severe,
  );

  /// Error when a message could not be sent over WebSocket.
  static const ErrorItem messageSendFailed = ErrorItem(
    title: 'Message Send Failure',
    code: 'WS_SEND_FAIL',
    description:
        'The message could not be sent through the WebSocket connection.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.warning,
  );

  /// Error when the server sends an invalid or unexpected response.
  static const ErrorItem invalidResponse = ErrorItem(
    title: 'Invalid WebSocket Response',
    code: 'WS_INVALID_RESPONSE',
    description: 'The server sent an unexpected or malformed message.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.severe,
  );

  /// Error when a timeout occurs while waiting for a WebSocket message.
  static const ErrorItem messageTimeout = ErrorItem(
    title: 'WebSocket Timeout',
    code: 'WS_TIMEOUT',
    description: 'Timeout while waiting for a WebSocket response.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.warning,
  );

  /// Generic fallback error for unrecognized WebSocket issues.
  static ErrorItem unknown({String? reason}) => ErrorItem(
        title: 'Unknown WebSocket Error',
        code: 'WS_UNKNOWN',
        description: reason ?? 'An unknown WebSocket error has occurred.',
        meta: const <String, dynamic>{sourceKey: sourceValue},
      );

  /// Returns a predefined [ErrorItem] based on the WebSocket error code.
  /// If the code is not recognized, returns [unknown].
  static ErrorItem fromCode(String code) {
    switch (code) {
      case 'WS_CONN_FAILED':
        return connectionFailed;
      case 'WS_CONN_LOST':
        return connectionClosedUnexpectedly;
      case 'WS_SEND_FAIL':
        return messageSendFailed;
      case 'WS_INVALID_RESPONSE':
        return invalidResponse;
      case 'WS_TIMEOUT':
        return messageTimeout;
      default:
        return unknown(reason: 'Unrecognized WebSocket code: $code');
    }
  }
}
