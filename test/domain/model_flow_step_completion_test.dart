import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelFlowStepCompletion', () {
    final DateTime completedAt = DateTime.utc(2026, 3, 15, 14);

    final ModelFlowStepCompletion completion = ModelFlowStepCompletion(
      stepIndex: 10,
      completedAt: completedAt,
      evidenceUrl:
          'https://workspace.jocaagura.dev/evidence/onboarding/step-10',
      notes: 'Repositorio clonado y dependencias instaladas.',
    );

    test(
      'Given a canonical completion When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = completion.toJson();
        final ModelFlowStepCompletion roundtrip =
            ModelFlowStepCompletion.fromJson(json);

        expect(roundtrip, completion);
        expect(roundtrip.toJson(), completion.toJson());
      },
    );

    test(
      'Given canonical JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelFlowStepCompletionEnum.stepIndex.name: 10,
          ModelFlowStepCompletionEnum.completedAt.name:
              DateUtils.dateTimeToString(completedAt),
          ModelFlowStepCompletionEnum.evidenceUrl.name:
              'https://workspace.jocaagura.dev/evidence/onboarding/step-10',
          ModelFlowStepCompletionEnum.notes.name:
              'Repositorio clonado y dependencias instaladas.',
        };

        final ModelFlowStepCompletion parsed =
            ModelFlowStepCompletion.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given a completion When copyWith overrides fields Then returns updated copy',
      () {
        final ModelFlowStepCompletion copy = completion.copyWith(
          stepIndex: 20,
          notes: 'Dependencias instaladas correctamente.',
        );

        expect(copy.stepIndex, 20);
        expect(copy.notes, 'Dependencias instaladas correctamente.');
        expect(copy.evidenceUrl, completion.evidenceUrl);
        expect(copy, isNot(completion));
      },
    );
  });
}
