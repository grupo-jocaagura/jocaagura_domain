import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('PersonModel Tests', () {
    test('Default values are set correctly', () {
      const PersonModel person = PersonModel(
        id: '',
        names: 'J.J.',
        photoUrl: '',
        lastNames: 'anonimo@anonimo.com.co',
        attributes: <String, AttributeModel<dynamic>>{},
      );

      expect(person.id, '');
      expect(person.names, 'J.J.');
      expect(person.photoUrl, '');
      expect(person.lastNames, 'anonimo@anonimo.com.co');
      expect(person.attributes, isEmpty);
    });

    test('fromJson creates correct instance', () {
      final Map<String, dynamic> json = <String, Object>{
        'id': '123',
        'names': 'John Doe',
        'photoUrl': 'url',
        'lastNames': 'Doe',
        'attributtes': <dynamic>[],
      };

      final PersonModel person = PersonModel.fromJson(json);

      expect(person.id, '123');
      expect(person.names, 'John Doe');
      expect(person.photoUrl, '');
      expect(person.lastNames, 'Doe');
      expect(person.attributes, isEmpty);
    });

    test('toJson returns correct map', () {
      const PersonModel person = PersonModel(
        id: '123',
        names: 'John Doe',
        photoUrl: 'url',
        lastNames: 'Doe',
        attributes: <String, AttributeModel<dynamic>>{
          'eyesColor': AttributeModel<String>(value: 'red', name: 'eyesColor'),
        },
      );

      final Map<String, dynamic> json = person.toJson();

      expect(json['id'], '123');
      expect(json['names'], 'John Doe');
      expect(json['photoUrl'], '');
      expect(json['lastNames'], 'Doe');
      expect(json['attributes'], isNotNull);
    });

    test('copyWith creates correct copy', () {
      const PersonModel original = PersonModel(
        id: '123',
        names: 'John Doe',
        photoUrl: 'url',
        lastNames: 'Doe',
        attributes: <String, AttributeModel<dynamic>>{},
      );

      final PersonModel copy = original.copyWith(
        id: '456',
        names: 'Jane Doe',
      );

      expect(copy.id, '456');
      expect(copy.names, 'Jane Doe');
      expect(copy.photoUrl, original.photoUrl);
      expect(copy.lastNames, original.lastNames);
      expect(copy.attributes, original.attributes);
      final PersonModel copy2 = copy.copyWith();
      expect(copy == copy2, true);
      expect(copy.toString(), copy2.toString());
    });

    test('Equality and hashCode work correctly', () {
      const PersonModel person1 = PersonModel(
        id: '123',
        names: 'John Doe',
        photoUrl: 'url',
        lastNames: 'Doe',
        attributes: <String, AttributeModel<dynamic>>{},
      );

      const PersonModel person2 = PersonModel(
        id: '123',
        names: 'John Doe',
        photoUrl: 'url',
        lastNames: 'Doe',
        attributes: <String, AttributeModel<dynamic>>{},
      );

      expect(person1, equals(person2));
      expect(person1.hashCode, equals(person2.hashCode));
    });
  });
}
