import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelAppVersion – Constructor & Immutability', () {
    test('Given local time When constructed Then buildAt is normalized to UTC',
        () {
      // Arrange
      final DateTime local = DateTime(
        2025,
        10,
        12,
        9,
      ).toLocal();
      final bool isLocalUtc = local.isUtc; // sanity: should be false commonly
      final String expectedIso =
          DateUtils.dateTimeToString(local.toUtc());

      // Act
      final ModelAppVersion m = ModelAppVersion(
        id: 'id-1',
        appName: 'app',
        version: '1.0.0',
        buildNumber: 1,
        platform: 'android',
        channel: 'dev',
        buildAt: local,
      );

      // Assert
      expect(isLocalUtc, isFalse);
      expect(m.buildAt, expectedIso);
      expect(m.buildAtDateTime.isUtc, isTrue);
    });

    test('Given meta map When constructed Then meta is unmodifiable', () {
      final Map<String, dynamic> meta = <String, dynamic>{'k': 'v'};
      final ModelAppVersion m = ModelAppVersion(
        id: 'id-2',
        appName: 'app',
        version: '1.0.0',
        buildNumber: 1,
        platform: 'android',
        channel: 'dev',
        buildAt: DateTime.now().toUtc(),
        meta: meta,
      );

      expect(() => m.meta['x'] = 1, throwsUnsupportedError);
    });
  });

  group('ModelAppVersion – Equality & HashCode', () {
    test('Given identical content When compared Then equals and same hash', () {
      final DateTime t = DateTime(2025, 10, 12, 14, 30).toUtc();

      final ModelAppVersion a = ModelAppVersion(
        id: 'id',
        appName: 'Pixel',
        version: '1.2.3',
        buildNumber: 123,
        platform: 'android',
        channel: 'prod',
        buildAt: t,
        meta: const <String, dynamic>{
          'commit': 'abc',
          'flags': <String>['x', 'y'],
        },
      );

      final ModelAppVersion b = ModelAppVersion(
        id: 'id',
        appName: 'Pixel',
        version: '1.2.3',
        buildNumber: 123,
        platform: 'android',
        channel: 'prod',
        buildAt: DateTime.fromMillisecondsSinceEpoch(
          t.millisecondsSinceEpoch,
          isUtc: true,
        ),
        meta: const <String, dynamic>{
          'flags': <String>['x', 'y'],
          'commit': 'abc',
        },
      );

      expect(a == b, isTrue);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('Given different meta deep value When compared Then not equal', () {
      final DateTime t = DateTime(2025, 10, 12, 14, 30).toUtc();

      final ModelAppVersion a = ModelAppVersion(
        id: 'id',
        appName: 'Pixel',
        version: '1.2.3',
        buildNumber: 123,
        platform: 'android',
        channel: 'prod',
        buildAt: t,
        meta: const <String, dynamic>{
          'k': <int>[1, 2, 3],
        },
      );

      final ModelAppVersion b = a.copyWith(
        meta: <String, dynamic>{
          'k': <int>[1, 2, 4],
        },
      );

      expect(a == b, isFalse);
      expect(a.hashCode == b.hashCode, isFalse); // en general debería diferir
    });
  });

  group('ModelAppVersion – copyWith', () {
    test(
        'Given copyWith When updating some fields Then returns a new immutable instance',
        () {
      final ModelAppVersion base = ModelAppVersion(
        id: 'base',
        appName: 'Pixel',
        version: '0.9.0',
        buildNumber: 90,
        platform: 'android',
        channel: 'beta',
        buildAt: DateTime.now().toUtc(),
        meta: const <String, dynamic>{'a': 1},
      );

      final ModelAppVersion copy = base.copyWith(
        version: '1.0.0',
        buildNumber: 100,
        meta: <String, dynamic>{'a': 1, 'b': 2},
      );

      expect(copy.version, '1.0.0');
      expect(copy.buildNumber, 100);
      expect(copy.meta, containsPair('b', 2));
      expect(() => copy.meta['c'] = 3, throwsUnsupportedError);
      expect(identical(base, copy), isFalse);
    });
  });

  group('ModelAppVersion – JSON Roundtrip', () {
    test('Given model When toJson then fromJson Then equals original', () {
      final ModelAppVersion original = ModelAppVersion(
        id: '42',
        appName: 'Pixel',
        version: '1.2.3+456',
        buildNumber: 456,
        platform: 'web',
        channel: 'prod',
        buildAt: DateTime(2025, 10, 12, 15, 45, 10, 250).toUtc(),
        minSupportedVersion: '1.0.0',
        forceUpdate: true,
        artifactUrl: 'https://example.com/a.zip',
        changelogUrl: 'https://example.com/changelog',
        commitSha: 'deadbeef',
        meta: const <String, dynamic>{
          'features': <String>['a', 'b'],
          'threshold': 0.75,
          'flags': <String, bool>{'f1': true, 'f2': false},
        },
      );

      // Act
      final Map<String, dynamic> json = original.toJson();
      final ModelAppVersion back = ModelAppVersion.fromJson(json);

      // Assert
      expect(back, equals(original));
      expect(back.buildAt, original.buildAt);
      expect(back.buildAtDateTime.isUtc, isTrue);
    });

    test(
        'Given raw/dynamic meta in JSON When fromJson Then keys are normalized and deep equal',
        () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'x',
        'appName': 'app',
        'version': '1.0.0',
        'buildNumber': 1,
        'platform': 'ios',
        'channel': 'dev',
        'buildAt': DateUtils.dateTimeToString(DateTime(2025, 10, 12).toUtc()),
        'meta': <dynamic, dynamic>{
          1: 'a',
          '1': 'a',
          'nums': <dynamic>[1, 2, 3],
        },
      };

      final ModelAppVersion m = ModelAppVersion.fromJson(json);

      // Claves '1' colisionan al stringificarse → queda una sola entrada '1': 'a'
      final Map<String, dynamic> normalized =
          Utils.mapFromDynamic(json['meta']);

      expect(Utils.deepEqualsMap(m.meta, normalized), isTrue);
    });

    test(
        'Given UTC string and local string buildAt When parsed Then stored as UTC in both cases',
        () {
      final String utcStr =
          DateUtils.dateTimeToString(DateTime(2025, 10, 12, 12).toUtc());
      // Simulamos que DateUtils.dateTimeFromDynamic acepta también `DateTime` local:
      final Map<String, dynamic> jsonUtc = <String, dynamic>{
        'id': 'a',
        'appName': 'app',
        'version': '1.0.0',
        'buildNumber': 1,
        'platform': 'web',
        'channel': 'dev',
        'buildAt': utcStr,
      };

      final ModelAppVersion fromUtc = ModelAppVersion.fromJson(jsonUtc);
      expect(fromUtc.buildAt, utcStr);
      expect(fromUtc.buildAtDateTime.isUtc, isTrue);

      final Map<String, dynamic> jsonLocal = <String, dynamic>{
        'id': 'a',
        'appName': 'app',
        'version': '1.0.0',
        'buildNumber': 1,
        'platform': 'web',
        'channel': 'dev',
        'buildAt': DateTime(2025, 10, 12, 12).toLocal(),
        // delega a DateUtils.*
      };

      final ModelAppVersion fromLocal = ModelAppVersion.fromJson(jsonLocal);
      expect(
        fromLocal.buildAt,
        DateUtils.dateTimeToString(DateTime(2025, 10, 12, 12).toUtc()),
      );
      expect(fromLocal.buildAtDateTime.isUtc, isTrue);
    });
  });

  group('ModelAppVersion – Defaults & Sentinels', () {
    test('Given defaultModelAppVersion Then has sentinel ISO buildAt', () {
      const ModelAppVersion d = ModelAppVersion.defaultModelAppVersion;
      expect(d.id, 'default');
      expect(d.version, '0.0.0');
      expect(d.buildNumber, 0);
      expect(d.buildAt, ModelAppVersion.kDefaultBuildAtIso);
      expect(d.buildAtDateTime.isUtc, isTrue);
      expect(d.platform, 'shared');
      expect(d.channel, 'dev');
    });
  });
}
