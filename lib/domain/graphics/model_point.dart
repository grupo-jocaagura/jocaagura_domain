part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enum for [ModelPoint] JSON fields.
enum ModelPointEnum {
  /// Human-readable label for the point (e.g., "January").
  label,

  /// 2D coordinates stored as a [ModelVector] JSON object.
  vector,
}

/// Default point for demos/tests: label "A" at (1, 1).
const ModelPoint defaultModelPoint = ModelPoint(
  label: 'A',
  vector: ModelVector(1.0, 1.0),
);

/// Small immutable set of default points for quick samples.
const List<ModelPoint> defaultModelPoints = <ModelPoint>[
  ModelPoint(label: 'A', vector: ModelVector(1.0, 10.0)),
  ModelPoint(label: 'B', vector: ModelVector(2.0, 15.0)),
  ModelPoint(label: 'C', vector: ModelVector(3.0, 12.0)),
];

/// Represents a labeled point in 2D space.
///
/// Holds a human-readable [label] and a [vector] with the X/Y coordinates
/// expressed as a [ModelVector]. This model is immutable and supports JSON
/// (de)serialization and value-based equality.
///
/// **Contracts**
/// - `fromJson` is lenient and *does not* throw: it stringifies `label`
///   and coerces `vector` via `Utils.mapFromDynamic(...)`.
/// - If the JSON does not contain a valid `vector`, the resulting
///   `ModelVector` may contain `NaN` components depending on `Utils.getDouble`
///   behavior. Callers should validate with `vector.isValidVector` if needed.
/// - `label` may be empty if the source value is `null`.
///
/// **Example**
/// ```dart
/// void main() {
///   // Construction
///   const ModelVector v = ModelVector(1.0, 60000.0);
///   const ModelPoint p = ModelPoint(label: 'January', vector: v);
///   print(p.toJson()); // { "label": "January", "vector": { "dx": 1.0, "dy": 60000.0 } }
///
///   // JSON round-trip
///   final Map<String, dynamic> json = <String, dynamic>{
///     "label": "Feb",
///    "vector": <String, dynamic>{"dx": 2, "dy": 45000}
///   };
///   final ModelPoint q = ModelPoint.fromJson(json);
///   final bool ok = q.vector.isValidVector; // true
///   print(ok);
/// }
/// ```
class ModelPoint extends Model {
  /// Creates a new labeled point with the given [label] and 2D [vector].
  const ModelPoint({required this.label, required this.vector});

  /// Builds a [ModelPoint] from a JSON map.
  ///
  /// The map is expected to contain:
  /// - `"label"`: a value convertible to `String`.
  /// - `"vector"`: a JSON object for [ModelVector.fromJson].
  ///
  /// It never throws; invalid shapes produce empty label `''` and/or a vector
  /// that may contain non-finite values (see [ModelVector.isValidVector]).
  factory ModelPoint.fromJson(Map<String, dynamic> json) => ModelPoint(
        label: Utils.getStringFromDynamic(json[ModelPointEnum.label.name]),
        vector: ModelVector.fromJson(
          Utils.mapFromDynamic(json[ModelPointEnum.vector.name]),
        ),
      );

  /// Human-readable point label (e.g., "January").
  final String label;

  /// 2D coordinates for this point.
  final ModelVector vector;

  /// Returns a copy with optional overrides.
  @override
  ModelPoint copyWith({String? label, ModelVector? vector}) =>
      ModelPoint(label: label ?? this.label, vector: vector ?? this.vector);

  /// Serializes this model to a JSON map.
  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelPointEnum.label.name: label,
        ModelPointEnum.vector.name: vector.toJson(),
      };

  /// Value-based equality: both [label] and [vector] must match.
  @override
  int get hashCode => Object.hash(label, vector);

  @override
  bool operator ==(Object other) =>
      other is ModelPoint && other.label == label && other.vector == vector;
}
