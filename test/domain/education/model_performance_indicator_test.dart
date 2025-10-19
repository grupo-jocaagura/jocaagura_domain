import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelPerformanceIndicator', () {
    ModelLearningGoal mkGoal({
      String id = 'GOAL-1',
      String label = 'Classify matter by composition',
      String code = 'SCI.MAT.G1',
    }) {
      return ModelLearningGoal(
        id: id,
        standard: defaultCompetencyStandard,
        label: label,
        code: code,
        version: 1,
        isActive: true,
        createdAtMs: 0,
        updatedAtMs: 0,
        authorId: 'teacher:ana',
      );
    }

    ModelPerformanceIndicator mkInd({
      String id = 'IND-1',
      ModelLearningGoal? goal,
      String label = 'Recognizes H2O',
      PerformanceLevel level = PerformanceLevel.basic,
      String code = 'SCI.WAT.IND.1',
    }) {
      return ModelPerformanceIndicator(
        id: id,
        modelLearningGoal: goal ?? mkGoal(),
        label: label,
        level: level,
        code: code,
      );
    }

    test(
      'Given indicador válido '
      'When toJson -> fromJson '
      'Then roundtrip preserva igualdad',
      () {
        final ModelPerformanceIndicator ind = mkInd();
        final Map<String, dynamic> j = ind.toJson();

        final ModelPerformanceIndicator copy =
            ModelPerformanceIndicator.fromJson(j);

        expect(copy, equals(ind));
        // Claves esperadas
        expect(j.containsKey(PerformanceIndicatorEnum.id.name), isTrue);
        expect(j.containsKey(PerformanceIndicatorEnum.goal.name), isTrue);
        expect(j.containsKey(PerformanceIndicatorEnum.label.name), isTrue);
        expect(j.containsKey(PerformanceIndicatorEnum.level.name), isTrue);
        expect(j.containsKey(PerformanceIndicatorEnum.code.name), isTrue);
      },
    );

    test(
      'Given fromJson sin "goal" '
      'When se parsea '
      'Then usa defaultLearningGoal como anidado',
      () {
        final Map<String, dynamic> j = <String, dynamic>{
          PerformanceIndicatorEnum.id.name: 'IND-DEF',
          // goal ausente -> debe usar defaultLearningGoal
          PerformanceIndicatorEnum.label.name: 'Defaulted goal',
          PerformanceIndicatorEnum.level.name: 'high',
          PerformanceIndicatorEnum.code.name: 'SCI.DEF.IND',
        };

        final ModelPerformanceIndicator ind =
            ModelPerformanceIndicator.fromJson(j);

        expect(ind.id, 'IND-DEF');
        expect(ind.modelLearningGoal.id, 'GOAL-DEFAULT');
        expect(ind.modelLearningGoal.code, 'GEN.LEARN.DEFAULT');
        expect(ind.modelLearningGoal.label, 'Undefined learning goal');
        expect(ind.level, PerformanceLevel.high);
      },
    );

    test(
      'Given fromJson con goal como String JSON '
      'When se normaliza via Utils.mapFromDynamic '
      'Then construye goal anidado correctamente',
      () {
        final ModelLearningGoal g = mkGoal(
          id: 'GOAL-S',
          label: 'Goal String',
          code: 'SCI.G.S',
        );
        final String goalJson = jsonEncode(g.toJson());

        final Map<String, dynamic> j = <String, dynamic>{
          PerformanceIndicatorEnum.id.name: 'IND-S',
          PerformanceIndicatorEnum.goal.name: goalJson, // String JSON
          PerformanceIndicatorEnum.label.name: 'Lbl',
          PerformanceIndicatorEnum.level.name: 'LOW', // mayúsculas
          PerformanceIndicatorEnum.code.name: 'C.1',
        };

        final ModelPerformanceIndicator ind =
            ModelPerformanceIndicator.fromJson(j);

        expect(ind.id, 'IND-S');
        expect(ind.modelLearningGoal.id, 'GOAL-S');
        expect(ind.modelLearningGoal.code, 'SCI.G.S');
        expect(ind.level, PerformanceLevel.low);
      },
    );

    test(
      'Given fromJson con level desconocido '
      'When se parsea '
      'Then level cae a PerformanceLevel.basic',
      () {
        final Map<String, dynamic> j = <String, dynamic>{
          PerformanceIndicatorEnum.id.name: 'IND-L',
          PerformanceIndicatorEnum.goal.name: mkGoal().toJson(),
          PerformanceIndicatorEnum.label.name: 'Lbl',
          PerformanceIndicatorEnum.level.name: 'unknown',
          PerformanceIndicatorEnum.code.name: 'C.X',
        };

        final ModelPerformanceIndicator ind =
            ModelPerformanceIndicator.fromJson(j);

        expect(ind.level, PerformanceLevel.basic);
      },
    );

    test(
      'Given listFromDynamic con String JSON '
      'When hay objetos y elementos no-objeto '
      'Then solo se parsean los objetos',
      () {
        final ModelPerformanceIndicator a = mkInd(id: 'A');
        final ModelPerformanceIndicator b = mkInd(id: 'B');

        final String json = jsonEncode(<dynamic>[
          a.toJson(),
          123, // ignorado
          b.toJson(),
          'noise', // ignorado
        ]);

        final List<ModelPerformanceIndicator> out =
            ModelPerformanceIndicator.listFromDynamic(json);

        expect(out.length, 2);
        expect(out.first.id, 'A');
        expect(out.last.id, 'B');
      },
    );

    test(
      'Given listFromDynamic con estructura no-String '
      'When delega a Utils.listFromDynamic '
      'Then parsea correctamente',
      () {
        final ModelPerformanceIndicator a = mkInd(id: 'X');
        final ModelPerformanceIndicator b = mkInd(id: 'Y');

        final List<Map<String, dynamic>> raw = <Map<String, dynamic>>[
          a.toJson(),
          b.toJson(),
        ];

        final List<ModelPerformanceIndicator> out =
            ModelPerformanceIndicator.listFromDynamic(raw);

        expect(out.length, 2);
        expect(out[0], equals(a));
        expect(out[1], equals(b));
      },
    );

    test(
      'Given copyWith '
      'When se modifican algunos campos '
      'Then retorna instancia actualizada y respeta invariantes',
      () {
        final ModelPerformanceIndicator base = mkInd();
        final ModelLearningGoal newGoal = mkGoal(id: 'GOAL-2');

        final ModelPerformanceIndicator changed = base.copyWith(
          id: 'IND-2',
          modelLearningGoal: newGoal,
          label: 'Recognizes CO2',
          level: PerformanceLevel.superior,
          code: 'SCI.GAS.IND.2',
        );

        expect(changed.id, 'IND-2');
        expect(changed.modelLearningGoal.id, 'GOAL-2');
        expect(changed.label, 'Recognizes CO2');
        expect(changed.level, PerformanceLevel.superior);
        expect(changed.code, 'SCI.GAS.IND.2');
      },
    );

    test(
      'Given igualdad/hashCode '
      'When dos instancias comparten mismos valores '
      'Then == es true y hashCodes coinciden',
      () {
        final ModelPerformanceIndicator a = mkInd();
        final ModelPerformanceIndicator b = mkInd();

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));

        // Cambio mínimo
        final ModelPerformanceIndicator c = a.copyWith(code: 'DIFF');
        expect(a == c, isFalse);
      },
    );

    test(
      'Given toString '
      'When se invoca '
      'Then retorna JSON parseable y contiene claves del enum',
      () {
        final ModelPerformanceIndicator ind = mkInd();
        final String s = ind.toString();

        expect(() => jsonDecode(s), returnsNormally);
        expect(s, contains(PerformanceIndicatorEnum.id.name));
        expect(s, contains(PerformanceIndicatorEnum.goal.name));
        expect(s, contains(PerformanceIndicatorEnum.level.name));
      },
    );

    test(
      'Given listFromDynamic con JSON inválido '
      'When se parsea '
      'Then retorna lista vacía (tolerancia a fallos)',
      () {
        const String bad = 'no es json';
        final List<ModelPerformanceIndicator> out =
            ModelPerformanceIndicator.listFromDynamic(bad);
        expect(out, isEmpty);
      },
    );
  });
}
