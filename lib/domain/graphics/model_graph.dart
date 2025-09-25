part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Graph model holding axis specs and a **read-only** list of points.
///
/// The internal `points` list is wrapped in `List.unmodifiable` to prevent
/// external mutation. Avoid `const` here per project guideline.
///
/// ### Example (from tabular data)
/// ```dart
/// final List<Map<String, Object>> rows = <Map<String, Object>>[
///   {'label': 'Enero',  'value': 60000},
///   {'label': 'Febrero','value': 55000},
///   {'label': 'Marzo',  'value': 65000},
/// ];
///
/// final ModelGraph graph = ModelGraph.fromTable(
///   rows,
///   xLabelKey: 'label',
///   yValueKey: 'value',
///   title: 'Precio Pizza',
///   xTitle: 'Mes (índice)',
///   yTitle: 'Valor',
/// );
/// // graph.points[i].vector.dx -> x = 1..n
/// // graph.points[i].vector.dy -> y = precio
/// ```
class ModelGraph extends Model {
  ModelGraph({
    required this.xAxis,
    required this.yAxis,
    required List<ModelPoint> points,
    this.title,
    this.subtitle,
    this.description,
  }) : points = List<ModelPoint>.unmodifiable(points);

  factory ModelGraph.fromJson(Map<String, dynamic> json) => ModelGraph(
        xAxis: GraphAxisSpec.fromJson(
          Utils.mapFromDynamic(json[ModelGraphEnum.xAxis.name]),
        ),
        yAxis: GraphAxisSpec.fromJson(
          Utils.mapFromDynamic(json[ModelGraphEnum.yAxis.name]),
        ),
        points: Utils.listFromDynamic(json[ModelGraphEnum.points.name])
            .map(ModelPoint.fromJson)
            .toList(),
        title: json[ModelGraphEnum.title.name] as String?,
        subtitle: json[ModelGraphEnum.subtitle.name] as String?,
        description: json[ModelGraphEnum.description.name] as String?,
      );

  final GraphAxisSpec xAxis;
  final GraphAxisSpec yAxis;

  /// Ordered points to plot. Internally **unmodifiable**.
  final List<ModelPoint> points;

  final String? title;
  final String? subtitle;
  final String? description;

  /// Build a graph from a table-like source.
  ///
  /// - `xLabelKey`: column for the label.
  /// - `yValueKey`: column for the numeric Y.
  /// - `xFrom`: optional mapping to produce custom X values (defaults to 1-based index).
  /// - axis ranges auto-computed from data unless overridden by `xMin/xMax/yMin/yMax`.
  static ModelGraph fromTable(
    List<Map<String, Object?>> rows, {
    required String xLabelKey,
    required String yValueKey,
    String? title,
    String? subtitle,
    String? description,
    String xTitle = 'X',
    String yTitle = 'Y',
    double Function(int index, Map<String, Object?> row)? xFrom,
    double? xMin,
    double? xMax,
    double? yMin,
    double? yMax,
  }) {
    final List<ModelPoint> pts = <ModelPoint>[];
    for (int i = 0; i < rows.length; i++) {
      final Map<String, Object?> r = rows[i];
      final String label = (r[xLabelKey] ?? '').toString();
      final num yNum = (r[yValueKey] as num?) ?? 0;
      final double x = xFrom != null ? xFrom(i, r) : (i + 1).toDouble();
      final double y = yNum.toDouble();
      pts.add(ModelPoint(label: label, vector: ModelVector(x, y)));
    }

    final double minX =
        pts.isEmpty ? 0 : pts.map((ModelPoint p) => p.vector.dx).reduce(min);
    final double maxX =
        pts.isEmpty ? 0 : pts.map((ModelPoint p) => p.vector.dx).reduce(max);
    final double minY =
        pts.isEmpty ? 0 : pts.map((ModelPoint p) => p.vector.dy).reduce(min);
    final double maxY =
        pts.isEmpty ? 0 : pts.map((ModelPoint p) => p.vector.dy).reduce(max);

    return ModelGraph(
      xAxis: GraphAxisSpec(title: xTitle, min: xMin ?? minX, max: xMax ?? maxX),
      yAxis: GraphAxisSpec(title: yTitle, min: yMin ?? minY, max: yMax ?? maxY),
      points: pts,
      title: title,
      subtitle: subtitle,
      description: description,
    );
  }

  @override
  ModelGraph copyWith({
    GraphAxisSpec? xAxis,
    GraphAxisSpec? yAxis,
    List<ModelPoint>? points,
    String? title,
    String? subtitle,
    String? description,
  }) {
    return ModelGraph(
      xAxis: xAxis ?? this.xAxis,
      yAxis: yAxis ?? this.yAxis,
      points: points ?? this.points,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ModelGraphEnum.xAxis.name: xAxis.toJson(),
        ModelGraphEnum.yAxis.name: yAxis.toJson(),
        ModelGraphEnum.points.name:
            points.map((ModelPoint point) => point.toJson()).toList(),
        ModelGraphEnum.title.name: title,
        ModelGraphEnum.subtitle.name: subtitle,
        ModelGraphEnum.description.name: description,
      };

  @override
  int get hashCode => Object.hash(
        xAxis,
        yAxis,
        Utils.listHash(points),
        title,
        subtitle,
        description,
      );

  @override
  bool operator ==(Object other) =>
      other is ModelGraph &&
      other.xAxis == xAxis &&
      other.yAxis == yAxis &&
      Utils.listEquals(other.points, points) &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.description == description;
}
