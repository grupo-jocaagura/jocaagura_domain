part of '../../jocaagura_domain.dart';

/// Collection of common **session/auth** domain errors using [ErrorItem].
///
/// All items carry a `reason` in `meta` so implementers can branch logic
/// reliably across providers and transports (HTTP, SDKs, etc).
///
/// ### Reasons metadata
/// - [reasonKey]: machine-friendly reason (e.g. `invalid_credentials`)
/// - [providerKey]: optional origin (e.g. `firebase`, `oauth_google`)
/// - [retryAfterSecondsKey]: for rate limiting/backoff
/// - [lockUntilKey]: for temporary account lock (epoch millis / ISO ts)
///
/// ### Example
/// ```dart
/// final ErrorItem e = SessionErrorItems.invalidCredentials;
/// final String reason = SessionErrorItems.getReason(e); // 'invalid_credentials'
///
/// // Map a provider error string to a standard ErrorItem:
/// final ErrorItem mapped = SessionErrorItems.fromReason('token_expired');
/// ```
///
/// Conventions:
/// - `code` fields use `AUTH_*`.
/// - `errorLevel` indicates UI handling as per [ErrorLevelEnum].
abstract class SessionErrorItems {
  /// Meta keys used across items.
  static const String reasonKey = 'reason';
  static const String providerKey = 'provider';
  static const String retryAfterSecondsKey = 'retryAfterSeconds';
  static const String lockUntilKey = 'lockUntil';
  static const String scopeKey = 'scope';

  /// Reads the `reason` from an [ErrorItem]'s meta, or returns '' if missing.
  static String getReason(ErrorItem error) {
    final dynamic v = error.meta[reasonKey];
    return v is String ? v : '';
  }

  /// Returns a standard [ErrorItem] given a machine-friendly reason.
  /// Unknown reasons map to [unknown].
  static ErrorItem fromReason(String reason) {
    switch (reason.trim().toLowerCase()) {
      case 'invalid_credentials':
        return invalidCredentials;
      case 'invalid_email':
        return invalidEmailFormat;
      case 'user_not_found':
        return userNotFound;
      case 'email_already_in_use':
        return emailAlreadyInUse;
      case 'weak_password':
        return weakPassword;
      case 'account_disabled':
        return accountDisabled;
      case 'account_locked':
        return accountLocked;
      case 'mfa_required':
        return mfaRequired;
      case 'mfa_invalid_code':
        return mfaInvalidCode;
      case 'not_signed_in':
        return notSignedIn;
      case 'sign_in_required':
        return signInRequired;
      case 'permission_denied':
        return permissionDenied;
      case 'token_expired':
        return tokenExpired;
      case 'token_invalid':
        return tokenInvalid;
      case 'token_revoked':
        return tokenRevoked;
      case 'refresh_failed':
        return refreshFailed;
      case 'provider_cancelled':
        return providerCancelled;
      case 'account_exists_with_different_credential':
        return accountExistsWithDifferentCredential;
      case 'rate_limited':
        return rateLimited;
      case 'network_unavailable':
        return networkUnavailable;
      case 'timeout':
        return timeout;
      case 'operation_cancelled':
        return operationCancelled;
      case 'service_unavailable':
        return serviceUnavailable;
      default:
        return unknown.copyWith(
          meta: <String, dynamic>{...unknown.meta, reasonKey: reason},
        );
    }
  }

  // ---------- Core auth/user errors ----------

  static const ErrorItem invalidCredentials = ErrorItem(
    title: 'Invalid credentials',
    code: 'AUTH_INVALID_CREDENTIALS',
    description: 'The provided email/password are incorrect.',
    errorLevel: ErrorLevelEnum.warning,
    meta: <String, dynamic>{reasonKey: 'invalid_credentials'},
  );

  static const ErrorItem invalidEmailFormat = ErrorItem(
    title: 'Invalid email',
    code: 'AUTH_INVALID_EMAIL',
    description: 'The email format is invalid.',
    errorLevel: ErrorLevelEnum.warning,
    meta: <String, dynamic>{reasonKey: 'invalid_email'},
  );

  static const ErrorItem userNotFound = ErrorItem(
    title: 'User not found',
    code: 'AUTH_USER_NOT_FOUND',
    description: 'No user corresponds to the provided identifier.',
    errorLevel: ErrorLevelEnum.warning,
    meta: <String, dynamic>{reasonKey: 'user_not_found'},
  );

