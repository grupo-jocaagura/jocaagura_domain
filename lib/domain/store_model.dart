part of '../jocaagura_domain.dart';

/// Enumerates the JSON field names used by [StoreModel].
///
/// Contracts:
/// - Keys are serialized by `name`, so enum order is irrelevant.
/// - Keep names stable to avoid breaking persisted data.
enum StoreModelEnum {
  /// Unique identifier for the store.
  id,

  /// NIT (tax identification number) of the store.
  nit,

  /// URL pointing to the store photo.
  photoUrl,

  /// URL pointing to the cover photo of the store.
  coverPhotoUrl,

  /// Contact email address of the store.
  email,

  /// Owner's email address.
  ownerEmail,

  /// Store name.
  name,

  /// Alias or alternative name for the store.
  alias,

  /// Postal address of the store (as [AddressModel] JSON).
  address,

  /// Primary phone number.
  phoneNumber1,

  /// Secondary phone number.
  phoneNumber2,
}

/// A default instance of [StoreModel] for testing or fallback purposes.
///
/// This instance provides placeholder values for a typical store.
const StoreModel defaultStoreModel = StoreModel(
  id: 'store_id',
  nit: 12345,
  photoUrl: 'https://example.com/photo.jpg',
  coverPhotoUrl: 'https://example.com/cover.jpg',
  email: 'store@example.com',
  ownerEmail: 'owner@example.com',
  name: 'My Store',
  alias: 'Store',
  address: defaultAddressModel,
  phoneNumber1: 123456,
  phoneNumber2: 789012,
);

/// Represents a store with identification, contact data, media URLs, and address.
///
/// ### Contracts
/// - `toJson()` emits a **proper JSON map** for [address] using `address.toJson()`.
/// - Equality is structural on all fields (does not depend on `hashCode`).
/// - Phone numbers are stored as integers; formatting helpers are provided.
/// - NIT check digit is computed via [getVerificationNITNumber] (Colombia).
///
/// ### Minimal runnable example
/// ```dart
/// void main() {
///   final StoreModel store = StoreModel(
///     id: 'store_001',
///     nit: 98765,
///     photoUrl: 'https://example.com/photo.jpg',
///     coverPhotoUrl: 'https://example.com/cover.jpg',
///     email: 'store@example.com',
///     ownerEmail: 'owner@example.com',
///     name: 'Super Store',
///     alias: 'SS',
///     address: defaultAddressModel,
///     phoneNumber1: 123456789,
///     phoneNumber2: 987654321,
///   );
///
///   print(store.nitNumber);            // "<nit> - <dv>"
///   print(store.formatedPhoneNumber1); // formatted primary phone
///   print(store.toJson()['address']);  // address as JSON map, not string
/// }
/// ```
///
/// ### Notes
/// - `Utils` helpers are used for defensive parsing on `fromJson`.
/// - Consider validating non-negative NIT/phone numbers at boundaries if needed.
class StoreModel extends Model {
  const StoreModel({
    required this.id,
    required this.nit,
    required this.photoUrl,
    required this.coverPhotoUrl,
    required this.email,
    required this.ownerEmail,
    required this.name,
    required this.alias,
    required this.address,
    required this.phoneNumber1,
    required this.phoneNumber2,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: Utils.getStringFromDynamic(json[StoreModelEnum.id.name]),
      nit: Utils.getIntegerFromDynamic(json[StoreModelEnum.nit.name]),
      photoUrl: Utils.getUrlFromDynamic(json[StoreModelEnum.photoUrl.name]),
      coverPhotoUrl:
          Utils.getUrlFromDynamic(json[StoreModelEnum.coverPhotoUrl.name]),
      email: Utils.getEmailFromDynamic(json[StoreModelEnum.email.name]),
      ownerEmail:
          Utils.getEmailFromDynamic(json[StoreModelEnum.ownerEmail.name]),
      name: Utils.getStringFromDynamic(json[StoreModelEnum.name.name]),
      alias: Utils.getStringFromDynamic(json[StoreModelEnum.alias.name]),
      address: AddressModel.fromJson(
        Utils.mapFromDynamic(json[StoreModelEnum.address.name]),
      ),
      phoneNumber1:
          Utils.getIntegerFromDynamic(json[StoreModelEnum.phoneNumber1.name]),
      phoneNumber2:
          Utils.getIntegerFromDynamic(json[StoreModelEnum.phoneNumber2.name]),
    );
  }

  /// Unique identifier for the store.
  final String id;

