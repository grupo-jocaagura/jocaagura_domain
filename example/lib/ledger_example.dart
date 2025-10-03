import 'dart:math' show Random, max;

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  runApp(const LedgerChartsApp());
}

class LedgerChartsApp extends StatelessWidget {
  const LedgerChartsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ledger • Ponqué y Barras',
      theme: ThemeData.light(),
      home: const LedgerChartsPage(regionName: 'Colombia'),
    );
  }
}

class LedgerChartsPage extends StatefulWidget {
  const LedgerChartsPage({required this.regionName, super.key});

  final String regionName;

  @override
  State<LedgerChartsPage> createState() => _LedgerChartsPageState();
}

class _LedgerChartsPageState extends State<LedgerChartsPage> {
  final BlocGeneral<LedgerModel> _ledgerBloc =
      BlocGeneral<LedgerModel>(defaultLedgerModel());
  final BlocGeneral<ModelGraph> _barsBloc =
      BlocGeneral<ModelGraph>(defaultModelGraph()); // egresos por mes

  // Paleta fija por categoría (pastel).
  final Map<String, Color> _categoryColors = <String, Color>{
    'Mercado': const Color(0xFFFFD54F),
    'Transporte': const Color(0xFF90CAF9),
    'Entretenimiento': const Color(0xFFF48FB1),
    'Servicios': const Color(0xFFA5D6A7),
    'Arriendo': const Color(0xFFB39DDB),
    'Otros': const Color(0xFFFFAB91),
  };

  @override
  void initState() {
    super.initState();
    final LedgerModel ledger2024 = _buildDemoLedger2024(widget.regionName);
    _ledgerBloc.value = ledger2024;

    // Construimos barras (egreso mensual) desde el Ledger.
    final ModelGraph bars = _buildMonthlyExpensesGraph(ledger2024);
    _barsBloc.value = bars;
  }

