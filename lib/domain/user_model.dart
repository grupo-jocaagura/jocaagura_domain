part of '../jocaagura_domain.dart';

/// Enumerates the properties of a user in the [UserModel].
///
/// These properties represent essential attributes of a user, such as their ID,
/// display name, profile photo URL, email address, and JSON Web Token (JWT).
enum UserEnum {
  /// Unique identifier for the user.
  id,

  /// Display name of the user.
  displayName,

  /// URL pointing to the user's profile photo.
  photoUrl,

  /// Email address of the user.
  email,

  /// JSON Web Token associated with the user.
  jwt,
}

/// A default instance of [UserModel] for testing or fallback purposes.
///
/// This instance provides placeholder values for a typical user.
const UserModel defaultUserModel = UserModel(
  id: '',
  displayName: 'J.J.',
  photoUrl: '',
  email: 'anonimo@anonimo.com.co',
  jwt: <String, dynamic>{},
);

/// Represents a user within the application.
///
/// This model class encapsulates details about a user, including their
/// identification, display name, profile photo, email, and authentication token.
///
/// Example of using [UserModel] in a practical application:
///
/// ```dart
/// void main() {
///   final UserModel user = UserModel(
///     id: 'user_001',
///     displayName: 'John Doe',
///     photoUrl: 'https://example.com/profile.jpg',
///     email: 'john.doe@example.com',
///     jwt: <String, dynamic>{'token': 'abc123'},
///   );
///
///   print('User ID: ${user.id}');
///   print('Display Name: ${user.displayName}');
///   print('Email: ${user.email}');
/// }
/// ```
class UserModel extends Model {
  /// Constructs a new [UserModel] with the given details.
  const UserModel({
    required this.id,
    required this.displayName,
    required this.photoUrl,
    required this.email,
    required this.jwt,
  });

  /// Deserializes a JSON map into an instance of [UserModel].
  ///
  /// The JSON map must contain keys corresponding to the [UserEnum] values.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json[UserEnum.id.name]?.toString() ?? defaultUserModel.id,
      displayName: json[UserEnum.displayName.name]?.toString() ??
          defaultUserModel.displayName,
      photoUrl: Utils.getUrlFromDynamic(json[UserEnum.photoUrl.name]),
      email: Utils.getEmailFromDynamic(json[UserEnum.email.name]),
      jwt: Utils.mapFromDynamic(json[UserEnum.jwt.name]),
    );
  }

  /// Unique identifier for the user.
  final String id;

  /// Display name of the user.
  final String displayName;

  /// URL pointing to the user's profile photo.
  final String photoUrl;

  /// Email address of the user.
  final String email;

  /// JSON Web Token associated with the user.
  final Map<String, dynamic> jwt;

  /// Creates a copy of this [UserModel] with optional new values.
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

  /// Serializes this [UserModel] into a JSON map.
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

  /// Compares this [UserModel] to another object.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl &&
          jwt == other.jwt &&
          email == other.email;

  /// Returns the hash code for this [UserModel].
  @override
  int get hashCode => Object.hash(id, displayName, photoUrl, email, jwt);

  /// Returns a string representation of this [UserModel].
  @override
  String toString() {
    return 'UserModel: ${toJson()}';
  }
}
