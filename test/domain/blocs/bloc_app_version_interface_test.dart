import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

class _FakeBlocAppVersion extends BlocAppVersionInterface {
  _FakeBlocAppVersion(Map<String, ModelAppVersion> seed)
      : _byId = Map<String, ModelAppVersion>.from(seed);

  final Map<String, ModelAppVersion> _byId;

  @override
  ModelAppVersion? findById(String id) => _byId[id];

  @override
  ModelAppVersion? findByKey({
    required String appName,
    required String platform,
    required String channel,
  }) {
    final String key = versionKey(
      appName: appName,
      platform: platform,
      channel: channel,
    );

    for (final ModelAppVersion v in _byId.values) {
      final String vKey = versionKey(
        appName: v.appName,
        platform: v.platform,
        channel: v.channel,
      );
      if (vKey == key) {
        return v;
      }
    }
    return null;
  }

  @override
  Future<Either<ErrorItem, List<ModelAppVersion>>> listByAppName(
    String appName,
  ) async {
    final String target = appName.trim().toLowerCase();
    final List<ModelAppVersion> out = _byId.values
        .where((ModelAppVersion v) => v.appName.trim().toLowerCase() == target)
        .toList(growable: false);

    return Right<ErrorItem, List<ModelAppVersion>>(out);
  }

  @override
  Future<Either<ErrorItem, List<ModelAppVersion>>> listAll({
    String appName = '',
    String platform = '',
    String channel = '',
  }) async {
    final String a = appName.trim().toLowerCase();
    final String p = platform.trim().toLowerCase();
    final String c = channel.trim().toLowerCase();

    bool matches(ModelAppVersion v) {
      final bool okA = a.isEmpty || v.appName.trim().toLowerCase() == a;
      final bool okP = p.isEmpty || v.platform.trim().toLowerCase() == p;
      final bool okC = c.isEmpty || v.channel.trim().toLowerCase() == c;
      return okA && okP && okC;
    }

    final List<ModelAppVersion> out =
        _byId.values.where(matches).toList(growable: false);

    return Right<ErrorItem, List<ModelAppVersion>>(out);
  }

  @override
  Future<Either<ErrorItem, ModelAppVersion>> upsert(
    ModelAppVersion model,
  ) async {
    _byId[model.id] = model;
    return Right<ErrorItem, ModelAppVersion>(model);
  }

  @override
  Future<Either<ErrorItem, ModelAppVersion>> readById(String id) async {
    final ModelAppVersion? found = _byId[id];
    if (found == null) {
      return Left<ErrorItem, ModelAppVersion>(
        ErrorItem(
          code: 'APP-VERSION-NOT-FOUND',
          title: 'Not found',
          description: 'No version found for id=$id',
        ),
      );
    }
    return Right<ErrorItem, ModelAppVersion>(found);
  }

  @override
  Future<Either<ErrorItem, bool>> deleteById(String id) async {
    final bool existed = _byId.remove(id) != null;
    return Right<ErrorItem, bool>(existed);
  }

  @override
  void dispose() {
    // No-op for fake.
  }
}

ModelAppVersion _v({
  required String id,
  required String version,
  required int buildNumber,
  required String appName,
  required String platform,
  required String channel,
  bool forceUpdate = false,
}) {
  return ModelAppVersion(
    id: id,
    appName: appName,
    version: version,
    buildNumber: buildNumber,
    platform: platform,
    channel: channel,
    forceUpdate: forceUpdate,
  );
}

