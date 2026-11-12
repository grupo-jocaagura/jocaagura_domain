import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('🧪 ModelCategory', () {
    const ModelCategory original = ModelCategory(
      category: 'Pet Store',
      description: 'Items related to pets and animals',
    );

    test('1️⃣ Roundtrip (toJson <-> fromJson)', () {
      final Map<String, dynamic> json = original.toJson();
      final ModelCategory fromJson = ModelCategory.fromJson(json);

      expect(fromJson, equals(original));
      expect(fromJson.toJson(), equals(json));
    });

    test('2️⃣ Category normalization on toJson', () {
      final Map<String, dynamic> json = original.toJson();
      expect(json['category'], equals('pet-store'));
    });

    test('3️⃣ copyWith preserves immutability and updates values', () {
      final ModelCategory modified = original.copyWith(
        description: 'Updated desc',
      );

      expect(modified.category, equals(original.category));
      expect(modified.description, equals('Updated desc'));
      expect(modified == original, isTrue);
    });

    test('4️⃣ Equality and hashCode based only on category', () {
      const ModelCategory sameCategoryDifferentDesc = ModelCategory(
        category: 'Pet Store',
        description: 'Completely different text',
      );

      expect(sameCategoryDifferentDesc, equals(original));
      expect(sameCategoryDifferentDesc.hashCode, equals(original.hashCode));
    });

    test('5️⃣ toString includes emoji and description', () {
      final String result = original.toString();
      expect(result, contains('📦 Category(Pet Store):'));
    });

    test('6️⃣ Default instance serializes correctly', () {
      expect(
        defaultModelCategory.toJson()['category'],
        equals('default-category'),
      );
    });
  });
}
