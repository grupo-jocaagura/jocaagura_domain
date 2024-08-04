part of '../../jocaagura_domain.dart';

enum AcceptanceClauseEnum {
  id,
  odontologistSignature,
  patientPrint,
  patientSignature,
  stringAcceptanceLeyend,
}

final SignatureModel defaultOdontologistSignature = SignatureModel(
  id: 'sig123',
  created: DateTime.now(),
  appId: 'appOdonto123',
  png64Image: 'base64EncodedImageStringForOdontologistSignature',
);

final SignatureModel defaultPatientSignature = SignatureModel(
  id: 'sig456',
  created: DateTime.now(),
  appId: 'appPatient456',
  png64Image: 'base64EncodedImageStringForPatientSignature',
);

final AcceptanceClauseModel defaultAcceptanceClauseModel =
    AcceptanceClauseModel(
  id: 'acm789',
  odontologistSignature: defaultOdontologistSignature,
  patientPrint: 'patientPrintData',
  patientSignature: defaultPatientSignature,
  stringAcceptanceLeyend: '''
# Términos de Aceptación
Por la presente, yo, el paciente, acepto los términos y condiciones del tratamiento odontológico proporcionado por [Nombre del odontólogo] y confirmo que he sido informado adecuadamente sobre los procedimientos y riesgos involucrados.

Firma del Odontólogo: ![Firma del Odontólogo](data:image/png;base64,base64EncodedImageStringForOdontologistSignature)
Firma del Paciente: ![Firma del Paciente](data:image/png;base64,base64EncodedImageStringForPatientSignature)

ID: xmio
    ''',
);

/// Represents an acceptance clause within a healthcare management application.
///
/// This model class encapsulates an acceptance clause for treatments, typically involving
/// legal agreements between the odontologist and the patient. It includes signatures and
/// other forms of consent from both parties.
///
/// Example of using [AcceptanceClauseModel] in a practical application:
///
/// ```dart
/// void main() {
///   var odontologistSignature = SignatureModel(
///     id: '001',
///     created: DateTime.now(),
///     appId: 'DentalApp',
///     png64Image: 'base64EncodedImage',
///   );
///
///   var patientSignature = SignatureModel(
///     id: '002',
///     created: DateTime.now(),
///     appId: 'DentalApp',
///     png64Image: 'base64EncodedImage',
///   );
///
///   var acceptanceClause = AcceptanceClauseModel(
///     id: 'AC001',
///     odontologistSignature: odontologistSignature,
///     patientPrint: 'John Doe',
///     patientSignature: patientSignature,
///     stringAcceptanceLeyend: 'I hereby accept the terms of the treatment.',
///   );
///
///   print('Acceptance Clause ID: ${acceptanceClause.id}');
///   print('Odontologist Signature ID: ${acceptanceClause.odontologistSignature.id}');
///   print('Patient Print: ${acceptanceClause.patientPrint}');
///   print('Patient Signature ID: ${acceptanceClause.patientSignature.id}');
///   print('Acceptance Leyend: ${acceptanceClause.stringAcceptanceLeyend}');
/// }
/// ```
///
/// This class is crucial for managing consent and legal acknowledgments in contexts
/// where medical treatments require clear agreements and records of patient consent.
class AcceptanceClauseModel extends Model {
  /// Constructs a new [AcceptanceClauseModel] with the given [id], [odontologistSignature],
  /// [patientPrint], [patientSignature], and [stringAcceptanceLeyend].
  const AcceptanceClauseModel({
    required this.id,
    required this.odontologistSignature,
    required this.patientPrint,
    required this.patientSignature,
    required this.stringAcceptanceLeyend,
  });

  /// Deserializes a JSON map into an instance of [AcceptanceClauseModel].
  ///
  /// The JSON map must contain keys for 'id', 'odontologistSignature', 'patientPrint',
  /// 'patientSignature', and 'stringAcceptanceLeyend' with appropriate values.
  factory AcceptanceClauseModel.fromJson(Map<String, dynamic> json) {
    return AcceptanceClauseModel(
      id: Utils.getStringFromDynamic(json[AcceptanceClauseEnum.id.name]),
      odontologistSignature: SignatureModel.fromJson(
        Utils.mapFromDynamic(
          json[AcceptanceClauseEnum.odontologistSignature.name],
        ),
      ),
      patientPrint: Utils.getStringFromDynamic(
        json[AcceptanceClauseEnum.patientPrint.name],
      ),
      patientSignature: SignatureModel.fromJson(
        Utils.mapFromDynamic(
          json[AcceptanceClauseEnum.patientSignature.name],
        ),
      ),
      stringAcceptanceLeyend: Utils.getStringFromDynamic(
        json[AcceptanceClauseEnum.stringAcceptanceLeyend.name],
      ),
    );
  }

  /// A unique identifier for the acceptance clause.
  final String id;

  /// The signature of the odontologist as part of the acceptance clause.
  final SignatureModel odontologistSignature;

  /// The printed name of the patient as part of the consent process.
  final String patientPrint;

  /// The signature of the patient, indicating their consent to the treatment.
  final SignatureModel patientSignature;

  /// The legal leyend or text that the patient acknowledges and accepts.
  final String stringAcceptanceLeyend;

  /// Creates a copy of this [AcceptanceClauseModel] with optional new values.
  @override
  AcceptanceClauseModel copyWith({
    String? id,
    SignatureModel? odontologistSignature,
    String? patientPrint,
    SignatureModel? patientSignature,
    String? stringAcceptanceLeyend,
  }) {
    return AcceptanceClauseModel(
      id: id ?? this.id,
      odontologistSignature:
          odontologistSignature ?? this.odontologistSignature,
      patientPrint: patientPrint ?? this.patientPrint,
      patientSignature: patientSignature ?? this.patientSignature,
      stringAcceptanceLeyend:
          stringAcceptanceLeyend ?? this.stringAcceptanceLeyend,
    );
  }

  /// Serializes this [AcceptanceClauseModel] into a JSON map.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      AcceptanceClauseEnum.id.name: id,
      AcceptanceClauseEnum.odontologistSignature.name:
          odontologistSignature.toJson(),
      AcceptanceClauseEnum.patientPrint.name: patientPrint,
      AcceptanceClauseEnum.patientSignature.name: patientSignature.toJson(),
      AcceptanceClauseEnum.stringAcceptanceLeyend.name: stringAcceptanceLeyend,
    };
  }

  /// Determines if two [AcceptanceClauseModel] instances are equal.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AcceptanceClauseModel &&
            hashCode == other.hashCode &&
            other.runtimeType == runtimeType;
  }

  /// Returns the hash code for this [AcceptanceClauseModel].
  @override
  int get hashCode => Object.hash(
        id,
        odontologistSignature,
        patientPrint,
        patientSignature,
        stringAcceptanceLeyend,
      );
}
