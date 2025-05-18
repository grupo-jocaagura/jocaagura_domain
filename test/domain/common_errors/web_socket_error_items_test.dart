import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('WebSocketErrorItems', () {
    test('connectionFailed has expected properties', () {
      const ErrorItem error = WebSocketErrorItems.connectionFailed;
      expect(error.title, 'WebSocket Connection Failed');
      expect(error.code, 'WS_CONN_FAILED');
      expect(
        error.meta[WebSocketErrorItems.sourceKey],
        WebSocketErrorItems.sourceValue,
      );
      expect(error.errorLevel, ErrorLevelEnum.danger);
    });

    test('connectionClosedUnexpectedly has expected properties', () {
      const ErrorItem error = WebSocketErrorItems.connectionClosedUnexpectedly;
      expect(error.title, 'WebSocket Disconnected');
      expect(error.code, 'WS_CONN_LOST');
      expect(
        error.meta[WebSocketErrorItems.sourceKey],
        WebSocketErrorItems.sourceValue,
      );
      expect(error.errorLevel, ErrorLevelEnum.severe);
    });

    test('messageSendFailed has expected properties', () {
      const ErrorItem error = WebSocketErrorItems.messageSendFailed;
      expect(error.title, 'Message Send Failure');
      expect(error.code, 'WS_SEND_FAIL');
      expect(
        error.meta[WebSocketErrorItems.sourceKey],
        WebSocketErrorItems.sourceValue,
      );
      expect(error.errorLevel, ErrorLevelEnum.warning);
    });

    test('invalidResponse has expected properties', () {
      const ErrorItem error = WebSocketErrorItems.invalidResponse;
      expect(error.title, 'Invalid WebSocket Response');
      expect(error.code, 'WS_INVALID_RESPONSE');
      expect(
        error.meta[WebSocketErrorItems.sourceKey],
        WebSocketErrorItems.sourceValue,
      );
      expect(error.errorLevel, ErrorLevelEnum.severe);
    });

    test('messageTimeout has expected properties', () {
      const ErrorItem error = WebSocketErrorItems.messageTimeout;
      expect(error.title, 'WebSocket Timeout');
      expect(error.code, 'WS_TIMEOUT');
      expect(
        error.meta[WebSocketErrorItems.sourceKey],
        WebSocketErrorItems.sourceValue,
      );
      expect(error.errorLevel, ErrorLevelEnum.warning);
    });

    test('unknown returns systemInfo error with fallback message', () {
      final ErrorItem error = WebSocketErrorItems.unknown();
      expect(error.title, 'Unknown WebSocket Error');
      expect(error.code, 'WS_UNKNOWN');
      expect(error.description, 'An unknown WebSocket error has occurred.');
      expect(
        error.meta[WebSocketErrorItems.sourceKey],
        WebSocketErrorItems.sourceValue,
      );
      expect(error.errorLevel, ErrorLevelEnum.systemInfo);
    });

    test('unknown returns custom description if provided', () {
      final ErrorItem error =
          WebSocketErrorItems.unknown(reason: 'Timeout at handshake');
      expect(error.description, 'Timeout at handshake');
    });
  });
  group('WebSocketErrorItems.fromCode', () {
    test('returns connectionFailed', () {
      final ErrorItem error = WebSocketErrorItems.fromCode('WS_CONN_FAILED');
      expect(error, WebSocketErrorItems.connectionFailed);
    });

    test('returns connectionClosedUnexpectedly', () {
      final ErrorItem error = WebSocketErrorItems.fromCode('WS_CONN_LOST');
      expect(error, WebSocketErrorItems.connectionClosedUnexpectedly);
    });

    test('returns messageSendFailed', () {
      final ErrorItem error = WebSocketErrorItems.fromCode('WS_SEND_FAIL');
      expect(error, WebSocketErrorItems.messageSendFailed);
    });

    test('returns invalidResponse', () {
      final ErrorItem error =
          WebSocketErrorItems.fromCode('WS_INVALID_RESPONSE');
      expect(error, WebSocketErrorItems.invalidResponse);
    });

    test('returns messageTimeout', () {
      final ErrorItem error = WebSocketErrorItems.fromCode('WS_TIMEOUT');
      expect(error, WebSocketErrorItems.messageTimeout);
    });

    test('returns unknown for unrecognized code', () {
      final ErrorItem error = WebSocketErrorItems.fromCode('WS_CUSTOM_ERROR');
      expect(error.code, 'WS_UNKNOWN');
      expect(error.description, contains('WS_CUSTOM_ERROR'));
      expect(
        error.meta[WebSocketErrorItems.sourceKey],
        WebSocketErrorItems.sourceValue,
      );
    });
  });
}
