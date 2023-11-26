import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('AddressModel', () {
    final Map<String, dynamic> jsonMap = <String, dynamic>{
      'id': '1',
      'postalCode': 12345,
      'country': 'USA',
      'administrativeArea': 'CA',
      'city': 'San Francisco',
      'locality': 'SOMA',
      'address': '123 Main St',
      'notes': 'Some notes',
    };

    test('fromJson should create an AddressModel from a valid map', () {
      final AddressModel addressModel = AddressModel.fromJson(jsonMap);

      expect(addressModel.id, '1');
      expect(addressModel.postalCode, 12345);
      expect(addressModel.country, 'USA');
      // ... agregar más expectativas para otros campos
    });

    test('toJson should convert AddressModel to a valid map', () {
      final Map<String, dynamic> jsonMap = defaultAddressModel.toJson();

      expect(jsonMap['id'], '1');
      expect(jsonMap['postalCode'], 12345);
      expect(jsonMap['country'], 'USA');
    });

    test('Copy with method', () {
      final AddressModel addressModel2 =
          defaultAddressModel.copyWith(id: 'Tcech');
      final AddressModel addressModel3 = defaultAddressModel.copyWith();

      expect(addressModel3, defaultAddressModel);
      expect(addressModel3.hashCode == defaultAddressModel.hashCode, isTrue);
      expect(addressModel2.hashCode != defaultAddressModel.hashCode, isTrue);
      expect(addressModel2.id == 'Tcech', isTrue);
      expect(addressModel2.toString().contains('Tcech'), isTrue);
    });
  });
}