  @override
  void dispose() {
    _ledgerBloc.dispose();
    _barsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen financiero 2024 • ${widget.regionName}'),
      ),
      body: StreamBuilder<LedgerModel>(
        stream: _ledgerBloc.stream,
        initialData: _ledgerBloc.value,
        builder: (BuildContext context, AsyncSnapshot<LedgerModel> ledgerSnap) {
          final LedgerModel? ledger = ledgerSnap.data;
          if (ledger == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final Map<String, double> byCategory = _sumExpensesByCategory(ledger);
          final double totalExpenses =
              byCategory.values.fold(0.0, (double a, double b) => a + b);

          return StreamBuilder<ModelGraph>(
            stream: _barsBloc.stream,
            initialData: _barsBloc.value,
            builder:
                (BuildContext context, AsyncSnapshot<ModelGraph> barsSnap) {
              final ModelGraph? bars = barsSnap.data;
              if (bars == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints c) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // --- Ponqué por categoría ---
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Por categoría',
                            textAlign: TextAlign.center,
                            style: t.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        AspectRatio(
                          aspectRatio: 1.1,
                          child: Card(
                            elevation: 2,
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: _PieChart(
                                totals: byCategory,
                                colors: _categoryColors,
                                centerLabel: 'Gasto total',
                                centerValue: _fmtCOP(totalExpenses),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- Barras por mes (egreso) ---
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Por fecha',
                            textAlign: TextAlign.center,
                            style: t.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        AspectRatio(
                          aspectRatio: 1.7,
                          child: Card(
                            elevation: 2,
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: _BarsChart(graph: bars),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        _Legend(colors: _categoryColors, totals: byCategory),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DEMO DATA
  // ---------------------------------------------------------------------------

  LedgerModel _buildDemoLedger2024(String region) {
    // Helper que delega a la versión completa (con ventas/eventos).
    return _buildDemoLedger2024Full(region: region);
  }

  LedgerModel _buildDemoLedger2024Full({required String region}) {
    final Random rng = Random(2024);
    final List<FinancialMovementModel> incomes = <FinancialMovementModel>[];
    final List<FinancialMovementModel> expenses = <FinancialMovementModel>[];

    // Ingresos: salario mensual (25 de cada mes), + ventas ocasionales (mar, jul, nov).
    for (int m = 1; m <= 12; m++) {
      final DateTime d = DateTime(2024, m, 25);
      const int salary = 3500000; // COP
      incomes.add(
        FinancialMovementModel(
          id: 'inc-sal-$m',
          amount: salary,
          date: d,
          concept: 'Salario',
          detailedDescription: 'Salario mensual',
          category: 'Salario',
          createdAt: d,
        ),
      );

      if (<int>{3, 7, 11}.contains(m)) {
        final int sale = 300000 + rng.nextInt(400000); // 300k..699k
        incomes.add(
          FinancialMovementModel(
            id: 'inc-sell-$m',
            amount: sale,
            date: DateTime(2024, m, 12),
            concept: 'Venta',
            detailedDescription: 'Venta ocasional',
            category: 'Ventas',
            createdAt: DateTime(2024, m, 12),
          ),
        );
      }
    }

    // Gastos fijos: arriendo (1 de cada mes), servicios (15 de cada mes).
    for (int m = 1; m <= 12; m++) {
      expenses.add(
        FinancialMovementModel(
          id: 'exp-rent-$m',
          amount: 1500000,
          date: DateTime(2024, m),
          concept: 'Arriendo',
          detailedDescription: 'Arriendo mensual',
          category: 'Arriendo',
          createdAt: DateTime(2024, m),
        ),
      );
      final int utilities = 220000 + rng.nextInt(60000); // 220k..279k
      expenses.add(
        FinancialMovementModel(
          id: 'exp-utils-$m',
          amount: utilities,
          date: DateTime(2024, m, 15),
          concept: 'Servicios',
          detailedDescription: 'Luz/agua/internet',
          category: 'Servicios',
          createdAt: DateTime(2024, m, 15),
        ),
      );
    }

    // Gastos variables: mercado (semanal aprox), transporte y entretenimiento
    for (int m = 1; m <= 12; m++) {
      // Mercado (4 veces al mes)
      for (int k = 0; k < 4; k++) {
        final int groceries = 220000 + rng.nextInt(80000); // 220k..299k
        expenses.add(
          FinancialMovementModel(
            id: 'exp-groc-$m-$k',
            amount: groceries,
            date: DateTime(2024, m, 3 + k * 7),
            concept: 'Mercado',
            detailedDescription: 'Supermercado',
            category: 'Mercado',
            createdAt: DateTime(2024, m, 3 + k * 7),
          ),
        );
      }

      // Transporte (20 días hábiles aprox.)
      for (int d = 1; d <= 20; d++) {
        final int transport = 8000 + rng.nextInt(3000); // bus/metro/taxi
        expenses.add(
          FinancialMovementModel(
            id: 'exp-trns-$m-$d',
            amount: transport,
            date: DateTime(2024, m, 2 + d),
            concept: 'Transporte',
            detailedDescription: 'Movilidad urbana',
            category: 'Transporte',
            createdAt: DateTime(2024, m, 2 + d),
          ),
        );
      }

      // Entretenimiento (2 veces/mes)
      for (int e = 0; e < 2; e++) {
        final int fun = 60000 + rng.nextInt(120000); // cine/salida
        expenses.add(
          FinancialMovementModel(
            id: 'exp-fun-$m-$e',
            amount: fun,
            date: DateTime(2024, m, 6 + e * 12),
            concept: 'Entretenimiento',
            detailedDescription: 'Ocio',
            category: 'Entretenimiento',
            createdAt: DateTime(2024, m, 6 + e * 12),
          ),
        );
      }
    }

    // Creamos el Ledger.
    final LedgerModel ledger = LedgerModel(
      incomeLedger: List<FinancialMovementModel>.unmodifiable(incomes),
      expenseLedger: List<FinancialMovementModel>.unmodifiable(expenses),
      nameOfLedger: 'My ledger',
    );
    return ledger;
  }

  // ---------------------------------------------------------------------------
  // DERIVACIONES A GRÁFICAS
  // ---------------------------------------------------------------------------

  Map<String, double> _sumExpensesByCategory(LedgerModel ledger) {
    final Map<String, double> out = <String, double>{};
    for (final FinancialMovementModel m in ledger.expenseLedger) {
      final String cat = m.category;
      final double v = out[cat] ?? 0.0;
      out[cat] = v + m.amount.toDouble();
    }
    return out;
  }

  ModelGraph _buildMonthlyExpensesGraph(LedgerModel ledger) {
    // Total de egresos por mes; etiquetas minúsculas "ene", "feb", ...
    final List<String> short = <String>[
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final List<Map<String, Object?>> rows = <Map<String, Object?>>[];

    for (int m = 1; m <= 12; m++) {
      double sum = 0.0;
      for (final FinancialMovementModel e in ledger.expenseLedger) {
        if (e.date.year == 2024 && e.date.month == m) {
          sum += e.amount.toDouble();
        }
      }
      rows.add(<String, Object?>{'label': short[m - 1], 'value': sum});
    }

    // Creamos ModelGraph (ejes se calculan automáticamente).
    final ModelGraph g = ModelGraph.fromTable(
      rows,
      xLabelKey: 'label',
      yValueKey: 'value',
      title: 'Gasto mensual 2024',
      subtitle: 'Totales por mes (COP)',
      description: 'Fuente: ledger demo',
      xTitle: 'Mes',
      yTitle: 'COP',
    );
    return g;
  }
}

// -----------------------------------------------------------------------------
// UI: Pie (ponqué) y Barras sin librerías externas
// -----------------------------------------------------------------------------

class _Legend extends StatelessWidget {
  const _Legend({required this.colors, required this.totals});

  final Map<String, Color> colors;
  final Map<String, double> totals;

  @override
  Widget build(BuildContext context) {
    final List<String> cats = totals.keys.toList()..sort();
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: <Widget>[
        for (final String c in cats)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[c] ?? Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text('$c (${_fmtCOP(totals[c] ?? 0)})'),
            ],
          ),
      ],
    );
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart({
    required this.totals,
    required this.colors,
    this.centerLabel,
    this.centerValue,
  });

  final Map<String, double> totals;
  final Map<String, Color> colors;
  final String? centerLabel;
  final String? centerValue;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PiePainter(
        totals: totals,
        colors: colors,
        centerLabel: centerLabel,
        centerValue: centerValue,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter({
    required this.totals,
    required this.colors,
    this.centerLabel,
    this.centerValue,
  });

  final Map<String, double> totals;
  final Map<String, Color> colors;
  final String? centerLabel;
  final String? centerValue;

  @override
  void paint(Canvas canvas, Size size) {
    final double total = totals.values.fold(0.0, (double a, double b) => a + b);
    final Offset c = Offset(size.width / 2, size.height / 2);
    final double r = size.shortestSide * 0.38;

    if (total <= 0) {
      final Paint p = Paint()..color = Colors.pink.shade100;
      canvas.drawCircle(c, r, p);
      return;
    }

    double start = -90 * (3.14159 / 180);
    for (final MapEntry<String, double> e in totals.entries) {
      final double sweep = (e.value / total) * (2 * 3.14159);
      final Paint seg = Paint()
        ..color = colors[e.key] ?? Colors.grey
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        start,
        sweep,
        true,
        seg,
      );
      start += sweep;
    }

    // Centro
    final Paint hole = Paint()..color = Colors.white.withValues(alpha: 0.1);
    canvas.drawCircle(c, r * 0.55, hole);

    final TextPainter tp1 = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    if (centerLabel != null && centerLabel!.isNotEmpty) {
      tp1.text = TextSpan(
        text: centerLabel,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      );
      tp1.layout(maxWidth: r * 1.6);
      tp1.paint(canvas, Offset(c.dx - tp1.width / 2, c.dy - tp1.height - 2));
    }

    if (centerValue != null && centerValue!.isNotEmpty) {
      final TextPainter tp2 = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
          text: centerValue,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      )..layout(maxWidth: r * 1.6);
      tp2.paint(canvas, Offset(c.dx - tp2.width / 2, c.dy + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) {
    return oldDelegate.totals != totals;
    // Colores/labels estáticos; si cambian, también repintará por !=
  }
}

class _BarsChart extends StatelessWidget {
  const _BarsChart({required this.graph});

  final ModelGraph graph;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarsPainter(graph: graph),
      child: const SizedBox.expand(),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({required this.graph});

  final ModelGraph graph;

  @override
  void paint(Canvas canvas, Size size) {
    // Área de plot
    const double padLeft = 24;
    const double padRight = 16;
    const double padTop = 8;
    const double padBottom = 40;

    final Rect plot = Rect.fromLTWH(
      padLeft,
      padTop,
      size.width - padLeft - padRight,
      size.height - padTop - padBottom,
    );

    // Ejes
    final Paint axis = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(plot.left, plot.bottom),
      Offset(plot.right, plot.bottom),
      axis,
    );
    canvas.drawLine(
      Offset(plot.left, plot.top),
      Offset(plot.left, plot.bottom),
      axis,
    );

    final double xMin = graph.xAxis.min;
    final double xMax = graph.xAxis.max;
    const double yMin = 0; // anclamos a 0 para barras
    final double yMax = graph.yAxis.max <= 0 ? 1 : graph.yAxis.max;

    double sx(double x) => plot.left + (x - xMin) * plot.width / (xMax - xMin);
    double sy(double y) =>
        plot.bottom - (y - yMin) * plot.height / (yMax - yMin);

    // Barras (anchura calculada por número de puntos)
    final int n = graph.points.length;
    if (n == 0) {
      return;
    }

    final double band = plot.width / n;
    final double barWidth = band * 0.5;
    final Paint bar = Paint()..color = const Color(0xFFFFD54F);

    final TextPainter tp = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < n; i++) {
      final ModelPoint p = graph.points[i];
      final double cx = sx(p.vector.dx);
      final double top = sy(max(0, p.vector.dy));
      final Rect r = Rect.fromCenter(
        center: Offset(cx, (top + plot.bottom) / 2),
        width: barWidth,
        height: (plot.bottom - top).abs(),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(8)),
        bar,
      );

      // Label de mes (debajo)
      tp.text = TextSpan(
        text: p.label,
        style: const TextStyle(fontSize: 10, color: Colors.black87),
      );
      tp.layout(maxWidth: band);
      tp.paint(canvas, Offset(cx - tp.width / 2, plot.bottom + 8));
    }

    // Ticks Y (4 marcas)
    final TextPainter ty = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    for (int i = 0; i <= 4; i++) {
      final double v = yMin + (i * (yMax - yMin) / 4.0);
      final double yy = sy(v);
      canvas.drawLine(Offset(plot.left - 4, yy), Offset(plot.left, yy), axis);

      ty.text = TextSpan(
        text: _fmtShortCop(v),
        style: const TextStyle(fontSize: 10, color: Colors.black87),
      );
      ty.layout();
      ty.paint(canvas, Offset(plot.left - 6 - ty.width, yy - ty.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) =>
      oldDelegate.graph != graph;

  String _fmtShortCop(double v) {
    if (v >= 1e6) {
      return '${(v / 1e6).toStringAsFixed(1)}M';
    }
    if (v >= 1e3) {
      return '${(v / 1e3).toStringAsFixed(0)}k';
    }
    return v.toStringAsFixed(0);
  }
}

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------

String _fmtCOP(double v) {
  // COP simple: separador de miles con puntos (visual), sin decimales.
  final String s = v.toStringAsFixed(0);
  final StringBuffer b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final int idx = s.length - i;
    b.write(s[i]);
    if (idx > 1 && idx % 3 == 1) {
      b.write('.');
    }
  }
  return '\$$b';
}
