import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelFlowCertificate', () {
    final DateTime createdAt = DateTime.utc(2026, 3, 15, 13, 30);
    final DateTime certifiedAt = DateTime.utc(2026, 3, 15, 15);

    final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
      name: 'TechnicalOnboarding',
      description: 'Linear onboarding checklist for new technical operators.',
      steps: <ModelFlowStep>[
        ModelFlowStep.immutable(
          index: 10,
          title: 'CloneRepository',
          description: 'Clone the main repository and verify local access.',
          failureCode: 'REPO_SETUP_FAILED',
          nextOnSuccessIndex: 20,
          nextOnFailureIndex: -1,
          constraints: const <String>['gitAccess'],
          cost: const <String, double>{'latencyMs': 300},
        ),
        ModelFlowStep.immutable(
          index: 20,
          title: 'InstallDependencies',
          description: 'Install project dependencies successfully.',
          failureCode: 'DEPENDENCY_SETUP_FAILED',
          nextOnSuccessIndex: 30,
          nextOnFailureIndex: -1,
          constraints: const <String>['flutterSdk'],
          cost: const <String, double>{'latencyMs': 1200},
        ),
        ModelFlowStep.immutable(
          index: 30,
          title: 'RunValidation',
          description: 'Execute mandatory validation commands of the flow.',
          failureCode: 'VALIDATION_FAILED',
          nextOnSuccessIndex: -1,
          nextOnFailureIndex: -1,
          cost: const <String, double>{'latencyMs': 500},
        ),
      ],
    );

    const UserModel candidate = UserModel(
      id: 'user_001',
      displayName: 'John Doe',
      photoUrl: 'https://example.com/profile.jpg',
      email: 'john.doe@example.com',
      jwt: <String, dynamic>{'token': 'abc123', 'exp': 1735689600},
    );

    const UserModel certifier = UserModel(
      id: 'user_100',
      displayName: 'Jane Certifier',
      photoUrl: 'https://example.com/certifier.jpg',
      email: 'jane.certifier@example.com',
      jwt: <String, dynamic>{'token': 'cert789', 'exp': 1735689600},
    );

    final ModelFlowCertificate certificate = ModelFlowCertificate(
      id: 'flow_cert_onboarding_001',
      certificateKey: 'CERT-ONBOARDING-001',
      flow: flow,
      candidate: candidate,
      candidateDisplayName: 'John Doe',
      createdAt: createdAt,
      stepCompletionsByIndex: <int, ModelFlowStepCompletion>{
        10: ModelFlowStepCompletion(
          stepIndex: 10,
          completedAt: DateTime.utc(2026, 3, 15, 14),
          evidenceUrl:
              'https://workspace.jocaagura.dev/evidence/onboarding/step-10',
          notes: 'Repositorio clonado y dependencias instaladas.',
        ),
        20: ModelFlowStepCompletion(
          stepIndex: 20,
          completedAt: DateTime.utc(2026, 3, 15, 14, 20),
        ),
        30: ModelFlowStepCompletion(
          stepIndex: 30,
          completedAt: DateTime.utc(2026, 3, 15, 14, 40),
        ),
      },
      state: ModelFlowCertificateStateEnum.certified,
      certifiedAt: certifiedAt,
      certifiedBy: certifier,
      certifierNotes:
          'Checklist validada secuencialmente y aprobada para cierre.',
    );

    test(
      'Given a certificate When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = certificate.toJson();
        final ModelFlowCertificate roundtrip =
            ModelFlowCertificate.fromJson(json);

        expect(roundtrip, certificate);
        expect(roundtrip.toJson(), certificate.toJson());
      },
    );

    test(
      'Given current Dart JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = certificate.toJson();

        final ModelFlowCertificate parsed = ModelFlowCertificate.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given a certificate When copyWith overrides fields Then returns updated copy',
      () {
        final ModelFlowCertificate copy = certificate.copyWith(
          certificateKey: 'CERT-ONBOARDING-002',
          state: ModelFlowCertificateStateEnum.readyForCertification,
          certifiedAt: null,
          certifiedBy: null,
          certifierNotes: null,
        );

        expect(copy.certificateKey, 'CERT-ONBOARDING-002');
        expect(copy.state, ModelFlowCertificateStateEnum.readyForCertification);
        expect(copy.certifiedAt, isNull);
        expect(copy.certifiedBy, isNull);
        expect(copy.certifierNotes, isNull);
        expect(copy, isNot(certificate));
      },
    );
  });
}
