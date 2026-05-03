import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelAclPlan', () {
    const ModelAclPlan plan = ModelAclPlan(
      id: 'acl_plan_bienvenido_operator_v1',
      name: 'BienvenidoOperatorDefaults',
      description:
          'Default access bundle for regular operators in the Bienvenido app.',
      appName: 'bienvenido',
      acls: <ModelAcl>[
        ModelAcl(
          id: 'acl_bienvenido_dashboard_operator',
          roleType: RoleType.viewer,
          appName: 'bienvenido',
          feature: 'dashboard',
          email: 'template@jocaagura.dev',
          isActive: true,
          emailAutorizedBy: 'admin@jocaagura.dev',
          autorizedAtIsoDate: '2026-03-20T10:00:00.000Z',
          note: 'Default dashboard access for operator plan.',
        ),
        ModelAcl(
          id: 'acl_bienvenido_profile_operator',
          roleType: RoleType.editor,
          appName: 'bienvenido',
          feature: 'profile',
          email: 'template@jocaagura.dev',
          isActive: true,
          emailAutorizedBy: 'admin@jocaagura.dev',
          autorizedAtIsoDate: '2026-03-20T10:00:00.000Z',
          note: 'Default profile update access for operator plan.',
        ),
      ],
    );

    test(
      'Given a canonical ACL plan When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = plan.toJson();
        final ModelAclPlan roundtrip = ModelAclPlan.fromJson(json);

        expect(roundtrip, plan);
        expect(roundtrip.toJson(), plan.toJson());
      },
    );

    test(
      'Given canonical JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = plan.toJson();

        final ModelAclPlan parsed = ModelAclPlan.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given an ACL plan When copyWith overrides fields Then returns updated copy',
      () {
        final ModelAclPlan copy = plan.copyWith(
          name: 'BienvenidoEditors',
          description: null,
        );

        expect(copy.name, 'BienvenidoEditors');
        expect(copy.description, isNull);
        expect(copy, isNot(plan));
      },
    );
  });
}
