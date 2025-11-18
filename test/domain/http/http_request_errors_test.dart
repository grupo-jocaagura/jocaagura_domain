import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Fake simple que permite controlar la salida del delegado.
class _FakeDelegateErrorMapper extends DefaultErrorMapper {
  const _FakeDelegateErrorMapper();

  @override
  ErrorItem fromException(
    Object error,
    StackTrace stackTrace, {
    String location = 'unknown',
  }) {
    return ErrorItem(
      title: 'Base exception title',
      code: 'BASE_EXCEPTION_CODE',
      description: 'Base exception at $location',
      errorLevel: ErrorLevelEnum.warning,
      meta: <String, dynamic>{
        'source': 'delegate_exception',
        'location': location,
      },
    );
  }

  @override
  ErrorItem? fromPayload(
    Map<String, dynamic> payload, {
    String location = 'unknown',
  }) {
    // Usamos "code" del payload si existe para poder verificar
    // que el mapper HTTP remapea o conserva el valor según el status.
    final String baseCode = payload['code'] is String
        ? payload['code'] as String
        : 'BASE_PAYLOAD_CODE';

    return ErrorItem(
      title: 'Base payload title',
      code: baseCode,
      description: 'Base payload at $location',
      errorLevel: ErrorLevelEnum.warning,
      meta: <String, dynamic>{
        'source': 'delegate_payload',
        'location': location,
      },
    );
  }
}

/// Fake que siempre devuelve null en fromPayload para cubrir la rama base == null.
class _FakeNullPayloadErrorMapper extends DefaultErrorMapper {
  const _FakeNullPayloadErrorMapper();

  @override
  ErrorItem fromException(
    Object error,
    StackTrace stackTrace, {
    String location = 'unknown',
  }) {
    return const ErrorItem(
      title: 'Unused',
      code: 'UNUSED',
      description: 'Unused',
      errorLevel: ErrorLevelEnum.warning,
    );
  }

  @override
  ErrorItem? fromPayload(
    Map<String, dynamic> payload, {
    String location = 'unknown',
  }) {
    return null;
  }
}

