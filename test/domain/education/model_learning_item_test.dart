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
          cineLevel: 0,
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

    test(
        'Given cineLevel out of range When construct Then assertion error (debug mode)',
        () {
      expect(
        () => ModelLearningItem(
          id: 'x',
          label: 'y',
          correctAnswer: 'A',
          wrongAnswerOne: 'B',
          wrongAnswerTwo: 'C',
          wrongAnswerThree: 'D',
          explanation: '',
          attributes: const <ModelAttribute<dynamic>>[],
          achievementOne: mkPI('PI-1'),
          cineLevel: -1,
          // invalid
          estimatedTimeForAnswer: const Duration(seconds: 1),
          category: cat(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
