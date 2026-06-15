import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

class _CustomLockValue {
  const _CustomLockValue();

  @override
  String toString() => 'custom-lock-value';
}

void main() {
  group('SessionErrorItems.getReason', () {
    test(
        'Given ErrorItem with string reason When getReason is called Then returns reason',
        () {
      const ErrorItem error = SessionErrorItems.invalidCredentials;

      final String reason = SessionErrorItems.getReason(error);

      expect(reason, 'invalid_credentials');
    });

    test(
        'Given ErrorItem without reason When getReason is called Then returns empty string',
        () {
      const ErrorItem error = ErrorItem(
        title: 'Custom error',
        code: 'CUSTOM_ERROR',
        description: 'Custom description.',
      );

      final String reason = SessionErrorItems.getReason(error);

      expect(reason, '');
    });

    test(
        'Given ErrorItem with non-string reason When getReason is called Then returns empty string',
        () {
      const ErrorItem error = ErrorItem(
        title: 'Custom error',
        code: 'CUSTOM_ERROR',
        description: 'Custom description.',
        meta: <String, dynamic>{SessionErrorItems.reasonKey: 404},
      );

      final String reason = SessionErrorItems.getReason(error);

      expect(reason, '');
    });
  });

  group('SessionErrorItems.fromReason', () {
    test(
        'Given known reason When fromReason is called Then returns matching auth error',
        () {
      final Map<String, ErrorItem> expectedItems = <String, ErrorItem>{
        'invalid_credentials': SessionErrorItems.invalidCredentials,
        'invalid_email': SessionErrorItems.invalidEmailFormat,
        'user_not_found': SessionErrorItems.userNotFound,
        'email_already_in_use': SessionErrorItems.emailAlreadyInUse,
        'weak_password': SessionErrorItems.weakPassword,
        'account_disabled': SessionErrorItems.accountDisabled,
        'account_locked': SessionErrorItems.accountLocked,
        'mfa_required': SessionErrorItems.mfaRequired,
        'mfa_invalid_code': SessionErrorItems.mfaInvalidCode,
        'not_signed_in': SessionErrorItems.notSignedIn,
        'sign_in_required': SessionErrorItems.signInRequired,
        'permission_denied': SessionErrorItems.permissionDenied,
        'token_expired': SessionErrorItems.tokenExpired,
        'token_invalid': SessionErrorItems.tokenInvalid,
        'token_revoked': SessionErrorItems.tokenRevoked,
        'refresh_failed': SessionErrorItems.refreshFailed,
        'provider_cancelled': SessionErrorItems.providerCancelled,
        'account_exists_with_different_credential':
            SessionErrorItems.accountExistsWithDifferentCredential,
        'rate_limited': SessionErrorItems.rateLimited,
        'network_unavailable': SessionErrorItems.networkUnavailable,
        'timeout': SessionErrorItems.timeout,
        'operation_cancelled': SessionErrorItems.operationCancelled,
        'service_unavailable': SessionErrorItems.serviceUnavailable,
      };

      for (final MapEntry<String, ErrorItem> entry in expectedItems.entries) {
        final ErrorItem result = SessionErrorItems.fromReason(entry.key);

        expect(result.code, entry.value.code);
        expect(SessionErrorItems.getReason(result), entry.key);
      }
    });

    test(
        'Given known reason with spaces and uppercase When fromReason is called Then normalizes reason',
        () {
      final ErrorItem result = SessionErrorItems.fromReason(' TOKEN_EXPIRED ');

      expect(result.code, SessionErrorItems.tokenExpired.code);
      expect(SessionErrorItems.getReason(result), 'token_expired');
    });

    test(
        'Given unknown reason When fromReason is called Then returns unknown error preserving original reason',
        () {
      final ErrorItem result =
          SessionErrorItems.fromReason('custom_provider_error');

      expect(result.code, SessionErrorItems.unknown.code);
      expect(result.title, SessionErrorItems.unknown.title);
      expect(SessionErrorItems.getReason(result), 'custom_provider_error');
    });
  });

  group('SessionErrorItems.mergeProviderMeta', () {
    test(
        'Given provider metadata When mergeProviderMeta is called Then merges values preserving base reason',
        () {
      final DateTime lockUntil = DateTime.utc(2026, 6, 15, 10, 30);

      final ErrorItem result = SessionErrorItems.mergeProviderMeta(
        SessionErrorItems.rateLimited,
        provider: 'firebase',
        retryAfterSeconds: 60,
        scope: 'email',
        lockUntil: lockUntil,
      );

      expect(result.code, SessionErrorItems.rateLimited.code);
      expect(SessionErrorItems.getReason(result), 'rate_limited');
      expect(result.meta[SessionErrorItems.providerKey], 'firebase');
      expect(result.meta[SessionErrorItems.retryAfterSecondsKey], 60);
      expect(result.meta[SessionErrorItems.scopeKey], 'email');
      expect(
        result.meta[SessionErrorItems.lockUntilKey],
        '2026-06-15T10:30:00.000Z',
      );
    });

    test(
        'Given null and empty metadata When mergeProviderMeta is called Then does not add optional keys',
        () {
      final ErrorItem result = SessionErrorItems.mergeProviderMeta(
        SessionErrorItems.permissionDenied,
        provider: '',
        scope: '',
      );

      expect(result.code, SessionErrorItems.permissionDenied.code);
      expect(SessionErrorItems.getReason(result), 'permission_denied');
      expect(result.meta.containsKey(SessionErrorItems.providerKey), false);
      expect(
        result.meta.containsKey(SessionErrorItems.retryAfterSecondsKey),
        false,
      );
      expect(result.meta.containsKey(SessionErrorItems.scopeKey), false);
      expect(result.meta.containsKey(SessionErrorItems.lockUntilKey), false);
    });

    test(
        'Given numeric lockUntil When mergeProviderMeta is called Then keeps numeric value',
        () {
      final ErrorItem result = SessionErrorItems.mergeProviderMeta(
        SessionErrorItems.accountLocked,
        lockUntil: 1781519400000,
      );

      expect(result.meta[SessionErrorItems.lockUntilKey], 1781519400000);
    });

    test(
        'Given string lockUntil When mergeProviderMeta is called Then keeps string value',
        () {
      final ErrorItem result = SessionErrorItems.mergeProviderMeta(
        SessionErrorItems.accountLocked,
        lockUntil: '2026-06-15T10:30:00.000Z',
      );

      expect(
        result.meta[SessionErrorItems.lockUntilKey],
        '2026-06-15T10:30:00.000Z',
      );
    });

    test(
        'Given custom lockUntil object When mergeProviderMeta is called Then stores string representation',
        () {
      final ErrorItem result = SessionErrorItems.mergeProviderMeta(
        SessionErrorItems.accountLocked,
        lockUntil: const _CustomLockValue(),
      );

      expect(
        result.meta[SessionErrorItems.lockUntilKey],
        'custom-lock-value',
      );
    });
  });
}
