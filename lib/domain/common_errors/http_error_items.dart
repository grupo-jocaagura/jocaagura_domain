part of '../../jocaagura_domain.dart';

/// Collection of standard HTTP error representations using [ErrorItem].
///
/// This class provides constants for each common HTTP status code, mapped to
/// a descriptive [ErrorItem] instance. You can use [fromStatusCode] to obtain
/// the default error item from a numeric HTTP status.
abstract class HttpErrorItems {
  /// Key used to store the HTTP status code in [ErrorItem.meta].
  static const String httpCode = 'httpCode';

  /// Extracts the integer HTTP code from an [ErrorItem].
  /// Returns -1 if the key is missing or not an integer.
  static int getHttpCode(ErrorItem error) {
    final dynamic value = error.meta[httpCode];
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? -1;
    }
    return -1;
  }

  // 1xx - Informational Responses
  static const ErrorItem continueRequest = ErrorItem(
    title: 'Continue',
    code: 'HTTP_100',
    description: 'The server has received the request headers.',
    meta: <String, dynamic>{httpCode: 100},
  );

  static const ErrorItem switchingProtocols = ErrorItem(
    title: 'Switching Protocols',
    code: 'HTTP_101',
    description: 'The server is switching protocols as requested.',
    meta: <String, dynamic>{httpCode: 101},
  );

  // 2xx - Success (Not typically treated as errors)

  // 3xx - Redirection (Can be used for logic-level control, not shown in UI)
  static const ErrorItem notModified = ErrorItem(
    title: 'Not Modified',
    code: 'HTTP_304',
    description: 'The resource has not been modified since the last request.',
    meta: <String, dynamic>{httpCode: 304},
  );

  // 4xx - Client Errors
  static const ErrorItem badRequest = ErrorItem(
    title: 'Bad Request',
    code: 'HTTP_400',
    description:
        'The server could not understand the request due to invalid syntax.',
    meta: <String, dynamic>{httpCode: 400},
    errorLevel: ErrorLevelEnum.warning,
  );

  static const ErrorItem unauthorized = ErrorItem(
    title: 'Unauthorized',
    code: 'HTTP_401',
    description:
        'Authentication is required and has failed or has not yet been provided.',
    meta: <String, dynamic>{httpCode: 401},
    errorLevel: ErrorLevelEnum.warning,
  );

  static const ErrorItem paymentRequired = ErrorItem(
    title: 'Payment Required',
    code: 'HTTP_402',
    description: 'Reserved for future use.',
    meta: <String, dynamic>{httpCode: 402},
  );

  static const ErrorItem forbidden = ErrorItem(
    title: 'Forbidden',
    code: 'HTTP_403',
    description: 'You do not have permission to access this resource.',
    meta: <String, dynamic>{httpCode: 403},
    errorLevel: ErrorLevelEnum.severe,
  );

  static const ErrorItem notFound = ErrorItem(
    title: 'Not Found',
    code: 'HTTP_404',
    description: 'The requested resource could not be found.',
    meta: <String, dynamic>{httpCode: 404},
    errorLevel: ErrorLevelEnum.danger,
  );

  static const ErrorItem methodNotAllowed = ErrorItem(
    title: 'Method Not Allowed',
    code: 'HTTP_405',
    description:
        'The request method is known by the server but is not supported.',
    meta: <String, dynamic>{httpCode: 405},
    errorLevel: ErrorLevelEnum.severe,
  );

  static const ErrorItem notAcceptable = ErrorItem(
    title: 'Not Acceptable',
    code: 'HTTP_406',
    description:
        'The requested resource is capable of generating only content not acceptable.',
    meta: <String, dynamic>{httpCode: 406},
    errorLevel: ErrorLevelEnum.severe,
  );

  static const ErrorItem conflict = ErrorItem(
    title: 'Conflict',
    code: 'HTTP_409',
    description:
        'The request conflicts with the current state of the resource.',
    meta: <String, dynamic>{httpCode: 409},
    errorLevel: ErrorLevelEnum.warning,
  );

  static const ErrorItem gone = ErrorItem(
    title: 'Gone',
    code: 'HTTP_410',
    description: 'The resource requested is no longer available.',
    meta: <String, dynamic>{httpCode: 410},
  );

  static const ErrorItem unsupportedMediaType = ErrorItem(
    title: 'Unsupported Media Type',
    code: 'HTTP_415',
    description: 'The media format is not supported by the server.',
    meta: <String, dynamic>{httpCode: 415},
    errorLevel: ErrorLevelEnum.severe,
  );

  static const ErrorItem tooManyRequests = ErrorItem(
    title: 'Too Many Requests',
    code: 'HTTP_429',
    description: 'You have sent too many requests in a given amount of time.',
    meta: <String, dynamic>{httpCode: 429},
    errorLevel: ErrorLevelEnum.severe,
  );

  // 5xx - Server Errors
  static const ErrorItem internalServerError = ErrorItem(
    title: 'Internal Server Error',
    code: 'HTTP_500',
    description: 'The server encountered an unexpected condition.',
    meta: <String, dynamic>{httpCode: 500},
    errorLevel: ErrorLevelEnum.danger,
  );

  static const ErrorItem notImplemented = ErrorItem(
    title: 'Not Implemented',
    code: 'HTTP_501',
    description: 'The server does not support the functionality required.',
    meta: <String, dynamic>{httpCode: 501},
    errorLevel: ErrorLevelEnum.danger,
  );

  static const ErrorItem badGateway = ErrorItem(
    title: 'Bad Gateway',
    code: 'HTTP_502',
    description:
        'The server received an invalid response from the upstream server.',
    meta: <String, dynamic>{httpCode: 502},
    errorLevel: ErrorLevelEnum.danger,
  );

  static const ErrorItem serviceUnavailable = ErrorItem(
    title: 'Service Unavailable',
    code: 'HTTP_503',
    description: 'The server is currently unavailable (overloaded or down).',
    meta: <String, dynamic>{httpCode: 503},
    errorLevel: ErrorLevelEnum.danger,
  );

  static const ErrorItem gatewayTimeout = ErrorItem(
    title: 'Gateway Timeout',
    code: 'HTTP_504',
    description: 'The upstream server failed to send a request in time.',
    meta: <String, dynamic>{httpCode: 504},
    errorLevel: ErrorLevelEnum.danger,
  );

  /// Returns a standard [ErrorItem] from a given [statusCode].
  /// If no specific item is found, returns a generic error.
  static ErrorItem fromStatusCode(int statusCode) {
    switch (statusCode) {
      case 100:
        return continueRequest;
      case 101:
        return switchingProtocols;
      case 304:
        return notModified;
      case 400:
        return badRequest;
      case 401:
        return unauthorized;
      case 402:
        return paymentRequired;
      case 403:
        return forbidden;
      case 404:
        return notFound;
      case 405:
        return methodNotAllowed;
      case 406:
        return notAcceptable;
      case 409:
        return conflict;
      case 410:
        return gone;
      case 415:
        return unsupportedMediaType;
      case 429:
        return tooManyRequests;
      case 500:
        return internalServerError;
      case 501:
        return notImplemented;
      case 502:
        return badGateway;
      case 503:
        return serviceUnavailable;
      case 504:
        return gatewayTimeout;
      default:
        return ErrorItem(
          title: 'Unknown HTTP Error',
          code: 'HTTP_$statusCode',
          description:
              'An unknown error occurred with HTTP status $statusCode.',
          meta: <String, dynamic>{httpCode: statusCode},
        );
    }
  }
}
