import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelAiMessage', () {
    const ModelAiMessage message = ModelAiMessage(
      role: ModelAiMessageRoleEnum.user,
      content: 'Resume la arquitectura en tres puntos.',
    );

    test(
      'Given a canonical message When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = message.toJson();
        final ModelAiMessage roundtrip = ModelAiMessage.fromJson(json);

        expect(roundtrip, message);
        expect(roundtrip.toJson(), message.toJson());
      },
    );

    test(
      'Given canonical JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelAiMessageEnum.role.name: 'assistant',
          ModelAiMessageEnum.content.name:
              'El dominio prioriza contratos JSON canonicos.',
        };

        final ModelAiMessage parsed = ModelAiMessage.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given a message When copyWith overrides fields Then returns updated copy',
      () {
        final ModelAiMessage copy = message.copyWith(
          role: ModelAiMessageRoleEnum.assistant,
          content: 'El dominio prioriza interoperabilidad.',
        );

        expect(copy.role, ModelAiMessageRoleEnum.assistant);
        expect(copy.content, 'El dominio prioriza interoperabilidad.');
        expect(copy, isNot(message));
      },
    );
  });
}
