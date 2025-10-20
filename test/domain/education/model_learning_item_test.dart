import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelLearningItem (no legacy)', () {
    ModelPerformanceIndicator mkPI(String id) => ModelPerformanceIndicator(
          id: id,
          modelLearningGoal: defaultLearningGoal,
          label: 'L$id',
          level: PerformanceLevel.basic,
          code: 'C$id',
        );

    ModelAttribute<dynamic> attr(String n, dynamic v) =>
        AttributeModel<dynamic>(name: n, value: v);

    ModelCategory cat() =>
        const ModelCategory(category: 'science', description: 'Science');

    ModelLearningItem mkItem() => ModelLearningItem(
          id: 'LI-1',
          label: 'Water formula is...',
          correctAnswer: 'H₂O',
          wrongAnswerOne: 'CO₂',
          wrongAnswerTwo: 'O₂',
          wrongAnswerThree: 'NaCl',
          explanation: 'Two hydrogen and one oxygen atoms.',
          attributes: <ModelAttribute<dynamic>>[attr('topic', 'chem')],
          achievementOne: mkPI('PI-1'),
          achievementTwo: mkPI('PI-2'),
          achievementThree: mkPI('PI-3'),
          estimatedTimeForAnswer: const Duration(minutes: 2),
          category: cat(),
        );

    test('Given valid item When toJson->fromJson Then roundtrip equality', () {
      final ModelLearningItem a = mkItem();
      final Map<String, dynamic> j = a.toJson();
      final ModelLearningItem b = ModelLearningItem.fromJson(j);
      expect(b, equals(a));
    });

    test(
        'Given missing achievementOne When fromJson Then throws FormatException',
        () {
      final Map<String, dynamic> j = mkItem().toJson();
      j.remove(LearningItemEnum.achievementOne.name);
      expect(() => ModelLearningItem.fromJson(j), throwsFormatException);
    });

    test('Given attributes list When constructed Then list is unmodifiable',
        () {
      final ModelLearningItem item = mkItem();
      expect(
        () => item.attributes.add(attr('x', 1)),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('Given copyWith When override subset Then returns modified instance',
        () {
      final ModelLearningItem base = mkItem();
      final ModelLearningItem copy = base.copyWith(
        label: 'New',
        wrongAnswerTwo: 'X',
        achievementThree: mkPI('PI-3'),
        estimatedTimeForAnswer: const Duration(seconds: 30),
      );
      expect(
        defaultModelLearningItem,
        equals(
          defaultModelLearningItem.copyWith(),
        ),
      );
      expect(copy.label, 'New');
      expect(copy.wrongAnswerTwo, 'X');
      expect(copy.achievementThree?.id, 'PI-3');
      expect(copy.estimatedTimeForAnswer, const Duration(seconds: 30));
      expect(copy.correctAnswer, base.correctAnswer);
    });

    test(
        'Given optionsShuffled with seed When invoked twice Then deterministic',
        () {
      final ModelLearningItem item = mkItem();
      final List<String> r1 = item.optionsShuffled(42);
      final List<String> r2 = item.optionsShuffled(42);
      expect(r1, equals(r2));
      expect(r1.toSet(), <String>{'H₂O', 'CO₂', 'O₂', 'NaCl'});
    });

    test('Given equality/hashCode When same values Then equals & same hash',
        () {
      final ModelLearningItem a = mkItem();
      final ModelLearningItem b = mkItem();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      final ModelLearningItem c = a.copyWith(label: 'diff');
      expect(a == c, isFalse);
    });

    test('Given toString When invoked Then is valid JSON with enum keys', () {
      final ModelLearningItem item = mkItem();
      final dynamic decoded = jsonDecode(item.toString());
      expect(decoded, isA<Map<String, dynamic>>());
      expect(item.toString(), contains(LearningItemEnum.id.name));
      expect(item.toString(), contains(LearningItemEnum.estimatedTimeMs.name));
    });
  });
  group('ModelLearningItem – construcción y contratos', () {
    test(
        'Given attributes mutables externamente When se construye Then internos son unmodifiable',
        () {
      final List<ModelAttribute<dynamic>> attrs = <ModelAttribute<dynamic>>[];
      final ModelLearningItem item = ModelLearningItem(
        id: 'LI-1',
        label: 'L',
        correctAnswer: 'A',
        wrongAnswerOne: 'B',
        wrongAnswerTwo: 'C',
        wrongAnswerThree: 'D',
        explanation: 'E',
        attributes: attrs,
        achievementOne: const ModelPerformanceIndicator(
          id: 'PI-1',
          modelLearningGoal: defaultLearningGoal,
          label: 'I',
          level: PerformanceLevel.basic,
          code: 'CODE',
        ),
        estimatedTimeForAnswer: const Duration(seconds: 1),
        category:
            const ModelCategory(category: 'general', description: 'General'),
      );

      expect(
        () => item.attributes.add(
          const AttributeModel<String>(name: 'k', value: 'v'),
        ),
        throwsUnsupportedError,
      );

      // Cambiar afuera no afecta adentro
      attrs.add(const AttributeModel<String>(name: 'k', value: 'v'));
      expect(item.attributes.length, 0);
    });

    test(
        'Given json sin achievementOne When fromJson Then lanza FormatException',
        () {
      final Map<String, dynamic> json = <String, dynamic>{
        LearningItemEnum.id.name: 'LI-X',
        LearningItemEnum.label.name: 'L',
        LearningItemEnum.correctAnswer.name: 'A',
        LearningItemEnum.wrongAnswerOne.name: 'B',
        LearningItemEnum.wrongAnswerTwo.name: 'C',
        LearningItemEnum.wrongAnswerThree.name: 'D',
        LearningItemEnum.explanation.name: '',
        LearningItemEnum.attributes.name: <Map<String, dynamic>>[],
        LearningItemEnum.cineLevel.name: 0,
        LearningItemEnum.estimatedTimeMs.name:
            ModelLearningItem.defaultETA.inMilliseconds,
        LearningItemEnum.category.name:
            const ModelCategory(category: 'general', description: 'General')
                .toJson(),
        // achievementOne omitido
      };

      expect(
        () => ModelLearningItem.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ModelLearningItem – (de)serialización y defaults', () {
    test('Given json sin estimatedTimeMs When fromJson Then usa defaultETA',
        () {
      final Map<String, dynamic> json = <String, dynamic>{
        LearningItemEnum.id.name: 'LI-2',
        LearningItemEnum.label.name: 'L2',
        LearningItemEnum.correctAnswer.name: 'A',
        LearningItemEnum.wrongAnswerOne.name: 'B',
        LearningItemEnum.wrongAnswerTwo.name: 'C',
        LearningItemEnum.wrongAnswerThree.name: 'D',
        LearningItemEnum.explanation.name: '',
        LearningItemEnum.attributes.name: <Map<String, dynamic>>[],
        LearningItemEnum.achievementOne.name: const ModelPerformanceIndicator(
          id: 'PI-1',
          modelLearningGoal: defaultLearningGoal,
          label: 'I',
          level: PerformanceLevel.basic,
          code: 'CODE',
        ).toJson(),
        LearningItemEnum.cineLevel.name: 1,
        LearningItemEnum.category.name:
            const ModelCategory(category: 'general', description: 'General')
                .toJson(),
      };

      final ModelLearningItem item = ModelLearningItem.fromJson(json);
      expect(item.estimatedTimeForAnswer, ModelLearningItem.defaultETA);
    });

    test(
        'Given instancia con achievements opcionales When toJson Then serializa condicionalmente',
        () {
      final ModelLearningItem withAll = ModelLearningItem(
        id: 'ALL',
        label: 'L',
        correctAnswer: 'A',
        wrongAnswerOne: 'B',
        wrongAnswerTwo: 'C',
        wrongAnswerThree: 'D',
        explanation: '',
        attributes: const <ModelAttribute<dynamic>>[],
        achievementOne: const ModelPerformanceIndicator(
          id: 'PI-1',
          modelLearningGoal: defaultLearningGoal,
          label: 'I1',
          level: PerformanceLevel.basic,
          code: 'C1',
        ),
        achievementTwo: const ModelPerformanceIndicator(
          id: 'PI-2',
          modelLearningGoal: defaultLearningGoal,
          label: 'I2',
          level: PerformanceLevel.basic,
          code: 'C2',
        ),
        achievementThree: const ModelPerformanceIndicator(
          id: 'PI-3',
          modelLearningGoal: defaultLearningGoal,
          label: 'I3',
          level: PerformanceLevel.basic,
          code: 'C3',
        ),
        cineLevel: 2,
        estimatedTimeForAnswer: const Duration(minutes: 3),
        category:
            const ModelCategory(category: 'general', description: 'General'),
      );

      final Map<String, dynamic> j1 = withAll.toJson();
      expect(j1.containsKey(LearningItemEnum.achievementTwo.name), isTrue);
      expect(j1.containsKey(LearningItemEnum.achievementThree.name), isTrue);

      final ModelLearningItem withOnlyOne = withAll.copyWith();
      final Map<String, dynamic> j2 = withOnlyOne.toJson();
      expect(j2.containsKey(LearningItemEnum.achievementTwo.name), isFalse);
      expect(j2.containsKey(LearningItemEnum.achievementThree.name), isFalse);
    });

    test(
        'Given instancia válida When toJson->fromJson Then roundtrip conserva igualdad',
        () {
      final ModelLearningItem a = defaultModelLearningItem.copyWith(
        id: 'RT',
        label: 'Roundtrip',
        explanation: 'E',
      );

      final Map<String, dynamic> json = a.toJson();
      final ModelLearningItem b = ModelLearningItem.fromJson(json);

      expect(b, a);
      expect(b.hashCode, a.hashCode);
      expect(jsonEncode(b.toJson()), jsonEncode(json));
    });
  });

  group('ModelLearningItem – optionsShuffled()', () {
    test('Given seed fijo When optionsShuffled Then resultado determinístico',
        () {
      final ModelLearningItem item = defaultModelLearningItem.copyWith(
        correctAnswer: 'A',
        wrongAnswerOne: 'B',
        wrongAnswerTwo: 'C',
        wrongAnswerThree: 'D',
      );

      final List<String> s1 = item.optionsShuffled(42);
      final List<String> s2 = item.optionsShuffled(42);
      expect(s1, s2);
      // Misma multiconjunto de opciones
      final List<String> base = <String>['A', 'B', 'C', 'D'];
      expect(s1.toSet(), base.toSet());
      expect(s1.length, base.length);
    });

    test(
        'Given seeds distintos When optionsShuffled Then ordenes distintos (probable)',
        () {
      final ModelLearningItem item = defaultModelLearningItem.copyWith(
        correctAnswer: 'A',
        wrongAnswerOne: 'B',
        wrongAnswerTwo: 'C',
        wrongAnswerThree: 'D',
      );

      final List<String> s1 = item.optionsShuffled(1);
      final List<String> s2 = item.optionsShuffled(2);
      // Puede coincidir por azar, pero con 4! es poco probable; si falla espuriamente, cambiar seeds.
      expect(s1, isNot(equals(s2)));
    });
  });

  group('ModelLearningItem – igualdad y toString', () {
    test('Given atributos en distinto orden When == Then false', () {
      const ModelAttribute<String> a1 =
          AttributeModel<String>(name: 'k1', value: 'v1');
      const ModelAttribute<String> a2 =
          AttributeModel<String>(name: 'k2', value: 'v2');

      final ModelLearningItem i1 = defaultModelLearningItem.copyWith(
        id: 'EQ',
        attributes: <ModelAttribute<dynamic>>[a1, a2],
      );
      final ModelLearningItem i2 = defaultModelLearningItem.copyWith(
        id: 'EQ',
        attributes: <ModelAttribute<dynamic>>[a2, a1], // orden diferente
      );

      expect(i1 == i2, isFalse);
    });

    test('Given instancia When toString Then JSON parseable', () {
      final String s = defaultModelLearningItem.toString();
      expect(s, isNotEmpty);
      expect(() => jsonDecode(s), returnsNormally);
    });
  });
}
