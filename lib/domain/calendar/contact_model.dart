part of '../../jocaagura_domain.dart';

enum ContactEnum {
  id,
  name,
  relationship,
  phoneNumber,
  email,
}

const ContactModel defaultContactModel = ContactModel(
  id: 'contact001',
  name: 'Maria Garcia',
  relationship: 'Madre',
  phoneNumber: '123-456-7890',
  email: 'maria.garcia@example.com',
);

/// Represents a contact within a healthcare management application.
///
/// This model class encapsulates the details of a contact person, such as a family member or
/// emergency contact, including information like the name, relationship to the patient,
/// phone number, and email address.
///
/// Example of using [ContactModel] in a practical application:
///
/// ```dart
/// void main() {
///   var contact = ContactModel(
///     id: 'contact001',
///     name: 'Maria Garcia',
///     relationship: 'Madre',
///     phoneNumber: '123-456-7890',
///     email: 'maria.garcia@example.com',
///   );
///
///   print('Contact ID: ${contact.id}');
///   print('Name: ${contact.name}');
///   print('Relationship: ${contact.relationship}');
///   print('Phone Number: ${contact.phoneNumber}');
///   print('Email: ${contact.email}');
/// }
/// ```
///
/// This class is essential for managing and storing contact information, which can be used
/// for various purposes such as emergency contacts or next of kin in healthcare applications.
class ContactModel extends Model {
  /// Constructs a new [ContactModel] with the given details.
  const ContactModel({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    required this.email,
  });

  /// Deserializes a JSON map into an instance of [ContactModel].
  ///
  /// The JSON map must contain keys for 'id', 'name', 'relationship',
  /// 'phoneNumber', and 'email' with appropriate values.
  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: Utils.getStringFromDynamic(json[ContactEnum.id.name]),
      name: Utils.getStringFromDynamic(json[ContactEnum.name.name]),
      relationship:
          Utils.getStringFromDynamic(json[ContactEnum.relationship.name]),
      phoneNumber:
          Utils.getStringFromDynamic(json[ContactEnum.phoneNumber.name]),
      email: Utils.getEmailFromDynamic(json[ContactEnum.email.name]),
    );
  }

  /// A unique identifier for the contact.
  final String id;

  /// The name of the contact person.
  final String name;

  /// The relationship of the contact person to the patient (e.g., Mother, Father, Spouse).
  final String relationship;

  /// The phone number of the contact person.
  final String phoneNumber;

  /// The email address of the contact person.
  final String email;

  /// Creates a copy of this [ContactModel] with optional new values.
  @override
  ContactModel copyWith({
    String? id,
    String? name,
    String? relationship,
    String? phoneNumber,
    String? email,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }

  /// Serializes this [ContactModel] into a JSON map.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ContactEnum.id.name: id,
      ContactEnum.name.name: name,
      ContactEnum.relationship.name: relationship,
      ContactEnum.phoneNumber.name: phoneNumber,
      ContactEnum.email.name: email,
    };
  }

  /// Determines if two [ContactModel] instances are equal.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ContactModel &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            name == other.name &&
            relationship == other.relationship &&
            phoneNumber == other.phoneNumber &&
            email == other.email &&
            hashCode == other.hashCode;
  }

  /// Returns the hash code for this [ContactModel].
  @override
  int get hashCode => Object.hash(id, name, relationship, phoneNumber, email);
}