  static const ErrorItem emailAlreadyInUse = ErrorItem(
    title: 'Email already in use',
    code: 'AUTH_EMAIL_ALREADY_IN_USE',
    description:
        'The email address is already associated with another account.',
    errorLevel: ErrorLevelEnum.warning,
    meta: <String, dynamic>{reasonKey: 'email_already_in_use'},
  );

  static const ErrorItem weakPassword = ErrorItem(
    title: 'Weak password',
    code: 'AUTH_WEAK_PASSWORD',
    description: 'The chosen password does not meet security requirements.',
    errorLevel: ErrorLevelEnum.warning,
    meta: <String, dynamic>{reasonKey: 'weak_password'},
  );

  static const ErrorItem accountDisabled = ErrorItem(
    title: 'Account disabled',
    code: 'AUTH_ACCOUNT_DISABLED',
    description: 'This account has been disabled by an administrator.',
    errorLevel: ErrorLevelEnum.severe,
    meta: <String, dynamic>{reasonKey: 'account_disabled'},
  );

  static const ErrorItem accountLocked = ErrorItem(
    title: 'Account locked',
    code: 'AUTH_ACCOUNT_LOCKED',
    description: 'Too many failed attempts. The account is temporarily locked.',
    errorLevel: ErrorLevelEnum.severe,
    meta: <String, dynamic>{reasonKey: 'account_locked'},
  );

  static const ErrorItem mfaRequired = ErrorItem(
    title: 'Multi-factor required',
    code: 'AUTH_MFA_REQUIRED',
    description: 'Additional verification is required to complete the sign-in.',
    errorLevel: ErrorLevelEnum.severe,
    meta: <String, dynamic>{reasonKey: 'mfa_required'},
  );

  static const ErrorItem mfaInvalidCode = ErrorItem(
    title: 'Invalid verification code',
    code: 'AUTH_MFA_INVALID_CODE',
    description: 'The provided verification code is invalid or expired.',
    errorLevel: ErrorLevelEnum.warning,
    meta: <String, dynamic>{reasonKey: 'mfa_invalid_code'},
  );

  static const ErrorItem notSignedIn = ErrorItem(
    title: 'Not signed in',
    code: 'AUTH_NOT_SIGNED_IN',
    description: 'No active session was found.',
    errorLevel: ErrorLevelEnum.warning,
    meta: <String, dynamic>{reasonKey: 'not_signed_in'},
  );

  static const ErrorItem signInRequired = ErrorItem(
    title: 'Sign-in required',
    code: 'AUTH_SIGN_IN_REQUIRED',
    description: 'This operation requires an authenticated user.',
    errorLevel: ErrorLevelEnum.warning,
    meta: <String, dynamic>{reasonKey: 'sign_in_required'},
  );

  static const ErrorItem permissionDenied = ErrorItem(
    title: 'Permission denied',
    code: 'AUTH_PERMISSION_DENIED',
    description: 'You lack the required permissions or scopes.',
    errorLevel: ErrorLevelEnum.severe,
    meta: <String, dynamic>{reasonKey: 'permission_denied'},
  );

  // ---------- Token/session lifecycle ----------

  static const ErrorItem tokenExpired = ErrorItem(
    title: 'Session expired',
    code: 'AUTH_TOKEN_EXPIRED',
    description: 'Your session has expired. Please sign in again.',
    errorLevel: ErrorLevelEnum.warning,
    meta: <String, dynamic>{reasonKey: 'token_expired'},
  );

  static const ErrorItem tokenInvalid = ErrorItem(
    title: 'Invalid token',
    code: 'AUTH_TOKEN_INVALID',
    description: 'The token is malformed or not valid for this resource.',
    errorLevel: ErrorLevelEnum.severe,
    meta: <String, dynamic>{reasonKey: 'token_invalid'},
  );

  static const ErrorItem tokenRevoked = ErrorItem(
    title: 'Token revoked',
    code: 'AUTH_TOKEN_REVOKED',
    description: 'Access token has been revoked.',
    errorLevel: ErrorLevelEnum.severe,
    meta: <String, dynamic>{reasonKey: 'token_revoked'},
  );

  static const ErrorItem refreshFailed = ErrorItem(
    title: 'Refresh failed',
    code: 'AUTH_REFRESH_FAILED',
    description: 'The session could not be refreshed.',
    errorLevel: ErrorLevelEnum.severe,
    meta: <String, dynamic>{reasonKey: 'refresh_failed'},
  );

  // ---------- Federated identity / providers ----------

  static const ErrorItem providerCancelled = ErrorItem(
    title: 'Sign-in cancelled',
    code: 'AUTH_PROVIDER_CANCELLED',
    description: 'The provider sign-in flow was cancelled.',
    errorLevel: ErrorLevelEnum.warning,
    meta: <String, dynamic>{reasonKey: 'provider_cancelled'},
  );

