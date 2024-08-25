import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ContactModel Tests', () {
    // Define test data
    const String id = 'contact001';
    const String name = 'Maria Garcia';
    const String relationship = 'Madre';
    const String phoneNumber = '123-456-7890';
    const String email = 'maria.garcia@example.com';

    // Test the default model
    test('default model is correct', () {
      expect(defaultContactModel, isA<ContactModel>());
      expect(defaultContactModel.id, id);
      expect(defaultContactModel.name, name);
      expect(defaultContactModel.relationship, relationship);
      expect(defaultContactModel.phoneNumber, phoneNumber);
      expect(defaultContactModel.email, email);
    });

    // Test the constructor
    test('constructor sets values properly', () {
      final ContactModel contact = ContactModel(
        id: id,
        name: name,
        relationship: relationship,
        phoneNumber: phoneNumber,
        email: email,
      );

      expect(contact.id, id);
      expect(contact.name, name);
      expect(contact.relationship, relationship);
      expect(contact.phoneNumber, phoneNumber);
      expect(contact.email, email);
    });

    // Test copyWith
    test('copyWith updates values', () {
      final ContactModel updatedContact = defaultContactModel.copyWith(
        id: 'new_id',
        name: 'Juan Garcia',
        relationship: 'Padre',
        phoneNumber: '987-654-3210',
        email: 'juan.garcia@example.com',
      );

      expect(updatedContact.id, 'new_id');
      expect(updatedContact.name, 'Juan Garcia');
      expect(updatedContact.relationship, 'Padre');
      expect(updatedContact.phoneNumber, '987-654-3210');
      expect(updatedContact.email, 'juan.garcia@example.com');
    });

    test('copyWith without arguments returns the same object', () {
      final ContactModel copiedContact = defaultContactModel.copyWith();
      expect(copiedContact, equals(defaultContactModel));
      expect(copiedContact.hashCode, equals(defaultContactModel.hashCode));
    });

    // Test toJson
    test('toJson returns correct map', () {
      const ContactModel contact = defaultContactModel;
      final Map<String, dynamic> json = contact.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json[ContactEnum.id.name], id);
      expect(json[ContactEnum.name.name], name);
      expect(json[ContactEnum.relationship.name], relationship);
      expect(json[ContactEnum.phoneNumber.name], phoneNumber);
      expect(json[ContactEnum.email.name], email);
    });

    // Test fromJson
    test('fromJson creates a new instance from json', () {
      final Map<String, String> json = <String, String>{
        ContactEnum.id.name: 'new_id',
        ContactEnum.name.name: 'Juan Garcia',
        ContactEnum.relationship.name: 'Padre',
        ContactEnum.phoneNumber.name: '987-654-3210',
        ContactEnum.email.name: 'juan.garcia@example.com',
      };

      final ContactModel fromJsonContact = ContactModel.fromJson(json);
      expect(fromJsonContact, isA<ContactModel>());
      expect(fromJsonContact.id, 'new_id');
      expect(fromJsonContact.name, 'Juan Garcia');
      expect(fromJsonContact.relationship, 'Padre');
      expect(fromJsonContact.phoneNumber, '987-654-3210');
      expect(fromJsonContact.email, 'juan.garcia@example.com');
    });

    // Test hashCode
    test('hashCode is consistent for the same values', () {
      const ContactModel contact1 = defaultContactModel;
      const ContactModel contact2 = defaultContactModel;

      expect(contact1.hashCode, contact2.hashCode);
    });

    // Test equality operator
    test('equality operator works correctly', () {
      const ContactModel contact1 = defaultContactModel;
      const ContactModel contact2 = defaultContactModel;

      expect(contact1, equals(contact2));
    });

    // Add any additional tests here to cover edge cases or other methods
  });
}