void main() {
  group('DefaultHttpErrorMapper.fromException', () {
    test(
      'Given a TimeoutException '
      'When fromException is called '
      'Then it returns an ErrorItem based on kHttpTimeoutErrorItem with extra meta',
      () {
        // Arrange
        const DefaultHttpErrorMapper mapper = DefaultHttpErrorMapper(
          delegate: _FakeDelegateErrorMapper(),
        );

        final TimeoutException error = TimeoutException(
          'Operation timed out',
          const Duration(seconds: 10),
        );

        // Act
        final ErrorItem item = mapper.fromException(
          error,
          StackTrace.current,
          location: 'MyLocation',
        );

        // Assert - campos básicos del template
        expect(item.code, equals(kHttpTimeoutErrorItem.code));
        expect(item.title, equals(kHttpTimeoutErrorItem.title));
        expect(item.errorLevel, equals(kHttpTimeoutErrorItem.errorLevel));
        expect(
          item.description,
          contains(kHttpTimeoutErrorItem.description),
        );
        expect(
          item.description,
          contains('Operation timed out'),
        );

        // Assert - meta enriquecido
        expect(
          item.meta['category'],
          equals(kHttpTimeoutErrorItem.meta['category']),
        );
        expect(
          item.meta['transport'],
          equals(kHttpTimeoutErrorItem.meta['transport']),
        );
        expect(
          item.meta['retryable'],
          equals(kHttpTimeoutErrorItem.meta['retryable']),
        );
        expect(item.meta['location'], equals('MyLocation'));
        expect(item.meta['type'], equals('TimeoutException'));
      },
    );

    test(
      'Given a non-timeout exception '
      'When fromException is called '
      'Then it delegates to DefaultErrorMapper and adds transport=http to meta',
      () {
        // Arrange
        const DefaultHttpErrorMapper mapper = DefaultHttpErrorMapper(
          delegate: _FakeDelegateErrorMapper(),
        );

        final Exception error = Exception('Generic failure');

        // Act
        final ErrorItem item = mapper.fromException(
          error,
          StackTrace.current,
          location: 'OtherLocation',
        );

        // Assert - datos del delegado preservados
        expect(item.code, equals('BASE_EXCEPTION_CODE'));
        expect(item.title, equals('Base exception title'));
        expect(item.description, contains('Base exception at OtherLocation'));
        expect(item.errorLevel, equals(ErrorLevelEnum.warning));

        // Assert - meta combinado
        expect(item.meta['source'], equals('delegate_exception'));
        expect(item.meta['location'], equals('OtherLocation'));
        // transport siempre debe ser http
        expect(item.meta['transport'], equals('http'));
      },
    );
  });

  group('DefaultHttpErrorMapper.fromPayload - base null handling', () {
    test(
      'Given a delegate that returns null fromPayload '
      'When fromPayload is called '
      'Then DefaultHttpErrorMapper also returns null',
      () {
        // Arrange
        const DefaultHttpErrorMapper mapper = DefaultHttpErrorMapper(
          delegate: _FakeNullPayloadErrorMapper(),
        );

        final Map<String, dynamic> payload = <String, dynamic>{
          'message': 'something went wrong',
        };

        // Act
        final ErrorItem? item = mapper.fromPayload(
          payload,
          location: 'NullLocation',
        );

        // Assert
        expect(item, isNull);
      },
    );
  });

  group('DefaultHttpErrorMapper.fromPayload - status code mapping', () {
    const DefaultHttpErrorMapper mapper = DefaultHttpErrorMapper(
      delegate: _FakeDelegateErrorMapper(),
    );

    test(
      'Given a payload with statusCode 400/401/403/404/409/429 '
      'When fromPayload is called '
      'Then it remaps the code to the corresponding HTTP constant',
      () {
        // 400 Bad Request
        final ErrorItem? badRequest = mapper.fromPayload(
          <String, dynamic>{
            'code': 'BASE_400',
            'statusCode': 400,
          },
          location: 'Loc',
        );
        expect(badRequest, isNotNull);
        expect(badRequest!.code, equals(kHttpBadRequestErrorItem.code));
        expect(badRequest.meta['transport'], equals('http'));
        expect(badRequest.meta['httpStatus'], equals(400));
        expect(badRequest.meta['source'], equals('delegate_payload'));

        // 401 Unauthorized
        final ErrorItem? unauthorized = mapper.fromPayload(
          <String, dynamic>{
            'code': 'BASE_401',
            'statusCode': 401,
          },
          location: 'Loc',
        );
        expect(unauthorized, isNotNull);
        expect(unauthorized!.code, equals(kHttpUnauthorizedErrorItem.code));
        expect(unauthorized.meta['httpStatus'], equals(401));

        // 403 Forbidden
        final ErrorItem? forbidden = mapper.fromPayload(
          <String, dynamic>{
            'code': 'BASE_403',
            'statusCode': 403,
          },
          location: 'Loc',
        );
        expect(forbidden, isNotNull);
        expect(forbidden!.code, equals(kHttpForbiddenErrorItem.code));
        expect(forbidden.meta['httpStatus'], equals(403));

        // 404 Not Found
        final ErrorItem? notFound = mapper.fromPayload(
          <String, dynamic>{
            'code': 'BASE_404',
            'statusCode': 404,
          },
          location: 'Loc',
        );
        expect(notFound, isNotNull);
        expect(notFound!.code, equals(kHttpNotFoundErrorItem.code));
        expect(notFound.meta['httpStatus'], equals(404));

        // 409 Conflict
        final ErrorItem? conflict = mapper.fromPayload(
          <String, dynamic>{
            'code': 'BASE_409',
            'statusCode': 409,
          },
          location: 'Loc',
        );
        expect(conflict, isNotNull);
        expect(conflict!.code, equals(kHttpConflictErrorItem.code));
        expect(conflict.meta['httpStatus'], equals(409));

        // 429 Too Many Requests
        final ErrorItem? tooMany = mapper.fromPayload(
          <String, dynamic>{
            'code': 'BASE_429',
            'statusCode': 429,
          },
          location: 'Loc',
        );
        expect(tooMany, isNotNull);
        expect(tooMany!.code, equals(kHttpTooManyRequestsErrorItem.code));
        expect(tooMany.meta['httpStatus'], equals(429));
      },
    );

    test(
      'Given a payload with httpStatus in the 5xx range '
      'When fromPayload is called '
      'Then it remaps the code to HTTP_SERVER_ERROR',
      () {
        // Arrange - usamos httpStatus en lugar de statusCode
        final ErrorItem? serverError = mapper.fromPayload(
          <String, dynamic>{
            'code': 'BASE_503',
            'httpStatus': 503,
          },
          location: 'Loc',
        );

        // Assert
        expect(serverError, isNotNull);
        expect(serverError!.code, equals(kHttpServerErrorItem.code));
        expect(serverError.meta['httpStatus'], equals(503));
        expect(serverError.meta['transport'], equals('http'));
        expect(serverError.meta['source'], equals('delegate_payload'));
      },
    );

    test(
      'Given a payload without statusCode/httpStatus '
      'When fromPayload is called '
      'Then it preserves the base code and only adds transport=http to meta',
      () {
        // Arrange
        final ErrorItem? item = mapper.fromPayload(
          <String, dynamic>{
            'code': 'BASE_ORIGINAL',
          },
          location: 'NoStatusLocation',
        );

        // Assert
        expect(item, isNotNull);
        expect(item!.code, equals('BASE_ORIGINAL'));
        expect(item.meta['source'], equals('delegate_payload'));
        expect(item.meta['location'], equals('NoStatusLocation'));
        expect(item.meta['transport'], equals('http'));
        expect(item.meta.containsKey('httpStatus'), isFalse);
      },
    );
  });
}
