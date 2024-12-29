part of '../jocaagura_domain.dart';

/// The default [LegalIdModel] instance, representing a sample legal identification.
///
/// This instance includes sample data for testing or as a fallback value.
const LegalIdModel defaultLegalIdModel = LegalIdModel(
  id: 'vHi05635G',
  idType: LegalIdTypeEnum.cedula,
  names: 'pedro luis',
  lastNames: 'manjarrez paez',
  legalIdNumber: '123456',
  attributes: <String, AttributeModel<dynamic>>{
    'rh': AttributeModel<String>(value: 'O+', name: 'rh'),
    'fechaExpedición': AttributeModel<String>(
      value: '1979-09-04T00:00:00.000',
      name: 'fechaExpedición',
    ),
  },
);

/// Enum representing the types of legal identification documents.
enum LegalIdTypeEnum {
  registroCivil,
  tarjetaIdentidad,
  cedula,
  cedulaExtranjeria,
  pasaporte,
  licenciaConduccion,
  certificadoNacidoVivo,
}

/// Extension for [LegalIdTypeEnum] to provide human-readable descriptions for the enum values.
extension LegalIdTypeExtension on LegalIdTypeEnum {
  String get description {
    switch (this) {
      case LegalIdTypeEnum.registroCivil:
        return 'Registro Civil';
      case LegalIdTypeEnum.tarjetaIdentidad:
        return 'Tarjeta de Identidad';
      case LegalIdTypeEnum.cedula:
        return 'Cédula de Ciudadanía';
      case LegalIdTypeEnum.cedulaExtranjeria:
        return 'Cédula de Extranjería';
      case LegalIdTypeEnum.pasaporte:
        return 'Pasaporte';
      case LegalIdTypeEnum.licenciaConduccion:
        return 'Licencia de Conducción';
      case LegalIdTypeEnum.certificadoNacidoVivo:
        return 'Certificado de Nacido Vivo';
    }
  }
}

/// Retrieves a [LegalIdTypeEnum] value based on its description.
///
/// If the description does not match any predefined value, it defaults to [LegalIdTypeEnum.cedula].
LegalIdTypeEnum getEnumValueFromString(String description) {
  switch (description.toLowerCase()) {
    case 'registro civil':
      return LegalIdTypeEnum.registroCivil;
    case 'tarjeta de identidad':
      return LegalIdTypeEnum.tarjetaIdentidad;
    case 'cédula de ciudadanía':
      return LegalIdTypeEnum.cedula;
    case 'cédula de extranjería':
      return LegalIdTypeEnum.cedulaExtranjeria;
    case 'pasaporte':
      return LegalIdTypeEnum.pasaporte;
    case 'licencia de conducción':
      return LegalIdTypeEnum.licenciaConduccion;
    case 'certificado de nacido vivo':
      return LegalIdTypeEnum.certificadoNacidoVivo;
    default:
      return LegalIdTypeEnum.cedula;
  }
}

/// Enum representing the fields of a legal identification model.
enum LegalIdEnum {
  id,
  idType,
  names,
  lastNames,
  legalIdNumber,
  attributes,
}

/// A model representing a legal identification record.
///
/// The [LegalIdModel] class stores information about a person's legal identification,
/// including the type of document, the individual's name, and additional attributes.
@immutable
class LegalIdModel implements Model {
  const LegalIdModel({
    required this.idType,
    required this.names,
    required this.lastNames,
    required this.legalIdNumber,
    this.id = '',
    this.attributes = const <String, AttributeModel<dynamic>>{},
  });

  /// Factory method to create a [LegalIdModel] from a JSON object.
  factory LegalIdModel.fromJson(Map<String, dynamic> json) {
    return LegalIdModel(
      idType: getEnumValueFromString(json[LegalIdEnum.idType.name].toString()),
      id: Utils.getStringFromDynamic(json[LegalIdEnum.id.name]),
      names: Utils.getStringFromDynamic(json[LegalIdEnum.names.name]),
      lastNames: Utils.getStringFromDynamic(json[LegalIdEnum.lastNames.name]),
      legalIdNumber:
          Utils.getStringFromDynamic(json[LegalIdEnum.legalIdNumber.name]),
    );
  }

  /// Unique identifier for the legal identification record.
  final String id;

  /// The type of legal identification document.
  final LegalIdTypeEnum idType;

  /// The first and middle names of the individual.
  final String names;

  /// The last names of the individual.
  final String lastNames;

  /// The legal identification number.
  final String legalIdNumber;

  /// Additional attributes related to the legal identification, stored as a map.
  final Map<String, AttributeModel<dynamic>> attributes;

  /// Creates a copy of this [LegalIdModel] with optional new values.
  @override
  LegalIdModel copyWith({
    String? id,
    LegalIdTypeEnum? idType,
    String? names,
    String? lastNames,
    String? legalIdNumber,
    Map<String, AttributeModel<dynamic>>? attributes,
  }) {
    return LegalIdModel(
      id: id ?? this.id,
      idType: idType ?? this.idType,
      names: names ?? this.names,
      lastNames: lastNames ?? this.lastNames,
      legalIdNumber: legalIdNumber ?? this.legalIdNumber,
      attributes: attributes ?? this.attributes,
    );
  }

  /// Converts this [LegalIdModel] to a JSON object.
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> attributesMap = <String, dynamic>{};
    for (final MapEntry<String, AttributeModel<dynamic>> entry
        in attributes.entries) {
      attributesMap[entry.key] = entry.value.toJson();
    }
    return <String, dynamic>{
      LegalIdEnum.id.name: id,
      LegalIdEnum.idType.name: idType.description,
      LegalIdEnum.names.name: names,
      LegalIdEnum.lastNames.name: lastNames,
      LegalIdEnum.legalIdNumber.name: legalIdNumber,
      LegalIdEnum.attributes.name: attributesMap,
    };
  }

  @override
  int get hashCode =>
      Object.hash(id, idType, names, lastNames, legalIdNumber, attributes);

  @override
  bool operator ==(Object other) {
    return identical(other, this) ||
        other is LegalIdModel &&
            other.id == id &&
            other.idType == idType &&
            other.names == names &&
            other.lastNames == lastNames &&
            other.legalIdNumber == legalIdNumber &&
            other.attributes == attributes;
  }

  @override
  String toString() => toJson().toString();
}
