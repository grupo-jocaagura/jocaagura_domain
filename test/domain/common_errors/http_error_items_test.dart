import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('HttpErrorItems.getHttpCode', () {
    test('returns correct int from meta', () {
      const ErrorItem error = ErrorItem(
        title: 'Test',
        code: 'HTTP_418',
        description: "I'm a teapot",
        meta: <String, dynamic>{HttpErrorItems.httpCode: 418},
      );
      expect(HttpErrorItems.getHttpCode(error), 418);
    });

    test('parses int from string in meta', () {
      const ErrorItem error = ErrorItem(
        title: 'Test',
        code: 'HTTP_STRING',
        description: 'Code as string',
        meta: <String, dynamic>{HttpErrorItems.httpCode: '404'},
      );
      expect(HttpErrorItems.getHttpCode(error), 404);
    });

    test('returns -1 when key is missing', () {
      const ErrorItem error = ErrorItem(
        title: 'Test',
        code: 'NO_META',
        description: 'No code key',
      );
      expect(HttpErrorItems.getHttpCode(error), -1);
    });

    test('returns -1 for invalid string', () {
      const ErrorItem error = ErrorItem(
        title: 'Test',
        code: 'INVALID_STRING',
        description: 'Not a number',
        meta: <String, dynamic>{HttpErrorItems.httpCode: 'NaN'},
      );
      expect(HttpErrorItems.getHttpCode(error), -1);
    });

    test('returns -1 for unexpected type', () {
      const ErrorItem error = ErrorItem(
        title: 'Test',
        code: 'INVALID_TYPE',
        description: 'Map instead of code',
        meta: <String, dynamic>{
          HttpErrorItems.httpCode: <String, bool>{'unexpected': true},
        },
      );
      expect(HttpErrorItems.getHttpCode(error), -1);
    });
  });
  group('HttpErrorItems.fromStatusCode', () {
    test('returns correct ErrorItem for HTTP 100', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(100);
      expect(error.title, 'Continue');
      expect(HttpErrorItems.getHttpCode(error), 100);
    });

    test('returns correct ErrorItem for HTTP 101', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(101);
      expect(error.title, 'Switching Protocols');
      expect(HttpErrorItems.getHttpCode(error), 101);
    });

    test('returns correct ErrorItem for HTTP 304', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(304);
      expect(error.title, 'Not Modified');
      expect(HttpErrorItems.getHttpCode(error), 304);
    });

    test('returns correct ErrorItem for HTTP 400', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(400);
      expect(error.title, 'Bad Request');
      expect(HttpErrorItems.getHttpCode(error), 400);
    });

    test('returns correct ErrorItem for HTTP 401', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(401);
      expect(error.title, 'Unauthorized');
      expect(HttpErrorItems.getHttpCode(error), 401);
    });

    test('returns correct ErrorItem for HTTP 402', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(402);
      expect(error.title, 'Payment Required');
      expect(HttpErrorItems.getHttpCode(error), 402);
    });

    test('returns correct ErrorItem for HTTP 403', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(403);
      expect(error.title, 'Forbidden');
      expect(HttpErrorItems.getHttpCode(error), 403);
    });

    test('returns correct ErrorItem for HTTP 404', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(404);
      expect(error.title, 'Not Found');
      expect(HttpErrorItems.getHttpCode(error), 404);
    });

    test('returns correct ErrorItem for HTTP 405', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(405);
      expect(error.title, 'Method Not Allowed');
      expect(HttpErrorItems.getHttpCode(error), 405);
    });

    test('returns correct ErrorItem for HTTP 406', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(406);
      expect(error.title, 'Not Acceptable');
      expect(HttpErrorItems.getHttpCode(error), 406);
    });

    test('returns correct ErrorItem for HTTP 409', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(409);
      expect(error.title, 'Conflict');
      expect(HttpErrorItems.getHttpCode(error), 409);
    });

    test('returns correct ErrorItem for HTTP 410', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(410);
      expect(error.title, 'Gone');
      expect(HttpErrorItems.getHttpCode(error), 410);
    });

    test('returns correct ErrorItem for HTTP 415', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(415);
      expect(error.title, 'Unsupported Media Type');
      expect(HttpErrorItems.getHttpCode(error), 415);
    });

    test('returns correct ErrorItem for HTTP 429', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(429);
      expect(error.title, 'Too Many Requests');
      expect(HttpErrorItems.getHttpCode(error), 429);
    });

    test('returns correct ErrorItem for HTTP 500', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(500);
      expect(error.title, 'Internal Server Error');
      expect(HttpErrorItems.getHttpCode(error), 500);
    });

    test('returns correct ErrorItem for HTTP 501', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(501);
      expect(error.title, 'Not Implemented');
      expect(HttpErrorItems.getHttpCode(error), 501);
    });

    test('returns correct ErrorItem for HTTP 502', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(502);
      expect(error.title, 'Bad Gateway');
      expect(HttpErrorItems.getHttpCode(error), 502);
    });

    test('returns correct ErrorItem for HTTP 503', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(503);
      expect(error.title, 'Service Unavailable');
      expect(HttpErrorItems.getHttpCode(error), 503);
    });

    test('returns correct ErrorItem for HTTP 504', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(504);
      expect(error.title, 'Gateway Timeout');
      expect(HttpErrorItems.getHttpCode(error), 504);
    });

    test('returns fallback ErrorItem for unknown HTTP status', () {
      final ErrorItem error = HttpErrorItems.fromStatusCode(999);
      expect(error.title, 'Unknown HTTP Error');
      expect(HttpErrorItems.getHttpCode(error), 999);
    });
  });
}
