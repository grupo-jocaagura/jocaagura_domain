import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('AppointmentModel Tests', () {
    // Define test data
    const String id = 'appt001';
    final DateTime date = DateTime(2024, 07, 24);
    const String odontologist = 'Dr. Juan Pérez';
    const String purpose = 'Consulta General';
    const String status = 'Pendiente';
    const String notes = 'Revisar dolor en la muela';

    // Test the default model
    test('default model is correct', () {
      expect(defaultAppointmentModel, isA<AppointmentModel>());
      expect(defaultAppointmentModel.id, id);
      expect(defaultAppointmentModel.date, date);
      expect(defaultAppointmentModel.odontologist, odontologist);
      expect(defaultAppointmentModel.purpose, purpose);
      expect(defaultAppointmentModel.status, status);
      expect(defaultAppointmentModel.notes, notes);
    });

    // Test the constructor
    test('constructor sets values properly', () {
      final AppointmentModel appointment = AppointmentModel(
        id: id,
        date: date,
        odontologist: odontologist,
        purpose: purpose,
        status: status,
        notes: notes,
      );

      expect(appointment.id, id);
      expect(appointment.date, date);
      expect(appointment.odontologist, odontologist);
      expect(appointment.purpose, purpose);
      expect(appointment.status, status);
      expect(appointment.notes, notes);
    });

    // Test copyWith
    test('copyWith updates values', () {
      final AppointmentModel updatedAppointment =
          defaultAppointmentModel.copyWith(
        id: 'new_id',
        date: DateTime(2025, 07, 24),
        odontologist: 'Dr. María López',
        purpose: 'Limpieza Dental',
        status: 'Confirmado',
        notes: 'Paciente solicita revisión adicional',
      );

      expect(updatedAppointment.id, 'new_id');
      expect(updatedAppointment.date, DateTime(2025, 07, 24));
      expect(updatedAppointment.odontologist, 'Dr. María López');
      expect(updatedAppointment.purpose, 'Limpieza Dental');
      expect(updatedAppointment.status, 'Confirmado');
      expect(updatedAppointment.notes, 'Paciente solicita revisión adicional');
    });

    test('copyWith without arguments returns the same object', () {
      final AppointmentModel copiedAppointment =
          defaultAppointmentModel.copyWith();
      expect(copiedAppointment, equals(defaultAppointmentModel));
      expect(
          copiedAppointment.hashCode, equals(defaultAppointmentModel.hashCode));
    });

    // Test toJson
    test('toJson returns correct map', () {
      final AppointmentModel appointment = defaultAppointmentModel;
      final Map<String, dynamic> json = appointment.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json[AppointmentEnum.id.name], id);
      expect(json[AppointmentEnum.date.name], DateUtils.dateTimeToString(date));
      expect(json[AppointmentEnum.odontologist.name], odontologist);
      expect(json[AppointmentEnum.purpose.name], purpose);
      expect(json[AppointmentEnum.status.name], status);
      expect(json[AppointmentEnum.notes.name], notes);
    });

    // Test fromJson
    test('fromJson creates a new instance from json', () {
      final Map<String, String> json = <String, String>{
        AppointmentEnum.id.name: 'new_id',
        AppointmentEnum.date.name:
            DateUtils.dateTimeToString(DateTime(2025, 07, 24)),
        AppointmentEnum.odontologist.name: 'Dr. María López',
        AppointmentEnum.purpose.name: 'Limpieza Dental',
        AppointmentEnum.status.name: 'Confirmado',
        AppointmentEnum.notes.name: 'Paciente solicita revisión adicional',
      };

      final AppointmentModel fromJsonAppointment =
          AppointmentModel.fromJson(json);
      expect(fromJsonAppointment, isA<AppointmentModel>());
      expect(fromJsonAppointment.id, 'new_id');
      expect(fromJsonAppointment.date, DateTime(2025, 07, 24));
      expect(fromJsonAppointment.odontologist, 'Dr. María López');
      expect(fromJsonAppointment.purpose, 'Limpieza Dental');
      expect(fromJsonAppointment.status, 'Confirmado');
      expect(fromJsonAppointment.notes, 'Paciente solicita revisión adicional');
    });

    // Test hashCode
    test('hashCode is consistent for the same values', () {
      final AppointmentModel appointment1 = defaultAppointmentModel;
      final AppointmentModel appointment2 = defaultAppointmentModel;

      expect(appointment1.hashCode, appointment2.hashCode);
    });

    // Test equality operator
    test('equality operator works correctly', () {
      final AppointmentModel appointment1 = defaultAppointmentModel;
      final AppointmentModel appointment2 = defaultAppointmentModel;

      expect(appointment1, equals(appointment2));
    });

    // Add any additional tests here to cover edge cases or other methods
  });
}
