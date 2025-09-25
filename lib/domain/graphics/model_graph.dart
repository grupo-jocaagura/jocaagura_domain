part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Fields for [ModelGraph].
enum ModelGraphEnum { xAxis, yAxis, points, title, subtitle, description }

/// Graph model holding axis specs and a read-only list of points.
///
/// The constructor wraps the incoming [points] with `List.unmodifiable`.
/// Titles and descriptions are **non-null Strings** (default to `''`) and are
/// stringified leniently on JSON parsing.
///
/// **Contracts**
/// - `fromJson` is lenient:
///   - `xAxis`/`yAxis` come from `GraphAxisSpec.fromJson(Utils.mapFromDynamic(...))`.
///   - `points` uses `Utils.listFromDynamic(...).map(ModelPoint.fromJson)`.
///   - `title`/`subtitle`/`description` are always non-null `String`s:
///     any dynamic value is stringified; missing/invalid yields `''`.
/// - Axis invariants (`min <= max`) and finiteness are **not** enforced here.
///   Validate at upper layers if required.
/// Default graph built from [defaultModelPoints] and default axis ranges.
///
/// Example:
/// ```dart
/// void main() {
///   final ModelGraph g = defaultModelGraph();
///   print(g.points.length); // 3
/// }
/// ```
ModelGraph defaultModelGraph({
  String title = 'Default Graph',
  String subtitle = 'Sample points A..C',
  String description = 'Demo dataset with 3 points',
}) {
  const List<ModelPoint> pts = defaultModelPoints;
  final double minX = pts.map((ModelPoint p) => p.vector.dx).reduce(min);
  final double maxX = pts.map((ModelPoint p) => p.vector.dx).reduce(max);
  final double minY = pts.map((ModelPoint p) => p.vector.dy).reduce(min);
  final double maxY = pts.map((ModelPoint p) => p.vector.dy).reduce(max);

  return ModelGraph(
    xAxis: ModelGraphAxisSpec(title: 'X', min: minX, max: maxX),
    yAxis: ModelGraphAxisSpec(title: 'Y', min: minY, max: maxY),
    points: pts,
    title: title,
    subtitle: subtitle,
    description: description,
  );
}

/// Demo graph of pizza prices for 2024 (LATAM — Región Andina).
///
/// Builds a [ModelGraph] from a tabular dataset (month/price) using
/// [ModelGraph.fromTable]. Labels are Spanish month names; values in COP.
///
/// Example:
/// ```dart
/// void main() {
///   final ModelGraph g = demoPizzaPrices2024Graph();
///   print(g.title); // "Precio Pizza — LATAM — Región Andina"
///   print(g.points.first.label); // "Enero"
/// }
/// ```
ModelGraph demoPizzaPrices2024Graph({
  String region = 'LATAM — Región Andina',
}) {
  final List<Map<String, Object?>> rows = <Map<String, Object?>>[
    <String, Object?>{'label': 'Enero', 'value': 60000},
    <String, Object?>{'label': 'Febrero', 'value': 59000},
    <String, Object?>{'label': 'Marzo', 'value': 61000},
    <String, Object?>{'label': 'Abril', 'value': 60500},
    <String, Object?>{'label': 'Mayo', 'value': 62000},
    <String, Object?>{'label': 'Junio', 'value': 61500},
    <String, Object?>{'label': 'Julio', 'value': 63000},
    <String, Object?>{'label': 'Agosto', 'value': 62500},
    <String, Object?>{'label': 'Septiembre', 'value': 64000},
    <String, Object?>{'label': 'Octubre', 'value': 65000},
    <String, Object?>{'label': 'Noviembre', 'value': 64500},
    <String, Object?>{'label': 'Diciembre', 'value': 66000},
  ];

  return ModelGraph.fromTable(
    rows,
    xLabelKey: 'label',
    yValueKey: 'value',
    title: 'Precio Pizza — $region',
    subtitle: 'Serie mensual 2024',
    description: 'Valores representativos (COP) por mes • fuente: demo',
    xTitle: 'Mes (índice)',
    yTitle: 'Precio (COP)',
  );
}

