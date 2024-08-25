part of '../../jocaagura_domain.dart';

enum AppointmentEnum {
  id,
  date,
  odontologist,
  purpose,
  status,
  notes,
}

final AppointmentModel defaultAppointmentModel = AppointmentModel(
  id: 'appt001',
  date: DateTime(2024, 07, 24),
  odontologist: 'Dr. Juan Pérez',
  purpose: 'Consulta General',
  status: 'Pendiente',
  notes: 'Revisar dolor en la muela',
);

/// Represents an appointment within a healthcare management application.
///
/// This model class encapsulates the details of a dental appointment,
/// including information such as the date, the attending odontologist,
/// the purpose of the visit, the current status of the appointment, and
/// any additional notes related to the appointment.
///
/// Example of using [AppointmentModel] in a practical application:
///
/// ```dart
/// void main() {
///   var appointment = AppointmentModel(
///     id: 'appt001',
///     date: DateTime.now(),
///     odontologist: 'Dr. Juan Pérez',
///     purpose: 'Consulta General',
///     status: 'Pendiente',
///     notes: 'Revisar dolor en la muela',
///   );
///
///   print('Appointment ID: ${appointment.id}');
///   print('Date: ${appointment.date}');
///   print('Odontologist: ${appointment.odontologist}');
///   print('Purpose: ${appointment.purpose}');
///   print('Status: ${appointment.status}');
///   print('Notes: ${appointment.notes}');
/// }
/// ```
///
/// This class is useful for managing and tracking dental appointments,
/// ensuring that all relevant details are recorded and easily accessible.
class AppointmentModel extends Model {
  /// Constructs a new [AppointmentModel] with the given details.
  const AppointmentModel({
    required this.id,
    required this.date,
    required this.odontologist,
    required this.purpose,
    required this.status,
    required this.notes,
  });

  /// Deserializes a JSON map into an instance of [AppointmentModel].
  ///
  /// The JSON map must contain keys for 'id', 'date', 'odontologist',
  /// 'purpose', 'status', and 'notes' with appropriate values.
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: Utils.getStringFromDynamic(json[AppointmentEnum.id.name]),
      date: DateUtils.dateTimeFromDynamic(json[AppointmentEnum.date.name]),
      odontologist:
          Utils.getStringFromDynamic(json[AppointmentEnum.odontologist.name]),
      purpose: Utils.getStringFromDynamic(json[AppointmentEnum.purpose.name]),
      status: Utils.getStringFromDynamic(json[AppointmentEnum.status.name]),
      notes: Utils.getStringFromDynamic(json[AppointmentEnum.notes.name]),
    );
  }

  /// A unique identifier for the appointment.
  final String id;

  /// The date and time of the appointment.
  final DateTime date;

  /// The name of the odontologist attending the appointment.
  final String odontologist;

  /// The purpose of the appointment.
  final String purpose;

  /// The current status of the appointment (e.g., Pending, Confirmed, Completed).
  final String status;

  /// Additional notes related to the appointment.
  final String notes;

  /// Creates a copy of this [AppointmentModel] with optional new values.
  @override
  AppointmentModel copyWith({
    String? id,
    DateTime? date,
    String? odontologist,
    String? purpose,
    String? status,
    String? notes,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      date: date ?? this.date,
      odontologist: odontologist ?? this.odontologist,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  /// Serializes this [AppointmentModel] into a JSON map.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      AppointmentEnum.id.name: id,
      AppointmentEnum.date.name: DateUtils.dateTimeToString(date),
      AppointmentEnum.odontologist.name: odontologist,
      AppointmentEnum.purpose.name: purpose,
      AppointmentEnum.status.name: status,
      AppointmentEnum.notes.name: notes,
    };
  }

  /// Determines if two [AppointmentModel] instances are equal.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppointmentModel &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            date == other.date &&
            odontologist == other.odontologist &&
            purpose == other.purpose &&
            status == other.status &&
            notes == other.notes &&
            hashCode == other.hashCode;
  }

  /// Returns the hash code for this [AppointmentModel].
  @override
  int get hashCode =>
      Object.hash(id, date, odontologist, purpose, status, notes);
}
