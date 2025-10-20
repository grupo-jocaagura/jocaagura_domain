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

/// Represents an immutable assessment composed of multiple [ModelLearningItem]s.
///
/// Uses [AssessmentEnum] `.name` keys for **stable JSON roundtrip**.
/// Parsing is tolerant via `Utils.*`.
///
/// Contracts:
/// - `items` are stored as an **unmodifiable** list.
/// - `timeLimitMs` is serialized as **milliseconds**; internally exposed as [Duration].
/// - `passScore` is **clamped to 0..100** on construction and JSON parsing.
/// - **Equality is order-sensitive** for [items].
///
/// Defaults & notes:
/// - Constructor default `timeLimit` is [defaultTimeLimit] (60 minutes).
/// - `fromJson` default `timeLimit` is also [defaultTimeLimit] when `timeLimitMs` is
///   missing or invalid (aligned with constructor).
/// - Enum `.name` keys require stable case names; renaming enum cases breaks persisted data.
///
/// Minimal runnable example:
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
    Duration timeLimit = defaultTimeLimit,
  })  : items = List<ModelLearningItem>.unmodifiable(items),
        passScore = _clampPassScore(passScore),
        _timeLimit = timeLimit;

  /// Builds a [ModelAssessment] from JSON-like input.
  ///
  /// Defaults:
  /// - `shuffleItems`: `true` if missing/invalid.
  /// - `shuffleOptions`: `true` if missing/invalid.
  /// - `timeLimitMs`: `Duration.zero` if missing/invalid.
  /// - `passScore`: `0` if missing/invalid (then clamped 0..100).
  factory ModelAssessment.fromJson(Map<String, dynamic> json) {
    final List<ModelLearningItem> parsedItems =
        Utils.listFromDynamic(json[AssessmentEnum.items.name])
            .map<ModelLearningItem>(ModelLearningItem.fromJson)
            .toList();

    final bool parsedShuffleItems = Utils.getBoolFromDynamic(
      json[AssessmentEnum.shuffleItems.name],
      defaultValueIfNull: true,
    );

    final bool parsedShuffleOptions = Utils.getBoolFromDynamic(
      json[AssessmentEnum.shuffleOptions.name],
      defaultValueIfNull: true,
    );

    final Duration parsedTimeLimit = Utils.durationFromJson(
      json[AssessmentEnum.timeLimitMs.name],
      defaultDuration: defaultTimeLimit,
    );

    final int parsedPassScore = _clampPassScore(
      Utils.getIntegerFromDynamic(json[AssessmentEnum.passScore.name]),
    );

    return ModelAssessment(
      id: Utils.getStringFromDynamic(json[AssessmentEnum.id.name]),
      title: Utils.getStringFromDynamic(json[AssessmentEnum.title.name]),
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
  Duration get timeLimit => _timeLimit;
  final Duration _timeLimit;

  static const Duration defaultTimeLimit = Duration(minutes: 60);

  /// Passing score in int from (0..100).
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
