import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('CompetencyStandard', () {
    ModelCompetencyStandard buildSample({
      String id = 'STD-MATH-ALG-001',
      String code = 'MATH.ALG.001',
      String label = 'Understands linear functions',
      int cine = 2,
      int ver = 1,
      int? created,
      int? updated,
      String author = 'teacher:ana',
    }) {
      return ModelCompetencyStandard(
        id: id,
        label: label,
        area: const ModelCategory(category: 'math', description: 'Mathematics'),
        cineLevel: cine,
        code: code,
      );
    }

    test(
      'Given instance '
      'When toJson->fromJson '
      'Then roundtrip preserves equality',
      () {
        final ModelCompetencyStandard std = buildSample();
        final Map<String, dynamic> json = std.toJson();
        final ModelCompetencyStandard copy =
            ModelCompetencyStandard.fromJson(json);
        expect(copy, equals(std));
        // Asegura que usamos enum keys
        expect(json.containsKey(CompetencyStandardEnum.id.name), isTrue);
      },
    );

    test(
      'Given missing fields in fromJson '
      'When defaults apply '
      'Then object is created with neutral values',
      () {
        final Map<String, dynamic> j = <String, dynamic>{
          CompetencyStandardEnum.area.name:
              const ModelCategory(category: 'math', description: 'Mathematics')
                  .toJson(),
        };

        final ModelCompetencyStandard parsed =
            ModelCompetencyStandard.fromJson(j);
        final ModelCompetencyStandard mimic = parsed.copyWith();
        expect(parsed, equals(mimic));
        expect(parsed.hashCode, isA<int>());
        expect(parsed.id, '');
        expect(parsed.label, '');
        expect(parsed.cineLevel, 0);
        expect(parsed.code, '');
      },
    );

    test(
      'Given copyWith '
      'When overriding some fields '
      'Then returns a modified instance leaving others intact',
      () {
        final ModelCompetencyStandard base = buildSample();
        final ModelCompetencyStandard changed = base.copyWith(
          id: 'STD-NEW',
          area: const ModelCategory(category: 'sci', description: 'Science'),
        );

        expect(changed.id, 'STD-NEW');

        expect(changed.area.category, 'sci');

        // Invariantes
        expect(changed.code, base.code);
      },
    );

    test(
      'Given toString '
      'When called '
      'Then returns JSON string with enum keys',
      () {
        final ModelCompetencyStandard std = buildSample();
        final String s = std.toString();
        expect(() => jsonDecode(s), returnsNormally);
        expect(s, contains(CompetencyStandardEnum.id.name));
        expect(s, contains(CompetencyStandardEnum.code.name));
      },
    );
  });
}