  static const ErrorItem accountExistsWithDifferentCredential = ErrorItem(
    title: 'Account exists with different credential',
    code: 'AUTH_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL',
    description:
        'An account already exists with the same email but different sign-in credentials.',
    errorLevel: ErrorLevelEnum.severe,
    meta: <String, dynamic>{
      reasonKey: 'account_exists_with_different_credential',
    },
  );

  // ---------- Transport / availability ----------

  static const ErrorItem rateLimited = ErrorItem(
    title: 'Too many attempts',
    code: 'AUTH_RATE_LIMITED',
    description: 'Too many attempts. Please try again later.',
    errorLevel: ErrorLevelEnum.severe,
    meta: <String, dynamic>{reasonKey: 'rate_limited'},
  );

  static const ErrorItem networkUnavailable = ErrorItem(
    title: 'Network unavailable',
    code: 'AUTH_NETWORK_UNAVAILABLE',
    description: 'No internet connection is available.',
    errorLevel: ErrorLevelEnum.warning,
    meta: <String, dynamic>{reasonKey: 'network_unavailable'},
  );

  static const ErrorItem timeout = ErrorItem(
    title: 'Timeout',
    code: 'AUTH_TIMEOUT',
    description: 'The operation timed out.',
    errorLevel: ErrorLevelEnum.warning,
    meta: <String, dynamic>{reasonKey: 'timeout'},
  );

  static const ErrorItem operationCancelled = ErrorItem(
    title: 'Operation cancelled',
    code: 'AUTH_OPERATION_CANCELLED',
    description: 'The operation was cancelled before completion.',
    errorLevel: ErrorLevelEnum.warning,
    meta: <String, dynamic>{reasonKey: 'operation_cancelled'},
  );

  static const ErrorItem serviceUnavailable = ErrorItem(
    title: 'Service unavailable',
    code: 'AUTH_SERVICE_UNAVAILABLE',
    description: 'The authentication service is temporarily unavailable.',
    errorLevel: ErrorLevelEnum.danger,
    meta: <String, dynamic>{reasonKey: 'service_unavailable'},
  );

  // ---------- Fallback ----------

  static const ErrorItem unknown = ErrorItem(
    title: 'Unknown auth error',
    code: 'AUTH_UNKNOWN',
    description: 'An unknown authentication error has occurred.',
    meta: <String, dynamic>{reasonKey: 'unknown'},
  );

  /// Returns a new [ErrorItem] with provider-related metadata merged into [base].
  ///
  /// This helper preserves existing metadata and only adds/overrides the keys:
  /// - [providerKey]           → e.g. 'firebase', 'oauth_google'
  /// - [retryAfterSecondsKey]  → number of seconds to back off
  /// - [scopeKey]              → affected permission scope (e.g. 'email', 'profile')
  /// - [lockUntilKey]          → Date/time or raw value indicating lock expiration
  ///
  /// If [lockUntil] is a [DateTime], it is serialized to UTC ISO-8601.
  ///
  /// ### Example
  /// ```dart
  /// final ErrorItem base = SessionErrorItems.rateLimited;
  /// final ErrorItem decorated = SessionErrorItems.mergeProviderMeta(
  ///   base,
  ///   provider: 'oauth_google',
  ///   retryAfterSeconds: 60,
  ///   scope: 'profile',
  ///   lockUntil: DateTime.now().add(const Duration(minutes: 5)),
  /// );
  /// // decorated.meta contains provider/scope/retryAfterSeconds/lockUntil
  /// ```
  static ErrorItem mergeProviderMeta(
    ErrorItem base, {
    String? provider,
    int? retryAfterSeconds,
    String? scope,
    Object? lockUntil,
  }) {
    final Map<String, dynamic> meta = Map<String, dynamic>.from(base.meta);

    if (provider != null && provider.isNotEmpty) {
      meta[providerKey] = provider;
    }
    if (retryAfterSeconds != null) {
      meta[retryAfterSecondsKey] = retryAfterSeconds;
    }
    if (scope != null && scope.isNotEmpty) {
      meta[scopeKey] = scope;
    }
    if (lockUntil != null) {
      if (lockUntil is DateTime) {
        meta[lockUntilKey] = lockUntil.toUtc().toIso8601String();
      } else if (lockUntil is num || lockUntil is String) {
        meta[lockUntilKey] = lockUntil;
      } else {
        meta[lockUntilKey] = lockUntil.toString();
      }
    }

    return base.copyWith(meta: meta);
  }
}
