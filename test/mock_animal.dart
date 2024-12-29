import 'package:jocaagura_domain/jocaagura_domain.dart';

class MockAnimal extends AnimalModel {
  const MockAnimal({
    required super.energy,
    required super.weight,
    required super.intelligence,
    required super.animalType,
    required super.joyful,
    required super.hygiene,
    required super.gender,
  });

  @override
  AnimalModel eat(double value) {
    return copyWith(energy: energy + value);
  }

  @override
  AnimalModel play(double value) {
    return copyWith(joyful: joyful + value);
  }

  @override
  AnimalModel rest(double value) {
    return copyWith(energy: energy + value);
  }

  @override
  AnimalModel train(double value) {
    return copyWith(intelligence: intelligence + value);
  }

  @override
  AnimalModel clean(double value) {
    return copyWith(hygiene: hygiene + value);
  }

  @override
  AnimalModel copyWith({
    double? energy,
    double? weight,
    double? intelligence,
    AnimalTypeEnum? animalType,
    double? joyful,
    double? hygiene,
    SexEnum? gender,
  }) {
    return MockAnimal(
      energy: energy ?? this.energy,
      weight: weight ?? this.weight,
      intelligence: intelligence ?? this.intelligence,
      animalType: animalType ?? this.animalType,
      joyful: joyful ?? this.joyful,
      hygiene: hygiene ?? this.hygiene,
      gender: gender ?? this.gender,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'energy': energy,
      'weight': weight,
      'intelligence': intelligence,
      'animalType': animalType.name,
      'joyful': joyful,
      'hygiene': hygiene,
      'gender': gender.name,
    };
  }

  @override
  int get hashCode => Object.hash(
        energy,
        weight,
        intelligence,
        animalType,
        joyful,
        hygiene,
        gender,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MockAnimal &&
            runtimeType == other.runtimeType &&
            hashCode == other.hashCode;
  }
}