///
/// **Example (from tabular data)**
/// ```dart
/// void main() {
///   final List<Map<String, Object>> rows = <Map<String, Object>>[
///     {'label': 'Enero',  'value': 60000},
///     {'label': 'Febrero','value': 55000},
///     {'label': 'Marzo',  'value': 65000},
///   ];
///
///   final ModelGraph graph = ModelGraph.fromTable(
///     rows,
///     xLabelKey: 'label',
///     yValueKey: 'value',
///     title: 'Precio Pizza',
///     xTitle: 'Mes (índice)',
///     yTitle: 'Valor',
///   );
///   print(graph.points.length); // 3
/// }
/// ```
class ModelGraph extends Model {
  ModelGraph({
    required this.xAxis,
    required this.yAxis,
    required List<ModelPoint> points,
    this.title = '',
    this.subtitle = '',
    this.description = '',
  }) : points = List<ModelPoint>.unmodifiable(points);

  /// Builds a [ModelGraph] from a JSON map (lenient).
  ///
  /// Notes:
  /// - Non-string values for titles are stringified; empty string becomes `null`.
  factory ModelGraph.fromJson(Map<String, dynamic> json) => ModelGraph(
        xAxis: ModelGraphAxisSpec.fromJson(
          Utils.mapFromDynamic(json[ModelGraphEnum.xAxis.name]),
        ),
        yAxis: ModelGraphAxisSpec.fromJson(
          Utils.mapFromDynamic(json[ModelGraphEnum.yAxis.name]),
        ),
        points: Utils.listFromDynamic(json[ModelGraphEnum.points.name])
            .map(ModelPoint.fromJson)
            .toList(),
        title: Utils.getStringFromDynamic(json[ModelGraphEnum.title.name]),
        subtitle:
            Utils.getStringFromDynamic(json[ModelGraphEnum.subtitle.name]),
        description:
            Utils.getStringFromDynamic(json[ModelGraphEnum.description.name]),
      );

  /// Human-readable metadata for the X axis.
  final ModelGraphAxisSpec xAxis;

  /// Human-readable metadata for the Y axis.
  final ModelGraphAxisSpec yAxis;

  /// Ordered points to plot. Internally **unmodifiable**.
  final List<ModelPoint> points;

  /// Optional graph title.
  final String title;

  /// Optional graph subtitle.
  final String subtitle;

  /// Optional graph description.
  final String description;

  /// Build a graph from a table-like source.
  ///
  /// - `xLabelKey`: column for the label.
  /// - `yValueKey`: column for the numeric Y.
  /// - `xFrom`: optional mapping to produce custom X values (defaults to 1-based index).
  /// - Axis ranges are auto-computed from data unless overridden by `xMin/xMax/yMin/yMax`.
  static ModelGraph fromTable(
    List<Map<String, Object?>> rows, {
    required String xLabelKey,
    required String yValueKey,
    String title = '',
    String subtitle = '',
    String description = '',
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
      xAxis: ModelGraphAxisSpec(
        title: xTitle,
        min: xMin ?? minX,
        max: xMax ?? maxX,
      ),
      yAxis: ModelGraphAxisSpec(
        title: yTitle,
        min: yMin ?? minY,
        max: yMax ?? maxY,
      ),
      points: pts,
      title: title,
      subtitle: subtitle,
      description: description,
    );
  }

  /// Returns a copy with optional overrides. The [points] argument will be
  /// wrapped as unmodifiable by the constructor.
  @override
  ModelGraph copyWith({
    ModelGraphAxisSpec? xAxis,
    ModelGraphAxisSpec? yAxis,
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

  /// Serializes this model to JSON.
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

  /// Value-based equality including ordered [points].
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
