part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Errores HTTP / red más comunes estandarizados para el dominio.
///
/// Estos son *plantillas* reutilizables. El mapper concreto (p.ej.
/// [DefaultHttpErrorMapper]) puede tomar su `code`, `title`, `description`
/// y complementar el `meta` con información contextual (location, type, etc.).

const ErrorItem kHttpTimeoutErrorItem = ErrorItem(
  title: 'Tiempo de espera agotado',
  code: 'HTTP_TIMEOUT',
  description: 'La solicitud HTTP excedió el tiempo máximo configurado.',
  errorLevel: ErrorLevelEnum.severe,
  meta: <String, dynamic>{
    'category': 'network',
    'transport': 'http',
    'retryable': true,
  },
);

const ErrorItem kHttpNoConnectionErrorItem = ErrorItem(
  title: 'Sin conexión a internet',
  code: 'HTTP_NO_CONNECTION',
  description: 'No fue posible establecer conexión con el servidor.',
  errorLevel: ErrorLevelEnum.severe,
  meta: <String, dynamic>{
    'category': 'network',
    'transport': 'http',
    'retryable': true,
  },
);

const ErrorItem kHttpCancelledErrorItem = ErrorItem(
  title: 'Solicitud cancelada',
  code: 'HTTP_CANCELLED',
  description: 'La solicitud HTTP fue cancelada antes de completarse.',
  errorLevel: ErrorLevelEnum.warning,
  meta: <String, dynamic>{
    'category': 'client',
    'transport': 'http',
    'retryable': false,
  },
);

const ErrorItem kHttpBadRequestErrorItem = ErrorItem(
  title: 'Solicitud inválida',
  code: 'HTTP_BAD_REQUEST',
  description: 'El servidor rechazó la solicitud por datos inválidos (400).',
  errorLevel: ErrorLevelEnum.warning,
  meta: <String, dynamic>{
    'category': 'client',
    'transport': 'http',
    'retryable': false,
  },
);

const ErrorItem kHttpUnauthorizedErrorItem = ErrorItem(
  title: 'No autorizado',
  code: 'HTTP_UNAUTHORIZED',
  description: 'Se requiere autenticación válida para esta operación (401).',
  errorLevel: ErrorLevelEnum.warning,
  meta: <String, dynamic>{
    'category': 'auth',
    'transport': 'http',
    'retryable': true,
  },
);

const ErrorItem kHttpForbiddenErrorItem = ErrorItem(
  title: 'Acceso prohibido',
  code: 'HTTP_FORBIDDEN',
  description: 'El servidor negó el acceso al recurso solicitado (403).',
  errorLevel: ErrorLevelEnum.warning,
  meta: <String, dynamic>{
    'category': 'auth',
    'transport': 'http',
    'retryable': false,
  },
);

const ErrorItem kHttpNotFoundErrorItem = ErrorItem(
  title: 'Recurso no encontrado',
  code: 'HTTP_NOT_FOUND',
  description: 'El recurso solicitado no existe o no está disponible (404).',
  meta: <String, dynamic>{
    'category': 'client',
    'transport': 'http',
    'retryable': false,
  },
);

const ErrorItem kHttpConflictErrorItem = ErrorItem(
  title: 'Conflicto en la operación',
  code: 'HTTP_CONFLICT',
  description: 'La operación entró en conflicto con el estado actual (409).',
  errorLevel: ErrorLevelEnum.warning,
  meta: <String, dynamic>{
    'category': 'business',
    'transport': 'http',
    'retryable': false,
  },
);

const ErrorItem kHttpTooManyRequestsErrorItem = ErrorItem(
  title: 'Demasiadas solicitudes',
  code: 'HTTP_TOO_MANY_REQUESTS',
  description: 'Se superó el límite de llamadas permitidas (429).',
  errorLevel: ErrorLevelEnum.warning,
  meta: <String, dynamic>{
    'category': 'throttling',
    'transport': 'http',
    'retryable': true,
  },
);

const ErrorItem kHttpServerErrorItem = ErrorItem(
  title: 'Error interno del servidor',
  code: 'HTTP_SERVER_ERROR',
  description: 'El servidor encontró un error al procesar la solicitud (5xx).',
  errorLevel: ErrorLevelEnum.severe,
  meta: <String, dynamic>{
    'category': 'server',
    'transport': 'http',
    'retryable': true,
  },
);

