part of '../jocaagura_domain.dart';

enum UserEnum {
  id,
  displayName,
  photoUrl,
  email,
  jwt,
}

const UserModel defaultUserModel = UserModel(
  id: '',
  displayName: 'J.J.',
  photoUrl: '',
  email: 'anonimo@anonimo.com.co',
  jwt: <String, dynamic>{},
);

class UserModel extends Model {
  const UserModel({
    required this.id,
    required this.displayName,
    required this.photoUrl,
    required this.email,
    required this.jwt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json[UserEnum.id.name]?.toString() ?? defaultUserModel.id,
      displayName: json[UserEnum.displayName.name]?.toString() ??
          defaultUserModel.displayName,
      photoUrl: Utils.getUrlFromMap(json[UserEnum.photoUrl.name]),
      email: Utils.getEmailFromMap(json[UserEnum.email.name]),
      jwt: Utils.mapFromString(json[UserEnum.jwt.name]),
    );
  }

  final String id;
  final String displayName;
  final String photoUrl;
  final String email;
  final Map<String, dynamic> jwt;

  @override
  UserModel copyWith({
    String? id,
    String? displayName,
    String? photoUrl,
    String? email,
    Map<String, dynamic>? jwt,
  }) =>
      UserModel(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        email: email ?? this.email,
        jwt: jwt ?? this.jwt,
      );

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      UserEnum.id.name: id,
      UserEnum.displayName.name: displayName,
      UserEnum.photoUrl.name: photoUrl,
      UserEnum.email.name: email,
      UserEnum.jwt.name: Utils.mapToString(jwt),
    };
  }
}
