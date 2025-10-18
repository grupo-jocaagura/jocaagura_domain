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

    test('format numbers and nit', () {
      expect(defaultStoreModel.nitNumber, '12345 - 8');
      expect(defaultStoreModel.formatedPhoneNumber1, '(00) 0 012 3456');
      expect(defaultStoreModel.formatedPhoneNumber2, '000 078 9012');
    });
  });
  group('StoreModel', () {
    test('Given address When toJson Then address is a JSON map (not string)',
        () {
      const StoreModel s = StoreModel(
        id: 'id',
        nit: 12345,
        photoUrl: 'https://x/p.jpg',
        coverPhotoUrl: 'https://x/c.jpg',
        email: 'e@x.com',
        ownerEmail: 'o@x.com',
        name: 'N',
        alias: 'A',
        address: defaultAddressModel,
        phoneNumber1: 111,
        phoneNumber2: 222,
      );
      final dynamic addr = s.toJson()['address'];
      expect(addr, isA<Map<String, dynamic>>());
    });

    test('Given two equal stores When compare Then == true and hash equal', () {
      const StoreModel a = StoreModel(
        id: '1',
        nit: 10,
        photoUrl: 'p',
        coverPhotoUrl: 'c',
        email: 'a@x.com',
        ownerEmail: 'o@x.com',
        name: 'N',
        alias: 'A',
        address: defaultAddressModel,
        phoneNumber1: 1,
        phoneNumber2: 2,
      );
      const StoreModel b = StoreModel(
        id: '1',
        nit: 10,
        photoUrl: 'p',
        coverPhotoUrl: 'c',
        email: 'a@x.com',
        ownerEmail: 'o@x.com',
        name: 'N',
        alias: 'A',
        address: defaultAddressModel,
        phoneNumber1: 1,
        phoneNumber2: 2,
      );
      expect(a == b, isTrue);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('Given nit When getVerificationNITNumber Then returns dv in [0,1..9]',
        () {
      final int dv = StoreModel.getVerificationNITNumber(900373106);
      expect(dv, inInclusiveRange(0, 9));
    });

    test('Given fromJson Then roundtrip preserves shape and address map', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'xyz',
        'nit': 123,
        'photoUrl': 'https://x/p.jpg',
        'coverPhotoUrl': 'https://x/c.jpg',
        'email': 'e@x.com',
        'ownerEmail': 'o@x.com',
        'name': 'Name',
        'alias': 'Alias',
        'address': defaultAddressModel.toJson(),
        'phoneNumber1': 555,
        'phoneNumber2': 666,
      };
      final StoreModel s = StoreModel.fromJson(json);
      final Map<String, dynamic> out = s.toJson();
      expect(out['address'], isA<Map<String, dynamic>>());
      expect(out['id'], 'xyz');
    });
  });
}
