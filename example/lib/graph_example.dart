import 'dart:async';
import 'dart:math' show Random, max, min;

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  runApp(const PizzaPricesApp());
}

/// Simple demo app that shows a table and a line chart of monthly pizza prices.
/// Data is modeled with ModelGraph and updated via BlocGeneral<ModelGraph>
/// every 5 seconds, appending future months up to +12 beyond December 2024.
class PizzaPricesApp extends StatelessWidget {
  const PizzaPricesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pizza Prices 2024 — Graph Demo',
      theme: ThemeData.light(),
      home: const PizzaPricesPage(regionName: 'LATAM — Región Andina'),
    );
  }
}

class PizzaPricesPage extends StatefulWidget {
  const PizzaPricesPage({required this.regionName, super.key});

  final String regionName;

  @override
  State<PizzaPricesPage> createState() => _PizzaPricesPageState();
}

class _PizzaPricesPageState extends State<PizzaPricesPage> {
  // Business state holder (domain Bloc).
  final BlocGeneral<ModelGraph> _bloc =
      BlocGeneral<ModelGraph>(demoPizzaPrices2024Graph());

  Timer? _timer;
  final Random _rng = Random(2024);

  // Track how many future months we have appended (max 12).
  int _futureMonthsAppended = 0;

  @override
  void initState() {
    super.initState();
    // Seed with 2024 data:
    final ModelGraph initial = _buildInitialGraph(widget.regionName);
    _bloc.value = initial;

    // Periodic updates: every 5 seconds add next month (up to +12 months).
    _timer = Timer.periodic(const Duration(seconds: 5), _onTick);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bloc.dispose(); // Assuming BlocGeneral exposes dispose()
    super.dispose();
  }

  void _onTick(Timer timer) {
    if (_futureMonthsAppended >= 12) {
      timer.cancel();
      return;
    }
    final ModelGraph current = _bloc.value;
    final ModelGraph next = _appendNextMonth(current, widget.regionName);
    _futureMonthsAppended += 1;
    _bloc.value = next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pizza Prices 2024 • ${widget.regionName}'),
      ),
      body: StreamBuilder<ModelGraph>(
        stream: _bloc.stream,
        initialData: _bloc.value,
        builder: (BuildContext context, AsyncSnapshot<ModelGraph> snap) {
          final ModelGraph? graph = snap.data;
          if (graph == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    _Header(graph: graph),
                    const SizedBox(height: 12),
                    Expanded(
                      flex: 2,
                      child: _GraphCard(graph: graph),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      flex: 3,
                      child: _TableCard(graph: graph),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ---------- Domain building helpers ----------

  /// Builds an initial ModelGraph for Jan..Dec 2024 with base prices.
  ModelGraph _buildInitialGraph(String region) {
    // Example base prices (COP) for 2024 months — you can adjust these numbers.
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

    // Build ModelGraph from table with auto ranges:
    final ModelGraph graph = ModelGraph.fromTable(
      rows,
      xLabelKey: 'label',
      yValueKey: 'value',
      title: 'Precio Pizza — $region',
      subtitle: 'Serie mensual 2024',
      description: 'Valores representativos (COP) por mes • fuente: demo',
      xTitle: 'Mes (índice)',
      yTitle: 'Precio (COP)',
    );

    return graph;
  }

  /// Returns a new ModelGraph with the next month appended and ranges updated.
  ModelGraph _appendNextMonth(ModelGraph current, String region) {
    final List<ModelPoint> pts = List<ModelPoint>.from(current.points);

    // Determine next month label and x index:
    final int nextIndex = pts.isEmpty ? 1 : (pts.last.vector.dx.round() + 1);
    final String label = _labelForIndex(nextIndex);

    // Create a new y based on last y plus a small random delta:
    final double lastY = pts.isEmpty ? 60000.0 : pts.last.vector.dy;
    // +/- up to 2000 COP with a slight upward trend
    final double delta = (_rng.nextDouble() * 4000.0) - 1000.0;
    final double nextY = (lastY + delta).clamp(50000.0, 90000.0);

    pts.add(
      ModelPoint(
        label: label,
        vector: ModelVector(nextIndex.toDouble(), nextY),
      ),
    );

    // Recompute ranges using data unless overridden:
    final double minX = pts.map((ModelPoint p) => p.vector.dx).reduce(min);
    final double maxX = pts.map((ModelPoint p) => p.vector.dx).reduce(max);
    final double minY = pts.map((ModelPoint p) => p.vector.dy).reduce(min);
    final double maxY = pts.map((ModelPoint p) => p.vector.dy).reduce(max);

    final ModelGraph next = ModelGraph(
      xAxis:
          ModelGraphAxisSpec(title: current.xAxis.title, min: minX, max: maxX),
      yAxis:
          ModelGraphAxisSpec(title: current.yAxis.title, min: minY, max: maxY),
      points: pts,
      title: current.title.isEmpty ? 'Precio Pizza — $region' : current.title,
      subtitle: 'Serie mensual 2024 (+ futuro simulado)',
      description: current.description,
    );
    return next;
  }

  /// Maps 1..N to month labels starting Jan 2024 and then rolling forward.
  String _labelForIndex(int index) {
    // 1..12 -> Enero..Diciembre, then 13.. -> Ene(2025), Feb(2025) ...
    final List<String> months = <String>[
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    if (index <= 12) {
      return months[index - 1];
    }
    // Future months
    final int zeroBased = (index - 1) % 12; // 0..11
    final int yearOffset = (index - 1) ~/ 12; // 1 for months > 12
    final int year = 2024 + yearOffset;
    final String short = <String>[
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ][zeroBased];
    return '$short ($year)';
  }
}

// ---------- UI widgets ----------

class _Header extends StatelessWidget {
  const _Header({required this.graph});

  final ModelGraph graph;

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          graph.title.isEmpty ? 'Pizza Prices' : graph.title,
          style: t.titleLarge,
        ),
        if (graph.subtitle.isNotEmpty)
          Text(graph.subtitle, style: t.bodyMedium),
        if (graph.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(graph.description, style: t.bodySmall),
          ),
      ],
    );
  }
}

class _GraphCard extends StatelessWidget {
  const _GraphCard({required this.graph});

