part of '../jocaagura_domain.dart';

/// Enumerates the properties of a person in the [PersonModel].
///
/// These properties define the structure of a person, including their unique
/// identifier, names, photo URL, last names, and additional attributes.
enum PersonEnum {
  /// Unique identifier for the person.
  id,

  /// The names of the person.
  names,

  /// URL pointing to the photo of the person.
  photoUrl,

  /// The last names of the person.
  lastNames,

  /// Additional attributes related to the person, stored as key-value pairs.
  attributes,
}

/// A default instance of [PersonModel] for testing or fallback purposes.
///
/// This instance represents a person with basic placeholder values.
const PersonModel defaultPersonModel = PersonModel(
  id: '',
  names: 'J.J.',
  photoUrl: '',
  lastNames: 'Last Names',
  attributes: <String, AttributeModel<dynamic>>{},
);

/// Represents a person within the application.
///
/// This model class encapsulates details about a person, including their ID,
/// names, photo URL, last names, and additional attributes.
///
/// Example of using [PersonModel] in a practical application:
///
/// ```dart
/// void main() {
///   final PersonModel person = PersonModel(
///     id: '123',
///     names: 'John',
///     photoUrl: 'https://example.com/photo.jpg',
///     lastNames: 'Doe',
///     attributes: {
///       'age': AttributeModel<int>(value: 30, name: 'age'),
///       'gender': AttributeModel<String>(value: 'Male', name: 'gender'),
///     },
///   );
///
///   print('Person ID: ${person.id}');
///   print('Full Name: ${person.names} ${person.lastNames}');
///   print('Photo URL: ${person.photoUrl}');
///   print('Attributes: ${person.attributes}');
/// }
/// ```
class PersonModel extends Model {
  /// Constructs a new [PersonModel] with the given details.
  const PersonModel({
    required this.id,
    required this.names,
    required this.photoUrl,
    required this.lastNames,
    required this.attributes,
  });

  /// Deserializes a JSON map into an instance of [PersonModel].
  ///
  /// The JSON map must contain keys corresponding to the [PersonEnum] values.
  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: Utils.getStringFromDynamic(json[PersonEnum.id.name]),
      names: Utils.getStringFromDynamic(json[PersonEnum.names.name]),
      photoUrl: Utils.getUrlFromDynamic(json[PersonEnum.photoUrl.name]),
      lastNames: Utils.getStringFromDynamic(json[PersonEnum.lastNames.name]),
      attributes: const <String, AttributeModel<dynamic>>{},
    );
  }

  /// Unique identifier for the person.
  final String id;

  /// The names of the person.
  final String names;

  /// URL pointing to the person's photo.
  final String photoUrl;

  /// The last names of the person.
  final String lastNames;

  /// Additional attributes related to the person, stored as key-value pairs.
  final Map<String, AttributeModel<dynamic>> attributes;

  /// Creates a copy of this [PersonModel] with optional new values.
  @override
  PersonModel copyWith({
    String? id,
    String? names,
    String? photoUrl,
    String? lastNames,
    Map<String, AttributeModel<dynamic>>? attributes,
  }) =>
      PersonModel(
        id: id ?? this.id,
        names: names ?? this.names,
        photoUrl: photoUrl ?? this.photoUrl,
        lastNames: lastNames ?? this.lastNames,
        attributes: attributes ?? this.attributes,
      );

  /// Serializes this [PersonModel] into a JSON map.
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> mapTmp = <String, dynamic>{};
    for (final MapEntry<String, AttributeModel<dynamic>> element
        in attributes.entries) {
      mapTmp.addAll(element.value.toJson());
    }

    return <String, dynamic>{
      PersonEnum.id.name: id,
      PersonEnum.photoUrl.name: Utils.isValidUrl(photoUrl) ? photoUrl : '',
      PersonEnum.lastNames.name: lastNames,
      PersonEnum.names.name: names,
      PersonEnum.attributes.name: mapTmp,
    };
  }

  /// Checks if two [PersonModel] instances are equal.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          names == other.names &&
          photoUrl == other.photoUrl &&
          attributes == other.attributes &&
          lastNames == other.lastNames &&
          hashCode == other.hashCode;

  /// Returns the hash code for this [PersonModel].
  @override
  int get hashCode => '$id$names$photoUrl$lastNames$attributes'.hashCode;

  /// Converts the [PersonModel] to a string representation.
  @override
  String toString() {
    return '${toJson()}';
  }
}
