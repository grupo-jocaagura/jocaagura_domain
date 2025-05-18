import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('NetworkErrorItems', () {
    test('noInternet has expected properties', () {
      const ErrorItem error = NetworkErrorItems.noInternet;
      expect(error.title, 'No Internet Connection');
      expect(error.code, 'NET_NO_INTERNET');
      expect(error.description, 'You are currently offline.');
      expect(
        error.meta[NetworkErrorItems.sourceKey],
        NetworkErrorItems.sourceValue,
      );
      expect(error.errorLevel, ErrorLevelEnum.danger);
    });

    test('timeout has expected properties', () {
      const ErrorItem error = NetworkErrorItems.timeout;
      expect(error.title, 'Network Timeout');
      expect(error.code, 'NET_TIMEOUT');
      expect(error.description, 'The request took too long to complete.');
      expect(
        error.meta[NetworkErrorItems.sourceKey],
        NetworkErrorItems.sourceValue,
      );
      expect(error.errorLevel, ErrorLevelEnum.warning);
    });

    test('unreachable has expected properties', () {
      const ErrorItem error = NetworkErrorItems.unreachable;
      expect(error.title, 'Server Unreachable');
      expect(error.code, 'NET_UNREACHABLE');
      expect(error.description, 'Unable to reach the server.');
      expect(
        error.meta[NetworkErrorItems.sourceKey],
        NetworkErrorItems.sourceValue,
      );
      expect(error.errorLevel, ErrorLevelEnum.severe);
    });

    test('unknown returns default systemInfo error', () {
      final ErrorItem error = NetworkErrorItems.unknown();
      expect(error.title, 'Unknown Network Error');
      expect(error.code, 'NET_UNKNOWN');
      expect(error.description, 'An unknown network error has occurred.');
      expect(
        error.meta[NetworkErrorItems.sourceKey],
        NetworkErrorItems.sourceValue,
      );
      expect(error.errorLevel, ErrorLevelEnum.systemInfo);
    });

    test('unknown returns custom description if provided', () {
      final ErrorItem error = NetworkErrorItems.unknown('Custom message');
      expect(error.description, 'Custom message');
    });

    test('fromCode returns defined errors', () {
      expect(
        NetworkErrorItems.fromCode('NET_NO_INTERNET'),
        NetworkErrorItems.noInternet,
      );
      expect(
        NetworkErrorItems.fromCode('NET_TIMEOUT'),
        NetworkErrorItems.timeout,
      );
      expect(
        NetworkErrorItems.fromCode('NET_UNREACHABLE'),
        NetworkErrorItems.unreachable,
      );
    });

    test('fromCode returns unknown if code is unrecognized', () {
      final ErrorItem error = NetworkErrorItems.fromCode('NET_SOMETHING_NEW');
      expect(error.code, 'NET_UNKNOWN');
      expect(error.description, contains('NET_SOMETHING_NEW'));
    });
  });
}
