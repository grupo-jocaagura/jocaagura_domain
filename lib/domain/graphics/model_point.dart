part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// A labeled point in 2D space using [ModelVector] for coordinates.
///
/// - `label`: human-readable name (e.g., "Enero").
/// - `vector`: coordinates (x, y) using your existing [ModelVector].
///
/// ### Example
/// ```dart
/// final ModelPoint p = ModelPoint(label: 'Enero', vector: ModelVector(1, 60000));
/// ```
class ModelPoint extends Model {
  const ModelPoint({required this.label, required this.vector});

  factory ModelPoint.fromJson(Map<String, dynamic> json) => ModelPoint(
        label: Utils.getStringFromDynamic(json[ModelPointEnum.label.name]),
        vector: ModelVector.fromJson(
          Utils.mapFromDynamic(json[ModelPointEnum.vector.name]),
        ),
      );
  final String label;
  final ModelVector vector;

  @override
  ModelPoint copyWith({String? label, ModelVector? vector}) =>
      ModelPoint(label: label ?? this.label, vector: vector ?? this.vector);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelPointEnum.label.name: label,
        ModelPointEnum.vector.name: vector.toJson(),
      };

  @override
  int get hashCode => Object.hash(label, vector);

  @override
  bool operator ==(Object other) =>
      other is ModelPoint && other.label == label && other.vector == vector;
}
