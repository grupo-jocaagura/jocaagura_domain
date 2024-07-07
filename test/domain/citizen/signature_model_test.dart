import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('SignatureModel', () {
    final String dateToCompare =
        DateUtils.dateTimeToString(DateTime(2024, 07, 07));

    test('should create a default model without errors', () {
      expect(defaultSignatureModel.id, '0');
      expect(defaultSignatureModel.created, DateTime(2024, 07, 07));
      expect(defaultSignatureModel.appId, 'noapp');
      expect(defaultSignatureModel.png64Image, defaultPNG64Image);
    });

    test('fromJson should correctly deserialize', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': '123',
        'created': dateToCompare,
        'appId': 'testApp',
        'png64Image': 'testImage',
      };

      final SignatureModel signature = SignatureModel.fromJson(json);
      expect(signature.id, '123');
      expect(signature.created, DateTime(2024, 07, 07));
      expect(signature.appId, 'testApp');
      expect(signature.png64Image, 'testImage');
    });

    test('toJson should correctly serialize', () {
      final SignatureModel signature = SignatureModel(
        id: '123',
        created: DateTime(2024, 07, 07),
        appId: 'testApp',
        png64Image: 'testImage',
      );

      final Map<String, dynamic> json = signature.toJson();
      expect(json['id'], '123');
      expect(json['created'], dateToCompare);
      expect(json['appId'], 'testApp');
      expect(json['png64Image'], 'testImage');
    });

    test('copyWith should modify the necessary fields', () {
      final SignatureModel original = defaultSignatureModel;
      final SignatureModel modified =
          original.copyWith(id: 'newId', appId: 'newApp');

      expect(modified.id, 'newId');
      expect(modified.appId, 'newApp');
      expect(modified.created, original.created); // Unchanged
      expect(modified.png64Image, original.png64Image); // Unchanged
    });

    test('equality and hashCode', () {
      final SignatureModel original = defaultSignatureModel;
      final Model clone = original.copyWith();

      expect(original, equals(clone));
      expect(original.hashCode, clone.hashCode);

      final Model different = original.copyWith(id: 'different');
      expect(original, isNot(equals(different)));
    });
  });
}
