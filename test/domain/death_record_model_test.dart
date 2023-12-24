import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('DeathRecordModel Tests', () {
    // Initial test data
    const StoreModel testNotaria =
        defaultStoreModel; // Assuming defaultStoreModel is defined as per your provided classes
    const PersonModel testPerson =
        defaultPersonModel; // Assuming defaultPersonModel is defined
    const AddressModel testAddress =
        defaultAddressModel; // Assuming defaultAddressModel is defined
    const String testRecordId = 'testRecordId';
    const String testId = 'testId';

    // Test the default model
    test('default model is correct', () {
      expect(defaultDeathRecord, isA<DeathRecordModel>());
    });

    // Test the constructor
    test('can instantiate with values', () {
      const DeathRecordModel record = DeathRecordModel(
        notaria: testNotaria,
        person: testPerson,
        address: testAddress,
        recordId: testRecordId,
        id: testId,
      );

      expect(record.notaria, testNotaria);
      expect(record.person, testPerson);
      expect(record.address, testAddress);
      expect(record.recordId, testRecordId);
      expect(record.id, testId);
    });

    // Test copyWith
    test('copyWith preserves object identity when no new values are passed',
        () {
      final DeathRecordModel record = defaultDeathRecord.copyWith();
      expect(record, equals(defaultDeathRecord));
    });

    test('copyWith updates values', () {
      final DeathRecordModel updatedRecord = defaultDeathRecord.copyWith(
        id: 'newId',
        recordId: 'newRecordId',
      );

      expect(updatedRecord.id, 'newId');
      expect(updatedRecord.recordId, 'newRecordId');
    });

    // Test toJson
    test('toJson returns a map with correct key-value pairs', () {
      const DeathRecordModel record = defaultDeathRecord;
      final Map<String, dynamic> json = record.toJson();

      expect(json, isA<Map<String, dynamic>>());
      // Add more specific expectations based on your implementation
    });

    // Test fromJson
    test('fromJson returns a valid model for correct JSON', () {
      final Map<String, dynamic> json = defaultDeathRecord.toJson();
      final DeathRecordModel fromJsonRecord = defaultDeathRecord.fromJson(json);

      expect(fromJsonRecord, isA<DeathRecordModel>());
      // Add more specific expectations based on your implementation
    });

    // Test hashCode
    test('hashCode returns consistent result', () {
      const DeathRecordModel record = defaultDeathRecord;
      final int code1 = record.hashCode;
      final int code2 = record.hashCode;

      expect(code1, equals(code2));
    });

    // Test toString
    test('toString returns expected string', () {
      const DeathRecordModel record = defaultDeathRecord;
      expect(record.toString(), isA<String>());
      // You might want to check for specific formatting if applicable
    });

    // Test equality operator
    test('equality operator works as expected', () {
      const DeathRecordModel record1 = defaultDeathRecord;
      final DeathRecordModel record2 = defaultDeathRecord.copyWith();

      expect(record1, equals(record2));
    });
  });
}
