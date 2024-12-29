import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../../mock_animal.dart';

void main() {
  group('AnimalModel Tests', () {
    const MockAnimal mockAnimal = MockAnimal(
      energy: 50,
      weight: 10,
      intelligence: 70,
      animalType: AnimalTypeEnum.feline,
      joyful: 30,
      hygiene: 80,
      gender: SexEnum.male,
    );

    test('eat increases energy', () {
      final AnimalModel updatedAnimal = mockAnimal.eat(10);
      expect(updatedAnimal.energy, 60);
      expect(updatedAnimal.energy, isNot(mockAnimal.energy));
    });

    test('play increases joyful', () {
      final AnimalModel updatedAnimal = mockAnimal.play(20);
      expect(updatedAnimal.joyful, 50);
      expect(updatedAnimal.joyful, isNot(mockAnimal.joyful));
    });

    test('rest increases energy', () {
      final AnimalModel updatedAnimal = mockAnimal.rest(15);
      expect(updatedAnimal.energy, 65);
      expect(updatedAnimal.energy, isNot(mockAnimal.energy));
    });

    test('train increases intelligence', () {
      final AnimalModel updatedAnimal = mockAnimal.train(5);
      expect(updatedAnimal.intelligence, 75);
      expect(updatedAnimal.intelligence, isNot(mockAnimal.intelligence));
    });

    test('clean increases hygiene', () {
      final AnimalModel updatedAnimal = mockAnimal.clean(10);
      expect(updatedAnimal.hygiene, 90);
      expect(updatedAnimal.hygiene, isNot(mockAnimal.hygiene));
    });

    test('copyWith returns updated instance', () {
      final AnimalModel updatedAnimal =
          mockAnimal.copyWith(energy: 70, joyful: 100);
      expect(updatedAnimal.energy, 70);
      expect(updatedAnimal.joyful, 100);
      expect(updatedAnimal.weight, mockAnimal.weight);
      expect(updatedAnimal.hygiene, mockAnimal.hygiene);
    });

    test('toJson returns correct map', () {
      final Map<String, dynamic> json = mockAnimal.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['energy'], mockAnimal.energy);
      expect(json['weight'], mockAnimal.weight);
      expect(json['intelligence'], mockAnimal.intelligence);
      expect(json['animalType'], mockAnimal.animalType.name);
      expect(json['joyful'], mockAnimal.joyful);
      expect(json['hygiene'], mockAnimal.hygiene);
      expect(json['gender'], mockAnimal.gender.name);
    });

    test('hashCode remains the same with copyWith without changes', () {
      final AnimalModel updatedAnimal = mockAnimal.copyWith();
      expect(updatedAnimal.hashCode, mockAnimal.hashCode);
      expect(updatedAnimal, mockAnimal);
    });

    test('equality operator works correctly', () {
      final AnimalModel identicalAnimal = mockAnimal.copyWith();
      expect(mockAnimal, equals(identicalAnimal));
    });

    test('inequality operator works correctly', () {
      final AnimalModel differentAnimal = mockAnimal.copyWith(energy: 99);
      expect(mockAnimal, isNot(equals(differentAnimal)));
    });
  });
}
