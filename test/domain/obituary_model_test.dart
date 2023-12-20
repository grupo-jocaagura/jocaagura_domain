import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ObituaryModel Tests', () {
    test('fromJson creates correct instance', () {
      final Map<String, Object> json = <String, Object>{
        'id': '123',
        'photoUrl': 'http://example.com/photo.jpg',
        'person': <String, Object>{
          'id': '1',
          'names': 'John Doe',
          'photoUrl': '',
          'lastNames': 'Doe',
          'attributtes': <String, dynamic>{},
        },
        'creationDate': '2023-04-20T12:30:00.000',
        'vigilAddress': <String, dynamic>{
          // ... datos de AddressModel
        },
        'burialAddress': <String, dynamic>{
          // ... datos de AddressModel
        },
      };

      final ObituaryModel obituary = ObituaryModel.fromJson(json);

      expect(obituary.id, '123');
      expect(obituary.photoUrl, 'http://example.com/photo.jpg');
      // ... más expectativas para otros campos
    });

    test('toJson returns correct map', () {
      const PersonModel person = PersonModel(
        id: '1',
        names: 'John Doe',
        photoUrl: '',
        lastNames: 'Doe',
        attributtes: <String, AttributeModel<dynamic>>{},
      );
      const AddressModel address = defaultAddressModel;

      final ObituaryModel obituary = ObituaryModel(
        id: '123',
        person: person,
        creationDate: DateTime(2023, 4, 20, 12, 30),
        vigilDate: DateTime(2023, 4, 20, 16, 30),
        burialDate: DateTime(2023, 4, 20, 18, 30),
        vigilAddress: address,
        burialAddress: address,
        photoUrl: 'http://example.com/photo.jpg',
      );

      final Map<String, dynamic> json = obituary.toJson();

      expect(json['id'], '123');
      expect(json['photoUrl'], 'http://example.com/photo.jpg');
    });

    test('copyWith creates correct copy', () {
      final ObituaryModel original = defaultObituary;

      final ObituaryModel copy = original.copyWith(id: '456');
      expect(defaultObituary.toString() == original.toString(), true);

      expect(copy.id, '456');
      // ... más expectativas para otros campos
    });

    test('Equality and hashCode work correctly', () {
      final ObituaryModel obituary1 = defaultObituary;

      final ObituaryModel obituary2 = obituary1.copyWith();

      expect(obituary1, equals(obituary2));
      expect(obituary1.hashCode, equals(obituary2.hashCode));
    });
  });
}
