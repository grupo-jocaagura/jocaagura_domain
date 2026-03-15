import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelAiRequest', () {
    final ModelJsonSchemaDocument expectedSchema = ModelJsonSchemaDocument(
      id: 'schema_ai_domain_summary_v1',
      schemaId:
          'https://jocaagura.dev/schemas/jocaagura_domain/v1/domain_summary_response.schema.json',
      schemaTitle: 'DomainSummaryResponse',
      domainModel: 'DomainSummaryResponse',
      version: 'v1',
      schemaDescription: 'Structured summary response expected from the model.',
      schema: const <String, dynamic>{
        r'$schema': 'https://json-schema.org/draft/2020-12/schema',
        r'$id':
            'https://jocaagura.dev/schemas/jocaagura_domain/v1/domain_summary_response.schema.json',
        'title': 'DomainSummaryResponse',
        'description': 'Structured summary response expected from the model.',
        'type': 'object',
        'additionalProperties': false,
        'properties': <String, dynamic>{
          'summary': <String, dynamic>{'type': 'string'},
          'highlights': <String, dynamic>{
            'type': 'array',
            'items': <String, dynamic>{'type': 'string'},
          },
        },
        'required': <String>['summary', 'highlights'],
      },
      example: const <String, dynamic>{
        'summary':
            'El dominio prioriza interoperabilidad y contratos JSON canonicos.',
        'highlights': <String>[
          'Schemas versionados en v1',
          'Roundtrip JSON en modelos Dart',
          'Base agnostica para backend y Apps Script',
        ],
      },
      tags: const <String>['ai', 'response'],
      createdAt: DateTime.parse('2026-03-15T00:00:00.000Z'),
      updatedAt: DateTime.parse('2026-03-15T00:00:00.000Z'),
      isActive: true,
    );

    final ModelAiRequest request = ModelAiRequest(
      id: 'ai_req_customer_summary_001',
      provider: 'gemini',
      modelId: 'gemini-2.5-pro',
      taskType: ModelAiTaskTypeEnum.groundedTextGeneration,
      systemInstruction:
          'Responde solo con JSON valido y no agregues texto extra.',
      messages: const <ModelAiMessage>[
        ModelAiMessage(
          role: ModelAiMessageRoleEnum.user,
          content: 'Lee las referencias y resume los puntos clave del dominio.',
        ),
      ],
      references: const <String>['https://example.com/domain-overview'],
      executionConfig: const ModelAiExecutionConfig(
        temperature: 0,
        topP: 0.95,
        maxOutputTokens: 512,
        deterministicPreferred: true,
      ),
      expectedResponseSchema: expectedSchema,
    );

    test(
      'Given a canonical request When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = request.toJson();
        final ModelAiRequest roundtrip = ModelAiRequest.fromJson(json);

        expect(roundtrip, request);
        expect(roundtrip.toJson(), request.toJson());
      },
    );

    test(
      'Given canonical JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = request.toJson();

        final ModelAiRequest parsed = ModelAiRequest.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given a request When copyWith overrides fields Then returns updated copy',
      () {
        final ModelAiRequest copy = request.copyWith(
          provider: 'openai',
          modelId: 'gpt-5.4',
          taskType: ModelAiTaskTypeEnum.textGeneration,
          references: <String>['https://example.com/brief'],
        );

        expect(copy.provider, 'openai');
        expect(copy.modelId, 'gpt-5.4');
        expect(copy.taskType, ModelAiTaskTypeEnum.textGeneration);
        expect(copy.references, <String>['https://example.com/brief']);
        expect(copy, isNot(request));
      },
    );
  });
}
