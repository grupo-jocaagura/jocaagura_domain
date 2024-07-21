import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('DiagnosisModel Tests', () {
    const String id = 'xox';
    const String title = 'diagnostico';
    const String description = 'Descripcion del diagnostico';

    test('default model is correct', () {
      expect(defaultDiagnosisModel, isA<DiagnosisModel>());
      expect(defaultDiagnosisModel.id, id);
      expect(defaultDiagnosisModel.title, title);
      expect(defaultDiagnosisModel.description, description);
    });

    test('constructor sets values properly', () {
      const DiagnosisModel diagnosis = DiagnosisModel(
        id: id,
        title: title,
        description: description,
      );

      expect(diagnosis.id, id);
      expect(diagnosis.title, title);
      expect(diagnosis.description, description);
    });

    test('copyWith updates values', () {
      final DiagnosisModel updatedDiagnosis = defaultDiagnosisModel.copyWith(
        id: 'newId',
        title: 'newTitle',
        description: 'newDescription',
      );

      expect(updatedDiagnosis.id, 'newId');
      expect(updatedDiagnosis.title, 'newTitle');
      expect(updatedDiagnosis.description, 'newDescription');
    });

    test('copyWith without arguments returns the same object', () {
      final DiagnosisModel copiedDiagnosis = defaultDiagnosisModel.copyWith();
      expect(copiedDiagnosis, equals(defaultDiagnosisModel));
      expect(copiedDiagnosis.hashCode, equals(defaultDiagnosisModel.hashCode));
    });

    test('toJson returns correct map', () {
      const DiagnosisModel diagnosis = defaultDiagnosisModel;
      final Map<String, dynamic> json = diagnosis.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json[DiagnosisModelEnum.id.name], id);
      expect(json[DiagnosisModelEnum.title.name], title);
      expect(json[DiagnosisModelEnum.description.name], description);
    });

    test('fromJson creates a new instance from json', () {
      final Map<String, String> json = <String, String>{
        DiagnosisModelEnum.id.name: 'newId',
        DiagnosisModelEnum.title.name: 'newTitle',
        DiagnosisModelEnum.description.name: 'newDescription',
      };

      final DiagnosisModel fromJsonDiagnosis = DiagnosisModel.fromJson(json);
      expect(fromJsonDiagnosis, isA<DiagnosisModel>());
      expect(fromJsonDiagnosis.id, 'newId');
      expect(fromJsonDiagnosis.title, 'newTitle');
      expect(fromJsonDiagnosis.description, 'newDescription');
    });

    test('hashCode is consistent for the same values', () {
      const DiagnosisModel diagnosis1 = defaultDiagnosisModel;
      const DiagnosisModel diagnosis2 = defaultDiagnosisModel;

      expect(diagnosis1.hashCode, diagnosis2.hashCode);
    });

    test('equality operator works correctly', () {
      const DiagnosisModel diagnosis1 = defaultDiagnosisModel;
      const DiagnosisModel diagnosis2 = defaultDiagnosisModel;

      expect(diagnosis1, equals(diagnosis2));
    });
  });
}
