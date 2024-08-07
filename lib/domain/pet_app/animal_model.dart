part of '../../jocaagura_domain.dart';

enum AnimalTypeEnum {
  fish,
  feline,
  canine,
  bird,
  reptile,
}

enum SexEnum {
  male,
  female,
}

abstract class AnimalModel implements Model {
  const AnimalModel({
    required this.energy,
    required this.weight,
    required this.intelligence,
    required this.animalType,
    required this.joyful,
    required this.hygiene,
    required this.gender,
  });

  final double energy;
  final double weight;
  final double intelligence;
  final AnimalTypeEnum animalType;
  final double joyful;
  final double hygiene;
  final SexEnum gender;

  AnimalModel eat(double value);
  AnimalModel play(double value);
  AnimalModel rest(double value);
  AnimalModel train(double value);
  AnimalModel clean(double value);
}
