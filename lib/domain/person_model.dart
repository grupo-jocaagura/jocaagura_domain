part of '../jocaagura_domain.dart';

enum PersonEnum {
  id,
  names,
  photoUrl,
  lastNames,
  attributes,
}

const PersonModel defaultPersonModel = PersonModel(
  id: '',
  names: 'J.J.',
  photoUrl: '',
  lastNames: 'Last Names',
  attributtes: <String, AttributeModel<dynamic>>{},
);

class PersonModel extends Model {
  const PersonModel({
    required this.id,
    required this.names,
    required this.photoUrl,
    required this.lastNames,
    required this.attributtes,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: Utils.getStringFromDynamic(json[PersonEnum.id.name]),
      names: Utils.getStringFromDynamic(json[PersonEnum.names.name]),
      photoUrl: Utils.getUrlFromDynamic(json[PersonEnum.photoUrl.name]),
      lastNames: Utils.getStringFromDynamic(json[PersonEnum.lastNames.name]),
      attributtes: const <String, AttributeModel<dynamic>>{},
    );
  }

  final String id;
  final String names;
  final String photoUrl;
  final String lastNames;
  final Map<String, AttributeModel<dynamic>> attributtes;

  @override
  PersonModel copyWith({
    String? id,
    String? names,
    String? photoUrl,
    String? lastNames,
    Map<String, AttributeModel<dynamic>>? attributtes,
  }) =>
      PersonModel(
        id: id ?? this.id,
        names: names ?? this.names,
        photoUrl: photoUrl ?? this.photoUrl,
        lastNames: lastNames ?? this.lastNames,
        attributtes: attributtes ?? this.attributtes,
      );

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> mapTmp = <String, dynamic>{};
    for (final MapEntry<String, AttributeModel<dynamic>> element
        in attributtes.entries) {
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          names == other.names &&
          photoUrl == other.photoUrl &&
          attributtes == other.attributtes &&
          lastNames == other.lastNames &&
          hashCode == other.hashCode;

  @override
  int get hashCode => '$id$names$photoUrl$lastNames$attributtes'.hashCode;

  @override
  String toString() {
    return '${toJson()}';
  }
}
