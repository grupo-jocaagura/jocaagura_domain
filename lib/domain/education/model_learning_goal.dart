part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// JSON keys for [ModelLearningGoal]. Kept as enum to guarantee roundtrip
/// stability (avoid string typos and allow `.name` usage).
enum LearningGoalEnum {
  id,
  standard,
  label,
  code,
}

/// A default instance for tests or placeholders.
///
/// Uses [defaultCompetencyStandard] as nested standard.
/// Not intended for production data.
const ModelLearningGoal defaultLearningGoal = ModelLearningGoal(
  id: 'GOAL-DEFAULT',
  standard: defaultCompetencyStandard,
  label: 'Undefined learning goal',
  code: 'GEN.LEARN.DEFAULT',
);

/// Represents a learning goal that refines a [ModelCompetencyStandard].
///
/// Immutable value object with stable JSON roundtrip using
/// [LearningGoalEnum] `.name` keys. Parsing is tolerant via `Utils.*`.
///
/// Contracts:
/// - [standard] is required and parsed via [Utils.mapFromDynamic]; if missing
///   or invalid, it falls back to [defaultCompetencyStandard].
/// - Equality compares all fields by value.
/// - Using enum `.name` as JSON keys requires **stable case names**; renaming
///   enum cases breaks persisted data.
///
/// Minimal runnable example:
/// ```dart
/// void main() {
///   final ModelLearningGoal g = ModelLearningGoal(
///     id: 'GOAL-1',
///     standard: defaultCompetencyStandard,
///     label: 'Classify matter by composition',
///     code: 'SCI.MAT.G1',
///   );
///
///   final Map<String, dynamic> json = g.toJson();
///   final ModelLearningGoal copy = ModelLearningGoal.fromJson(json);
///   assert(g == copy); // roundtrip
/// }
/// ```
class ModelLearningGoal extends Model {
  const ModelLearningGoal({
    required this.id,
    required this.standard,
    required this.label,
    required this.code,
  });

  /// Builds a [ModelLearningGoal] from a JSON-like [Map].
  ///
  /// Missing fields fall back to neutral defaults (e.g., `''`, `0`, `true`).
  /// The nested `standard` is normalized via [Utils.mapFromDynamic].
  factory ModelLearningGoal.fromJson(Map<String, dynamic> json) {
    return ModelLearningGoal(
      id: Utils.getStringFromDynamic(json[LearningGoalEnum.id.name]),
      standard: json[LearningGoalEnum.standard.name] == null
          ? defaultCompetencyStandard
          : ModelCompetencyStandard.fromJson(
              Utils.mapFromDynamic(json[LearningGoalEnum.standard.name]),
            ),
      label: Utils.getStringFromDynamic(json[LearningGoalEnum.label.name]),
      code: Utils.getStringFromDynamic(json[LearningGoalEnum.code.name]),
    );
  }

  final String id;
  final ModelCompetencyStandard standard;
  final String label;
  final String code;

  /// Returns a new instance replacing provided fields.
  @override
  ModelLearningGoal copyWith({
    String? id,
    ModelCompetencyStandard? standard,
    String? label,
    String? code,
  }) {
    return ModelLearningGoal(
      id: id ?? this.id,
      standard: standard ?? this.standard,
      label: label ?? this.label,
      code: code ?? this.code,
    );
  }

  /// Serializes to JSON using [LearningGoalEnum] keys.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        LearningGoalEnum.id.name: id,
        LearningGoalEnum.standard.name: standard.toJson(),
        LearningGoalEnum.label.name: label,
        LearningGoalEnum.code.name: code,
      };

  @override
  int get hashCode => Object.hash(
        id,
        standard,
        label,
        code,
      );

  @override
  bool operator ==(Object other) =>
      other is ModelLearningGoal &&
      other.id == id &&
      other.standard == standard &&
      other.label == label &&
      other.code == code;

  /// JSON string representation (useful for logs & diffs).
  @override
  String toString() => jsonEncode(toJson());
}
