import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('StoreModel', () {
    test('fromJson should correctly parse a non-empty map', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'store_id',
        'nit': 12345,
        'photoUrl': 'https://example.com/photo.jpg',
        'coverPhotoUrl': 'https://example.com/cover.jpg',
        'email': 'store@example.com',
        'ownerEmail': 'owner@example.com',
        'name': 'My Store',
        'alias': 'Store',
        'address': defaultAddressModel.toString(),
        'phoneNumber1': 123456,
        'phoneNumber2': 789012,
      };

      final StoreModel store = StoreModel.fromJson(json);

      expect(store.id, 'store_id');
      expect(store.nit, 12345);
      expect(store.photoUrl, 'https://example.com/photo.jpg');
      expect(store.coverPhotoUrl, 'https://example.com/cover.jpg');
      expect(store.email, 'store@example.com');
      expect(store.ownerEmail, 'owner@example.com');
      expect(store.name, 'My Store');
      expect(store.alias, 'Store');
    });

    test('fromJson should handle an empty map', () {
      final Map<String, dynamic> json = <String, dynamic>{};

      final StoreModel store = StoreModel.fromJson(json);

      expect(store.id, '');
      expect(store.nit, 0);
      expect(store.photoUrl, '');
    });

    test('copyWith should create a copy without arguments', () {
      final StoreModel copy = defaultStoreModel.copyWith();

      expect(copy.id, 'store_id');
      expect(copy.nit, 12345);
      expect(copy.photoUrl, 'https://example.com/photo.jpg');
      expect(copy.coverPhotoUrl, 'https://example.com/cover.jpg');
      expect(copy.email, 'store@example.com');
      expect(copy.ownerEmail, 'owner@example.com');
      expect(copy.name, 'My Store');
      expect(copy.alias, 'Store');
      expect(copy.toString().contains('12345'), true);
      expect(copy.hashCode, equals(defaultStoreModel.hashCode));
      expect(copy == defaultStoreModel, true);
    });

    test('Verification code', () {
      expect(StoreModel.getVerificationNITNumber(1070955061), 3);
      expect(StoreModel.getVerificationNITNumber(12345), 8);
    });
  });
}