void main() {
  group('BlocAppVersionInterface - versionKey', () {
    test(
        'Given mixed-case values When versionKey Then returns canonical lowercase trimmed key',
        () {
      final _FakeBlocAppVersion bloc =
          _FakeBlocAppVersion(<String, ModelAppVersion>{});

      final String key = bloc.versionKey(
        appName: '  Pixel ',
        platform: ' ANDROID ',
        channel: ' Prod ',
      );

      expect(key, 'pixel::android::prod');
    });
  });

  group('BlocAppVersionInterface - latestByBuildNumber', () {
    test('Given empty list When latestByBuildNumber Then returns null', () {
      final _FakeBlocAppVersion bloc =
          _FakeBlocAppVersion(<String, ModelAppVersion>{});

      final ModelAppVersion? latest =
          bloc.latestByBuildNumber(<ModelAppVersion>[]);

      expect(latest, isNull);
    });

    test(
        'Given list with multiple items When latestByBuildNumber Then returns max buildNumber',
        () {
      final _FakeBlocAppVersion bloc =
          _FakeBlocAppVersion(<String, ModelAppVersion>{});

      final List<ModelAppVersion> items = <ModelAppVersion>[
        _v(
          id: 'a',
          version: '1.0.0',
          buildNumber: 10,
          appName: 'Pixel',
          platform: 'android',
          channel: 'prod',
        ),
        _v(
          id: 'b',
          version: '1.1.0',
          buildNumber: 12,
          appName: 'Pixel',
          platform: 'android',
          channel: 'prod',
        ),
        _v(
          id: 'c',
          version: '1.0.5',
          buildNumber: 11,
          appName: 'Pixel',
          platform: 'android',
          channel: 'prod',
        ),
      ];

      final ModelAppVersion? latest = bloc.latestByBuildNumber(items);

      expect(latest, isNotNull);
      expect(latest!.id, 'b');
      expect(latest.buildNumber, 12);
    });
  });

  group('BlocAppVersionInterface - shouldForceUpdate (buildNumber strategy)',
      () {
    test('Given latest.forceUpdate=false When outdated Then returns false', () {
      final _FakeBlocAppVersion bloc =
          _FakeBlocAppVersion(<String, ModelAppVersion>{});

      final ModelAppVersion current = _v(
        id: 'c',
        version: '1.0.0',
        buildNumber: 10,
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
      );
      final ModelAppVersion latest = _v(
        id: 'l',
        version: '1.1.0',
        buildNumber: 11,
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
      );

      final bool result =
          bloc.shouldForceUpdate(current: current, latest: latest);

      expect(result, false);
    });

    test(
        'Given latest.forceUpdate=true and latest newer by buildNumber When shouldForceUpdate Then true',
        () {
      final _FakeBlocAppVersion bloc =
          _FakeBlocAppVersion(<String, ModelAppVersion>{});

      final ModelAppVersion current = _v(
        id: 'c',
        version: '1.0.0',
        buildNumber: 10,
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
      );
      final ModelAppVersion latest = _v(
        id: 'l',
        version: '1.1.0',
        buildNumber: 11,
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
        forceUpdate: true,
      );

      final bool result =
          bloc.shouldForceUpdate(current: current, latest: latest);

      expect(result, true);
    });

    test(
        'Given latest.forceUpdate=true but not outdated When shouldForceUpdate Then false',
        () {
      final _FakeBlocAppVersion bloc =
          _FakeBlocAppVersion(<String, ModelAppVersion>{});

      final ModelAppVersion current = _v(
        id: 'c',
        version: '1.1.0',
        buildNumber: 11,
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
      );
      final ModelAppVersion latest = _v(
        id: 'l',
        version: '1.1.0',
        buildNumber: 11,
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
        forceUpdate: true,
      );

      final bool result =
          bloc.shouldForceUpdate(current: current, latest: latest);

      expect(result, false);
    });

    test(
        'Given minSupportedBuildNumber provided and current below it When shouldForceUpdate Then true',
        () {
      final _FakeBlocAppVersion bloc =
          _FakeBlocAppVersion(<String, ModelAppVersion>{});

      final ModelAppVersion current = _v(
        id: 'c',
        version: '1.0.0',
        buildNumber: 10,
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
      );
      final ModelAppVersion latest = _v(
        id: 'l',
        version: '1.2.0',
        buildNumber: 12,
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
      );

      final bool result = bloc.shouldForceUpdate(
        current: current,
        latest: latest,
        minSupportedBuildNumber: 11,
      );

      expect(result, true);
    });

    test(
        'Given minSupportedBuildNumber disabled (-1) When only outdated and forceUpdate=false Then false',
        () {
      final _FakeBlocAppVersion bloc =
          _FakeBlocAppVersion(<String, ModelAppVersion>{});

      final ModelAppVersion current = _v(
        id: 'c',
        version: '1.0.0',
        buildNumber: 10,
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
      );
      final ModelAppVersion latest = _v(
        id: 'l',
        version: '1.1.0',
        buildNumber: 11,
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
      );

      final bool result = bloc.shouldForceUpdate(
        current: current,
        latest: latest,
      );

      expect(result, false);
    });
  });

  group('BlocAppVersionInterface - tryParseSemVer', () {
    test('Given "1" When tryParseSemVer Then returns [1,0,0]', () {
      final _FakeBlocAppVersion bloc =
          _FakeBlocAppVersion(<String, ModelAppVersion>{});
      expect(bloc.tryParseSemVer('1'), <int>[1, 0, 0]);
    });

    test('Given "1.2" When tryParseSemVer Then returns [1,2,0]', () {
      final _FakeBlocAppVersion bloc =
          _FakeBlocAppVersion(<String, ModelAppVersion>{});
      expect(bloc.tryParseSemVer('1.2'), <int>[1, 2, 0]);
    });

    test('Given "1.2.3" When tryParseSemVer Then returns [1,2,3]', () {
      final _FakeBlocAppVersion bloc =
          _FakeBlocAppVersion(<String, ModelAppVersion>{});
      expect(bloc.tryParseSemVer('1.2.3'), <int>[1, 2, 3]);
    });

    test(
        'Given "1.2.3-beta+7" When tryParseSemVer Then ignores suffix and returns [1,2,3]',
        () {
      final _FakeBlocAppVersion bloc =
          _FakeBlocAppVersion(<String, ModelAppVersion>{});
      expect(bloc.tryParseSemVer('1.2.3-beta+7'), <int>[1, 2, 3]);
    });

    test('Given invalid semver When tryParseSemVer Then returns null', () {
      final _FakeBlocAppVersion bloc =
          _FakeBlocAppVersion(<String, ModelAppVersion>{});
      expect(bloc.tryParseSemVer('x.y.z'), isNull);
      expect(bloc.tryParseSemVer('1.x.3'), isNull);
      expect(bloc.tryParseSemVer(''), isNull);
      expect(bloc.tryParseSemVer('   '), isNull);
    });
  });

  group('BlocAppVersionInterface - shouldForceUpdateBySemVerOrBuildNumber', () {
    test(
        'Given semver newer and latest.forceUpdate=true When shouldForceUpdateBySemVerOrBuildNumber Then true',
        () {
      final _FakeBlocAppVersion bloc =
          _FakeBlocAppVersion(<String, ModelAppVersion>{});

      final ModelAppVersion current = _v(
        id: 'c',
        version: '1.2.3',
        buildNumber: 10,
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
      );
      final ModelAppVersion latest = _v(
        id: 'l',
        version: '1.3.0',
        buildNumber:
            9, // even if buildNumber is smaller, semver wins when parseable
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
        forceUpdate: true,
      );

      final bool result = bloc.shouldForceUpdateBySemVerOrBuildNumber(
        current: current,
        latest: latest,
      );

      expect(result, true);
    });

    test(
        'Given semver equal and latest.forceUpdate=true When shouldForceUpdateBySemVerOrBuildNumber Then false',
        () {
      final _FakeBlocAppVersion bloc =
          _FakeBlocAppVersion(<String, ModelAppVersion>{});

      final ModelAppVersion current = _v(
        id: 'c',
        version: '1.2.3',
        buildNumber: 10,
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
      );
      final ModelAppVersion latest = _v(
        id: 'l',
        version: '1.2.3',
        buildNumber: 11,
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
        forceUpdate: true,
      );

      final bool result = bloc.shouldForceUpdateBySemVerOrBuildNumber(
        current: current,
        latest: latest,
      );

      // SemVer is not newer, so should be false even if buildNumber differs.
      expect(result, false);
    });

    test(
        'Given semver cannot be parsed When shouldForceUpdateBySemVerOrBuildNumber Then falls back to buildNumber',
        () {
      final _FakeBlocAppVersion bloc =
          _FakeBlocAppVersion(<String, ModelAppVersion>{});

      final ModelAppVersion current = _v(
        id: 'c',
        version: 'dev-build',
        buildNumber: 10,
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
      );
      final ModelAppVersion latest = _v(
        id: 'l',
        version: 'main-branch',
        buildNumber: 11,
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
        forceUpdate: true,
      );

      final bool result = bloc.shouldForceUpdateBySemVerOrBuildNumber(
        current: current,
        latest: latest,
      );

      expect(result, true);
    });

    test(
        'Given latest.forceUpdate=false When newer Then shouldForceUpdateBySemVerOrBuildNumber returns false',
        () {
      final _FakeBlocAppVersion bloc =
          _FakeBlocAppVersion(<String, ModelAppVersion>{});

      final ModelAppVersion current = _v(
        id: 'c',
        version: '1.0.0',
        buildNumber: 10,
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
      );
      final ModelAppVersion latest = _v(
        id: 'l',
        version: '2.0.0',
        buildNumber: 20,
        appName: 'Pixel',
        platform: 'android',
        channel: 'prod',
      );

      final bool result = bloc.shouldForceUpdateBySemVerOrBuildNumber(
        current: current,
        latest: latest,
      );

      expect(result, false);
    });
  });
}
