import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('MedicationModel Tests', () {
    // Datos de prueba
    const String id = 'med001';
    const String name = 'Ibuprofeno';
    const String dosage = '200mg';
    const String frequency = 'Cada 8 horas';
    final DateTime startDate = DateTime(2024, 07, 20);
    final DateTime endDate = DateTime(2024, 07, 25);

    // Test del modelo por defecto
    test('default model is correct', () {
      expect(defaultMedicationModel, isA<MedicationModel>());
      expect(defaultMedicationModel.id, id);
      expect(defaultMedicationModel.name, name);
      expect(defaultMedicationModel.dosage, dosage);
      expect(defaultMedicationModel.frequency, frequency);
      expect(defaultMedicationModel.startDate, startDate);
      expect(defaultMedicationModel.endDate, endDate);
    });

    // Test del constructor
    test('constructor sets values properly', () {
      final MedicationModel medication = MedicationModel(
        id: id,
        name: name,
        dosage: dosage,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
      );

      expect(medication.id, id);
      expect(medication.name, name);
      expect(medication.dosage, dosage);
      expect(medication.frequency, frequency);
      expect(medication.startDate, startDate);
      expect(medication.endDate, endDate);
    });

    // Test del método copyWith que actualiza valores
    test('copyWith updates values', () {
      final MedicationModel updatedMedication = defaultMedicationModel.copyWith(
        id: 'med002',
        name: 'Paracetamol',
        dosage: '500mg',
        frequency: 'Cada 6 horas',
        startDate: DateTime(2024, 07, 21),
        endDate: DateTime(2024, 07, 26),
      );

      expect(updatedMedication.id, 'med002');
      expect(updatedMedication.name, 'Paracetamol');
      expect(updatedMedication.dosage, '500mg');
      expect(updatedMedication.frequency, 'Cada 6 horas');
      expect(updatedMedication.startDate, DateTime(2024, 07, 21));
      expect(updatedMedication.endDate, DateTime(2024, 07, 26));
    });

    // Test del método copyWith sin argumentos que debería devolver el mismo objeto
    test('copyWith without arguments returns the same object', () {
      final MedicationModel copiedMedication =
          defaultMedicationModel.copyWith();
      expect(copiedMedication, equals(defaultMedicationModel));
      expect(
        copiedMedication.hashCode,
        equals(defaultMedicationModel.hashCode),
      );
    });

    // Test del método toJson
    test('toJson returns correct map', () {
      final MedicationModel medication = defaultMedicationModel;
      final Map<String, dynamic> json = medication.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json[MedicationEnum.id.name], id);
      expect(json[MedicationEnum.name.name], name);
      expect(json[MedicationEnum.dosage.name], dosage);
      expect(json[MedicationEnum.frequency.name], frequency);
      expect(
        json[MedicationEnum.startDate.name],
        DateUtils.dateTimeToString(startDate),
      );
      expect(
        json[MedicationEnum.endDate.name],
        DateUtils.dateTimeToString(endDate),
      );
    });

    // Test del método fromJson
    test('fromJson creates a new instance from json', () {
      final Map<String, String> json = <String, String>{
        MedicationEnum.id.name: 'med003',
        MedicationEnum.name.name: 'Amoxicilina',
        MedicationEnum.dosage.name: '250mg',
        MedicationEnum.frequency.name: 'Cada 12 horas',
        MedicationEnum.startDate.name:
            DateUtils.dateTimeToString(DateTime(2024, 07, 22)),
        MedicationEnum.endDate.name:
            DateUtils.dateTimeToString(DateTime(2024, 07, 27)),
      };

      final MedicationModel fromJsonMedication = MedicationModel.fromJson(json);
      expect(fromJsonMedication, isA<MedicationModel>());
      expect(fromJsonMedication.id, 'med003');
      expect(fromJsonMedication.name, 'Amoxicilina');
      expect(fromJsonMedication.dosage, '250mg');
      expect(fromJsonMedication.frequency, 'Cada 12 horas');
      expect(fromJsonMedication.startDate, DateTime(2024, 07, 22));
      expect(fromJsonMedication.endDate, DateTime(2024, 07, 27));
    });

    // Test del hashCode para verificar consistencia con los mismos valores
    test('hashCode is consistent for the same values', () {
      final MedicationModel medication1 = defaultMedicationModel;
      final MedicationModel medication2 = defaultMedicationModel;

      expect(medication1.hashCode, medication2.hashCode);
    });

    // Test del hashCode con copyWith sin argumentos
    test('hashCode remains the same when using copyWith without arguments', () {
      final MedicationModel copiedMedication =
          defaultMedicationModel.copyWith();
      expect(copiedMedication.hashCode, defaultMedicationModel.hashCode);
    });

    // Test del operador de igualdad
    test('equality operator works correctly', () {
      final MedicationModel medication1 = defaultMedicationModel;
      final MedicationModel medication2 = defaultMedicationModel;

      expect(medication1, equals(medication2));
    });

    // Agrega cualquier prueba adicional aquí para cubrir casos extremos u otros métodos
  });
}
