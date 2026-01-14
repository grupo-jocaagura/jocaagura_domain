import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RequestContext', () {
    test(
        'Given required fields only When created Then optional fields are null and metadata is empty',
        () {
      // Arrange
      final Uri uri = Uri.parse('https://example.com');

      // Act
      final RequestContext ctx = RequestContext(method: 'GET', uri: uri);

      // Assert
      expect(ctx.method, 'GET');
      expect(ctx.uri, uri);
      expect(ctx.headers, isNull);
      expect(ctx.body, isNull);
      expect(ctx.timeout, isNull);
      expect(ctx.metadata, isA<Map<String, dynamic>>());
      expect(ctx.metadata, isEmpty);
    });

    test('Given all fields When created Then values are preserved by reference',
        () {
      // Arrange
      final Uri uri = Uri.parse('https://example.com/api');
      final Map<String, String> headers = <String, String>{'x-id': '123'};
      final Map<String, dynamic> body = <String, dynamic>{'name': 'Ada'};
      const Duration timeout = Duration(seconds: 2);
      final Map<String, dynamic> metadata = <String, dynamic>{
        'forceError': true,
      };

      // Act
      final RequestContext ctx = RequestContext(
        method: 'POST',
        uri: uri,
        headers: headers,
        body: body,
        timeout: timeout,
        metadata: metadata,
      );

      // Assert
      expect(ctx.method, 'POST');
      expect(ctx.uri, uri);
      expect(ctx.headers, same(headers));
      expect(ctx.body, same(body));
      expect(ctx.timeout, timeout);
      expect(ctx.metadata, same(metadata));
    });

    test(
        'Given default metadata When trying to mutate Then it throws UnsupportedError',
        () {
      // Arrange
      final RequestContext ctx = RequestContext(
        method: 'GET',
        uri: Uri.parse('https://example.com'),
      );

      // Act & Assert
      expect(() => ctx.metadata['a'] = 1, throwsA(isA<UnsupportedError>()));
    });

    test(
        'Given const constructor When instantiated as const Then instance is canonicalized',
        () {
      // Arrange & Act
      final RequestContext a = RequestContext(
        method: 'GET',
        uri: Uri.parse('https://example.com'),
      );
      final RequestContext b = RequestContext(
        method: 'GET',
        uri: Uri.parse('https://example.com'),
      );

      // Assert
      expect(identical(a.uri.toString(), b.uri.toString()), isTrue);
    });

    test(
        'Given mutable metadata When caller mutates map Then ctx observes the change (documented behavior)',
        () {
      // Arrange
      final Map<String, dynamic> metadata = <String, dynamic>{'flag': false};
      final RequestContext ctx = RequestContext(
        method: 'GET',
        uri: Uri.parse('https://example.com'),
        metadata: metadata,
      );

      // Act
      metadata['flag'] = true;

      // Assert
      expect(ctx.metadata['flag'], isTrue);
    });
  });
}

/// Class under test (normally imported from your library).
class RequestContext {
  const RequestContext({
    required this.method,
    required this.uri,
    this.headers,
    this.body,
    this.timeout,
    this.metadata = const <String, dynamic>{},
  });

  final String method;
  final Uri uri;
  final Map<String, String>? headers;
  final Map<String, dynamic>? body;
  final Duration? timeout;

  /// Arbitrary test-only flags (e.g. force malformed response).
  final Map<String, dynamic> metadata;
}
