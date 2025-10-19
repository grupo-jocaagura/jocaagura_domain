part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// JSON keys for [ModelLearningGoal]. Kept as enum to guarantee roundtrip
/// stability (avoid string typos and allow `.name` usage).
enum LearningGoalEnum {
  id,
  standard,
  label,
  code,
  version,
  isActive,
  createdAtMs,
  updatedAtMs,
  authorId,
}

/// Learning goal that refines a [ModelCompetencyStandard].
///
/// Immutable model; JSON roundtrip uses [LearningGoalEnum] keys.
///
/// ### Minimal runnable example
/// ```dart
/// void main() {
///   final ModelLearningGoal g = ModelLearningGoal(
///     id: 'GOAL-1',
///     standard: defaultCompetencyStandard,
///     label: 'Classify matter by composition',
///     code: 'SCI.MAT.G1',
///     version: 1,
///     isActive: true,
///     createdAtMs: nowMs(),
///     updatedAtMs: nowMs(),
///     authorId: 'teacher:ana',
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
    required this.version,
    required this.isActive,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.authorId,
  }) : assert(version > 0, 'version must be > 0');

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
      version: Utils.getIntegerFromDynamic(
        json[LearningGoalEnum.version.name],
        defaultValue: 1,
      ),
      isActive: Utils.getBoolFromDynamic(json[LearningGoalEnum.isActive.name]),
      createdAtMs:
          Utils.getIntegerFromDynamic(json[LearningGoalEnum.createdAtMs.name]),
      updatedAtMs:
          Utils.getIntegerFromDynamic(json[LearningGoalEnum.updatedAtMs.name]),
      authorId:
          Utils.getStringFromDynamic(json[LearningGoalEnum.authorId.name]),
    );
  }

  final String id;
  final ModelCompetencyStandard standard;
  final String label;
  final String code;
  final int version;
  final bool isActive;
  final int createdAtMs;
  final int updatedAtMs;
  final String authorId;

  /// Returns a new instance replacing provided fields.
  @override
  ModelLearningGoal copyWith({
    String? id,
    ModelCompetencyStandard? standard,
    String? label,
    String? code,
    int? version,
    bool? isActive,
    int? createdAtMs,
    int? updatedAtMs,
    String? authorId,
  }) {
    return ModelLearningGoal(
      id: id ?? this.id,
      standard: standard ?? this.standard,
      label: label ?? this.label,
      code: code ?? this.code,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      authorId: authorId ?? this.authorId,
    );
  }

  /// Serializes to JSON using [LearningGoalEnum] keys.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        LearningGoalEnum.id.name: id,
        LearningGoalEnum.standard.name: standard.toJson(),
        LearningGoalEnum.label.name: label,
        LearningGoalEnum.code.name: code,
        LearningGoalEnum.version.name: version,
        LearningGoalEnum.isActive.name: isActive,
        LearningGoalEnum.createdAtMs.name: createdAtMs,
        LearningGoalEnum.updatedAtMs.name: updatedAtMs,
        LearningGoalEnum.authorId.name: authorId,
      };

  @override
  int get hashCode => Object.hash(
        id,
        standard,
        label,
        code,
        version,
        isActive,
        createdAtMs,
        updatedAtMs,
        authorId,
      );

  @override
  bool operator ==(Object other) =>
      other is ModelLearningGoal &&
      other.id == id &&
      other.standard == standard &&
      other.label == label &&
      other.code == code &&
      other.version == version &&
      other.isActive == isActive &&
      other.createdAtMs == createdAtMs &&
      other.updatedAtMs == updatedAtMs &&
      other.authorId == authorId;

  /// JSON string representation (useful for logs & diffs).
  @override
  String toString() => jsonEncode(toJson());
}
