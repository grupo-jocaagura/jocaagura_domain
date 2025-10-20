import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelLearningGoal', () {
    ModelCompetencyStandard mkStd({
      String id = 'STD-1',
      String code = 'SCI.STD.1',
      String label = 'Std Label',
      String areaCat = 'sci',
      String areaDesc = 'Science',
      int cine = 1,
      int version = 1,
      bool active = true,
      int created = 1000,
      int updated = 2000,
      String author = 'teacher:ana',
    }) {
      return ModelCompetencyStandard(
        id: id,
        label: label,
        area: ModelCategory(category: areaCat, description: areaDesc),
        cineLevel: cine,
        code: code,
      );
    }

    ModelLearningGoal mkGoal({
      String id = 'GOAL-1',
      ModelCompetencyStandard? std,
      String label = 'Classify matter by composition',
      String code = 'SCI.MAT.G1',
      int version = 1,
      bool isActive = true,
      int createdAtMs = 1111,
      int updatedAtMs = 2222,
      String authorId = 'teacher:ana',
    }) {
      return ModelLearningGoal(
        id: id,
        standard: std ?? mkStd(),
        label: label,
        code: code,
      );
    }

    test(
      'Given a valid instance '
      'When toJson -> fromJson '
      'Then roundtrip preserves equality',
      () {
        final ModelLearningGoal g = mkGoal();
        final Map<String, dynamic> j = g.toJson();
        final ModelLearningGoal copy = ModelLearningGoal.fromJson(j);
        final ModelLearningGoal copyTwo = copy.copyWith();
        expect(copy, equals(g));
        expect(copy, equals(copyTwo));
        expect(j.containsKey(LearningGoalEnum.id.name), isTrue);
        expect(j.containsKey(LearningGoalEnum.standard.name), isTrue);
      },
    );

    test(
      'Given copyWith '
      'When overriding a subset of fields '
      'Then returns a modified instance and leaves others intact',
      () {
        final ModelLearningGoal base = mkGoal();
        final ModelCompetencyStandard newStd = mkStd(id: 'STD-2', code: 'C.2');

        final ModelLearningGoal changed = base.copyWith(
          id: 'GOAL-2',
          code: 'SCI.MAT.G2',
          standard: newStd,
        );

        expect(changed.id, 'GOAL-2');
        expect(changed.code, 'SCI.MAT.G2');

        expect(changed.standard, same(newStd));

        // Invariantes preservadas
        expect(changed.label, base.label);
      },
    );

    test(
      'Given fromJson with missing fields '
      'When defaults apply '
      'Then standard falls back to defaultCompetencyStandard and numerics to 0/1',
      () {
        final Map<String, dynamic> j = <String, dynamic>{
          // Solo label y code (lo demás ausente)
          LearningGoalEnum.label.name: 'L',
          LearningGoalEnum.code.name: 'C',
          // standard intencionalmente null → usa defaultCompetencyStandard
          LearningGoalEnum.standard.name: null,
        };

        final ModelLearningGoal g = ModelLearningGoal.fromJson(j);

        expect(g.id, ''); // Utils.getStringFromDynamic(null) → ''
        expect(g.label, 'L');
        expect(g.code, 'C');

        expect(g.standard, equals(defaultCompetencyStandard));
      },
    );

    test(
      'Given fromJson with nested standard as JSON String '
      'When parsed via Utils.mapFromDynamic '
      'Then builds nested ModelCompetencyStandard correctly',
      () {
        final ModelCompetencyStandard std = mkStd(
          id: 'STD-JSON',
          code: 'SCI.JSON',
          label: 'Std JSON',
        );
        final String stdJson = jsonEncode(std.toJson());

        final Map<String, dynamic> j = <String, dynamic>{
          LearningGoalEnum.id.name: 'GOAL-JSON',
          LearningGoalEnum.standard.name: stdJson, // String JSON
          LearningGoalEnum.label.name: 'L',
          LearningGoalEnum.code.name: 'C',
        };

        final ModelLearningGoal g = ModelLearningGoal.fromJson(j);

        expect(g.id, 'GOAL-JSON');

        expect(g.standard.id, 'STD-JSON');
        expect(g.standard.code, 'SCI.JSON');
        expect(g.standard.label, 'Std JSON');
      },
    );

    test(
      'Given equality and hashCode '
      'When two instances share same field values '
      'Then == is true and hashCodes are equal',
      () {
        final ModelLearningGoal a = mkGoal();
        final ModelLearningGoal b = mkGoal();

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));

        final ModelLearningGoal c = a.copyWith(code: 'DIFF');
        expect(a == c, isFalse);
      },
    );

    test(
      'Given toString '
      'When called '
      'Then returns parseable JSON and contains enum keys',
      () {
        final ModelLearningGoal g = mkGoal();
        final String s = g.toString();
        final dynamic decoded = jsonDecode(s);

        expect(decoded, isA<Map<String, dynamic>>());
        expect(s, contains(LearningGoalEnum.id.name));
        expect(s, contains(LearningGoalEnum.standard.name));
      },
    );

    test(
      'Given toJson '
      'When serializing '
      'Then standard is serialized as a nested Map (not an object reference)',
      () {
        final ModelLearningGoal g = mkGoal();
        final Map<String, dynamic> j = g.toJson();

        expect(j[LearningGoalEnum.standard.name], isA<Map<String, dynamic>>());
        final Map<String, dynamic> stdJson =
            j[LearningGoalEnum.standard.name] as Map<String, dynamic>;

        // Chequea algunas claves del enum del estándar:
        expect(stdJson.containsKey(CompetencyStandardEnum.id.name), isTrue);
        expect(stdJson.containsKey(CompetencyStandardEnum.code.name), isTrue);
      },
    );
  });
}
