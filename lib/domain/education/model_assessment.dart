part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// JSON keys for [ModelAssessment]. Enum-backed for roundtrip stability.
enum AssessmentEnum {
  id,
  title,
  items,
  shuffleItems,
  shuffleOptions,
  timeLimitMs, // store as milliseconds
  passScore, // 0..100
}

/// Default instance of [ModelAssessment] for tests or fallback scenarios.
///
/// Uses `defaultModelLearningItem`, zero time limit, and neutral values.
/// Not intended for production data.
final ModelAssessment defaultModelAssessment = ModelAssessment(
  id: 'ASMT-DEFAULT',
  title: 'Undefined assessment',
  items: <ModelLearningItem>[defaultModelLearningItem],
  shuffleItems: true,
  shuffleOptions: true,
  timeLimit: Duration.zero,
  passScore: 0,
);

/// Assessment made of multiple [ModelLearningItem]s.
///
/// Immutable; JSON roundtrip uses [AssessmentEnum] keys. Tolerant parsing via
/// `Utils.*`.
///
/// Contracts:
/// - `items` is stored unmodifiable.
/// - `timeLimitMs` represents milliseconds; internally exposed as [Duration].
/// - `passScore` is an integer in 0..100 (values outside are clamped).
///
/// ### Minimal runnable example
/// ```dart
/// void main() {
///   final ModelAssessment a = ModelAssessment(
///     id: 'ASMT-1',
///     title: 'Basic Chemistry',
///     items: <ModelLearningItem>[defaultModelLearningItem],
///     shuffleItems: true,
///     shuffleOptions: true,
///     timeLimit: const Duration(minutes: 10),
///     passScore: 60,
///   );
///   final Map<String, dynamic> json = a.toJson();
///   final ModelAssessment copy = ModelAssessment.fromJson(json);
///   assert(a == copy);
/// }
/// ```
class ModelAssessment extends Model {
  ModelAssessment({
    required this.id,
    required this.title,
    required List<ModelLearningItem> items,
    required this.shuffleItems,
    required this.shuffleOptions,
    required int passScore,
    this.timeLimit = defaultTimeLimit,
  })  : items = List<ModelLearningItem>.unmodifiable(items),
        passScore = _clampPassScore(passScore),
        assert(!timeLimit.isNegative, 'timeLimit must be >= 0');

  /// Builds a [ModelAssessment] from JSON-like input.
  ///
  /// Defaults:
  /// - `shuffleItems`: `true` if missing/invalid.
  /// - `shuffleOptions`: `true` if missing/invalid.
  /// - `timeLimitMs`: `Duration.zero` if missing/invalid.
  /// - `passScore`: `0` if missing/invalid (then clamped 0..100).
  factory ModelAssessment.fromJson(Map<String, dynamic> map) {
    final List<ModelLearningItem> parsedItems =
        Utils.listFromDynamic(map[AssessmentEnum.items.name])
            .map<ModelLearningItem>(ModelLearningItem.fromJson)
            .toList();

    final bool parsedShuffleItems = Utils.getBoolFromDynamic(
      map[AssessmentEnum.shuffleItems.name],
      defaultValueIfNull: true,
    );

    final bool parsedShuffleOptions = Utils.getBoolFromDynamic(
      map[AssessmentEnum.shuffleOptions.name],
      defaultValueIfNull: true,
    );

    final Duration parsedTimeLimit = Utils.durationFromJson(
      map[AssessmentEnum.timeLimitMs.name],
    );

    final int parsedPassScore = _clampPassScore(
      Utils.getIntegerFromDynamic(map[AssessmentEnum.passScore.name]),
    );

    return ModelAssessment(
      id: Utils.getStringFromDynamic(map[AssessmentEnum.id.name]),
      title: Utils.getStringFromDynamic(map[AssessmentEnum.title.name]),
      items: parsedItems,
      shuffleItems: parsedShuffleItems,
      shuffleOptions: parsedShuffleOptions,
      timeLimit: parsedTimeLimit,
      passScore: parsedPassScore,
    );
  }

  final String id;
  final String title;
  final List<ModelLearningItem> items;
  final bool shuffleItems;
  final bool shuffleOptions;

  /// Time limit for the whole assessment.
  final Duration timeLimit;

  static const Duration defaultTimeLimit = Duration(minutes: 60);

  /// Passing score in percentage (0..100).
  final int passScore;

  /// Returns a new instance replacing provided fields.
  @override
  ModelAssessment copyWith({
    String? id,
    String? title,
    List<ModelLearningItem>? items,
    bool? shuffleItems,
    bool? shuffleOptions,
    Duration? timeLimit,
    int? passScore,
  }) {
    return ModelAssessment(
      id: id ?? this.id,
      title: title ?? this.title,
      items: items ?? this.items,
      shuffleItems: shuffleItems ?? this.shuffleItems,
      shuffleOptions: shuffleOptions ?? this.shuffleOptions,
      timeLimit: timeLimit ?? this.timeLimit,
      passScore: passScore ?? this.passScore,
    );
  }

  /// Serializes to JSON using [AssessmentEnum] keys.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        AssessmentEnum.id.name: id,
        AssessmentEnum.title.name: title,
        AssessmentEnum.items.name:
            items.map((ModelLearningItem e) => e.toJson()).toList(),
        AssessmentEnum.shuffleItems.name: shuffleItems,
        AssessmentEnum.shuffleOptions.name: shuffleOptions,
        AssessmentEnum.timeLimitMs.name: Utils.durationToJson(timeLimit),
        AssessmentEnum.passScore.name: passScore,
      };

  @override
  int get hashCode => Object.hashAll(<Object?>[
        id,
        title,
        Utils.listHash(items),
        shuffleItems,
        shuffleOptions,
        timeLimit,
        passScore,
      ]);

  @override
  bool operator ==(Object other) =>
      other is ModelAssessment &&
      other.id == id &&
      other.title == title &&
      Utils.listEquals(other.items, items) &&
      other.shuffleItems == shuffleItems &&
      other.shuffleOptions == shuffleOptions &&
      other.timeLimit == timeLimit &&
      other.passScore == passScore;

  /// JSON string representation (useful for logs & diffs).
  @override
  String toString() => jsonEncode(toJson());
}

int _clampPassScore(int v) => v < 0 ? 0 : (v > 100 ? 100 : v);
