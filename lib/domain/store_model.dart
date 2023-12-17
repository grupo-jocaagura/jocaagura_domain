part of '../jocaagura_domain.dart';

enum StoreModelEnum {
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
}

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

  final String id;
  final int nit;
  final String photoUrl;
  final String coverPhotoUrl;
  final String email;
  final String ownerEmail;
  final String name;
  final String alias;
  final AddressModel address;
  final int phoneNumber1;
  final int phoneNumber2;

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
      StoreModelEnum.address.name: address.toString(),
      StoreModelEnum.phoneNumber1.name: phoneNumber1,
      StoreModelEnum.phoneNumber2.name: phoneNumber2,
    };
  }

  @override
  int get hashCode =>
      '$id$nit$photoUrl$coverPhotoUrl$email$ownerEmail$name$alias'
              '$address$phoneNumber1$phoneNumber2'
          .hashCode;

  @override
  String toString() {
    return Utils.getJsonEncode(toJson());
  }

  @override
  bool operator ==(Object other) {
    return identical(other, this) ||
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
            phoneNumber2 == other.phoneNumber2 &&
            hashCode == other.hashCode;
  }

  String get nitNumber => '$nit - ${StoreModel.getVerificationNITNumber(nit)}';
  String get formatedPhoneNumber1 => Utils.getFormatedPhoneNumber(phoneNumber1);
  String get formatedPhoneNumber2 =>
      Utils.getFormatedPhoneNumberAlt(phoneNumber2);

  static int getVerificationNITNumber(int nitNumber) {
    final List<int> digitos = nitNumber
        .toString()
        .split('')
        .map((String d) => int.parse(d))
        .toList()
        .reversed
        .toList();

    // Definir los pesos para cada posición del RUT
    final List<int> pesos = <int>[
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

    // Calcular la suma de los productos de los dígitos por los pesos
    int suma = 0;
    for (int i = 0; i < digitos.length; i++) {
      suma += digitos[i] * pesos[i];
    }

    // Calcular el residuo
    final int residuo = suma % 11;

    // Calcular el dígito de verificación
    final int digitoVerificacion = 11 - residuo;

    // Manejar casos especiales
    if (digitoVerificacion == 10) {
      return 0;
    } else if (digitoVerificacion == 11) {
      return 1;
    } else {
      return digitoVerificacion;
    }
  }
}
