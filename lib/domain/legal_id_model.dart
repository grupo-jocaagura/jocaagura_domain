part of '../jocaagura_domain.dart';

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

enum LegalIdTypeEnum {
  registroCivil,
  tarjetaIdentidad,
  cedula,
  cedulaExtranjeria,
  pasaporte,
  licenciaConduccion,
  certificadoNacidoVivo,
}

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

enum LegalIdEnum {
  id,
  idType,
  names,
  lastNames,
  legalIdNumber,
  attributes,
}

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

  final String id;
  final LegalIdTypeEnum idType;
  final String names;
  final String lastNames;
  final String legalIdNumber;
  final Map<String, AttributeModel<dynamic>> attributes;

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

  LegalIdModel from(Map<String, dynamic> json) {
    return LegalIdModel(
      idType: getEnumValueFromString(json[LegalIdEnum.idType.name].toString()),
      id: Utils.getStringFromDynamic(json[LegalIdEnum.id.name]),
      names: Utils.getStringFromDynamic(json[LegalIdEnum.names.name]),
      lastNames: Utils.getStringFromDynamic(json[LegalIdEnum.lastNames.name]),
      legalIdNumber:
          Utils.getStringFromDynamic(json[LegalIdEnum.legalIdNumber.name]),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> mapTmp = <String, dynamic>{};
    for (final MapEntry<String, AttributeModel<dynamic>> element
        in attributes.entries) {
      mapTmp.addAll(element.value.toJson());
    }
    return <String, dynamic>{
      LegalIdEnum.id.name: id,
      LegalIdEnum.idType.name: idType.description,
      LegalIdEnum.lastNames.name: lastNames,
      LegalIdEnum.names.name: names,
      LegalIdEnum.legalIdNumber.name: legalIdNumber,
      LegalIdEnum.attributes.name: mapTmp,
    };
  }

  @override
  int get hashCode =>
      '$id$idType$names$lastNames$legalIdNumber${attributes.hashCode}'.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(other, this) ||
        other is LegalIdModel &&
            other.runtimeType == runtimeType &&
            other.names == names &&
            other.lastNames == lastNames &&
            other.legalIdNumber == legalIdNumber &&
            other.attributes == attributes &&
            other.idType == idType &&
            other.id == id &&
            other.hashCode == hashCode;
  }

  @override
  String toString() {
    return '${toJson()}';
  }
}