  /// NIT (tax identification number) of the store.
  final int nit;

  /// URL pointing to the photo of the store.
  final String photoUrl;

  /// URL pointing to the cover photo of the store.
  final String coverPhotoUrl;

  /// Email address of the store.
  final String email;

  /// Email address of the store owner.
  final String ownerEmail;

  /// Name of the store.
  final String name;

  /// Alias or alternative name for the store.
  final String alias;

  /// Address details of the store.
  final AddressModel address;

  /// Primary phone number of the store.
  final int phoneNumber1;

  /// Secondary phone number of the store.
  final int phoneNumber2;

  /// Creates a copy of this [StoreModel] with optional new values.
  @override
  StoreModel copyWith({
    String? id,
    int? nit,
    String? photoUrl,
    String? coverPhotoUrl,
    String? email,
    String? lastNames,
    String? ownerEmail,
    String? name,
    String? alias,
    AddressModel? address,
    int? phoneNumber1,
    int? phoneNumber2,
  }) {
    return StoreModel(
      id: id ?? this.id,
      nit: nit ?? this.nit,
      photoUrl: photoUrl ?? this.photoUrl,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      email: email ?? this.email,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      name: name ?? this.name,
      alias: alias ?? this.alias,
      address: address ?? this.address,
      phoneNumber1: phoneNumber1 ?? this.phoneNumber1,
      phoneNumber2: phoneNumber2 ?? this.phoneNumber2,
    );
  }

  /// Serializes this [StoreModel] into a JSON map.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      StoreModelEnum.id.name: id,
      StoreModelEnum.nit.name: nit,
      StoreModelEnum.photoUrl.name: Utils.getUrlFromDynamic(photoUrl),
      StoreModelEnum.coverPhotoUrl.name: Utils.getUrlFromDynamic(coverPhotoUrl),
      StoreModelEnum.email.name: Utils.getEmailFromDynamic(email),
      StoreModelEnum.ownerEmail.name: Utils.getEmailFromDynamic(ownerEmail),
      StoreModelEnum.name.name: name,
      StoreModelEnum.alias.name: alias,
      StoreModelEnum.address.name: address.toJson(),
      StoreModelEnum.phoneNumber1.name: phoneNumber1,
      StoreModelEnum.phoneNumber2.name: phoneNumber2,
    };
  }

  @override
  int get hashCode => Object.hash(
        id,
        nit,
        photoUrl,
        coverPhotoUrl,
        email,
        ownerEmail,
        name,
        alias,
        address,
        phoneNumber1,
        phoneNumber2,
      );

  @override
  String toString() {
    return Utils.getJsonEncode(toJson());
  }

  @override
  bool operator ==(Object other) =>
      identical(other, this) ||
      other is StoreModel &&
          other.runtimeType == runtimeType &&
          id == other.id &&
          nit == other.nit &&
          photoUrl == other.photoUrl &&
          coverPhotoUrl == other.coverPhotoUrl &&
          email == other.email &&
          ownerEmail == other.ownerEmail &&
          name == other.name &&
          alias == other.alias &&
          address == other.address &&
          phoneNumber1 == other.phoneNumber1 &&
          phoneNumber2 == other.phoneNumber2;

  /// Retrieves the NIT formatted with a verification number.
  String get nitNumber => '$nit - ${StoreModel.getVerificationNITNumber(nit)}';

  /// Formats the primary phone number.
  String get formatedPhoneNumber1 => Utils.getFormatedPhoneNumber(phoneNumber1);

  /// Formats the secondary phone number.
  String get formatedPhoneNumber2 =>
      Utils.getFormatedPhoneNumberAlt(phoneNumber2);

  /// Calculates the verification number for a given NIT. in Colombia only 2024
  static int getVerificationNITNumber(int nitNumber) {
    final List<int> digits = nitNumber
        .toString()
        .split('')
        .map((String d) => int.parse(d))
        .toList()
        .reversed
        .toList();

    const List<int> weights = <int>[
      3,
      7,
      13,
      17,
      19,
      23,
      29,
      37,
      41,
      43,
      47,
      53,
      59,
      67,
      71,
    ];

    final int len =
        digits.length < weights.length ? digits.length : weights.length;

    int sum = 0;
    for (int i = 0; i < len; i++) {
      sum += digits[i] * weights[i];
    }

    final int residue = sum % 11;
    final int dv = 11 - residue;

    if (dv == 10) {
      return 0;
    }
    if (dv == 11) {
      return 1;
    }
    return dv;
  }
}
