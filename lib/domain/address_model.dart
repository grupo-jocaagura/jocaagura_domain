part of '../jocaagura_domain.dart';

/// A default instance of [AddressModel] representing a sample address.
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

/// Represents an address within a healthcare management application or any other domain
/// where address information is required.
///
/// This class encapsulates details about an address, including the postal code,
/// country, administrative area (state), city, locality, and specific address. It also
/// includes optional fields for notes and a unique identifier.
///
/// Example of using [AddressModel] in a practical application:
///
/// ```dart
/// void main() {
///   var address = AddressModel(
///     id: '2',
///     postalCode: 67890,
///     country: 'Canada',
///     administrativeArea: 'ON',
///     city: 'Toronto',
///     locality: 'Downtown',
///     address: '456 King St W',
///     notes: 'Near the CN Tower',
///   );
///
///   print('Address ID: ${address.id}');
///   print('Country: ${address.country}');
///   print('City: ${address.city}');
///   print('Full Address: ${address.address}');
/// }
/// ```
///
/// This class is essential for managing structured address data across applications.
class AddressModel extends Model {
  /// Constructs a new [AddressModel] with the given details.
  ///
  /// The [country], [administrativeArea], [city], [locality], and [address] fields
  /// are required. The [id], [postalCode], and [notes] fields are optional and default
  /// to empty or zero values.
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

  /// Creates a new [AddressModel] from a JSON map.
  ///
  /// This factory constructor is used for deserializing a JSON structure into
  /// an instance of [AddressModel].
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

  /// A unique identifier for the address.
  final String id;

  /// The postal code of the address.
  final int postalCode;

  /// The country where the address is located.
  final String country;

  /// The administrative area (state/province) of the address.
  final String administrativeArea;

  /// The city where the address is located.
  final String city;

  /// The locality (neighborhood) of the address.
  final String locality;

  /// The specific address line (street address).
  final String address;

  /// Optional notes about the address.
  final String notes;

  /// Creates a copy of this [AddressModel] with optional new values.
  ///
  /// This method allows immutability while supporting modifications to the model.
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

  /// Converts this [AddressModel] into a JSON map.
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

  /// Returns the hash code for this [AddressModel].
  ///
  /// The hash code is generated based on the concatenation of all fields as a single string.
  @override
  int get hashCode =>
      '$id$postalCode$country$administrativeArea$city$locality$address$notes'
          .hashCode;

  /// Compares this [AddressModel] to another object.
  ///
  /// Two instances are considered equal if all their fields match.
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

  /// Returns a string representation of the address as JSON.
  ///
  /// This method uses the [toJson] method and encodes it as a JSON string.
  @override
  String toString() {
    return Utils.getJsonEncode(toJson());
  }
}
