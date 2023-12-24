part of '../jocaagura_domain.dart';

enum DeathRecordEnum {
  id,
  notaria,
  person,
  address,
  recordId,
}

const DeathRecordModel defaultDeathRecord = DeathRecordModel(
  notaria: defaultStoreModel,
  person: defaultPersonModel,
  address: defaultAddressModel,
  recordId: '9807666',
  id: 'gx86GyNM',
);

@immutable
class DeathRecordModel implements Model {
  const DeathRecordModel({
    required this.notaria,
    required this.person,
    required this.address,
    required this.recordId,
    this.id = '',
  });

  final String id;
  final String recordId;
  final StoreModel notaria;
  final PersonModel person;
  final AddressModel address;

  @override
  DeathRecordModel copyWith({
    String? id,
    StoreModel? notaria,
    String? recordId,
    PersonModel? person,
    AddressModel? address,
  }) {
    return DeathRecordModel(
      notaria: notaria ?? this.notaria,
      person: person ?? this.person,
      address: address ?? this.address,
      recordId: recordId ?? this.recordId,
      id: id ?? this.id,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      DeathRecordEnum.id.name: id,
      DeathRecordEnum.notaria.name: notaria.toJson(),
      DeathRecordEnum.recordId.name: recordId,
      DeathRecordEnum.person.name: person.toJson(),
      DeathRecordEnum.address.name: address.toJson(),
    };
  }

  DeathRecordModel fromJson(Map<String, dynamic> json) {
    return DeathRecordModel(
      id: Utils.getStringFromDynamic(json[DeathRecordEnum.id.name]),
      notaria: StoreModel.fromJson(
        Utils.mapFromDynamic(json[DeathRecordEnum.notaria.name]),
      ),
      person: PersonModel.fromJson(
        Utils.mapFromDynamic(json[DeathRecordEnum.recordId.name]),
      ),
      address: AddressModel.fromJson(
        Utils.mapFromDynamic(json[DeathRecordEnum.person.name]),
      ),
      recordId: Utils.getStringFromDynamic(json[DeathRecordEnum.address.name]),
    );
  }

  @override
  int get hashCode =>
      '$id${person.hashCode}${notaria.hashCode}${address.hashCode}$recordId'
          .hashCode;

  @override
  String toString() {
    return '${toJson()}';
  }

  @override
  bool operator ==(Object other) {
    return identical(other, this) ||
        other is DeathRecordModel &&
            runtimeType == other.runtimeType &&
            other.id == id &&
            other.person == person &&
            other.address == address &&
            other.notaria == notaria &&
            other.recordId == recordId &&
            hashCode == other.hashCode;
  }
}
