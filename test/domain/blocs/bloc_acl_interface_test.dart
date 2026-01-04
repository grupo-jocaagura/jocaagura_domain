import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

class _FakeBlocAcl extends BlocAclInterface {
  _FakeBlocAcl(Map<String, ModelAcl> seed)
      : _store = Map<String, ModelAcl>.from(seed);

  final Map<String, ModelAcl> _store;

  @override
  ModelAcl? findAcl(String feature) => _store[feature];

  @override
  Future<Either<ErrorItem, ModelAcl>> upsertAcl(ModelAcl acl) async {
    _store[featureKey(acl.feature)] = acl;
    return Right<ErrorItem, ModelAcl>(acl);
  }

  @override
  Future<Either<ErrorItem, Map<String, ModelAcl>>> getAllAcls(
    String email,
  ) async {
    return Right<ErrorItem, Map<String, ModelAcl>>(
      Map<String, ModelAcl>.unmodifiable(_store),
    );
  }

  @override
  void dispose() {
    // No-op for fake.
  }
}

void main() {
  group('BlocAclInterface defaults - featureKey', () {
    test(
        'Given mixed-case and spaces When featureKey Then returns trimmed lowercase',
        () {
      final _FakeBlocAcl bloc = _FakeBlocAcl(<String, ModelAcl>{});
      expect(bloc.featureKey('  PayMENTS:Upsert  '), 'payments:upsert');
    });
  });

  group('BlocAclInterface defaults - resolveRoleType', () {
    test('Given missing ACL When resolveRoleType Then returns viewer', () {
      final _FakeBlocAcl bloc = _FakeBlocAcl(<String, ModelAcl>{});
      expect(bloc.resolveRoleType('router'), RoleType.viewer);
    });

    test('Given existing ACL When resolveRoleType Then returns stored role',
        () {
      final _FakeBlocAcl bloc = _FakeBlocAcl(<String, ModelAcl>{
        'router': const ModelAcl(
          id: '1',
          roleType: RoleType.editor,
          appName: 'sat-p',
          feature: 'router',
          email: 'user@pragma.com.co',
          isActive: true,
          emailAutorizedBy: 'admin@pragma.com.co',
          autorizedAtIsoDate: '2026-01-03T00:00:00.000Z',
        ),
      });

      expect(bloc.resolveRoleType('router'), RoleType.editor);
    });
  });

  group('BlocAclInterface defaults - canTrust', () {
    test('Given missing ACL When canTrust Then false', () {
      final _FakeBlocAcl bloc = _FakeBlocAcl(<String, ModelAcl>{});
      expect(bloc.canTrust('router'), false);
    });

    test('Given ACL with invalid autorizedAtIsoDate When canTrust Then false',
        () {
      final _FakeBlocAcl bloc = _FakeBlocAcl(<String, ModelAcl>{
        'router': const ModelAcl(
          id: '1',
          roleType: RoleType.admin,
          appName: 'sat-p',
          feature: 'router',
          email: 'user@pragma.com.co',
          isActive: true,
          emailAutorizedBy: 'admin@pragma.com.co',
          autorizedAtIsoDate: 'not-a-date',
        ),
      });

      expect(bloc.canTrust('router'), false);
    });

    test('Given ACL with valid autorizedAtIsoDate When canTrust Then true', () {
      final _FakeBlocAcl bloc = _FakeBlocAcl(<String, ModelAcl>{
        'router': const ModelAcl(
          id: '1',
          roleType: RoleType.admin,
          appName: 'sat-p',
          feature: 'router',
          email: 'user@pragma.com.co',
          isActive: true,
          emailAutorizedBy: 'admin@pragma.com.co',
          autorizedAtIsoDate: '2026-01-03T00:00:00.000Z',
        ),
      });

      expect(bloc.canTrust('router'), true);
    });
  });

  group('BlocAclInterface defaults - hasAtLeast', () {
    test('Given viewer When hasAtLeast(editor) Then false', () {
      final _FakeBlocAcl bloc = _FakeBlocAcl(<String, ModelAcl>{
        'router': const ModelAcl(
          id: '1',
          roleType: RoleType.viewer,
          appName: 'sat-p',
          feature: 'router',
          email: 'user@pragma.com.co',
          isActive: true,
          emailAutorizedBy: 'admin@pragma.com.co',
          autorizedAtIsoDate: '2026-01-03T00:00:00.000Z',
        ),
      });

      expect(bloc.hasAtLeast('router', RoleType.editor), false);
    });

    test('Given editor When hasAtLeast(viewer) Then true', () {
      final _FakeBlocAcl bloc = _FakeBlocAcl(<String, ModelAcl>{
        'router': const ModelAcl(
          id: '1',
          roleType: RoleType.editor,
          appName: 'sat-p',
          feature: 'router',
          email: 'user@pragma.com.co',
          isActive: true,
          emailAutorizedBy: 'admin@pragma.com.co',
          autorizedAtIsoDate: '2026-01-03T00:00:00.000Z',
        ),
      });

      expect(bloc.hasAtLeast('router', RoleType.viewer), true);
    });

    test('Given admin When hasAtLeast(admin) Then true', () {
      final _FakeBlocAcl bloc = _FakeBlocAcl(<String, ModelAcl>{
        'router': const ModelAcl(
          id: '1',
          roleType: RoleType.admin,
          appName: 'sat-p',
          feature: 'router',
          email: 'user@pragma.com.co',
          isActive: true,
          emailAutorizedBy: 'admin@pragma.com.co',
          autorizedAtIsoDate: '2026-01-03T00:00:00.000Z',
        ),
      });

      expect(bloc.hasAtLeast('router', RoleType.admin), true);
    });
  });

  group('BlocAclInterface - canonicalization consistency', () {
    test(
        'Given ACL stored by featureKey When resolveRoleType called with raw feature Then still works',
        () async {
      final _FakeBlocAcl bloc = _FakeBlocAcl(<String, ModelAcl>{});

      await bloc.upsertAcl(
        const ModelAcl(
          id: '1',
          roleType: RoleType.editor,
          appName: 'sat-p',
          feature: 'RouTER ',
          email: 'user@pragma.com.co',
          isActive: true,
          emailAutorizedBy: 'admin@pragma.com.co',
          autorizedAtIsoDate: '2026-01-03T00:00:00.000Z',
        ),
      );

      expect(bloc.resolveRoleType(' router'), RoleType.editor);
      expect(bloc.canTrust('ROUTER'), true);
    });
  });
}
