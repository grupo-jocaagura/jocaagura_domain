part of '../jocaagura_domain.dart';

/// Enum for [ModelVector] fields, representing the X and Y components of the vector.
enum ModelVectorEnum { dx, dy }

/// Default instance of [ModelVector] with both components set to 1.0.
const ModelVector defaultModelVector = ModelVector(1.0, 1.0);

/// A model representing a 2D vector, encapsulating its X (`dx`) and Y (`dy`) components.
///
/// This class is useful for mathematical and graphical operations that require vector manipulation.
/// It provides JSON (de)serialization utilities and conversion to [Offset].
///
/// ### Example
/// ```dart
/// void main() {
///   const ModelVector vector = ModelVector(3.0, 4.0);
///   print('Vector: $vector');                 // (3.0, 4.0)
///   print('Offset: ${vector.offset}');        // Offset(3.0, 4.0)
///   print('Is correct: ${vector.isCorrectVector}'); // true
///
///   // Integer-oriented view (round policy: .5 away from zero):
///   const ModelVector v = ModelVector(10.4, -3.5);
///   print('x=${v.x}, y=${v.y}');              // x=10, y=-4
///   print('key=${v.key}');                    // "10,-4"
///
///   // Copy using integer overrides:
///   final ModelVector c = v.copyWithInts(y: 5);
///   print('copy: $c');                        // (10.0, 5.0)
/// }
/// ```
class ModelVector extends Model {
  /// Constructs a new [ModelVector] with the given X ([dx]) and Y ([dy]) components.
  const ModelVector(this.dx, this.dy);

  /// Creates a [ModelVector] from an [Offset].
  ///
  /// Useful for converting graphical coordinates into a [ModelVector].
  factory ModelVector.fromOffset(Offset offset) {
    return ModelVector(offset.dx, offset.dy);
  }

  /// Convenience factory to create a [ModelVector] from integer coordinates.
  ///
  /// Note: integers are stored as doubles (`dx=x.toDouble()`, `dy=y.toDouble()`).
  ///
  /// ### Example
  /// ```dart
  /// final ModelVector v = ModelVector.fromXY(3, -2); // dx=3.0, dy=-2.0
  /// ```
  factory ModelVector.fromXY(int x, int y) =>
      ModelVector(x.toDouble(), y.toDouble());

  /// Deserializes a JSON map into an instance of [ModelVector].
  ///
  /// The JSON map must contain numeric values for the keys `'dx'` and `'dy'`.
  factory ModelVector.fromJson(Map<String, dynamic> json) {
    return ModelVector(
      Utils.getDouble(json[ModelVectorEnum.dx.name]),
      Utils.getDouble(json[ModelVectorEnum.dy.name]),
    );
  }

  /// The X component of the vector.
  final double dx;

  /// The Y component of the vector.
  final double dy;

  // ---- Integer-oriented view (non-breaking additions) ----

  /// Rounded X component (nearest int).
  ///
  /// Dart's rounding policy for `.5` is **away from zero**:
  /// - `1.5.round() == 2`
  /// - `-1.5.round() == -2`
  int get x => dx.round();

  /// Rounded Y component (nearest int). See [x] for policy details.
  int get y => dy.round();

  /// Canonical key for map/set usage in pixel grids: `"x,y"`.
  ///
  /// This key reflects the integer-oriented view (`round()` policy). If the
  /// original doubles were not integers, `key` may not reconstruct the exact
  /// original `dx/dy` values.
  String get key => '$x,$y';

  /// Creates a copy using integer overrides; only provided axes are changed.
  ///
  /// The resulting doubles are assigned using `toDouble()` on the provided ints.
  ///
  /// ### Example
  /// ```dart
  /// const ModelVector v = ModelVector(7.2, 8.8);
  /// final ModelVector c1 = v.copyWithInts(x: -1); // (-1.0, 9.0)
  /// final ModelVector c2 = v.copyWithInts(y: 5);  // (7.0, 5.0)
  /// ```
  ModelVector copyWithInts({int? x, int? y}) =>
      ModelVector((x ?? this.x).toDouble(), (y ?? this.y).toDouble());

  // ---- Existing API (unchanged) ----

  /// Returns a copy of this [ModelVector] with optional new values for its components.
  @override
  ModelVector copyWith({double? dx, double? dy}) {
    return ModelVector(dx ?? this.dx, dy ?? this.dy);
  }

  /// Serializes this [ModelVector] into a JSON map.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ModelVectorEnum.dx.name: dx,
      ModelVectorEnum.dy.name: dy,
    };
  }

  /// Converts this [ModelVector] into an [Offset].
  Offset get offset => Offset(dx, dy);

  /// Checks if the vector components are valid numbers.
  bool get isCorrectVector => !dx.isNaN && !dy.isNaN;

  @override
  String toString() => '($dx, $dy)';

  @override
  int get hashCode => dx.hashCode ^ dy.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ModelVector && other.dx == dx && other.dy == dy;
  }
}
