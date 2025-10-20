part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// JSON keys for [ModelCompetencyStandard]. Kept as enum to guarantee roundtrip
/// stability (avoid string typos and allow `.name` usage).
enum CompetencyStandardEnum {
  id,
  label,
  area,
  cineLevel,
  code,
}

/// A default instance for tests or placeholders.
///
/// Uses neutral text values and a generic [ModelCategory].
/// Not intended for production data.
const ModelCompetencyStandard defaultCompetencyStandard =
    ModelCompetencyStandard(
  id: 'STD-DEFAULT',
  label: 'Undefined competency standard',
  area: ModelCategory(category: 'general', description: 'General'),
  cineLevel: 0,
  code: 'GEN.DEFAULT',
);

/// Represents a top-level competency standard (MEN reference).
///
/// Immutable value object with stable JSON roundtrip using
/// [CompetencyStandardEnum] `.name` keys. Parsing is tolerant via `Utils.*`.
///
/// Contracts:
/// - [cineLevel] MUST be >= 0. This is enforced with an `assert` in debug
///   builds; production builds must provide valid data.
/// - [area] MUST be a JSON object compatible with [ModelCategory.fromJson].
/// - Equality compares all fields by value.
///
/// Defaults & parsing notes:
/// - Missing or invalid fields are parsed with neutral defaults by `Utils.*`
///   (e.g., empty string for text, `0` for numeric).
/// - Using enum `.name` as JSON keys requires **stable case names**; renaming
///   enum cases breaks persisted data.
///
/// Minimal runnable example:
/// ```dart
/// void main() {
///   final ModelCompetencyStandard std = ModelCompetencyStandard(
///     id: 'STD-MATH-ALG-001',
///     label: 'Understands linear functions',
///     area: ModelCategory(category: 'math', description: 'Mathematics'),
///     cineLevel: 2,
///     code: 'MATH.ALG.001',
///   );
///
///   final Map<String, dynamic> json = std.toJson();
///   final ModelCompetencyStandard copy = ModelCompetencyStandard.fromJson(json);
///   assert(std == copy); // roundtrip
/// }
/// ```
///
/// Debug-only:
/// - Throws [AssertionError] if [cineLevel] is negative.
class ModelCompetencyStandard extends Model {
  const ModelCompetencyStandard({
    required this.id,
    required this.label,
    required this.area,
    required this.cineLevel,
    required this.code,
  }) : assert(cineLevel >= 0, 'cineLevel must be >= 0');

  /// Builds a [ModelCompetencyStandard] from a JSON-like [Map].
  ///
  /// Missing fields fall back to neutral defaults (e.g., `''`, `0`, `true`).
  /// `area` must be a JSON object compatible with [ModelCategory.fromJson].
  factory ModelCompetencyStandard.fromJson(Map<String, dynamic> json) {
    return ModelCompetencyStandard(
      id: Utils.getStringFromDynamic(json[CompetencyStandardEnum.id.name]),
      label:
          Utils.getStringFromDynamic(json[CompetencyStandardEnum.label.name]),
      area: json[CompetencyStandardEnum.area.name] == null
          ? defaultCompetencyStandard.area
          : ModelCategory.fromJson(
              Utils.mapFromDynamic(json[CompetencyStandardEnum.area.name]),
            ),
      cineLevel: Utils.getIntegerFromDynamic(
        json[CompetencyStandardEnum.cineLevel.name],
      ),
      code: Utils.getStringFromDynamic(json[CompetencyStandardEnum.code.name]),
    );
  }

  final String id;
  final String label;
  final ModelCategory area;
  final int cineLevel;
  final String code;

  /// Returns a new instance replacing provided fields.
  @override
  ModelCompetencyStandard copyWith({
    String? id,
    String? label,
    ModelCategory? area,
    int? cineLevel,
    String? code,
  }) {
    return ModelCompetencyStandard(
      id: id ?? this.id,
      label: label ?? this.label,
      area: area ?? this.area,
      cineLevel: cineLevel ?? this.cineLevel,
      code: code ?? this.code,
    );
  }

  /// Serializes to JSON using [CompetencyStandardEnum] keys.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        CompetencyStandardEnum.id.name: id,
        CompetencyStandardEnum.label.name: label,
        CompetencyStandardEnum.area.name: area.toJson(),
        CompetencyStandardEnum.cineLevel.name: cineLevel,
        CompetencyStandardEnum.code.name: code,
      };

  @override
  int get hashCode => Object.hash(
        id,
        label,
        area,
        cineLevel,
        code,
      );

  @override
  bool operator ==(Object other) =>
      other is ModelCompetencyStandard &&
      other.id == id &&
      other.label == label &&
      other.area == area &&
      other.cineLevel == cineLevel &&
      other.code == code;

  /// JSON string representation (useful for logs & diffs).
  @override
  String toString() => jsonEncode(toJson());
}
