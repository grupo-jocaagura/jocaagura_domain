part of '../../jocaagura_domain.dart';

enum SignatureEnum {
  id,
  created,
  appId,
  png64Image,
}

const String defaultPNG64Image =
    'iVBORw0KGgoAAAANSUhEUgAAADAAAAA0CAYAAADMk7uRAAACxElEQVRoQ+2YPZaqQBCFL3sZghewANgBngkmMjTEFAJDI0MDScfQ0GgCj+xAFkAwAezFV4iNOCJjdbXP885pshmkur57q/rPOdKD//hxLMCL3bMOvNgAWAesA0IFbAkJBRR/bh0QSygMYB0QCij+3LgDVZVht/zCtigouRx5Dvi+f0rU88b4mL0jfHsTJ64CGAKokKVLLJI1pXx5VOL1f/KapH18RKs5ZnEIKYocoEoRuEmTOCkdjQcSqwh01wH1I6w2n4gFFCKAKg3gJnXqlPh+g8/w8UyqbIrJqHHMX5U4aFJoA7TJk4p7UpGR+6WSqF+mkxHWdZ9oQugBkHoOqUejojzEwjomiKCBiPZHcpHX3xoANKBDA4KUP5LyvPH6f932ET8mG0CVjo5aQ6wqLreUmABn9e+UTpVlKN1wsB/qdaIsXYQ3TVMhDVwkOc8FHsC59nvVV30xVFqdKbcvho67LIBs6mC09rEqDzdzd3dK7Xt/Kp9fANr30R7HB7uZAXC2GP0zjxEADI/R10MMgHP931WHBp9O8P2HFrSBRSmjxW/xPceGFL5d9l4KYGI+BZoyfbyRDTpgAoA/EzEA+PbykfhjMAD49rIB1Cz1nFmI0hlaB9jZ9nygEZ/lABE0+yAjm7ifAPz6ryMwAVQZ6e0cB01SKzmjfLQAWhdM7kaVsxox2Q40O4LzSYzUKnsXJE5DqNLRc1ULoE4vmwa04JyOUoJDzSV57jZaSaQNcA1Bh/P5DDHjXFllKZaLpDlOkpOHBzdvP70VAZzKqXM4p0x+BekmrnMZYByg2SZnSJcLJLWc6qErFt/z4J3+LlAUzSVX+zpaYT6L9S4DOhRiB64VqS+4dvjablFQtt2rrFpt3/cwHn/g3cCFlpEe4Mw1z/qtYQeeleb9uBbg32t+PaJ1wDogVMCWkFBA8efWAbGEwgB/AWW4PYOGL7TjAAAAAElFTkSuQmCC';

final SignatureModel defaultSignatureModel = SignatureModel(
  id: '0',
  created: DateTime(2024, 07, 07),
  appId: 'noapp',
  png64Image: defaultPNG64Image,
);

/// A model that represents a digital signature within an application.
///
/// This class stores details about a digital signature including its ID,
/// creation date, the application ID associated with the signature, and
/// the signature image itself encoded in PNG64 format.
class SignatureModel extends Model {
  /// Constructs a [SignatureModel] with required fields.
  ///
  /// [id] is a unique identifier for the signature.
  /// [created] represents the DateTime the signature was created.
  /// [appId] is the identifier for the application where the signature was created.
  /// [png64Image] is the base64 encoded string of the signature image in PNG format.
  const SignatureModel({
    required this.id,
    required this.created,
    required this.appId,
    required this.png64Image,
  });

  /// Creates a new [SignatureModel] from a JSON map.
  ///
  /// [json] must contain all fields necessary for the model. It uses utility
  /// methods from `Utils` to safely extract data while handling possible type mismatches.
  factory SignatureModel.fromJson(Map<String, dynamic> json) {
    return SignatureModel(
      id: Utils.getStringFromDynamic(json[SignatureEnum.id.name]),
      created: DateUtils.dateTimeFromDynamic(json[SignatureEnum.created.name]),
      appId: Utils.getStringFromDynamic(json[SignatureEnum.appId.name]),
      png64Image:
          Utils.getStringFromDynamic(json[SignatureEnum.png64Image.name]),
    );
  }

  /// A unique identifier for the signature.
  final String id;

  /// The date and time when the signature was created.
  final DateTime created;

  /// An identifier for the application where the signature was made.
  final String appId;

  /// A base64 encoded PNG image of the signature.
  final String png64Image;

  /// Returns a new [SignatureModel] with any specified fields replaced with new values.
  ///
  /// This method supports updating individual fields without requiring all fields to be resupplied.
  /// Fields not specified will retain their current value in the new object.
  @override
  SignatureModel copyWith({
    String? id,
    DateTime? created,
    String? appId,
    String? png64Image,
  }) {
    return SignatureModel(
      id: id ?? this.id,
      created: created ?? this.created,
      appId: appId ?? this.appId,
      png64Image: png64Image ?? this.png64Image,
    );
  }

  /// Converts the [SignatureModel] to a JSON map.
  ///
  /// Useful for serializing the [SignatureModel] to JSON, for example when storing
  /// the model in a database or sending it over a network.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        SignatureEnum.id.name: id,
        SignatureEnum.created.name: DateUtils.dateTimeToString(created),
        SignatureEnum.appId.name: appId,
        SignatureEnum.png64Image.name: png64Image,
      };

  /// Checks if two [SignatureModel]s are equal.
  ///
  /// Returns true if the [other] object is an instance of [SignatureModel] and all fields are equal.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignatureModel &&
          runtimeType == other.runtimeType &&
          hashCode == other.hashCode;

  /// Returns a hash code for this [SignatureModel].
  ///
  /// The hash code is based on all of the fields of the model.
  @override
  int get hashCode => Object.hash(
        id,
        created,
        appId,
        png64Image,
      );
}