  final ModelGraph graph;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: CustomPaint(
          painter: _SimpleLineChartPainter(graph: graph),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.graph});

  final ModelGraph graph;

  @override
  Widget build(BuildContext context) {
    final List<DataRow> rows = graph.points
        .map(
          (ModelPoint p) => DataRow(
            cells: <DataCell>[
              DataCell(Text(p.label)),
              DataCell(Text(p.vector.dy.toStringAsFixed(0))), // COP approx
            ],
          ),
        )
        .toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowHeight: 36,
            dataRowMinHeight: 36,
            dataRowMaxHeight: 40,
            columns: const <DataColumn>[
              DataColumn(label: Text('Mes')),
              DataColumn(label: Text('Precio (COP)')),
            ],
            rows: rows,
          ),
        ),
      ),
    );
  }
}

// ---------- Simple chart painter (no external deps) ----------

class _SimpleLineChartPainter extends CustomPainter {
  _SimpleLineChartPainter({required this.graph});

  final ModelGraph graph;

  @override
  void paint(Canvas canvas, Size size) {
    // Padding for axes and labels.
    const double padLeft = 48;
    const double padRight = 16;
    const double padTop = 16;
    const double padBottom = 32;

    final Rect plot = Rect.fromLTWH(
      padLeft,
      padTop,
      size.width - padLeft - padRight,
      size.height - padTop - padBottom,
    );

    final Paint axisPaint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 1.0;

    // Axes
    // X axis
    canvas.drawLine(
      Offset(plot.left, plot.bottom),
      Offset(plot.right, plot.bottom),
      axisPaint,
    );
    // Y axis
    canvas.drawLine(
      Offset(plot.left, plot.top),
      Offset(plot.left, plot.bottom),
      axisPaint,
    );

    // Guard: need at least 2 points to draw a polyline
    if (graph.points.length < 2 ||
        !graph.xAxis.min.isFinite ||
        !graph.xAxis.max.isFinite ||
        !graph.yAxis.min.isFinite ||
        !graph.yAxis.max.isFinite ||
        graph.xAxis.max == graph.xAxis.min ||
        graph.yAxis.max == graph.yAxis.min) {
      _drawNoData(canvas, plot);
      return;
    }

    // Scaling
    final double xMin = graph.xAxis.min;
    final double xMax = graph.xAxis.max;
    final double yMin = graph.yAxis.min;
    final double yMax = graph.yAxis.max;

    double sx(double x) => plot.left + (x - xMin) * plot.width / (xMax - xMin);
    double sy(double y) =>
        plot.bottom - (y - yMin) * plot.height / (yMax - yMin);

    // Line + points
    final Paint linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    for (int i = 0; i < graph.points.length; i++) {
      final ModelPoint p = graph.points[i];
      final Offset o = Offset(sx(p.vector.dx), sy(p.vector.dy));
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    canvas.drawPath(path, linePaint);

    final Paint dotPaint = Paint()..color = Colors.blue;
    for (final ModelPoint p in graph.points) {
      final Offset o = Offset(sx(p.vector.dx), sy(p.vector.dy));
      canvas.drawCircle(o, 3.0, dotPaint);
    }

    // Basic ticks/labels (minimal: 4 ticks each)
    final TextPainter tp = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    // Y ticks
    for (int i = 0; i <= 4; i++) {
      final double t = yMin + (i * (yMax - yMin) / 4.0);
      final double yy = sy(t);
      canvas.drawLine(
        Offset(plot.left - 4, yy),
        Offset(plot.left, yy),
        axisPaint,
      );

      tp.text = TextSpan(
        text: t.toStringAsFixed(0),
        style: const TextStyle(fontSize: 10, color: Colors.black87),
      );
      tp.layout();
      tp.paint(canvas, Offset(plot.left - 6 - tp.width, yy - tp.height / 2));
    }

    // X ticks (use first, mid, last label if possible)
    final List<ModelPoint> pts = graph.points;
    final List<int> idxs =
        <int>{0, (pts.length / 2).floor(), pts.length - 1}.toList()..sort();
    for (final int i in idxs) {
      final ModelPoint p = pts[i];
      final double xx = sx(p.vector.dx);
      canvas.drawLine(
        Offset(xx, plot.bottom),
        Offset(xx, plot.bottom + 4),
        axisPaint,
      );

      tp.text = TextSpan(
        text: p.label,
        style: const TextStyle(fontSize: 10, color: Colors.black87),
      );
      tp.layout(maxWidth: 80);
      final double textX = xx - (tp.width / 2);
      tp.paint(
        canvas,
        Offset(
          textX.clamp(plot.left, plot.right - tp.width),
          plot.bottom + 6,
        ),
      );
    }
  }

  void _drawNoData(Canvas canvas, Rect plot) {
    final TextPainter tp = TextPainter(
      textDirection: TextDirection.ltr,
      text: const TextSpan(
        text: 'No data',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    )..layout();
    tp.paint(
      canvas,
      Offset(
        plot.left + (plot.width - tp.width) / 2,
        plot.top + (plot.height - tp.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _SimpleLineChartPainter oldDelegate) {
    return oldDelegate.graph != graph;
  }
}
