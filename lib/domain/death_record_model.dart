part of '../jocaagura_domain.dart';

/// Enum [DeathRecordEnum] defines the keys for serializing and deserializing
/// a [DeathRecordModel].
///
/// - **id**: Unique identifier for the record.
/// - **notaria**: Information about the notary office.
/// - **person**: Information about the deceased person.
/// - **address**: Address where the death was recorded.
/// - **recordId**: Official record identifier.
enum DeathRecordEnum {
  id,
  notaria,
  person,
  address,
  recordId,
}

/// A default instance of [DeathRecordModel] for testing or initialization.
const DeathRecordModel defaultDeathRecord = DeathRecordModel(
  notaria: defaultStoreModel,
  person: defaultPersonModel,
  address: defaultAddressModel,
  recordId: '9807666',
  id: 'gx86GyNM',
);

/// Represents a death record within a registry or healthcare management system.
///
/// This model encapsulates all details associated with a death record, including
/// the notary office, the deceased person's information, the address, and an official
/// record ID.
///
/// Example usage:
///
/// ```dart
/// void main() {
///   var deathRecord = DeathRecordModel(
///     id: 'record001',
///     notaria: defaultStoreModel,
///     person: defaultPersonModel,
///     address: defaultAddressModel,
///     recordId: '123456789',
///   );
///
///   print('Death Record ID: ${deathRecord.id}');
///   print('Notary Office: ${deathRecord.notaria}');
///   print('Deceased Person: ${deathRecord.person}');
///   print('Address: ${deathRecord.address}');
///   print('Record ID: ${deathRecord.recordId}');
/// }
/// ```
class DeathRecordModel extends Model {
  const DeathRecordModel({
    required this.notaria,
    required this.person,
    required this.address,
    required this.recordId,
    this.id = '',
  });

  /// Unique identifier for the death record.
  final String id;

  /// Official record identifier for the death.
  final String recordId;

  /// Details about the notary office managing the record.
  final StoreModel notaria;

  /// Information about the deceased person.
  final PersonModel person;

  /// Address where the death was recorded.
  final AddressModel address;

  /// Creates a copy of this [DeathRecordModel] with optional new values.
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

  /// Serializes this [DeathRecordModel] into a JSON map.
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

  /// Deserializes a JSON map into an instance of [DeathRecordModel].
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

  /// Converts this [DeathRecordModel] to a string representation.
  @override
  String toString() {
    return '${toJson()}';
  }

  /// Compares this [DeathRecordModel] to another object.
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
