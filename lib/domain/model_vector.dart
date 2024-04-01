part of '../jocaagura_domain.dart';

enum ModelVectorEnum {
  dx,
  dy,
}

const ModelVector defaultModelVector = ModelVector(1.0, 1.0);

class ModelVector extends Model {
  const ModelVector(this.dx, this.dy);

  factory ModelVector.fromOffset(Offset offset) {
    return ModelVector(
      offset.dx,
      offset.dy,
    );
  }
  factory ModelVector.fromJson(Map<String, dynamic> json) {
    return ModelVector(
      Utils.getDouble(json[ModelVectorEnum.dx.name]),
      Utils.getDouble(json[ModelVectorEnum.dy.name]),
    );
  }
  final double dx;
  final double dy;

  @override
  ModelVector copyWith({
    double? dx,
    double? dy,
  }) {
    return ModelVector(dx ?? this.dx, dy ?? this.dy);
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ModelVectorEnum.dx.name: dx,
      ModelVectorEnum.dy.name: dy,
    };
  }

  Offset get offset => Offset(dx, dy);

  @override
  String toString() {
    return '($dx, $dy)';
  }

  bool get isCorrectVector => !dx.isNaN && !dy.isNaN;

  @override
  int get hashCode => dx.hashCode ^ dy.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(other, this) ||
        other is ModelVector && other.dx == dx && other.dy == dy;
  }
}
