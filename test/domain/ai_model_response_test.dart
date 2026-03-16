import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelAiResponse', () {
    const ModelAiResponse response = ModelAiResponse(
      requestId: 'ai_req_customer_summary_001',
      provider: 'gemini',
      modelId: 'gemini-2.5-pro',
      content:
          '{"summary":"El dominio prioriza interoperabilidad y contratos JSON canonicos.","highlights":["Schemas versionados en v1","Roundtrip JSON en modelos Dart","Base agnostica para backend y Apps Script"]}',
      parsedJson: <String, dynamic>{
        'summary':
            'El dominio prioriza interoperabilidad y contratos JSON canonicos.',
        'highlights': <String>[
          'Schemas versionados en v1',
          'Roundtrip JSON en modelos Dart',
          'Base agnostica para backend y Apps Script',
        ],
      },
      finishReason: 'stop',
      usage: <String, dynamic>{
        'inputTokens': 312,
        'outputTokens': 97,
      },
    );

    test(
      'Given a canonical response When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = response.toJson();
        final ModelAiResponse roundtrip = ModelAiResponse.fromJson(json);

        expect(roundtrip, response);
        expect(roundtrip.toJson(), response.toJson());
      },
    );

    test(
      'Given canonical JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = response.toJson();

        final ModelAiResponse parsed = ModelAiResponse.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given a response When copyWith overrides fields Then returns updated copy',
      () {
        final ModelAiResponse copy = response.copyWith(
          provider: 'openai',
          modelId: 'gpt-5.4',
          finishReason: 'completed',
        );

        expect(copy.provider, 'openai');
        expect(copy.modelId, 'gpt-5.4');
        expect(copy.finishReason, 'completed');
        expect(copy, isNot(response));
      },
    );
  });
}
