import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('DentalConditionModel Tests', () {
    // Define test data
    const String id = 'xxiv';
    const int dentalId = 11;
    const DentalRegionEnum dentalRegion = DentalRegionEnum.gingival;
    const ToothConditionEnum condition = ToothConditionEnum.healthy;
    final DateTime dateTimeOfRecord = DateTime(2024, 07, 24);

    // Test the default model
    test('default model is correct', () {
      expect(dentalConditionModelDefault, isA<DentalConditionModel>());
      expect(dentalConditionModelDefault.id, id);
      expect(dentalConditionModelDefault.dentalId, dentalId);
      expect(dentalConditionModelDefault.dentalRegion, dentalRegion);
      expect(dentalConditionModelDefault.condition, condition);
      expect(dentalConditionModelDefault.dateTimeOfRecord, dateTimeOfRecord);
    });

    // Test the constructor
    test('constructor sets values properly', () {
      final DentalConditionModel dentalCondition = DentalConditionModel(
        id: id,
        dentalId: dentalId,
        dentalRegion: dentalRegion,
        condition: condition,
        dateTimeOfRecord: dateTimeOfRecord,
      );

      expect(dentalCondition.id, id);
      expect(dentalCondition.dentalId, dentalId);
      expect(dentalCondition.dentalRegion, dentalRegion);
      expect(dentalCondition.condition, condition);
      expect(dentalCondition.dateTimeOfRecord, dateTimeOfRecord);
    });

    // Test copyWith
    test('copyWith updates values', () {
      final DentalConditionModel updatedCondition =
          dentalConditionModelDefault.copyWith(
        id: 'newId',
        dentalId: 12,
        dentalRegion: DentalRegionEnum.occlusal,
        condition: ToothConditionEnum.cavity,
        dateTimeOfRecord: DateTime(2025, 07, 24),
      );

      expect(updatedCondition.id, 'newId');
      expect(updatedCondition.dentalId, 12);
      expect(updatedCondition.dentalRegion, DentalRegionEnum.occlusal);
      expect(updatedCondition.condition, ToothConditionEnum.cavity);
      expect(updatedCondition.dateTimeOfRecord, DateTime(2025, 07, 24));
    });

    test('copyWith without arguments returns the same object', () {
      final DentalConditionModel copiedCondition =
          dentalConditionModelDefault.copyWith();
      expect(copiedCondition, equals(dentalConditionModelDefault));
      expect(
        copiedCondition.hashCode,
        equals(dentalConditionModelDefault.hashCode),
      );
    });

    // Test toJson
    test('toJson returns correct map', () {
      final DentalConditionModel dentalCondition = dentalConditionModelDefault;
      final Map<String, dynamic> json = dentalCondition.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json[DentalConditionEnum.id.name], id);
      expect(json[DentalConditionEnum.dentalId.name], dentalId);
      expect(json[DentalConditionEnum.dentalRegion.name], dentalRegion.name);
      expect(json[DentalConditionEnum.condition.name], condition.name);
      expect(
        json[DentalConditionEnum.dateTimeOfRecord.name],
        DateUtils.dateTimeToString(dateTimeOfRecord),
      );
    });

    // Test fromJson
    test('fromJson creates a new instance from json', () {
      final Map<String, Object> json = <String, Object>{
        DentalConditionEnum.id.name: 'newId',
        DentalConditionEnum.dentalId.name: 12,
        DentalConditionEnum.dentalRegion.name: 'occlusal',
        DentalConditionEnum.condition.name: 'cavity',
        DentalConditionEnum.dateTimeOfRecord.name:
            DateUtils.dateTimeToString(DateTime(2025, 07, 24)),
      };

      final DentalConditionModel fromJsonCondition =
          DentalConditionModel.fromJson(json);
      expect(fromJsonCondition, isA<DentalConditionModel>());
      expect(fromJsonCondition.id, 'newId');
      expect(fromJsonCondition.dentalId, 12);
      expect(fromJsonCondition.dentalRegion, DentalRegionEnum.occlusal);
      expect(fromJsonCondition.condition, ToothConditionEnum.cavity);
      expect(fromJsonCondition.dateTimeOfRecord, DateTime(2025, 07, 24));
    });

    // Test hashCode
    test('hashCode is consistent for the same values', () {
      final DentalConditionModel condition1 = dentalConditionModelDefault;
      final DentalConditionModel condition2 = dentalConditionModelDefault;

      expect(condition1.hashCode, condition2.hashCode);
    });

    // Test equality operator
    test('equality operator works correctly', () {
      final DentalConditionModel condition1 = dentalConditionModelDefault;
      final DentalConditionModel condition2 = dentalConditionModelDefault;

      expect(condition1, equals(condition2));
    });
  });

  group('DentalConditionModel Method Tests', () {
    // Test getDentalRegionFromString
    test('getDentalRegionFromString returns correct enum for valid strings',
        () {
      expect(
        DentalConditionModel.getDentalRegionFromString('occlusal'),
        DentalRegionEnum.occlusal,
      );
      expect(
        DentalConditionModel.getDentalRegionFromString('vestibular'),
        DentalRegionEnum.vestibular,
      );
      expect(
        DentalConditionModel.getDentalRegionFromString('mesial'),
        DentalRegionEnum.mesial,
      );
      expect(
        DentalConditionModel.getDentalRegionFromString('distal'),
        DentalRegionEnum.distal,
      );
      expect(
        DentalConditionModel.getDentalRegionFromString('palatal'),
        DentalRegionEnum.palatal,
      );
      expect(
        DentalConditionModel.getDentalRegionFromString('lingual'),
        DentalRegionEnum.lingual,
      );
      expect(
        DentalConditionModel.getDentalRegionFromString('buccal'),
        DentalRegionEnum.buccal,
      );
      expect(
        DentalConditionModel.getDentalRegionFromString('labial'),
        DentalRegionEnum.labial,
      );
      expect(
        DentalConditionModel.getDentalRegionFromString('incisal'),
        DentalRegionEnum.incisal,
      );
      expect(
        DentalConditionModel.getDentalRegionFromString('gingival'),
        DentalRegionEnum.gingival,
      );
      expect(
        DentalConditionModel.getDentalRegionFromString('periodontal'),
        DentalRegionEnum.periodontal,
      );
      expect(
        DentalConditionModel.getDentalRegionFromString('maxillary'),
        DentalRegionEnum.maxillary,
      );
      expect(
        DentalConditionModel.getDentalRegionFromString('mandibular'),
        DentalRegionEnum.mandibular,
      );
      expect(
        DentalConditionModel.getDentalRegionFromString('none'),
        DentalRegionEnum.none,
      );
    });

    test('getDentalRegionFromString returns none for invalid string', () {
      expect(
        DentalConditionModel.getDentalRegionFromString('invalid'),
        DentalRegionEnum.none,
      );
    });

    // Test getToothConditionFromString
    test('getToothConditionFromString returns correct enum for valid strings',
        () {
      expect(
        DentalConditionModel.getToothConditionFromString('healthy'),
        ToothConditionEnum.healthy,
      );
      expect(
        DentalConditionModel.getToothConditionFromString('cavity'),
        ToothConditionEnum.cavity,
      );
      expect(
        DentalConditionModel.getToothConditionFromString('filled'),
        ToothConditionEnum.filled,
      );
      expect(
        DentalConditionModel.getToothConditionFromString('missing'),
        ToothConditionEnum.missing,
      );
      expect(
        DentalConditionModel.getToothConditionFromString('broken'),
        ToothConditionEnum.broken,
      );
      expect(
        DentalConditionModel.getToothConditionFromString('sensitive'),
        ToothConditionEnum.sensitive,
      );
      expect(
        DentalConditionModel.getToothConditionFromString('impacted'),
        ToothConditionEnum.impacted,
      );
      expect(
        DentalConditionModel.getToothConditionFromString('decayed'),
        ToothConditionEnum.decayed,
      );
      expect(
        DentalConditionModel.getToothConditionFromString('root canal'),
        ToothConditionEnum.rootCanal,
      );
      expect(
        DentalConditionModel.getToothConditionFromString('crown'),
        ToothConditionEnum.crown,
      );
      expect(
        DentalConditionModel.getToothConditionFromString('extraction needed'),
        ToothConditionEnum.extractionNeeded,
      );
      expect(
        DentalConditionModel.getToothConditionFromString('orthodontic issue'),
        ToothConditionEnum.orthodonticIssue,
      );
      expect(
        DentalConditionModel.getToothConditionFromString('none'),
        ToothConditionEnum.none,
      );
    });

    test('getToothConditionFromString returns none for invalid string', () {
      expect(
        DentalConditionModel.getToothConditionFromString('invalid'),
        ToothConditionEnum.none,
      );
    });

    // Test getDentalIDFromString
    test('getDentalIDFromString returns correct enum for valid strings', () {
      expect(
        DentalConditionModel.getDentalIDFromString('11'),
        DentalIDEnum.q11,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('12'),
        DentalIDEnum.q12,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('13'),
        DentalIDEnum.q13,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('14'),
        DentalIDEnum.q14,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('15'),
        DentalIDEnum.q15,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('16'),
        DentalIDEnum.q16,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('17'),
        DentalIDEnum.q17,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('18'),
        DentalIDEnum.q18,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('21'),
        DentalIDEnum.q21,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('22'),
        DentalIDEnum.q22,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('23'),
        DentalIDEnum.q23,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('24'),
        DentalIDEnum.q24,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('25'),
        DentalIDEnum.q25,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('26'),
        DentalIDEnum.q26,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('27'),
        DentalIDEnum.q27,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('28'),
        DentalIDEnum.q28,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('31'),
        DentalIDEnum.q31,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('32'),
        DentalIDEnum.q32,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('33'),
        DentalIDEnum.q33,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('34'),
        DentalIDEnum.q34,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('35'),
        DentalIDEnum.q35,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('36'),
        DentalIDEnum.q36,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('37'),
        DentalIDEnum.q37,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('38'),
        DentalIDEnum.q38,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('41'),
        DentalIDEnum.q41,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('42'),
        DentalIDEnum.q42,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('43'),
        DentalIDEnum.q43,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('44'),
        DentalIDEnum.q44,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('45'),
        DentalIDEnum.q45,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('46'),
        DentalIDEnum.q46,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('47'),
        DentalIDEnum.q47,
      );
      expect(
        DentalConditionModel.getDentalIDFromString('48'),
        DentalIDEnum.q48,
      );
    });

    test('getDentalIDFromString returns q11 for invalid string', () {
      expect(
        DentalConditionModel.getDentalIDFromString('invalid'),
        DentalIDEnum.q11,
      );
    });

    // Test getDentalIDAsInt
    test('getDentalIDAsInt returns correct int for valid string', () {
      expect(DentalConditionModel.getDentalIDAsInt('11'), 11);
      expect(DentalConditionModel.getDentalIDAsInt('21'), 21);
      expect(DentalConditionModel.getDentalIDAsInt('31'), 31);
      expect(DentalConditionModel.getDentalIDAsInt('41'), 41);
      expect(DentalConditionModel.getDentalIDAsInt('42'), 42);
      expect(DentalConditionModel.getDentalIDAsInt('43'), 43);
      expect(DentalConditionModel.getDentalIDAsInt('44'), 44);
      expect(DentalConditionModel.getDentalIDAsInt('45'), 45);
      expect(DentalConditionModel.getDentalIDAsInt('46'), 46);
      expect(DentalConditionModel.getDentalIDAsInt('47'), 47);
      expect(DentalConditionModel.getDentalIDAsInt('48'), 48);
      expect(DentalConditionModel.getDentalIDAsInt('49'), 11);
    });

    test('getDentalIDAsInt returns 11 for invalid string', () {
      expect(DentalConditionModel.getDentalIDAsInt('invalid'), 11);
    });
  });
}
