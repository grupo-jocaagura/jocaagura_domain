part of '../jocaagura_domain.dart';

enum ObituaryEnum {
  id,
  photoUrl,
  person,
  creationDate,
  vigilAddress,
  burialAddress,
  vigilDate,
  burialDate,
  message,
  deathRecord,
}

final ObituaryModel defaultObituary = ObituaryModel(
  id: 'qwerty',
  person: defaultPersonModel,
  creationDate: DateTime(2023, 12, 18),
  vigilDate: DateTime(2023, 07, 05, 14, 30),
  burialDate: DateTime(2023, 07, 05, 16, 30),
  vigilAddress: defaultAddressModel,
  burialAddress: defaultAddressModel,
  message:
      'Lamentamos profundamente tu perdida. Esperamos que tu memoria perdure como una fuente de inspiración y amor.',
);

@immutable
class ObituaryModel extends Model {
  const ObituaryModel({
    required this.id,
    required this.person,
    required this.creationDate,
    required this.vigilDate,
    required this.burialDate,
    required this.vigilAddress,
    required this.burialAddress,
    this.photoUrl = '',
    this.message = '',
    this.deathRecord,
  });

  factory ObituaryModel.fromJson(Map<String, dynamic> json) {
    return ObituaryModel(
      id: Utils.getStringFromDynamic(json[ObituaryEnum.id.name]),
      photoUrl: Utils.getUrlFromDynamic(json[ObituaryEnum.photoUrl.name]),
      person: PersonModel.fromJson(
        Utils.mapFromDynamic(json[ObituaryEnum.person.name]),
      ),
      creationDate:
          DateUtils.dateTimeFromDynamic(json[ObituaryEnum.creationDate.name]),
      vigilDate:
          DateUtils.dateTimeFromDynamic(json[ObituaryEnum.vigilDate.name]),
      burialDate:
          DateUtils.dateTimeFromDynamic(json[ObituaryEnum.burialDate.name]),
      vigilAddress: AddressModel.fromJson(
        Utils.mapFromDynamic(json[ObituaryEnum.vigilAddress.name]),
      ),
      burialAddress: AddressModel.fromJson(
        Utils.mapFromDynamic(json[ObituaryEnum.burialAddress.name]),
      ),
      message: Utils.getStringFromDynamic(json[ObituaryEnum.message.name]),
    );
  }

  final String id;
  final String photoUrl;
  final PersonModel person;
  final DateTime creationDate;
  final DateTime vigilDate;
  final DateTime burialDate;
  final AddressModel vigilAddress;
  final AddressModel burialAddress;
  final String message;
  final DeathRecordModel? deathRecord;

  @override
  ObituaryModel copyWith({
    String? id,
    String? photoUrl,
    PersonModel? person,
    DateTime? creationDate,
    DateTime? vigilDate,
    DateTime? burialDate,
    AddressModel? vigilAddress,
    AddressModel? burialAddress,
    String? message,
    DeathRecordModel? deathRecord,
  }) {
    return ObituaryModel(
      id: id ?? this.id,
      person: person ?? this.person,
      creationDate: creationDate ?? this.creationDate,
      vigilDate: vigilDate ?? this.vigilDate,
      burialDate: burialDate ?? this.burialDate,
      vigilAddress: vigilAddress ?? this.vigilAddress,
      burialAddress: burialAddress ?? this.burialAddress,
      message: message ?? this.message,
      deathRecord: deathRecord ?? this.deathRecord,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ObituaryEnum.id.name: id,
      ObituaryEnum.photoUrl.name: Utils.isValidUrl(photoUrl) ? photoUrl : '',
      ObituaryEnum.person.name: person.toJson(),
      ObituaryEnum.vigilAddress.name: vigilAddress.toJson(),
      ObituaryEnum.burialAddress.name: burialAddress.toJson(),
      ObituaryEnum.creationDate.name: DateUtils.dateTimeToString(creationDate),
      ObituaryEnum.vigilDate.name: DateUtils.dateTimeToString(vigilDate),
      ObituaryEnum.burialDate.name: DateUtils.dateTimeToString(burialDate),
      ObituaryEnum.message.name: message,
      ObituaryEnum.deathRecord.name: deathRecord?.toJson(),
    };
  }

  @override
  int get hashCode =>
      id.hashCode ^
      photoUrl.hashCode ^
      person.hashCode ^
      vigilAddress.hashCode ^
      burialAddress.hashCode ^
      message.hashCode ^
      vigilDate.hashCode ^
      burialDate.hashCode ^
      deathRecord.hashCode ^
      creationDate.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(other, this) ||
        other is ObituaryModel &&
            other.runtimeType == runtimeType &&
            other.id == id &&
            other.photoUrl == photoUrl &&
            other.person == person &&
            other.vigilAddress == vigilAddress &&
            other.burialAddress == burialAddress &&
            other.message == message &&
            other.vigilDate == vigilDate &&
            other.burialDate == burialDate &&
            other.deathRecord == deathRecord &&
            other.creationDate == creationDate;
  }

  @override
  String toString() {
    return '${toJson()}';
  }
}
