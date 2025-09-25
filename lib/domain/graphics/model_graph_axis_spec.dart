part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Fields for [ModelGraph].
enum ModelGraphEnum { xAxis, yAxis, points, title, subtitle, description }

/// Axis meta for simple 2D charts (min/max range + title).
///
/// ### Example
/// ```dart
/// final GraphAxisSpec x = GraphAxisSpec(title: 'Mes', min: 1, max: 6);
/// final GraphAxisSpec y = GraphAxisSpec(title: 'Precio', min: 55000, max: 65000);
/// ```
class GraphAxisSpec extends Model {
  const GraphAxisSpec({
    required this.title,
    required this.min,
    required this.max,
  });

  factory GraphAxisSpec.fromJson(Map<String, dynamic> json) => GraphAxisSpec(
        title: Utils.getStringFromDynamic(json[GraphAxisSpecEnum.title.name]),
        min: Utils.getDouble(json[GraphAxisSpecEnum.min.name]),
        max: Utils.getDouble(json[GraphAxisSpecEnum.max.name]),
      );
  final String title;
  final double min;
  final double max;

  @override
  GraphAxisSpec copyWith({String? title, double? min, double? max}) =>
      GraphAxisSpec(
        title: title ?? this.title,
        min: min ?? this.min,
        max: max ?? this.max,
      );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        GraphAxisSpecEnum.title.name: title,
        GraphAxisSpecEnum.min.name: min,
        GraphAxisSpecEnum.max.name: max,
      };

  @override
  int get hashCode => Object.hash(title, min, max);

  @override
  bool operator ==(Object other) =>
      other is GraphAxisSpec &&
      other.title == title &&
      other.min == min &&
      other.max == max;
}
