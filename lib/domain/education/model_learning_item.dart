part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// JSON keys for [ModelLearningItem]. Using enum guarantees stable roundtrip.
enum LearningItemEnum {
  id,
  label,
  correctAnswer,
  wrongAnswerOne,
  wrongAnswerTwo,
  wrongAnswerThree,
  explanation,
  attributes,
  achievementOne,
  achievementTwo,
  achievementThree,
  cineLevel,
  estimatedTimeMs, // milliseconds
  category,
}

/// Multiple-choice learning item linked to performance indicators.
///
/// Immutable; JSON roundtrip uses [LearningItemEnum] keys.
/// Enforced domain invariants:
/// - `achievementOne` is required; `achievementTwo/Three` are optional.
/// - `0 <= cineLevel <= 11`
///
/// ### Minimal runnable example
/// ```dart
/// void main() {
///   const ModelLearningItem item = ModelLearningItem(
///     id: 'LI-1',
///     label: 'Water formula is...',
///     correctAnswer: 'H₂O',
///     wrongAnswerOne: 'CO₂',
///     wrongAnswerTwo: 'O₂',
///     wrongAnswerThree: 'NaCl',
///     explanation: 'Two hydrogen and one oxygen atoms.',
///     attributes: <ModelAttribute<dynamic>>[],
///     achievementOne: ModelPerformanceIndicator(
///       id: 'PI-1',
///       modelLearningGoal: defaultLearningGoal,
///       label: 'Recognizes H2O',
///       level: PerformanceLevel.basic,
///       code: 'SCI.WAT.IND.1',
///     ),
///     cineLevel: 0,
///     estimatedTimeForAnswer: Duration(minutes: 2),
///     category: ModelCategory(category: 'science', description: 'Science'),
///   );
///
///   final Map<String, dynamic> json = item.toJson();
///   final ModelLearningItem copy = ModelLearningItem.fromJson(json);
///   assert(item == copy);
/// }
/// ```
class ModelLearningItem extends Model {
  ModelLearningItem({
    required this.id,
    required this.label,
    required this.correctAnswer,
    required this.wrongAnswerOne,
    required this.wrongAnswerTwo,
    required this.wrongAnswerThree,
    required this.explanation,
    required List<ModelAttribute<dynamic>> attributes,
    required this.achievementOne,
    required this.cineLevel,
    required this.estimatedTimeForAnswer,
    required this.category,
    this.achievementTwo,
    this.achievementThree,
  })  : assert(cineLevel >= 0 && cineLevel <= 11, 'cineLevel must be in 0..11'),
        attributes = List<ModelAttribute<dynamic>>.unmodifiable(attributes);

  /// Builds a [ModelLearningItem] from JSON-like input (no legacy keys).
  ///
  /// Required keys: `id`, `label`, `correctAnswer`, `wrongAnswerOne/Two/Three`,
  /// `explanation`, `attributes`, `achievementOne`, `cineLevel`,
  /// `estimatedTimeMs`, `category`.
  ///
  /// Throws:
  /// - [FormatException] if `achievementOne` is missing/invalid.
  factory ModelLearningItem.fromJson(Map<String, dynamic> json) {
    ModelPerformanceIndicator? parsePI(String key) {
      final Map<String, dynamic> m = Utils.mapFromDynamic(json[key]);
      if (m.isEmpty) {
        return null;
      }
      return ModelPerformanceIndicator.fromJson(m);
    }

    final ModelPerformanceIndicator? a1 =
        parsePI(LearningItemEnum.achievementOne.name);
    if (a1 == null) {
      throw const FormatException('achievementOne is required');
    }

    return ModelLearningItem(
      id: Utils.getStringFromDynamic(json[LearningItemEnum.id.name]),
      label: Utils.getStringFromDynamic(json[LearningItemEnum.label.name]),
      correctAnswer:
          Utils.getStringFromDynamic(json[LearningItemEnum.correctAnswer.name]),
      wrongAnswerOne: Utils.getStringFromDynamic(
        json[LearningItemEnum.wrongAnswerOne.name],
      ),
      wrongAnswerTwo: Utils.getStringFromDynamic(
        json[LearningItemEnum.wrongAnswerTwo.name],
      ),
      wrongAnswerThree: Utils.getStringFromDynamic(
        json[LearningItemEnum.wrongAnswerThree.name],
      ),
      explanation:
          Utils.getStringFromDynamic(json[LearningItemEnum.explanation.name]),
      attributes: AttributeModel.listFromDynamicShallow(
        json[LearningItemEnum.attributes.name],
      ),
      achievementOne: a1,
      achievementTwo: parsePI(LearningItemEnum.achievementTwo.name),
      achievementThree: parsePI(LearningItemEnum.achievementThree.name),
      cineLevel:
          Utils.getIntegerFromDynamic(json[LearningItemEnum.cineLevel.name]),
      estimatedTimeForAnswer: Utils.durationFromJson(
        json[LearningItemEnum.estimatedTimeMs.name],
        defaultDuration: defaultETA,
      ),
      category: ModelCategory.fromJson(
        Utils.mapFromDynamic(json[LearningItemEnum.category.name]),
      ),
    );
  }

  /// Default time to answer used when not provided.
  static const Duration defaultETA = Duration(minutes: 5);

  final String id;
  final String label;
  final String correctAnswer;
  final String wrongAnswerOne;
  final String wrongAnswerTwo;
  final String wrongAnswerThree;
  final String explanation;
  final List<ModelAttribute<dynamic>> attributes;

  /// Achievements split: one required, two optional.
  final ModelPerformanceIndicator achievementOne;
  final ModelPerformanceIndicator? achievementTwo;
  final ModelPerformanceIndicator? achievementThree;

