part of '../../jocaagura_domain.dart';

/// Enumeration representing different types of animals.
enum AnimalTypeEnum {
  fish,
  feline,
  canine,
  bird,
  reptile,
}

/// Enumeration representing the gender of an animal.
enum SexEnum {
  male,
  female,
}

/// Abstract class representing the model for an animal.
/// This class serves as a blueprint for creating various animal models,
/// encompassing attributes like energy, weight, intelligence, and more.
abstract class AnimalModel implements Model {
  /// Creates an instance of [AnimalModel].
  ///
  /// All properties are required and must be initialized.
  const AnimalModel({
    required this.energy,
    required this.weight,
    required this.intelligence,
    required this.animalType,
    required this.joyful,
    required this.hygiene,
    required this.gender,
  });

  /// The energy level of the animal.
  final double energy;

  /// The weight of the animal.
  final double weight;

  /// The intelligence level of the animal.
  final double intelligence;

  /// The type of the animal, represented by [AnimalTypeEnum].
  final AnimalTypeEnum animalType;

  /// The level of joy or happiness of the animal.
  final double joyful;

  /// The hygiene level of the animal.
  final double hygiene;

  /// The gender of the animal, represented by [SexEnum].
  final SexEnum gender;

  /// Allows the animal to eat, increasing its energy by [value].
  ///
  /// Returns a new instance of [AnimalModel] with the updated energy level.
  AnimalModel eat(double value);

  /// Allows the animal to play, increasing its joy by [value].
  ///
  /// Returns a new instance of [AnimalModel] with the updated joyful level.
  AnimalModel play(double value);

  /// Allows the animal to rest, increasing its energy by [value].
  ///
  /// Returns a new instance of [AnimalModel] with the updated energy level.
  AnimalModel rest(double value);

  /// Allows the animal to train, increasing its intelligence by [value].
  ///
  /// Returns a new instance of [AnimalModel] with the updated intelligence level.
  AnimalModel train(double value);

  /// Allows the animal to be cleaned, increasing its hygiene by [value].
  ///
  /// Returns a new instance of [AnimalModel] with the updated hygiene level.
  AnimalModel clean(double value);

  ///     Property Suggestions:
  ///         Age: Adding an age property can make the model more realistic.
  ///         Health: Including a health attribute might be beneficial,
  ///         as it could degrade or improve based on activities
  ///         like playing or eating.
  ///         Hunger Level: Tracking hunger could make the eat method more
  ///         meaningful.
}
