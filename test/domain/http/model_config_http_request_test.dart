import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelConfigHttpRequest - JSON round trip', () {
    test(
      'Given a full config '
      'When it is serialized and deserialized '
      'Then all fields are preserved (round-trip)',
      () {
        // Arrange
        final ModelConfigHttpRequest original = ModelConfigHttpRequest(
          method: HttpMethodEnum.post,
          uri: Uri.parse('https://api.example.com/users'),
          headers: const <String, String>{
            'Authorization': 'Bearer token',
            'Content-Type': 'application/json',
          },
          body: const <String, dynamic>{
            'name': 'John',
            'active': true,
            'roles': <String>['admin', 'user'],
          },
          timeout: const Duration(seconds: 5),
          metadata: const <String, dynamic>{
            'feature': 'createUser',
            'retryPolicy': 'default',
            'trackingId': 'abc-123',
          },
        );

        // Act
        final Map<String, dynamic> json = original.toJson();
        final ModelConfigHttpRequest restored =
            ModelConfigHttpRequest.fromJson(json);

        // Assert
        expect(restored, equals(original));
        expect(restored.hashCode, equals(original.hashCode));
        expect(restored.method, equals(HttpMethodEnum.post));
        expect(
          restored.uri.toString(),
          equals('https://api.example.com/users'),
        );
        expect(restored.headers['Authorization'], equals('Bearer token'));
        expect(restored.body['name'], equals('John'));
        expect(restored.timeout, equals(const Duration(seconds: 5)));
        expect(restored.metadata['feature'], equals('createUser'));
      },
    );
  });

  group('ModelConfigHttpRequest - defaults and optional fields', () {
    test(
      'Given minimal JSON with method and uri only '
      'When fromJson is called '
      'Then headers, body and metadata are empty maps and timeout is null',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelConfigHttpRequestEnum.method.name: HttpMethodEnum.get.name,
          ModelConfigHttpRequestEnum.uri.name: '/relative/path',
        };

        // Act
        final ModelConfigHttpRequest config =
            ModelConfigHttpRequest.fromJson(json);

        // Assert
        expect(config.method, equals(HttpMethodEnum.get));
        expect(config.uri.toString(), equals('/relative/path'));
        expect(config.headers, isNotNull);
        expect(config.headers, isEmpty);
        expect(config.body, isNotNull);
        expect(config.body, isEmpty);
        expect(config.metadata, isNotNull);
        expect(config.metadata, isEmpty);
        expect(config.timeout, isNull);
      },
    );

    test(
      'Given JSON with explicit null timeout '
      'When fromJson is called '
      'Then timeout remains null',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelConfigHttpRequestEnum.method.name: HttpMethodEnum.get.name,
          ModelConfigHttpRequestEnum.uri.name: 'https://example.com',
          ModelConfigHttpRequestEnum.timeout.name: null,
        };

        // Act
        final ModelConfigHttpRequest config =
            ModelConfigHttpRequest.fromJson(json);

        // Assert
        expect(config.timeout, isNull);
      },
    );
  });

  group('ModelConfigHttpRequest - headers and metadata normalization', () {
    test(
      'Given JSON with non-string header values '
      'When fromJson is called '
      'Then headers are normalized to strings',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelConfigHttpRequestEnum.method.name: HttpMethodEnum.get.name,
          ModelConfigHttpRequestEnum.uri.name: 'https://example.com',
          ModelConfigHttpRequestEnum.headers.name: <String, dynamic>{
            'x-int': 42,
            'x-bool': true,
            'x-str': 'value',
          },
        };

        // Act
        final ModelConfigHttpRequest config =
            ModelConfigHttpRequest.fromJson(json);

        // Assert
        expect(config.headers['x-int'], equals('42'));
        expect(config.headers['x-bool'], equals('true'));
        expect(config.headers['x-str'], equals('value'));
      },
    );

    test(
      'Given JSON with metadata as dynamic structure '
      'When fromJson is called '
      'Then metadata is normalized to a Map<String, dynamic>',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelConfigHttpRequestEnum.method.name: HttpMethodEnum.get.name,
          ModelConfigHttpRequestEnum.uri.name: 'https://example.com',
          ModelConfigHttpRequestEnum.metadata.name: <String, dynamic>{
            'feature': 'login',
            'attempt': 3,
            'flags': <String>['cold-start'],
          },
        };

        // Act
        final ModelConfigHttpRequest config =
            ModelConfigHttpRequest.fromJson(json);

        // Assert
        expect(config.metadata['feature'], equals('login'));
        expect(config.metadata['attempt'], equals(3));
        expect(config.metadata['flags'], isA<List<dynamic>>());
      },
    );
  });

  group('ModelConfigHttpRequest - method fallback and enum keys', () {
    test(
      'Given JSON with unknown method '
      'When fromJson is called '
      'Then method falls back to HttpMethodEnum.values.first',
      () {
        // Arrange
        final HttpMethodEnum expectedFallback = HttpMethodEnum.values.first;
        final Map<String, dynamic> json = <String, dynamic>{
          ModelConfigHttpRequestEnum.method.name: 'unknown_method',
          ModelConfigHttpRequestEnum.uri.name: 'https://example.com',
        };

        // Act
        final ModelConfigHttpRequest config =
            ModelConfigHttpRequest.fromJson(json);

        // Assert
        expect(config.method, equals(expectedFallback));
      },
    );

    test(
      'Given the enum ModelConfigHttpRequestEnum '
      'When accessing names '
      'Then they match the expected JSON keys',
      () {
        expect(ModelConfigHttpRequestEnum.method.name, equals('method'));
        expect(ModelConfigHttpRequestEnum.uri.name, equals('uri'));
        expect(ModelConfigHttpRequestEnum.headers.name, equals('headers'));
        expect(ModelConfigHttpRequestEnum.body.name, equals('body'));
        expect(ModelConfigHttpRequestEnum.timeout.name, equals('timeout'));
        expect(ModelConfigHttpRequestEnum.metadata.name, equals('metadata'));
      },
    );
  });

  group('ModelConfigHttpRequest - copyWith, equality and toString', () {
    test(
      'Given an instance '
      'When copyWith is called overriding some fields '
      'Then the new instance has mixed values and the original remains unchanged',
      () {
        // Arrange
        final ModelConfigHttpRequest original = ModelConfigHttpRequest(
          method: HttpMethodEnum.get,
          uri: Uri.parse('https://example.com/v1'),
          headers: const <String, String>{'h1': 'v1'},
          body: const <String, dynamic>{'a': 1},
          timeout: const Duration(seconds: 3),
          metadata: const <String, dynamic>{'feature': 'test'},
        );

        final Uri newUri = Uri.parse('https://example.com/v2');
        const Duration newTimeout = Duration(seconds: 10);
        final Map<String, String> newHeaders = <String, String>{'h2': 'v2'};

        // Act
        final ModelConfigHttpRequest modified = original.copyWith(
          uri: newUri,
          timeout: newTimeout,
          headers: newHeaders,
        );

        // Assert
        // Original unchanged
        expect(original.uri.toString(), equals('https://example.com/v1'));
        expect(original.timeout, equals(const Duration(seconds: 3)));
        expect(original.headers['h1'], equals('v1'));

        // New instance with overrides
        expect(modified.method, equals(HttpMethodEnum.get));
        expect(modified.uri, equals(newUri));
        expect(modified.timeout, equals(newTimeout));
        expect(modified.headers, equals(newHeaders));
        expect(modified.body, equals(original.body));
        expect(modified.metadata, equals(original.metadata));
        // originas equal t clone
        final ModelConfigHttpRequest clone = original.copyWith();
        expect(clone, equals(original));
        expect(clone.timeout, equals(original.timeout));
        expect(clone.uri, equals(original.uri));
      },
    );

    test(
      'Given two instances with same values '
      'When compared '
      'Then they are equal and share the same hashCode',
      () {
        // Arrange
        final ModelConfigHttpRequest a = ModelConfigHttpRequest(
          method: HttpMethodEnum.delete,
          uri: Uri.parse('https://example.com/resource'),
          headers: const <String, String>{'Authorization': 'Bearer token'},
          body: const <String, dynamic>{'id': 1},
          timeout: const Duration(milliseconds: 1500),
          metadata: const <String, dynamic>{'feature': 'deleteResource'},
        );

        final ModelConfigHttpRequest b = ModelConfigHttpRequest(
          method: HttpMethodEnum.delete,
          uri: Uri.parse('https://example.com/resource'),
          headers: const <String, String>{'Authorization': 'Bearer token'},
          body: const <String, dynamic>{'id': 1},
          timeout: const Duration(milliseconds: 1500),
          metadata: const <String, dynamic>{'feature': 'deleteResource'},
        );

        // Assert
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      },
    );

    test(
      'Given an instance '
      'When toString is called '
      'Then it returns a human readable representation containing method and uri',
      () {
        // Arrange
        final ModelConfigHttpRequest config = ModelConfigHttpRequest(
          method: HttpMethodEnum.get,
          uri: Uri.parse('https://example.com/path'),
        );

        // Act
        final String description = config.toString();

        // Assert
        expect(description, contains('ModelConfigHttpRequest('));
        expect(description, contains('method: ${HttpMethodEnum.get.name}'));
        expect(description, contains('uri: https://example.com/path'));
      },
    );
  });
}
