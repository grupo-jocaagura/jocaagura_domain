part of '../jocaagura_domain.dart';

const AddressModel defaultAddressModel = AddressModel(
  id: '1',
  postalCode: 12345,
  country: 'USA',
  administrativeArea: 'CA',
  city: 'San Francisco',
  locality: 'SOMA',
  address: '123 Main St',
  notes: 'Some notes',
);

class AddressModel extends Model {
  const AddressModel({
    required this.country,
    required this.administrativeArea,
    required this.city,
    required this.locality,
    required this.address,
    this.id = '',
    this.postalCode = 0,
    this.notes = '',
  });
  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: Utils.getStringFromDynamic(json['id']),
        postalCode: Utils.getIntegerFromDynamic(json['postalCode']),
        country: Utils.getStringFromDynamic(json['country']),
        administrativeArea:
            Utils.getStringFromDynamic(json['administrativeArea']),
        city: Utils.getStringFromDynamic(json['city']),
        locality: Utils.getStringFromDynamic(json['locality']),
        address: Utils.getStringFromDynamic(json['address']),
        notes: Utils.getStringFromDynamic(json['notes']),
      );
  final String id;
  final int postalCode;
  final String country;
  final String administrativeArea;
  final String city;
  final String locality;
  final String address;
  final String notes;

  @override
  AddressModel copyWith({
    String? id,
    int? postalCode,
    String? country,
    String? administrativeArea,
    String? city,
    String? locality,
    String? address,
    String? notes,
  }) =>
      AddressModel(
        id: id ?? this.id,
        postalCode: postalCode ?? this.postalCode,
        country: country ?? this.country,
        administrativeArea: administrativeArea ?? this.administrativeArea,
        city: city ?? this.city,
        locality: locality ?? this.locality,
        address: address ?? this.address,
        notes: notes ?? this.notes,
      );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'postalCode': postalCode,
        'country': country,
        'administrativeArea': administrativeArea,
        'city': city,
        'locality': locality,
        'address': address,
        'notes': notes,
      };

  @override
  int get hashCode =>
      '$id$postalCode$country$administrativeArea$city$locality$address$notes'
          .hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AddressModel &&
            runtimeType == other.runtimeType &&
            hashCode == other.hashCode &&
            id == other.id &&
            postalCode == other.postalCode &&
            country == other.country &&
            administrativeArea == other.administrativeArea &&
            city == other.city &&
            locality == other.locality &&
            address == other.address &&
            notes == other.notes;
  }

  @override
  String toString() {
    return Utils.getJsonEncode(toJson());
  }
}