  final int cineLevel; // 0..11
  final Duration estimatedTimeForAnswer;
  final ModelCategory category;

  /// Deterministically shuffle options when [seed] is provided.
  List<String> optionsShuffled([int? seed]) {
    final List<String> opts = <String>[
      correctAnswer,
      wrongAnswerOne,
      wrongAnswerTwo,
      wrongAnswerThree,
    ];
    if (seed == null) {
      opts.shuffle();
      return opts;
    }
    final List<String> result = List<String>.from(opts);
    int s = seed;
    for (int i = result.length - 1; i > 0; i--) {
      s = (s * 1103515245 + 12345) & 0x7fffffff;
      final int j = s % (i + 1);
      final String tmp = result[i];
      result[i] = result[j];
      result[j] = tmp;
    }
    return result;
  }

  /// Returns a new instance replacing provided fields.
  @override
  ModelLearningItem copyWith({
    String? id,
    String? label,
    String? correctAnswer,
    String? wrongAnswerOne,
    String? wrongAnswerTwo,
    String? wrongAnswerThree,
    String? explanation,
    List<ModelAttribute<dynamic>>? attributes,
    ModelPerformanceIndicator? achievementOne,
    ModelPerformanceIndicator? achievementTwo,
    ModelPerformanceIndicator? achievementThree,
    int? cineLevel,
    Duration? estimatedTimeForAnswer,
    ModelCategory? category,
  }) {
    return ModelLearningItem(
      id: id ?? this.id,
      label: label ?? this.label,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      wrongAnswerOne: wrongAnswerOne ?? this.wrongAnswerOne,
      wrongAnswerTwo: wrongAnswerTwo ?? this.wrongAnswerTwo,
      wrongAnswerThree: wrongAnswerThree ?? this.wrongAnswerThree,
      explanation: explanation ?? this.explanation,
      attributes: attributes ?? this.attributes,
      achievementOne: achievementOne ?? this.achievementOne,
      achievementTwo: achievementTwo ?? this.achievementTwo,
      achievementThree: achievementThree ?? this.achievementThree,
      cineLevel: cineLevel ?? this.cineLevel,
      estimatedTimeForAnswer:
          estimatedTimeForAnswer ?? this.estimatedTimeForAnswer,
      category: category ?? this.category,
    );
  }

  /// Serializes to JSON using [LearningItemEnum] keys.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        LearningItemEnum.id.name: id,
        LearningItemEnum.label.name: label,
        LearningItemEnum.correctAnswer.name: correctAnswer,
        LearningItemEnum.wrongAnswerOne.name: wrongAnswerOne,
        LearningItemEnum.wrongAnswerTwo.name: wrongAnswerTwo,
        LearningItemEnum.wrongAnswerThree.name: wrongAnswerThree,
        LearningItemEnum.explanation.name: explanation,
        LearningItemEnum.attributes.name:
            attributes.map((ModelAttribute<dynamic> e) => e.toJson()).toList(),
        LearningItemEnum.achievementOne.name: achievementOne.toJson(),
        if (achievementTwo != null)
          LearningItemEnum.achievementTwo.name: achievementTwo!.toJson(),
        if (achievementThree != null)
          LearningItemEnum.achievementThree.name: achievementThree!.toJson(),
        LearningItemEnum.cineLevel.name: cineLevel,
        LearningItemEnum.estimatedTimeMs.name:
            Utils.durationToJson(estimatedTimeForAnswer),
        LearningItemEnum.category.name: category.toJson(),
      };

  @override
  int get hashCode => Object.hashAll(<Object?>[
        id,
        label,
        correctAnswer,
        wrongAnswerOne,
        wrongAnswerTwo,
        wrongAnswerThree,
        explanation,
        cineLevel,
        estimatedTimeForAnswer,
        category,
        Utils.listHash(attributes),
        achievementOne,
        achievementTwo,
        achievementThree,
      ]);

  @override
  bool operator ==(Object other) =>
      other is ModelLearningItem &&
      other.id == id &&
      other.label == label &&
      other.correctAnswer == correctAnswer &&
      other.wrongAnswerOne == wrongAnswerOne &&
      other.wrongAnswerTwo == wrongAnswerTwo &&
      other.wrongAnswerThree == wrongAnswerThree &&
      other.explanation == explanation &&
      other.cineLevel == cineLevel &&
      other.estimatedTimeForAnswer == estimatedTimeForAnswer &&
      other.category == category &&
      Utils.listEquals(other.attributes, attributes) &&
      other.achievementOne == achievementOne &&
      other.achievementTwo == achievementTwo &&
      other.achievementThree == achievementThree;

  /// JSON string representation (useful for logs & diffs).
  @override
  String toString() => jsonEncode(toJson());
}

/// Default instance of [ModelLearningItem] for tests or fallback scenarios.
///
/// Uses `defaultLearningGoal` and neutral values. Not intended for production data.
final ModelLearningItem defaultModelLearningItem = ModelLearningItem(
  id: 'LI-DEFAULT',
  label: 'Undefined learning item',
  correctAnswer: 'A',
  wrongAnswerOne: 'B',
  wrongAnswerTwo: 'C',
  wrongAnswerThree: 'D',
  explanation: '',
  attributes: const <ModelAttribute<dynamic>>[],
  achievementOne: const ModelPerformanceIndicator(
    id: 'PI-DEFAULT',
    modelLearningGoal: defaultLearningGoal,
    label: 'Undefined indicator',
    level: PerformanceLevel.basic,
    code: 'GEN.PI.DEFAULT',
  ),
  cineLevel: 0,
  estimatedTimeForAnswer: ModelLearningItem.defaultETA,
  category: const ModelCategory(category: 'general', description: 'General'),
);
