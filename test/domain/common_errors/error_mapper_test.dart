import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('DefaultErrorMapper.fromPayload uncovered branches', () {
    test(
        'Given top-level code and description without message When fromPayload is called Then maps payload error using description branch',
        () {
      const DefaultErrorMapper mapper = DefaultErrorMapper();

      final ErrorItem? result = mapper.fromPayload(
        <String, dynamic>{
          'code': 'BUSINESS_RULE_FAILED',
          'description': 'The business rule was not satisfied.',
        },
        location: 'business-rule-gateway',
      );

      expect(result, isNotNull);
      expect(result!.title, 'Operation failed');
      expect(result.code, 'BUSINESS_RULE_FAILED');
      expect(result.description, 'The business rule was not satisfied.');
      expect(result.meta['location'], 'business-rule-gateway');
    });

    test(
        'Given success false payload without code When fromPayload is called Then uses payload fallback code',
        () {
      const DefaultErrorMapper mapper = DefaultErrorMapper();

      final ErrorItem? result = mapper.fromPayload(
        <String, dynamic>{
          'success': false,
          'title': 'Provider rejected operation',
          'message': 'The provider rejected the request.',
        },
        location: 'provider-gateway',
      );

      expect(result, isNotNull);
      expect(result!.title, 'Provider rejected operation');
      expect(result.code, 'ERR_PAYLOAD');
      expect(result.description, 'The provider rejected the request.');
      expect(result.meta['location'], 'provider-gateway');
    });

    test(
        'Given nested error with title When fromPayload is called Then keeps explicit title',
        () {
      const DefaultErrorMapper mapper = DefaultErrorMapper();

      final ErrorItem? result = mapper.fromPayload(
        <String, dynamic>{
          'error': <String, dynamic>{
            'title': 'Custom mapped title',
            'code': 'CUSTOM_ERROR',
            'description': 'Custom mapped description.',
          },
        },
        location: 'nested-error-gateway',
      );

      expect(result, isNotNull);
      expect(result!.title, 'Custom mapped title');
      expect(result.code, 'CUSTOM_ERROR');
      expect(result.description, 'Custom mapped description.');
      expect(result.meta['location'], 'nested-error-gateway');
    });
  });
}
