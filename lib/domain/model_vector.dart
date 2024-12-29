part of '../jocaagura_domain.dart';

/// Enum for [ModelVector] fields, representing the X and Y components of the vector.
enum ModelVectorEnum {
  dx,
  dy,
}

/// Default instance of [ModelVector] with both components set to 1.0.
const ModelVector defaultModelVector = ModelVector(1.0, 1.0);

/// A model representing a 2D vector, encapsulating its X (`dx`) and Y (`dy`) components.
///
/// This class is useful for mathematical and graphical operations that require vector manipulation.
///
/// Example of using [ModelVector] in a practical application:
///
/// ```dart
/// void main() {
///   const ModelVector vector = ModelVector(3.0, 4.0);
///   print('Vector: ${vector.toString()}');
///   print('Offset: ${vector.offset}');
///   print('Is Correct Vector: ${vector.isCorrectVector}');
/// }
/// ```
///
/// The [ModelVector] class provides utility methods for JSON serialization, deserialization,
/// and conversion to [Offset], enabling seamless integration with graphical operations.
class ModelVector extends Model {
  /// Constructs a new [ModelVector] with the given X ([dx]) and Y ([dy]) components.
  const ModelVector(this.dx, this.dy);

  /// Creates a [ModelVector] from an [Offset].
  ///
  /// This is useful for converting graphical coordinates into a [ModelVector].
  factory ModelVector.fromOffset(Offset offset) {
    return ModelVector(offset.dx, offset.dy);
  }

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

  /// Returns a copy of this [ModelVector] with optional new values for its components.
  @override
  ModelVector copyWith({
    double? dx,
    double? dy,
  }) {
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
  ///
  /// This is useful for integration with graphical operations in Flutter.
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
