part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// JSON keys for [CompetencyStandard]. Kept as enum to guarantee roundtrip
/// stability (avoid string typos and allow `.name` usage).
enum CompetencyStandardEnum {
  id,
  label,
  area,
  cineLevel,
  code,
  version,
  isActive,
  createdAtMs,
  updatedAtMs,
  authorId,
}

/// A default instance of [CompetencyStandard] for tests or fallback scenarios.
///
/// This placeholder uses neutral values and a generic `ModelCategory`.
/// Timestamps are set to `0` to avoid non-const expressions in a `const` context.
/// Not intended for production data.
const CompetencyStandard defaultCompetencyStandard = CompetencyStandard(
  id: 'STD-DEFAULT',
  label: 'Undefined competency standard',
  area: ModelCategory(category: 'general', description: 'General'),
  cineLevel: 0,
  // CINE difficulty floor
  code: 'GEN.DEFAULT',
  // generic code
  isActive: true,
  createdAtMs: 0,
  updatedAtMs: 0,
  authorId: 'system',
);

/// Top-level competency standard (MEN reference).
///
/// Represents what students should know/do, with CINE difficulty,
/// area/category, versioning and lifecycle metadata.
///
/// The model is immutable and JSON roundtrip friendly (via enum keys).
///
/// ### Minimal runnable example
/// ```dart
/// void main() {
///   final CompetencyStandard std = CompetencyStandard(
///     id: 'STD-MATH-ALG-001',
///     label: 'Understands linear functions',
///     area: ModelCategory(category: 'math', description: 'Mathematics'),
///     cineLevel: 2,
///     code: 'MATH.ALG.001',
///     version: 1,
///     isActive: true,
///     createdAtMs: nowMs(),
///     updatedAtMs: nowMs(),
///     authorId: 'teacher:ana',
///   );
///
///   final Map<String, dynamic> json = std.toJson();
///   final CompetencyStandard copy = CompetencyStandard.fromJson(json);
///   assert(std == copy); // roundtrip
/// }
/// ```
class CompetencyStandard extends Model {
  const CompetencyStandard({
    required this.id,
    required this.label,
    required this.area,
    required this.cineLevel,
    required this.code,
    required this.isActive,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.authorId,
    this.version = 1,
  })  : assert(version > 0, 'version must be > 0'),
        assert(cineLevel >= 0, 'cineLevel must be >= 0');

  /// Builds a [CompetencyStandard] from a JSON-like [Map].
  ///
  /// Missing fields fall back to neutral defaults (e.g., `''`, `0`, `true`).
  /// `area` must be a JSON object compatible with [ModelCategory.fromJson].
  factory CompetencyStandard.fromJson(Map<String, dynamic> json) {
    return CompetencyStandard(
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
      version: Utils.getIntegerFromDynamic(
        json[CompetencyStandardEnum.version.name],
        defaultValue: 1,
      ),
      isActive:
          Utils.getBoolFromDynamic(json[CompetencyStandardEnum.isActive.name]),
      createdAtMs: Utils.getIntegerFromDynamic(
        json[CompetencyStandardEnum.createdAtMs.name],
      ),
      updatedAtMs: Utils.getIntegerFromDynamic(
        json[CompetencyStandardEnum.updatedAtMs.name],
      ),
      authorId: Utils.getStringFromDynamic(
        json[CompetencyStandardEnum.authorId.name],
      ),
    );
  }

  final String id;
  final String label;
  final ModelCategory area;
  final int cineLevel;
  final String code;
  final int version;
  final bool isActive;
  final int createdAtMs;
  final int updatedAtMs;
  final String authorId;

  /// Returns a new instance replacing provided fields.
  @override
  CompetencyStandard copyWith({
    String? id,
    String? label,
    ModelCategory? area,
    int? cineLevel,
    String? code,
    int? version,
    bool? isActive,
    int? createdAtMs,
    int? updatedAtMs,
    String? authorId,
  }) {
    return CompetencyStandard(
      id: id ?? this.id,
      label: label ?? this.label,
      area: area ?? this.area,
      cineLevel: cineLevel ?? this.cineLevel,
      code: code ?? this.code,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      authorId: authorId ?? this.authorId,
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
        CompetencyStandardEnum.version.name: version,
        CompetencyStandardEnum.isActive.name: isActive,
        CompetencyStandardEnum.createdAtMs.name: createdAtMs,
        CompetencyStandardEnum.updatedAtMs.name: updatedAtMs,
        CompetencyStandardEnum.authorId.name: authorId,
      };

  @override
  int get hashCode => Object.hash(
        id,
        label,
        area,
        cineLevel,
        code,
        version,
        isActive,
        createdAtMs,
        updatedAtMs,
        authorId,
      );

  @override
  bool operator ==(Object other) =>
      other is CompetencyStandard &&
      other.id == id &&
      other.label == label &&
      other.area == area &&
      other.cineLevel == cineLevel &&
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
