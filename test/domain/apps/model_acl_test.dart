import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelAcl - constructor & immutability', () {
    test(
        'Given const constructor When created Then fields match and defaults are empty',
        () {
      // Arrange & Act
      const ModelAcl acl = ModelAcl(
        id: '1',
        roleType: RoleType.admin,
        appName: 'sat-p',
        feature: 'router',
        email: 'user@pragma.com.co',
        isActive: true,
        emailAutorizedBy: 'admin@pragma.com.co',
      );

      // Assert
      expect(acl.id, '1');
      expect(acl.roleType, RoleType.admin);
      expect(acl.appName, 'sat-p');
      expect(acl.feature, 'router');
      expect(acl.email, 'user@pragma.com.co');
      expect(acl.isActive, true);
      expect(acl.emailAutorizedBy, 'admin@pragma.com.co');
      expect(acl.autorizedAtIsoDate, '');
      expect(acl.revokedAtIsoDate, '');
      expect(acl.note, '');
    });
  });

  group('ModelAcl.fromJson - parsing & normalization', () {
    test(
        'Given full valid json When fromJson Then parses all fields and normalizes dates',
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclEnum.id.name: 'acl-1',
        ModelAclEnum.roleType.name: 'admin',
        ModelAclEnum.appName.name: 'sat-p',
        ModelAclEnum.feature.name: 'router',
        ModelAclEnum.email.name: 'user@pragma.com.co',
        ModelAclEnum.isActive.name: true,
        ModelAclEnum.emailAutorizedBy.name: 'admin@pragma.com.co',
        ModelAclEnum.autorizedAtIsoDate.name: '2026-01-03T00:00:00.000Z',
        ModelAclEnum.revokedAtIsoDate.name: '',
        ModelAclEnum.note.name: 'Seed',
        'unknownKey': 'ignored',
      };

      // Act
      final ModelAcl acl = ModelAcl.fromJson(json);

      // Assert
      expect(acl.id, 'acl-1');
      expect(acl.roleType, RoleType.admin);
      expect(acl.appName, 'sat-p');
      expect(acl.feature, 'router');
      expect(acl.email, 'user@pragma.com.co');
      expect(acl.isActive, true);
      expect(acl.emailAutorizedBy, 'admin@pragma.com.co');
      expect(acl.autorizedAtIsoDate, '2026-01-03T00:00:00.000Z');
      expect(acl.revokedAtIsoDate, '');
      expect(acl.note, 'Seed');
    });

    test('Given missing roleType When fromJson Then defaults to viewer', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclEnum.id.name: 'acl-2',
        ModelAclEnum.appName.name: 'sat-p',
        ModelAclEnum.feature.name: 'router',
        ModelAclEnum.email.name: 'user@pragma.com.co',
        ModelAclEnum.isActive.name: true,
        ModelAclEnum.emailAutorizedBy.name: 'admin@pragma.com.co',
        ModelAclEnum.autorizedAtIsoDate.name: '2026-01-03T00:00:00.000Z',
      };

      // Act
      final ModelAcl acl = ModelAcl.fromJson(json);

      // Assert
      expect(acl.roleType, RoleType.viewer);
    });

    test('Given invalid roleType When fromJson Then defaults to viewer', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclEnum.id.name: 'acl-3',
        ModelAclEnum.roleType.name: 'super-admin',
        ModelAclEnum.appName.name: 'sat-p',
        ModelAclEnum.feature.name: 'router',
        ModelAclEnum.email.name: 'user@pragma.com.co',
        ModelAclEnum.isActive.name: true,
        ModelAclEnum.emailAutorizedBy.name: 'admin@pragma.com.co',
        ModelAclEnum.autorizedAtIsoDate.name: '2026-01-03T00:00:00.000Z',
      };

      // Act
      final ModelAcl acl = ModelAcl.fromJson(json);

      // Assert
      expect(acl.roleType, RoleType.viewer);
    });

    test('Given int dates When fromJson Then normalizes to UTC ISO strings',
        () {
      // Arrange
      final DateTime utc = DateTime.utc(2026, 1, 3);
      final int ms = utc.millisecondsSinceEpoch;

      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclEnum.id.name: 'acl-4',
        ModelAclEnum.roleType.name: 'editor',
        ModelAclEnum.appName.name: 'sat-p',
        ModelAclEnum.feature.name: 'router',
        ModelAclEnum.email.name: 'user@pragma.com.co',
        ModelAclEnum.isActive.name: true,
        ModelAclEnum.emailAutorizedBy.name: 'admin@pragma.com.co',
        ModelAclEnum.autorizedAtIsoDate.name: ms,
        ModelAclEnum.revokedAtIsoDate.name: ms,
      };

      // Act
      final ModelAcl acl = ModelAcl.fromJson(json);

      // Assert
      expect(DateTime.parse(acl.autorizedAtIsoDate).toUtc(), utc);
      expect(DateTime.parse(acl.revokedAtIsoDate).toUtc(), utc);
    });

    test(
        'Given invalid autorizedAtIsoDate When fromJson Then keeps raw string and isValidAcl=false',
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclEnum.id.name: 'acl-5',
        ModelAclEnum.roleType.name: 'admin',
        ModelAclEnum.appName.name: 'sat-p',
        ModelAclEnum.feature.name: 'router',
        ModelAclEnum.email.name: 'user@pragma.com.co',
        ModelAclEnum.isActive.name: true,
        ModelAclEnum.emailAutorizedBy.name: 'admin@pragma.com.co',
        ModelAclEnum.autorizedAtIsoDate.name: 'not-a-date',
      };

      // Act
      final ModelAcl acl = ModelAcl.fromJson(json);

      // Assert
      expect(acl.autorizedAtIsoDate, 'not-a-date');
      expect(acl.isValidAcl, false);
      expect(acl.autorizedAtDateTime, isNull);
    });

    test(
        'Given empty revokedAtIsoDate When fromJson Then revokedAtDateTime is null',
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        ModelAclEnum.id.name: 'acl-6',
        ModelAclEnum.roleType.name: 'admin',
        ModelAclEnum.appName.name: 'sat-p',
        ModelAclEnum.feature.name: 'router',
        ModelAclEnum.email.name: 'user@pragma.com.co',
        ModelAclEnum.isActive.name: true,
        ModelAclEnum.emailAutorizedBy.name: 'admin@pragma.com.co',
        ModelAclEnum.autorizedAtIsoDate.name: '2026-01-03T00:00:00.000Z',
        ModelAclEnum.revokedAtIsoDate.name: '',
      };

      // Act
      final ModelAcl acl = ModelAcl.fromJson(json);

      // Assert
      expect(acl.revokedAtIsoDate, '');
      expect(acl.revokedAtDateTime, isNull);
    });
  });

  group('ModelAcl.toJson - roundtrip & normalization', () {
    test(
        'Given model When toJson Then keys match enum names and roleType serialized by name',
        () {
      // Arrange
      const ModelAcl acl = ModelAcl(
        id: 'acl-1',
        roleType: RoleType.editor,
        appName: 'sat-p',
        feature: 'router',
        email: 'user@pragma.com.co',
        isActive: true,
        emailAutorizedBy: 'admin@pragma.com.co',
        autorizedAtIsoDate: '2026-01-03T00:00:00.000Z',
        note: 'ok',
      );

      // Act
      final Map<String, dynamic> json = acl.toJson();

      // Assert
      expect(json[ModelAclEnum.id.name], 'acl-1');
      expect(json[ModelAclEnum.roleType.name], 'editor');
      expect(json[ModelAclEnum.appName.name], 'sat-p');
      expect(json[ModelAclEnum.feature.name], 'router');
      expect(json[ModelAclEnum.email.name], 'user@pragma.com.co');
      expect(json[ModelAclEnum.isActive.name], true);
      expect(json[ModelAclEnum.emailAutorizedBy.name], 'admin@pragma.com.co');
      expect(
        json[ModelAclEnum.autorizedAtIsoDate.name],
        '2026-01-03T00:00:00.000Z',
      );
      expect(json[ModelAclEnum.revokedAtIsoDate.name], '');
      expect(json[ModelAclEnum.note.name], 'ok');
    });

    test(
        'Given model with invalid autorizedAtIsoDate When toJson Then preserves raw (still invalid)',
        () {
      // Arrange
      const ModelAcl acl = ModelAcl(
        id: 'acl-raw',
        roleType: RoleType.admin,
        appName: 'sat-p',
        feature: 'router',
        email: 'user@pragma.com.co',
        isActive: true,
        emailAutorizedBy: 'admin@pragma.com.co',
        autorizedAtIsoDate: 'not-a-date',
      );

      // Act
      final Map<String, dynamic> json = acl.toJson();

      // Assert
      expect(json[ModelAclEnum.autorizedAtIsoDate.name], 'not-a-date');
    });

    test(
        'Given json roundtrip When toJson then fromJson Then model equals original',
        () {
      // Arrange
      const ModelAcl acl = ModelAcl(
        id: 'acl-rt',
        roleType: RoleType.viewer,
        appName: 'sat-p',
        feature: 'router',
        email: 'user@pragma.com.co',
        isActive: false,
        emailAutorizedBy: 'admin@pragma.com.co',
        autorizedAtIsoDate: '2026-01-03T00:00:00.000Z',
        revokedAtIsoDate: '2026-01-04T00:00:00.000Z',
        note: 'revoked',
      );

      // Act
      final Map<String, dynamic> json = acl.toJson();
      final ModelAcl back = ModelAcl.fromJson(json);

      // Assert
      expect(back, acl);
      expect(back.hashCode, acl.hashCode);
    });
  });

  group('ModelAcl trust getters - isValidAcl & DateTime getters', () {
    test(
        'Given valid autorizedAtIsoDate When isValidAcl Then true and autorizedAtDateTime is UTC',
        () {
      // Arrange
      const ModelAcl acl = ModelAcl(
        id: 'acl-1',
        roleType: RoleType.admin,
        appName: 'sat-p',
        feature: 'router',
        email: 'user@pragma.com.co',
        isActive: true,
        emailAutorizedBy: 'admin@pragma.com.co',
        autorizedAtIsoDate: '2026-01-03T00:00:00.000Z',
      );

      // Act
      final bool valid = acl.isValidAcl;
      final DateTime? dt = acl.autorizedAtDateTime;

      // Assert
      expect(valid, true);
      expect(dt, isNotNull);
      expect(dt!.isUtc, true);
      expect(dt.toUtc(), DateTime.utc(2026, 1, 3));
    });

    test(
        'Given empty autorizedAtIsoDate When isValidAcl Then false and autorizedAtDateTime null',
        () {
      // Arrange
      const ModelAcl acl = ModelAcl(
        id: 'acl-2',
        roleType: RoleType.admin,
        appName: 'sat-p',
        feature: 'router',
        email: 'user@pragma.com.co',
        isActive: true,
        emailAutorizedBy: 'admin@pragma.com.co',
      );

      // Assert
      expect(acl.isValidAcl, false);
      expect(acl.autorizedAtDateTime, isNull);
    });

    test(
        'Given invalid autorizedAtIsoDate When isValidAcl Then false and autorizedAtDateTime null',
        () {
      // Arrange
      const ModelAcl acl = ModelAcl(
        id: 'acl-3',
        roleType: RoleType.admin,
        appName: 'sat-p',
        feature: 'router',
        email: 'user@pragma.com.co',
        isActive: true,
        emailAutorizedBy: 'admin@pragma.com.co',
        autorizedAtIsoDate: 'nope',
      );

      // Assert
      expect(acl.isValidAcl, false);
      expect(acl.autorizedAtDateTime, isNull);
    });
  });

  group('ModelAcl.copyWith - behavior and optimization', () {
    test('Given no args When copyWith Then returns same instance', () {
      // Arrange
      const ModelAcl acl = ModelAcl(
        id: 'acl-1',
        roleType: RoleType.viewer,
        appName: 'sat-p',
        feature: 'router',
        email: 'user@pragma.com.co',
        isActive: true,
        emailAutorizedBy: 'admin@pragma.com.co',
        autorizedAtIsoDate: '2026-01-03T00:00:00.000Z',
      );

      // Act
      final ModelAcl sameRef = acl.copyWith();

      // Assert
      expect(identical(sameRef, acl), true);
      expect(sameRef, acl);
    });

    test(
        'Given one change When copyWith Then returns new instance with that change',
        () {
      // Arrange
      const ModelAcl acl = ModelAcl(
        id: 'acl-1',
        roleType: RoleType.viewer,
        appName: 'sat-p',
        feature: 'router',
        email: 'user@pragma.com.co',
        isActive: true,
        emailAutorizedBy: 'admin@pragma.com.co',
        autorizedAtIsoDate: '2026-01-03T00:00:00.000Z',
      );

      // Act
      final ModelAcl updated = acl.copyWith(note: 'hello');

      // Assert
      expect(identical(updated, acl), false);
      expect(updated.note, 'hello');
      expect(updated.id, acl.id);
      expect(updated.roleType, acl.roleType);
    });

    test('Given multiple changes When copyWith Then applies all changes', () {
      // Arrange
      const ModelAcl acl = ModelAcl(
        id: 'acl-1',
        roleType: RoleType.viewer,
        appName: 'sat-p',
        feature: 'router',
        email: 'user@pragma.com.co',
        isActive: true,
        emailAutorizedBy: 'admin@pragma.com.co',
      );

      // Act
      final ModelAcl updated = acl.copyWith(
        roleType: RoleType.admin,
        isActive: false,
        revokedAt: '2026-01-04T00:00:00.000Z',
      );

      // Assert
      expect(updated.roleType, RoleType.admin);
      expect(updated.isActive, false);
      expect(updated.revokedAtIsoDate, '2026-01-04T00:00:00.000Z');
    });
  });

  group('ModelAcl equality & hashCode', () {
    test(
        'Given two identical instances When compared Then equals and hashCode match',
        () {
      // Arrange
      const ModelAcl a = ModelAcl(
        id: 'acl-1',
        roleType: RoleType.admin,
        appName: 'sat-p',
        feature: 'router',
        email: 'user@pragma.com.co',
        isActive: true,
        emailAutorizedBy: 'admin@pragma.com.co',
        autorizedAtIsoDate: '2026-01-03T00:00:00.000Z',
        note: 'x',
      );

      const ModelAcl b = ModelAcl(
        id: 'acl-1',
        roleType: RoleType.admin,
        appName: 'sat-p',
        feature: 'router',
        email: 'user@pragma.com.co',
        isActive: true,
        emailAutorizedBy: 'admin@pragma.com.co',
        autorizedAtIsoDate: '2026-01-03T00:00:00.000Z',
        note: 'x',
      );

      // Assert
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('Given differing field When compared Then not equal', () {
      // Arrange
      const ModelAcl a = ModelAcl(
        id: 'acl-1',
        roleType: RoleType.admin,
        appName: 'sat-p',
        feature: 'router',
        email: 'user@pragma.com.co',
        isActive: true,
        emailAutorizedBy: 'admin@pragma.com.co',
      );

      const ModelAcl b = ModelAcl(
        id: 'acl-1',
        roleType: RoleType.editor,
        appName: 'sat-p',
        feature: 'router',
        email: 'user@pragma.com.co',
        isActive: true,
        emailAutorizedBy: 'admin@pragma.com.co',
      );

      // Assert
      expect(a == b, false);
    });
  });
}
