import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VirtualCrudService contract (via FakeVirtualCrudService)', () {
    test('Given a matching context When canHandle is called Then returns true',
        () {
      // Arrange
      final VirtualCrudService service = FakeVirtualCrudService();
      final RequestContext ctx = RequestContext(
        method: 'GET',
        uri: Uri.parse('https://example.com/items/42'),
      );

      // Act
      final bool result = service.canHandle(ctx);

      // Assert
      expect(result, isTrue);
    });

    test(
        'Given a non-matching context When canHandle is called Then returns false',
        () {
      // Arrange
      final VirtualCrudService service = FakeVirtualCrudService();
      final RequestContext ctx = RequestContext(
        method: 'POST',
        uri: Uri.parse('https://example.com/items'),
      );

      // Act
      final bool result = service.canHandle(ctx);

      // Assert
      expect(result, isFalse);
    });

    test(
        'Given a matching context When handle is called Then returns a JSON-like payload',
        () async {
      // Arrange
      final FakeVirtualCrudService service = FakeVirtualCrudService();
      final RequestContext ctx = RequestContext(
        method: 'GET',
        uri: Uri.parse('https://example.com/items/7'),
      );

      // Act
      final Map<String, dynamic> payload = await service.handle(ctx);

      // Assert
      expect(payload, isA<Map<String, dynamic>>());
      expect(payload['ok'], isTrue);
      expect(payload['id'], 7);
      expect(payload['calls'], 1);
    });

    test(
        'Given a non-matching context When handle is called Then throws StateError',
        () async {
      // Arrange
      final FakeVirtualCrudService service = FakeVirtualCrudService();
      final RequestContext ctx = RequestContext(
        method: 'DELETE',
        uri: Uri.parse('https://example.com/items/7'),
      );

      // Act & Assert
      expect(() => service.handle(ctx), throwsA(isA<StateError>()));
    });

    test(
        'Given multiple handle calls When reset is called Then internal state is cleared',
        () async {
      // Arrange
      final FakeVirtualCrudService service = FakeVirtualCrudService();
      final RequestContext ctx = RequestContext(
        method: 'GET',
        uri: Uri.parse('https://example.com/items/1'),
      );

      // Act
      await service.handle(ctx);
      await service.handle(ctx);
      service.reset();
      final Map<String, dynamic> payloadAfterReset = await service.handle(ctx);

      // Assert
      expect(payloadAfterReset['calls'], 1);
    });

    test(
        'Given same context When handle is called twice without reset Then calls increments deterministically',
        () async {
      // Arrange
      final FakeVirtualCrudService service = FakeVirtualCrudService();
      final RequestContext ctx = RequestContext(
        method: 'GET',
        uri: Uri.parse('https://example.com/items/3'),
      );

      // Act
      final Map<String, dynamic> first = await service.handle(ctx);
      final Map<String, dynamic> second = await service.handle(ctx);

      // Assert
      expect(first['calls'], 1);
      expect(second['calls'], 2);
    });
  });
}

/// --- Fake implementation used for unit tests ---

class FakeVirtualCrudService implements VirtualCrudService {
  int _calls = 0;

  @override
  bool canHandle(RequestContext ctx) {
    final bool isGet = ctx.method.toUpperCase() == 'GET';
    final List<String> segments = ctx.uri.pathSegments;
    final bool matchesItemsById =
        segments.length == 2 && segments[0] == 'items';
    final bool idIsInt = matchesItemsById && int.tryParse(segments[1]) != null;
    return isGet && matchesItemsById && idIsInt;
  }

  @override
  Future<Map<String, dynamic>> handle(RequestContext ctx) async {
    if (!canHandle(ctx)) {
      throw StateError(
        'FakeVirtualCrudService cannot handle: ${ctx.method} ${ctx.uri}',
      );
    }

    _calls += 1;

    final int id = int.parse(ctx.uri.pathSegments[1]);
    return <String, dynamic>{
      'ok': true,
      'id': id,
      'calls': _calls,
    };
  }

  @override
  void reset() {
    _calls = 0;
  }
}

/// --- Minimal RequestContext for compiling the test file ---
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

/// --- Interface under test ---
abstract class VirtualCrudService {
  bool canHandle(RequestContext ctx);
  Future<Map<String, dynamic>> handle(RequestContext ctx);
  void reset();
}
