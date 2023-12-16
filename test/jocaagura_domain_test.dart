import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('UserModel', () {
    test('fromJson should create a valid instance', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': '123',
        'displayName': 'John Doe',
        'photoUrl': 'https://example.com/avatar.png',
        'email': 'john@example.com',
        'jwt': <String, String>{'token': 'xyz123'},
      };
      final Map<String, dynamic> json2 = <String, dynamic>{
        'id': '123',
        'photoUrl': 'https://example.com/avatar.png',
        'email': 'john@example.com',
        'jwt': <String, String>{'token': 'xyz123'},
      };

      final UserModel userModel = UserModel.fromJson(json);
      final UserModel userModel2 = UserModel.fromJson(json2);

      expect(userModel.id, '123');
      expect(userModel.displayName, 'John Doe');
      expect(userModel2.displayName, defaultUserModel.displayName);
      expect(userModel.photoUrl, 'https://example.com/avatar.png');
      expect(userModel.email, 'john@example.com');
      expect(userModel.jwt, <String, String>{'token': 'xyz123'});
    });

    test('copyWith should create a copy with the provided values', () {
      const UserModel originalModel = UserModel(
        id: 'originalId',
        displayName: 'Original Name',
        photoUrl: 'https://example.com/original.png',
        email: 'original@example.com',
        jwt: <String, dynamic>{'original': 'token'},
      );

      final UserModel copiedModel = originalModel.copyWith(
        id: 'newId',
        names: 'New Name',
        photoUrl: 'https://example.com/new.png',
        lastNames: 'new@example.com',
        jwt: <String, dynamic>{'new': 'token'},
      );
      final UserModel copiedModel2 = originalModel.copyWith();

      expect(originalModel.hashCode == copiedModel2.hashCode, true);
      expect(originalModel == copiedModel2, true);
      expect(copiedModel.id, 'newId');
      expect(copiedModel.displayName, 'New Name');
      expect(copiedModel.photoUrl, 'https://example.com/new.png');
      expect(copiedModel.email, 'new@example.com');
      expect(copiedModel.jwt, <String, String>{'new': 'token'});
    });

    test('toJson should convert the model to a valid JSON map', () {
      const UserModel userModel = UserModel(
        id: '123',
        displayName: 'John Doe',
        photoUrl: 'https://example.com/avatar.png',
        email: 'john@example.com',
        jwt: <String, dynamic>{'token': 'xyz123'},
      );

      final Map<String, dynamic> json = userModel.toJson();

      expect(json['id'], '123');
      expect(json['displayName'], 'John Doe');
      expect(json['photoUrl'], 'https://example.com/avatar.png');
      expect(json['email'], 'john@example.com');
      expect(json['jwt'], '{"token":"xyz123"}');
    });

    test('equality should work correctly', () {
      const UserModel userModel1 = UserModel(
        id: '123',
        displayName: 'John Doe',
        photoUrl: 'https://example.com/avatar.png',
        email: 'john@example.com',
        jwt: <String, dynamic>{'token': 'xyz123'},
      );

      const UserModel userModel2 = UserModel(
        id: '123',
        displayName: 'John Doe',
        photoUrl: 'https://example.com/avatar.png',
        email: 'john@example.com',
        jwt: <String, dynamic>{'token': 'xyz123'},
      );

      expect(userModel1, userModel2);
    });

    test('equality should handle different instances correctly', () {
      const UserModel userModel1 = UserModel(
        id: '123',
        displayName: 'John Doe',
        photoUrl: 'https://example.com/avatar.png',
        email: 'john@example.com',
        jwt: <String, dynamic>{'token': 'xyz123'},
      );

      const UserModel userModel2 = UserModel(
        id: '123',
        displayName: 'John Doe',
        photoUrl: 'https://example.com/avatar.png',
        email: 'john@example.com',
        jwt: <String, dynamic>{'token': 'xyz123'},
      );

      expect(identical(userModel1, userModel2), isTrue);
    });

    test('hashCode should be the same for equal instances', () {
      const UserModel userModel1 = UserModel(
        id: '123',
        displayName: 'John Doe',
        photoUrl: 'https://example.com/avatar.png',
        email: 'john@example.com',
        jwt: <String, dynamic>{'token': 'xyz123'},
      );

      const UserModel userModel2 = UserModel(
        id: '123',
        displayName: 'John Doe',
        photoUrl: 'https://example.com/avatar.png',
        email: 'john@example.com',
        jwt: <String, dynamic>{'token': 'xyz123'},
      );

      expect(userModel1.hashCode, userModel2.hashCode);
    });

    test('hashCode should be different for different instances', () {
      const UserModel userModel1 = UserModel(
        id: '123',
        displayName: 'John Doe',
        photoUrl: 'https://example.com/avatar.png',
        email: 'john@example.com',
        jwt: <String, dynamic>{'token': 'xyz123'},
      );

      const UserModel userModel2 = UserModel(
        id: '456',
        displayName: 'Jane Doe',
        photoUrl: 'https://example.com/avatar.png',
        email: 'jane@example.com',
        jwt: <String, dynamic>{'token': 'abc456'},
      );
      expect(userModel1.toString(), isNot(userModel2.toString()));

      expect(userModel1.hashCode, isNot(userModel2.hashCode));
    });
  });
}
