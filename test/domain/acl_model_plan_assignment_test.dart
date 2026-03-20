import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelAclPlanAssignment', () {
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

    const UserModel targetUser = UserModel(
      id: 'user_201',
      displayName: 'Camila Operator',
      photoUrl: 'https://example.com/users/camila.jpg',
      email: 'camila.operator@example.com',
      jwt: <String, dynamic>{'token': 'user-plan-001', 'exp': 1773984000},
    );

    const UserModel assignedBy = UserModel(
      id: 'user_admin_001',
      displayName: 'Ana Admin',
      photoUrl: 'https://example.com/users/ana-admin.jpg',
      email: 'ana.admin@example.com',
      jwt: <String, dynamic>{'token': 'admin-plan-001', 'exp': 1773984000},
    );

    final ModelAclPlanAssignment assignment = ModelAclPlanAssignment(
      id: 'acl_assignment_bienvenido_operator_001',
      plan: plan,
      targetUser: targetUser,
      assignedAt: DateTime.utc(2026, 3, 20, 11, 30),
      assignedBy: assignedBy,
      notes: 'Default operator ACL plan seeded during onboarding.',
    );

    test(
      'Given a canonical ACL plan assignment When toJson and fromJson Then preserves the contract',
      () {
        final Map<String, dynamic> json = assignment.toJson();
        final ModelAclPlanAssignment roundtrip =
            ModelAclPlanAssignment.fromJson(json);

        expect(roundtrip, assignment);
        expect(roundtrip.toJson(), assignment.toJson());
      },
    );

    test(
      'Given current Dart JSON When fromJson and toJson Then preserves JSON roundtrip',
      () {
        final Map<String, dynamic> json = assignment.toJson();

        final ModelAclPlanAssignment parsed =
            ModelAclPlanAssignment.fromJson(json);

        expect(parsed.toJson(), json);
      },
    );

    test(
      'Given an ACL plan assignment When copyWith overrides fields Then returns updated copy',
      () {
        final ModelAclPlanAssignment copy = assignment.copyWith(
          notes: null,
          assignedBy: null,
        );

        expect(copy.notes, isNull);
        expect(copy.assignedBy, isNull);
        expect(copy, isNot(assignment));
      },
    );
  });
}