const ErrorItem kHttpGatewayTimeoutErrorItem = ErrorItem(
  title: 'Tiempo de espera en el servidor intermedio',
  code: 'HTTP_GATEWAY_TIMEOUT',
  description:
      'Un servidor intermedio no respondió a tiempo al reenviar la solicitud (504).',
  errorLevel: ErrorLevelEnum.severe,
  meta: <String, dynamic>{
    'category': 'network',
    'transport': 'http',
    'retryable': true,
  },
);

const ErrorItem kHttpUnknownErrorItem = ErrorItem(
  title: 'Error HTTP desconocido',
  code: 'HTTP_UNKNOWN',
  description: 'Ocurrió un error HTTP no clasificado.',
  errorLevel: ErrorLevelEnum.severe,
  meta: <String, dynamic>{
    'category': 'unknown',
    'transport': 'http',
    'retryable': false,
  },
);

/// ErrorMapper especializado para el flujo HTTP.
///
/// - Reutiliza [DefaultErrorMapper] para la lógica genérica.
/// - Añade siempre `transport: 'http'` al `meta`.
/// - Ajusta `code` según `statusCode`/`httpStatus` cuando está disponible.
/// - Mapea explícitamente `TimeoutException` a [kHttpTimeoutErrorItem].
class DefaultHttpErrorMapper implements ErrorMapper {
  const DefaultHttpErrorMapper({
    DefaultErrorMapper? delegate,
  }) : _delegate = delegate ?? const DefaultErrorMapper();

  /// Mapper genérico reutilizado como base.
  final DefaultErrorMapper _delegate;

  @override
  ErrorItem fromException(
    Object error,
    StackTrace stackTrace, {
    String location = 'unknown',
  }) {
    // Caso especial: timeout de transporte (ej: dio, http, etc.)
    if (error is TimeoutException) {
      return ErrorItem(
        title: kHttpTimeoutErrorItem.title,
        code: kHttpTimeoutErrorItem.code,
        description: '${kHttpTimeoutErrorItem.description} Detalle: $error',
        errorLevel: kHttpTimeoutErrorItem.errorLevel,
        meta: <String, dynamic>{
          ...kHttpTimeoutErrorItem.meta,
          'location': location,
          'type': error.runtimeType.toString(),
        },
      );
    }

    // Fallback: usamos el mapper genérico y lo marcamos como HTTP.
    final ErrorItem generic = _delegate.fromException(
      error,
      stackTrace,
      location: location,
    );

    return ErrorItem(
      title: generic.title,
      code: generic.code,
      description: generic.description,
      errorLevel: generic.errorLevel,
      meta: <String, dynamic>{
        ...generic.meta,
        'transport': 'http',
      },
    );
  }

  @override
  ErrorItem? fromPayload(
    Map<String, dynamic> payload, {
    String location = 'unknown',
  }) {
    // Primero intentamos con las convenciones del mapper genérico.
    final ErrorItem? base = _delegate.fromPayload(
      payload,
      location: location,
    );

    if (base == null) {
      return null;
    }

    // Intentamos obtener un status HTTP si el backend lo manda en el payload.
    int? statusCode;
    if (payload['statusCode'] is int) {
      statusCode = payload['statusCode'] as int;
    } else if (payload['httpStatus'] is int) {
      statusCode = payload['httpStatus'] as int;
    }

    // Ajustamos el code según el status cuando sea posible.
    String code = base.code;
    if (statusCode != null) {
      if (statusCode == 400) {
        code = kHttpBadRequestErrorItem.code;
      } else if (statusCode == 401) {
        code = kHttpUnauthorizedErrorItem.code;
      } else if (statusCode == 403) {
        code = kHttpForbiddenErrorItem.code;
      } else if (statusCode == 404) {
        code = kHttpNotFoundErrorItem.code;
      } else if (statusCode == 409) {
        code = kHttpConflictErrorItem.code;
      } else if (statusCode == 429) {
        code = kHttpTooManyRequestsErrorItem.code;
      } else if (statusCode >= 500 && statusCode <= 599) {
        code = kHttpServerErrorItem.code;
      }
    }

    final Map<String, dynamic> meta = <String, dynamic>{
      ...base.meta,
      'transport': 'http',
      if (statusCode != null) 'httpStatus': statusCode,
    };

    return ErrorItem(
      title: base.title,
      code: code,
      description: base.description,
      errorLevel: base.errorLevel,
      meta: meta,
    );
  }
}
