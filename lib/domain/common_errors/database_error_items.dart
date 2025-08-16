part of '../../jocaagura_domain.dart';

/// Common Database-related error definitions used across the domain layer.
///
/// These errors model typical CRUD and storage scenarios (create/read/update/delete),
/// connection issues, constraints, and concurrency conflicts. They are meant to be
/// used by Gateways and Repositories and mapped via [ErrorItem].
///
/// Conventions:
/// - Codes are prefixed with `DB_`.
/// - `meta['source'] == 'Database'` for quick filtering in logs.
abstract class DatabaseErrorItems {
  /// Key used in the meta field to indicate the error source.
  static const String sourceKey = 'source';

  /// Value representing Database as the error source.
  static const String sourceValue = 'Database';

  /// Error when the database connection cannot be established.
  static const ErrorItem connectionFailed = ErrorItem(
    title: 'Database Connection Failed',
    code: 'DB_CONN_FAILED',
    description: 'Unable to establish a connection with the database.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.danger,
  );

  /// Error when the database is reachable but currently unavailable (maintenance, outage).
  static const ErrorItem unavailable = ErrorItem(
    title: 'Database Unavailable',
    code: 'DB_UNAVAILABLE',
    description: 'The database service is temporarily unavailable.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.severe,
  );

  /// Error when authentication to the database fails (invalid credentials/token).
  static const ErrorItem unauthorized = ErrorItem(
    title: 'Database Unauthorized',
    code: 'DB_UNAUTHORIZED',
    description: 'Authentication failed when accessing the database.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.severe,
  );

  /// Error when the caller lacks permissions to perform the operation.
  static const ErrorItem forbidden = ErrorItem(
    title: 'Database Forbidden',
    code: 'DB_FORBIDDEN',
    description: 'You do not have permission to perform this operation.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.severe,
  );

  /// Error when the requested record/document is not found.
  static const ErrorItem notFound = ErrorItem(
    title: 'Record Not Found',
    code: 'DB_NOT_FOUND',
    description: 'The requested record does not exist in the database.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.warning,
  );

  /// Error when attempting to create an entity that already exists (unique key).
  static const ErrorItem alreadyExists = ErrorItem(
    title: 'Record Already Exists',
    code: 'DB_ALREADY_EXISTS',
    description: 'A record with the same identifier already exists.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.warning,
  );

  /// Error for version/concurrency conflicts (optimistic locking / ETag mismatch).
  static const ErrorItem conflict = ErrorItem(
    title: 'Concurrency Conflict',
    code: 'DB_CONFLICT',
    description: 'The record was modified concurrently by another process.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.warning,
  );

  /// Error when a constraint is violated (foreign key, unique, check).
  static const ErrorItem constraintViolation = ErrorItem(
    title: 'Constraint Violation',
    code: 'DB_CONSTRAINT_VIOLATION',
    description: 'The operation violates a database constraint.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.warning,
  );

  /// Error for invalid payload/shape (schema/validation failure).
  static const ErrorItem validationFailed = ErrorItem(
    title: 'Validation Failed',
    code: 'DB_VALIDATION_FAILED',
    description: 'The provided data is invalid or does not match the schema.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.warning,
  );

  /// Error when serialization/deserialization to/from storage fails.
  static const ErrorItem serializationError = ErrorItem(
    title: 'Serialization Error',
    code: 'DB_SERIALIZATION_ERROR',
    description: 'Failed to serialize or deserialize the data.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.severe,
  );

  /// Error when the database operation times out.
  static const ErrorItem timeout = ErrorItem(
    title: 'Database Timeout',
    code: 'DB_TIMEOUT',
    description: 'The database operation timed out.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.warning,
  );

  /// Error when storage limits/quotas are exceeded.
  static const ErrorItem quotaExceeded = ErrorItem(
    title: 'Quota Exceeded',
    code: 'DB_QUOTA_EXCEEDED',
    description:
        'The operation failed due to exceeded storage or quota limits.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.severe,
  );

  /// Error for transaction failures (rolled back due to internal errors).
  static const ErrorItem transactionFailed = ErrorItem(
    title: 'Transaction Failed',
    code: 'DB_TRANSACTION_FAILED',
    description:
        'The database transaction could not be completed and was rolled back.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.severe,
  );

  /// Error for deadlock detection/avoidance resulting in an aborted operation.
  static const ErrorItem deadlock = ErrorItem(
    title: 'Deadlock Detected',
    code: 'DB_DEADLOCK',
    description: 'The operation was aborted due to a detected deadlock.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.severe,
  );

  static const ErrorItem streamClosed = ErrorItem(
    title: 'Stream Closed',
    code: 'DB_STREAM_CLOSED',
    description: 'The database stream was closed unexpectedly.',
    meta: <String, dynamic>{sourceKey: sourceValue},
    errorLevel: ErrorLevelEnum.warning,
  );

  /// Generic fallback error for unrecognized Database issues.
  static ErrorItem unknown({String? reason}) => ErrorItem(
        title: 'Unknown Database Error',
        code: 'DB_UNKNOWN',
        description: reason ?? 'An unknown database error has occurred.',
        meta: const <String, dynamic>{sourceKey: sourceValue},
      );

  /// Returns a predefined [ErrorItem] based on the database error [code].
  /// If the code is not recognized, returns [unknown].
  static ErrorItem fromCode(String code) {
    switch (code) {
      case 'DB_CONN_FAILED':
        return connectionFailed;
      case 'DB_UNAVAILABLE':
        return unavailable;
      case 'DB_UNAUTHORIZED':
        return unauthorized;
      case 'DB_FORBIDDEN':
        return forbidden;
      case 'DB_NOT_FOUND':
        return notFound;
      case 'DB_ALREADY_EXISTS':
        return alreadyExists;
      case 'DB_CONFLICT':
        return conflict;
      case 'DB_CONSTRAINT_VIOLATION':
        return constraintViolation;
      case 'DB_VALIDATION_FAILED':
        return validationFailed;
      case 'DB_SERIALIZATION_ERROR':
        return serializationError;
      case 'DB_TIMEOUT':
        return timeout;
      case 'DB_QUOTA_EXCEEDED':
        return quotaExceeded;
      case 'DB_TRANSACTION_FAILED':
        return transactionFailed;
      case 'DB_DEADLOCK':
        return deadlock;
      case 'DB_STREAM_CLOSED':
        return streamClosed;
      default:
        return unknown(reason: 'Unrecognized Database code: $code');
    }
  }
}
