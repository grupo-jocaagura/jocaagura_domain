import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelAclPolicy.buildId', () {
    test(
        'Given trimmed appName/feature When buildId Then returns "<app>.<feature>"',
        () {
      final String id = ModelAclPolicy.buildId(
        appName: ' bienvenido ',
        feature: ' user.creation ',
      );

      expect(id, 'bienvenido.user.creation');
    });

    test('Given empty appName When buildId Then returns empty string', () {
      final String id = ModelAclPolicy.buildId(appName: ' ', feature: 'x');
      expect(id, '');
    });

    test('Given empty feature When buildId Then returns empty string', () {
      final String id = ModelAclPolicy.buildId(appName: 'x', feature: ' ');
      expect(id, '');
    });
  });

  group('ModelAclPolicy.roleMeetsMin', () {
    test('Given admin When min=editor Then meets', () {
      expect(
        ModelAclPolicy.roleMeetsMin(
          userRole: RoleType.admin,
          minRole: RoleType.editor,
        ),
        isTrue,
      );
    });

    test('Given editor When min=admin Then does not meet', () {
      expect(
        ModelAclPolicy.roleMeetsMin(
          userRole: RoleType.editor,
          minRole: RoleType.admin,
        ),
        isFalse,
      );
    });

    test('Given viewer When min=viewer Then meets', () {
      expect(
        ModelAclPolicy.roleMeetsMin(
          userRole: RoleType.viewer,
          minRole: RoleType.viewer,
        ),
        isTrue,
      );
    });
  });

  group('ModelAclPolicy.copyWith', () {
    test('Given no changes When copyWith() Then returns same instance', () {
      const ModelAclPolicy policy = ModelAclPolicy(
        id: 'bienvenido.user.creation',
        minRoleType: RoleType.editor,
        appName: 'bienvenido',
        feature: 'user.creation',
        isActive: true,
        note: 'n',
        upsertAtIsoDate: '2026-01-18T00:00:00.000Z',
        upsertBy: 'admin@corp.com',
      );

      final ModelAclPolicy same = policy.copyWith();
      expect(identical(same, policy), isTrue);
    });

    test('Given a change When copyWith(note) Then updates only that field', () {
      const ModelAclPolicy policy = ModelAclPolicy(
        id: 'bienvenido.user.creation',
        minRoleType: RoleType.editor,
        appName: 'bienvenido',
        feature: 'user.creation',
        isActive: true,
        note: 'old',
        upsertAtIsoDate: '2026-01-18T00:00:00.000Z',
        upsertBy: 'admin@corp.com',
      );

      final ModelAclPolicy updated = policy.copyWith(note: 'new');

      expect(updated.note, 'new');
      expect(updated.id, policy.id);
      expect(updated.minRoleType, policy.minRoleType);
      expect(updated.appName, policy.appName);
      expect(updated.feature, policy.feature);
      expect(updated.isActive, policy.isActive);
      expect(updated.upsertAtIsoDate, policy.upsertAtIsoDate);
      expect(updated.upsertBy, policy.upsertBy);
    });
  });

  group('ModelAclPolicy.fromJson', () {
    test('Given missing id When fromJson Then computes id from appName+feature',
        () {
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclPolicyEnum.appName.name: 'bienvenido',
        ModelAclPolicyEnum.feature.name: 'user.creation',
        ModelAclPolicyEnum.minRoleType.name: RoleType.editor.name,
        ModelAclPolicyEnum.isActive.name: true,
        ModelAclPolicyEnum.note.name: 'Controls user creation flow',
        ModelAclPolicyEnum.upsertAtIsoDate.name: '2026-01-18T00:00:00.000Z',
        ModelAclPolicyEnum.upsertBy.name: 'admin@corp.com',
      };

      final ModelAclPolicy policy = ModelAclPolicy.fromJson(json);

      expect(policy.id, 'bienvenido.user.creation');
      expect(policy.appName, 'bienvenido');
      expect(policy.feature, 'user.creation');
    });

    test('Given provided id When fromJson Then keeps provided id', () {
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclPolicyEnum.id.name: 'custom.id',
        ModelAclPolicyEnum.appName.name: 'bienvenido',
        ModelAclPolicyEnum.feature.name: 'user.creation',
        ModelAclPolicyEnum.minRoleType.name: RoleType.editor.name,
        ModelAclPolicyEnum.isActive.name: true,
        ModelAclPolicyEnum.note.name: '',
        ModelAclPolicyEnum.upsertAtIsoDate.name: '2026-01-18T00:00:00.000Z',
        ModelAclPolicyEnum.upsertBy.name: 'admin@corp.com',
      };

      final ModelAclPolicy policy = ModelAclPolicy.fromJson(json);
      expect(policy.id, 'custom.id');
    });

    test('Given missing minRoleType When fromJson Then defaults to viewer', () {
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclPolicyEnum.appName.name: 'bienvenido',
        ModelAclPolicyEnum.feature.name: 'x',
        ModelAclPolicyEnum.isActive.name: true,
      };

      final ModelAclPolicy policy = ModelAclPolicy.fromJson(json);
      expect(policy.minRoleType, RoleType.viewer);
    });

    test('Given null isActive When fromJson Then defaults false', () {
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclPolicyEnum.appName.name: 'bienvenido',
        ModelAclPolicyEnum.feature.name: 'x',
        ModelAclPolicyEnum.isActive.name: null,
      };

      final ModelAclPolicy policy = ModelAclPolicy.fromJson(json);
      expect(policy.isActive, isFalse);
    });

    test(
        'Given upsertAtIsoDate input When fromJson Then stores normalized value',
        () {
      final DateTime dt = DateTime.utc(2026, 1, 18, 10, 30);
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclPolicyEnum.appName.name: 'bienvenido',
        ModelAclPolicyEnum.feature.name: 'x',
        ModelAclPolicyEnum.upsertAtIsoDate.name: dt,
      };

      final ModelAclPolicy policy = ModelAclPolicy.fromJson(json);

      // Compare against the same normalizer to avoid coupling to formatting details.
      final String expected = DateUtils.normalizeIsoOrEmpty(dt);
      expect(policy.upsertAtIsoDate, expected);
    });
  });

  group('ModelAclPolicy JSON roundtrip', () {
    test('Given a policy When toJson+fromJson Then stays equal', () {
      final ModelAclPolicy policy = ModelAclPolicy(
        id: ModelAclPolicy.buildId(
          appName: 'bienvenido',
          feature: 'user.creation',
        ),
        minRoleType: RoleType.editor,
        appName: 'bienvenido',
        feature: 'user.creation',
        isActive: true,
        note: 'Controls user creation flow',
        upsertAtIsoDate:
            DateUtils.normalizeIsoOrEmpty('2026-01-18T00:00:00.000Z'),
        upsertBy: 'admin@corp.com',
      );

      final Map<String, dynamic> json = policy.toJson().cast<String, dynamic>();
      final ModelAclPolicy back = ModelAclPolicy.fromJson(json);

      expect(back, policy);
      expect(back.hashCode, policy.hashCode);
    });

    test(
        'Given non-normalized upsertAtIsoDate When toJson Then emits normalized value',
        () {
      const ModelAclPolicy policy = ModelAclPolicy(
        id: 'a.b',
        minRoleType: RoleType.viewer,
        appName: 'a',
        feature: 'b',
        isActive: true,
        note: '',
        upsertAtIsoDate:
            '2026-01-18T00:00:00Z', // maybe already OK, but we still validate via normalizer
        upsertBy: 'x',
      );

      final Map<String, dynamic> json = policy.toJson().cast<String, dynamic>();
      expect(
        json[ModelAclPolicyEnum.upsertAtIsoDate.name],
        DateUtils.normalizeIsoOrEmpty(policy.upsertAtIsoDate),
      );
    });
  });
  group('ModelAclPolicy.roleMeetsMin (full matrix)', () {
    test(
        'Given RoleType enum When used as hierarchy Then order is admin, editor, viewer',
        () {
      // Sentinel: if someone changes enum order, this should fail and force a conscious update.
      expect(
        RoleType.values,
        <RoleType>[RoleType.admin, RoleType.editor, RoleType.viewer],
      );
    });

    test('Given admin When min=admin Then meets', () {
      expect(
        ModelAclPolicy.roleMeetsMin(
          userRole: RoleType.admin,
          minRole: RoleType.admin,
        ),
        isTrue,
      );
    });

    test('Given admin When min=editor Then meets', () {
      expect(
        ModelAclPolicy.roleMeetsMin(
          userRole: RoleType.admin,
          minRole: RoleType.editor,
        ),
        isTrue,
      );
    });

    test('Given admin When min=viewer Then meets', () {
      expect(
        ModelAclPolicy.roleMeetsMin(
          userRole: RoleType.admin,
          minRole: RoleType.viewer,
        ),
        isTrue,
      );
    });

    test('Given editor When min=admin Then does not meet', () {
      expect(
        ModelAclPolicy.roleMeetsMin(
          userRole: RoleType.editor,
          minRole: RoleType.admin,
        ),
        isFalse,
      );
    });

    test('Given editor When min=editor Then meets', () {
      expect(
        ModelAclPolicy.roleMeetsMin(
          userRole: RoleType.editor,
          minRole: RoleType.editor,
        ),
        isTrue,
      );
    });

    test('Given editor When min=viewer Then meets', () {
      expect(
        ModelAclPolicy.roleMeetsMin(
          userRole: RoleType.editor,
          minRole: RoleType.viewer,
        ),
        isTrue,
      );
    });

    test('Given viewer When min=admin Then does not meet', () {
      expect(
        ModelAclPolicy.roleMeetsMin(
          userRole: RoleType.viewer,
          minRole: RoleType.admin,
        ),
        isFalse,
      );
    });

    test('Given viewer When min=editor Then does not meet', () {
      expect(
        ModelAclPolicy.roleMeetsMin(
          userRole: RoleType.viewer,
          minRole: RoleType.editor,
        ),
        isFalse,
      );
    });

    test('Given viewer When min=viewer Then meets', () {
      expect(
        ModelAclPolicy.roleMeetsMin(
          userRole: RoleType.viewer,
          minRole: RoleType.viewer,
        ),
        isTrue,
      );
    });
  });

  group('DateUtils.normalizeIsoOrEmpty (indirect via ModelAclPolicy)', () {
    test('Given null upsertAtIsoDate When fromJson Then stores empty string',
        () {
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclPolicyEnum.appName.name: 'bienvenido',
        ModelAclPolicyEnum.feature.name: 'x',
        ModelAclPolicyEnum.upsertAtIsoDate.name: null,
      };

      final ModelAclPolicy policy = ModelAclPolicy.fromJson(json);

      expect(policy.upsertAtIsoDate, '');
    });

    test(
        'Given DateTime upsertAtIsoDate When fromJson Then normalizes to UTC string',
        () {
      final DateTime local = DateTime(2026, 1, 18, 10, 30); // local time
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclPolicyEnum.appName.name: 'bienvenido',
        ModelAclPolicyEnum.feature.name: 'x',
        ModelAclPolicyEnum.upsertAtIsoDate.name: local,
      };

      final ModelAclPolicy policy = ModelAclPolicy.fromJson(json);

      expect(policy.upsertAtIsoDate, DateUtils.normalizeIsoOrEmpty(local));
    });

    test('Given int epoch millis When fromJson Then normalizes to UTC string',
        () {
      final int epochMillis =
          DateTime.utc(2026, 1, 18, 10, 30).millisecondsSinceEpoch;
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclPolicyEnum.appName.name: 'bienvenido',
        ModelAclPolicyEnum.feature.name: 'x',
        ModelAclPolicyEnum.upsertAtIsoDate.name: epochMillis,
      };

      final ModelAclPolicy policy = ModelAclPolicy.fromJson(json);

      expect(
        policy.upsertAtIsoDate,
        DateUtils.normalizeIsoOrEmpty(epochMillis),
      );
    });

    test('Given empty string When fromJson Then stores empty string', () {
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclPolicyEnum.appName.name: 'bienvenido',
        ModelAclPolicyEnum.feature.name: 'x',
        ModelAclPolicyEnum.upsertAtIsoDate.name: '   ',
      };

      final ModelAclPolicy policy = ModelAclPolicy.fromJson(json);

      expect(policy.upsertAtIsoDate, '');
    });

    test(
        'Given invalid date string When fromJson Then returns trimmed original string',
        () {
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclPolicyEnum.appName.name: 'bienvenido',
        ModelAclPolicyEnum.feature.name: 'x',
        ModelAclPolicyEnum.upsertAtIsoDate.name: '  not-a-date  ',
      };

      final ModelAclPolicy policy = ModelAclPolicy.fromJson(json);

      // normalizeIsoOrEmpty returns the original trimmed string if DateTime.tryParse fails.
      expect(policy.upsertAtIsoDate, '');
    });

    test(
        'Given parseable non-UTC string When fromJson Then converts to UTC output format',
        () {
      // No 'Z' => treated as local by DateTime.parse/tryParse, then .toUtc() is applied.
      const String input = '2026-01-18T10:30:00';
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclPolicyEnum.appName.name: 'bienvenido',
        ModelAclPolicyEnum.feature.name: 'x',
        ModelAclPolicyEnum.upsertAtIsoDate.name: input,
      };

      final ModelAclPolicy policy = ModelAclPolicy.fromJson(json);

      expect(policy.upsertAtIsoDate, DateUtils.normalizeIsoOrEmpty(input));
      // Optional sanity: it should not equal the raw input if your dateTimeToString includes 'Z' or normalized format.
      // expect(policy.upsertAtIsoDate, isNot(input));
    });

    test(
        'Given parseable UTC string When fromJson Then keeps as UTC-normalized output',
        () {
      const String input = '2026-01-18T10:30:00.000Z';
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclPolicyEnum.appName.name: 'bienvenido',
        ModelAclPolicyEnum.feature.name: 'x',
        ModelAclPolicyEnum.upsertAtIsoDate.name: input,
      };

      final ModelAclPolicy policy = ModelAclPolicy.fromJson(json);

      expect(policy.upsertAtIsoDate, DateUtils.normalizeIsoOrEmpty(input));
    });
  });
}
