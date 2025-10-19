import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelAssessment', () {
    ModelAssessment mk({
      String id = 'ASMT-1',
      String title = 'Basic Chemistry',
      List<ModelLearningItem>? items,
      bool shuffleItems = true,
      bool shuffleOptions = true,
      Duration timeLimit = const Duration(minutes: 10),
      int passScore = 60,
    }) {
      return ModelAssessment(
        id: id,
        title: title,
        items: items ?? <ModelLearningItem>[defaultModelLearningItem],
        shuffleItems: shuffleItems,
        shuffleOptions: shuffleOptions,
        timeLimit: timeLimit,
        passScore: passScore,
      );
    }

    test(
        'Given valid instance '
        'When toJson -> fromJson '
        'Then roundtrip equality holds', () {
      final ModelAssessment a = mk(
        items: <ModelLearningItem>[
          defaultModelLearningItem,
          defaultModelLearningItem.copyWith(id: 'LI-2', label: 'Alt item'),
        ],
        shuffleItems: false,
        timeLimit: const Duration(minutes: 15),
        passScore: 75,
      );

      final Map<String, dynamic> json = a.toJson();
      final ModelAssessment b = ModelAssessment.fromJson(json);
      expect(defaultModelAssessment, equals(defaultModelAssessment.copyWith()));
      expect(b, equals(a));

      // Verifica claves enum
      for (final AssessmentEnum k in AssessmentEnum.values) {
        expect(json.containsKey(k.name), isTrue);
      }
      // Verifica serialización de duración en ms
      expect(
        json[AssessmentEnum.timeLimitMs.name],
        equals(a.timeLimit.inMilliseconds),
      );
    });

    test(
        'Given items list '
        'When accessing items '
        'Then it is unmodifiable', () {
      final ModelAssessment a = mk();
      expect(
        () => a.items.add(defaultModelLearningItem),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test(
        'Given base instance '
        'When copyWith overrides some fields '
        'Then new instance reflects changes and preserves others', () {
      final ModelAssessment base = mk();
      final ModelAssessment c = base.copyWith(
        title: 'Advanced Chemistry',
        shuffleItems: false,
        timeLimit: const Duration(minutes: 30),
        passScore: 80,
      );

      expect(c.title, 'Advanced Chemistry');
      expect(c.shuffleItems, isFalse);
      expect(c.timeLimit, const Duration(minutes: 30));
      expect(c.passScore, 80);

      // Invariantes preservados
      expect(c.items, base.items);
      expect(c.shuffleOptions, base.shuffleOptions);
    });

    test(
        'Given out-of-range passScore in constructor '
        'When constructing '
        'Then value is clamped to 0..100', () {
      final ModelAssessment a = mk(passScore: -10);
      final ModelAssessment b = mk(passScore: 150);

      expect(a.passScore, 0);
      expect(b.passScore, 100);
    });

    test(
        'Given passScore out of range in fromJson '
        'When parsing '
        'Then passScore is clamped', () {
      final Map<String, dynamic> j = <String, dynamic>{
        AssessmentEnum.id.name: 'ASMT-CLAMP',
        AssessmentEnum.title.name: 'Clamp Test',
        AssessmentEnum.items.name: <Map<String, dynamic>>[
          defaultModelLearningItem.toJson(),
        ],
        AssessmentEnum.shuffleItems.name: true,
        AssessmentEnum.shuffleOptions.name: true,
        AssessmentEnum.timeLimitMs.name: 0,
        AssessmentEnum.passScore.name: 999, // fuera de rango
      };

      final ModelAssessment a = ModelAssessment.fromJson(j);
      expect(a.passScore, 100);

      j[AssessmentEnum.passScore.name] = -42;
      final ModelAssessment b = ModelAssessment.fromJson(j);
      expect(b.passScore, 0);
    });

    test(
        'Given missing shuffle flags and timeLimit '
        'When fromJson '
        'Then shuffle defaults to true and timeLimit defaults to Duration.zero',
        () {
      final Map<String, dynamic> j = <String, dynamic>{
        AssessmentEnum.id.name: 'ASMT-DEF',
        AssessmentEnum.title.name: 'Defaults Test',
        AssessmentEnum.items.name: <Map<String, dynamic>>[
          defaultModelLearningItem.toJson(),
        ],
        // Note: omitimos shuffleItems, shuffleOptions y timeLimitMs
        AssessmentEnum.passScore.name: 50,
      };

      final ModelAssessment a = ModelAssessment.fromJson(j);
      expect(a.shuffleItems, isTrue);
      expect(a.shuffleOptions, isTrue);
      expect(a.timeLimit, Duration.zero);
      expect(a.passScore, 50);
    });

    test(
        'Given timeLimitMs provided '
        'When fromJson '
        'Then timeLimit parsed as Duration(milliseconds)', () {
      final Map<String, dynamic> j =
          mk(timeLimit: const Duration(minutes: 3)).toJson();

      // Forzamos 90_000 ms (1.5 minutos)
      j[AssessmentEnum.timeLimitMs.name] = 90000;

      final ModelAssessment a = ModelAssessment.fromJson(j);
      expect(a.timeLimit, const Duration(milliseconds: 90000));
    });

    test(
        'Given two equal assessments '
        'When comparing '
        'Then equals and hashCode match; changing items order breaks equality',
        () {
      final ModelLearningItem i1 = defaultModelLearningItem;
      final ModelLearningItem i2 =
          defaultModelLearningItem.copyWith(id: 'LI-2', label: 'Alt item');

      final ModelAssessment a = mk(items: <ModelLearningItem>[i1, i2]);
      final ModelAssessment b = mk(items: <ModelLearningItem>[i1, i2]);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      final ModelAssessment c =
          mk(items: <ModelLearningItem>[i2, i1]); // otro orden
      expect(a == c, isFalse);
    });

    test(
        'Given instance '
        'When toString '
        'Then outputs valid JSON with enum keys', () {
      final ModelAssessment a = mk();
      final dynamic decoded = jsonDecode(a.toString());
      expect(decoded, isA<Map<String, dynamic>>());
      expect(a.toString(), contains(AssessmentEnum.id.name));
      expect(a.toString(), contains(AssessmentEnum.timeLimitMs.name));
    });

    test(
        'Given negative timeLimit '
        'When constructing '
        'Then assertion error (debug mode)', () {
      expect(
        () => ModelAssessment(
          id: 'NEG',
          title: 'Neg',
          items: <ModelLearningItem>[defaultModelLearningItem],
          shuffleItems: true,
          shuffleOptions: true,
          timeLimit: const Duration(seconds: -1),
          // negativo
          passScore: 50,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
