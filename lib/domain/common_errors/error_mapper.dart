part of '../../jocaagura_domain.dart';

/// Transversal error mapper to be used by Gateways and Repositories.
///
/// - `fromException`: builds an [ErrorItem] from a thrown exception.
/// - `fromPayload`: inspects a JSON-like payload and returns an [ErrorItem]
///   if a business error is encoded there; return `null` if no error detected.
///
/// Implementations should be pure and never throw.
abstract class ErrorMapper {
  /// Map a thrown [error] to an [ErrorItem].
  ErrorItem fromException(
    Object error,
    StackTrace stackTrace, {
    String location,
  });

  /// Extract a business error from a payload, or return `null` if none.
  ErrorItem? fromPayload(
    Map<String, dynamic> payload, {
    String location,
  });
}

/// Default, conservative error mapper.
///
/// Conventions this mapper understands:
/// - `{'error': {...}}` where inner map may contain `title`, `code`,
///   `description` or `message`, `meta`, `errorLevel`.
/// - Top-level `{'code': ..., 'message': ...}` or `{'errorCode': ..., 'errorMessage': ...}`.
/// - Top-level flags `ok:false` or `success:false`.
class DefaultErrorMapper implements ErrorMapper {
  const DefaultErrorMapper({
    this.errorKey = 'error',
    this.codeKey = 'code',
    this.titleKey = 'title',
    this.descriptionKey = 'description',
    this.messageKey = 'message',
    this.metaKey = 'meta',
    this.errorLevelKey = 'errorLevel',
    this.okKey = 'ok',
    this.successKey = 'success',
    this.unexpectedCode = 'ERR_UNEXPECTED',
    this.payloadCode = 'ERR_PAYLOAD',
  });

  final String errorKey;
  final String codeKey;
  final String titleKey;
  final String descriptionKey;
  final String messageKey;
  final String metaKey;
  final String errorLevelKey;
  final String okKey;
  final String successKey;
  final String unexpectedCode;
  final String payloadCode;

  @override
  ErrorItem fromException(
    Object error,
    StackTrace stackTrace, {
    String location = 'unknown',
  }) {
    return ErrorItem(
      title: 'Unexpected error',
      code: unexpectedCode,
      description: error.toString(),
      errorLevel: ErrorLevelEnum.severe,
      meta: <String, dynamic>{
        'location': location,
        'type': error.runtimeType.toString(),
      },
    );
  }

  @override
  ErrorItem? fromPayload(
    Map<String, dynamic> payload, {
    String location = 'unknown',
  }) {
    Map<String, dynamic>? errJson;

    // Case 1: nested {"error": {...}}
    final Object? nested = payload[errorKey];
    if (nested is Map<String, dynamic>) {
      errJson = nested;
    }

    // Case 2: top-level code/message
    if (errJson == null &&
        (payload.containsKey(codeKey) &&
            (payload.containsKey(messageKey) ||
                payload.containsKey(descriptionKey)))) {
      errJson = payload;
    }

    // Case 3: flags ok:false / success:false
    if (errJson == null &&
        ((payload[okKey] is bool && (payload[okKey] as bool) == false) ||
            (payload[successKey] is bool &&
                (payload[successKey] as bool) == false))) {
      errJson = payload;
    }

    if (errJson == null) {
      return null;
    }

    final String title = Utils.getStringFromDynamic(errJson[titleKey]).isEmpty
        ? 'Operation failed'
        : Utils.getStringFromDynamic(errJson[titleKey]);

    final String code = Utils.getStringFromDynamic(errJson[codeKey]).isEmpty
        ? payloadCode
        : Utils.getStringFromDynamic(errJson[codeKey]);

    final String description = Utils.getStringFromDynamic(
      errJson[descriptionKey] ?? errJson[messageKey] ?? 'Unknown error',
    );

    final Map<String, dynamic> meta = Utils.mapFromDynamic(
      errJson[metaKey] ?? <String, dynamic>{},
    )..addAll(<String, dynamic>{'location': location});

    final ErrorLevelEnum level = ErrorItem.getErrorLevelFromString(
      Utils.getStringFromDynamic(errJson[errorLevelKey]),
    );

    return ErrorItem(
      title: title,
      code: code,
      description: description,
      meta: meta,
      errorLevel: level,
    );
  }
}
