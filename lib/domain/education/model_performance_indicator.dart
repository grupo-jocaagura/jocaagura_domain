part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Performance level aligned with common MEN usage.
///
/// Typical levels in Colombia: **low**, **basic**, **high**, **superior**.
///
/// ### Example
/// ```dart
/// void main() {
///   final PerformanceLevel lvl = PerformanceLevel.basic;
///   print(lvl.name); // basic
/// }
/// ```
enum PerformanceLevel { low, basic, high, superior }

/// JSON keys for [ModelPerformanceIndicator]. Enum-backed for roundtrip stability.
enum PerformanceIndicatorEnum {
  id,
  goal,
  label,
  level,
  code,
}

/// Smallest performance indicator attached to a [ModelLearningGoal].
///
/// The relationship can be represented either as:
/// - `"goal"`: full nested object (preferred), or
/// - `"goalId"`: flat ID reference (kept for compatibility).
///
/// This model is immutable, enum-keyed (roundtrip-safe), and tolerant to input
/// shapes via `Utils.*`.
///
/// ### Minimal runnable example
/// ```dart
/// void main() {
///   const ModelLearningGoal goal = defaultLearningGoal;
///   final ModelPerformanceIndicator ind = ModelPerformanceIndicator(
///     id: 'IND-1',
///     modelLearningGoal: goal,
///     label: 'Recognizes H2O',
///     level: PerformanceLevel.basic,
///     code: 'SCI.WAT.IND.1',
///   );
///   final Map<String, dynamic> json = ind.toJson();
///   final ModelPerformanceIndicator copy = ModelPerformanceIndicator.fromJson(json);
///   assert(ind == copy); // roundtrip
/// }
/// ```
class ModelPerformanceIndicator extends Model {
  const ModelPerformanceIndicator({
    required this.id,
    required this.modelLearningGoal,
    required this.label,
    required this.level,
    required this.code,
  });

  /// Builds from JSON-like map (enum-keyed).
  ///
  /// - Accepts `"goal"` as `Map` or JSON string (normalized via [Utils.mapFromDynamic]).
  /// - If `"goal"` is missing/null, falls back to `goalId` and uses a minimal default goal.
  factory ModelPerformanceIndicator.fromJson(Map<String, dynamic> json) {
    final String id =
        Utils.getStringFromDynamic(json[PerformanceIndicatorEnum.id.name]);

    // Nested goal parsing (preferred). If absent, synthesize a minimal goal.
    ModelLearningGoal goal;
    final dynamic rawGoal = json[PerformanceIndicatorEnum.goal.name];
    if (rawGoal == null) {
      goal = defaultLearningGoal;
    } else {
      goal = ModelLearningGoal.fromJson(Utils.mapFromDynamic(rawGoal));
    }

    return ModelPerformanceIndicator(
      id: id,
      modelLearningGoal: goal,
      label:
          Utils.getStringFromDynamic(json[PerformanceIndicatorEnum.label.name]),
      level: _parsePerformanceLevel(json[PerformanceIndicatorEnum.level.name]),
      code:
          Utils.getStringFromDynamic(json[PerformanceIndicatorEnum.code.name]),
    );
  }

  /// Parses a list of indicators from dynamic input.
  ///
  /// - `String` JSON array → only object items are considered.
  /// - Non-string input → delegates to [Utils.listFromDynamic].
  /// Malformed items are skipped silently.
  static List<ModelPerformanceIndicator> listFromDynamic(dynamic input) {
    final List<Map<String, dynamic>> raw = (() {
      if (input is String) {
        try {
          final dynamic decoded = jsonDecode(input);
          if (decoded is Iterable) {
            final List<Map<String, dynamic>> tmp = <Map<String, dynamic>>[];
            for (final dynamic e in decoded) {
              if (e is Map<String, dynamic>) {
                tmp.add(e);
              }
            }
            return tmp;
          }
        } catch (_) {
          debugPrint('ModelPerformanceIndicator.listFromDynamic: invalid JSON');
        }
        return <Map<String, dynamic>>[];
      }
      return Utils.listFromDynamic(input);
    })();

    final List<ModelPerformanceIndicator> out = <ModelPerformanceIndicator>[];
    for (final Map<String, dynamic> m in raw) {
      try {
        out.add(ModelPerformanceIndicator.fromJson(m));
      } catch (_) {
        debugPrint('ModelPerformanceIndicator.listFromDynamic: skip item');
      }
    }
    return out;
  }

  final String id;

  /// Full nested learning goal (preferred for rich clients).
  final ModelLearningGoal modelLearningGoal;

  final String label;
  final PerformanceLevel level;
  final String code;

  /// Returns a new instance replacing provided fields.
  @override
  ModelPerformanceIndicator copyWith({
    String? id,
    ModelLearningGoal? modelLearningGoal,
    String? label,
    PerformanceLevel? level,
    String? code,
  }) {
    return ModelPerformanceIndicator(
      id: id ?? this.id,
      modelLearningGoal: modelLearningGoal ?? this.modelLearningGoal,
      label: label ?? this.label,
      level: level ?? this.level,
      code: code ?? this.code,
    );
  }

  /// Serializes using [PerformanceIndicatorEnum] keys.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      PerformanceIndicatorEnum.id.name: id,
      PerformanceIndicatorEnum.goal.name: modelLearningGoal.toJson(),
      PerformanceIndicatorEnum.label.name: label,
      PerformanceIndicatorEnum.level.name: level.name,
      PerformanceIndicatorEnum.code.name: code,
    };
  }

  @override
  int get hashCode => Object.hash(
        id,
        modelLearningGoal,
        label,
        level,
        code,
      );

  @override
  bool operator ==(Object other) =>
      other is ModelPerformanceIndicator &&
      other.id == id &&
      other.modelLearningGoal == modelLearningGoal &&
      other.label == label &&
      other.level == level &&
      other.code == code;

  /// JSON string representation (useful for logs & diffs).
  @override
  String toString() => jsonEncode(toJson());
}

/// Parses a [PerformanceLevel] from a dynamic value.
/// Falls back to [PerformanceLevel.basic] when unknown.
PerformanceLevel _parsePerformanceLevel(dynamic raw) {
  final String s = Utils.getStringFromDynamic(raw).trim().toLowerCase();
  for (final PerformanceLevel v in PerformanceLevel.values) {
    if (v.name == s) {
      return v;
    }
  }
  return PerformanceLevel.basic;
}
