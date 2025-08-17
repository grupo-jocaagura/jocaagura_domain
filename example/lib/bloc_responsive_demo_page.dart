import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Demo page for `BlocResponsive`.
///
/// ▶️ Objetivo
/// Esta página ilustra **cómo consumir** `BlocResponsive` desde la UI para:
/// - Mantener sincronizado el tamaño del viewport (con o sin `BuildContext`).
/// - Obtener métricas reactivas de layout: `deviceType`, `columnsNumber`,
///   `marginWidth`, `gutterWidth`, `columnWidth`, `workAreaSize`, etc.
/// - Visualizar una grilla de columnas y entender cómo se calculan.
///
/// 🧭 Flujo (Clean Architecture)
/// UI → AppManager → BlocResponsive (infra de presentación; sin I/O)
///
/// 💡 Recomendación de uso en apps reales
/// - Llama `setSizeFromContext(context)` en `build`, `didChangeDependencies`
///   o dentro de un `LayoutBuilder`, para mantener el bloc sincronizado con
///   el tamaño real de la vista.
/// - En tests/headless, usa `setSize(Size)` o `setSizeForTesting(Size)`.
///
/// 🔧 Esta demo también incluye un modo “simular tamaño” con sliders para
/// ver cómo cambian las métricas sin depender del dispositivo real.
class BlocResponsiveDemoPage extends StatefulWidget {
  /// Permite inyectar una instancia existente (p. ej. desde AppManager).
  /// Si viene null, la página crea y dispone su propio bloc.
  const BlocResponsiveDemoPage({super.key, this.injected});
  static const String name = 'BlocResponsiveDemoPage';

  final BlocResponsive? injected;

  @override
  State<BlocResponsiveDemoPage> createState() => _BlocResponsiveDemoPageState();
}

class _BlocResponsiveDemoPageState extends State<BlocResponsiveDemoPage> {
  late final BlocResponsive _bloc;
  late final bool _ownsBloc; // ¿Quién es dueño del ciclo de vida?

  bool _showGrid = true; // Muestra/oculta la superposición de columnas
  bool _simulateSize = false; // Activa el modo “simular tamaño”
  double _simWidth = 1024; // Ancho simulado
  double _simHeight = 720; // Alto simulado

  @override
  void initState() {
    super.initState();
    // 📦 Inyección opcional desde AppManager/configuración externa.
    if (widget.injected != null) {
      _bloc = widget.injected!;
      _ownsBloc = false; // No lo disponemos nosotros.
    } else {
      _bloc = BlocResponsive(); // Uso “standalone” para la demo.
      _ownsBloc = true; // Lo disponemos en dispose().
    }
  }

  @override
  void dispose() {
    // Si la UI creó el bloc, también debe disponerlo.
    if (_ownsBloc) {
      _bloc.dispose();
    }
    super.dispose();
  }

  /// Mantiene el bloc sincronizado con el tamaño actual.
  /// - En modo normal, usa `MediaQuery` a través de `setSizeFromContext`.
  /// - En modo simulado, empuja valores manuales con `setSizeForTesting`.
  void _syncSize(BuildContext context) {
    if (_simulateSize) {
      _bloc.setSizeForTesting(Size(_simWidth, _simHeight));
    } else {
      _bloc.setSizeFromContext(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 📌 Importante: Sincroniza el tamaño DESPUÉS del frame para evitar
    // loops de rebuild (especialmente útil si llamas desde `build`).
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncSize(context));

    return Scaffold(
      appBar: AppBar(
        title: const Text('BlocResponsive Demo'),
        actions: <Widget>[
          // Política de AppBar encapsulada en el bloc (presentación).
          // Si tu layout oculta la AppBar, `screenHeightWithoutAppbar` lo refleja.
          Row(
            children: <Widget>[
              const Text('Show AppBar', style: TextStyle(fontSize: 12)),
              Switch(
                value: _bloc.showAppbar,
                onChanged: (bool v) {
                  setState(() => _bloc.showAppbar = v);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),

      // Nos suscribimos al stream de tamaño de pantalla para actualizar métricas.
      body: StreamBuilder<Size>(
        stream: _bloc.appScreenSizeStream,
        initialData: _bloc.value,
        builder: (BuildContext context, AsyncSnapshot<Size> _) {
          // Re-sincroniza en cada rebuild significativo
          _syncSize(context);

          // 📐 Lee todas las métricas derivadas del bloc.
          final Size size = _bloc.size;
          final Size work = _bloc.workAreaSize;
          final int cols = _bloc.columnsNumber;
          final double margin = _bloc.marginWidth;
          final double gutter = _bloc.gutterWidth;
          final double colW = _bloc.columnWidth;
          final double drawerW = _bloc.drawerWidth;
          final ScreenSizeEnum device = _bloc.deviceType;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _DocCard(), // Guía en pantalla (qué hace y cómo se usa)
              const SizedBox(height: 12),

              // Controles de demo: grid overlay, simulación de tamaño (sliders)
              _ControlsCard(
                showGrid: _showGrid,
                simulateSize: _simulateSize,
                simWidth: _simWidth,
                simHeight: _simHeight,
                onToggleGrid: (bool v) => setState(() => _showGrid = v),
                onToggleSim: (bool v) {
                  setState(() {
                    _simulateSize = v;
                    _syncSize(context);
                  });
                },
                onWidthChanged: (double v) {
                  setState(() {
                    _simWidth = v;
                    _syncSize(context);
                  });
                },
                onHeightChanged: (double v) {
                  setState(() {
                    _simHeight = v;
                    _syncSize(context);
                  });
                },
              ),
              const SizedBox(height: 12),

              // Métricas “en vivo” para entender los cálculos de layout.
              _MetricsCard(
                device: device,
                size: size,
                work: work,
                cols: cols,
                margin: margin,
                gutter: gutter,
                colW: colW,
                drawer: drawerW,
                appBarHeight: _bloc.appBarHeight,
                heightWithoutAppBar: _bloc.screenHeightWithoutAppbar,
              ),
              const SizedBox(height: 12),

              // Vista previa de la grilla (columnas + gutters) respetando márgenes.
              _GridPreview(
                showGrid: _showGrid,
                cols: cols,
                margin: margin,
                gutter: gutter,
                columnWidth: colW,
                workArea: work,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Tarjeta con documentación en pantalla para el implementador.
/// Explica el propósito, el flujo y la forma recomendada de integración.
class _DocCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextStyle s = Theme.of(context).textTheme.bodyMedium!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: s,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'How this demo works / Cómo funciona',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                '1) The UI keeps the bloc in sync with the current viewport size.',
              ),
              Text(
                '   Use `setSizeFromContext(context)` in widgets, or `setSize(Size)` in headless tests.',
              ),
              SizedBox(height: 6),
              Text(
                '2) BlocResponsive computes device type, margins, gutters, columns and work area from the size and config.',
              ),
              Text(
                '   For desktop/TV it uses a percentage of the viewport as work area (config-driven).',
              ),
              SizedBox(height: 6),
              Text(
                '3) The grid preview draws columns respecting margins and gutters; useful to validate breakpoints.',
              ),
              SizedBox(height: 12),
              Text(
                'Clean Architecture: UI → AppManager → BlocResponsive (presentation infra).',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de controles de la demo.
/// - Muestra/oculta la grilla.
/// - Activa sliders para simular tamaños sin depender del dispositivo real.
class _ControlsCard extends StatelessWidget {
  const _ControlsCard({
    required this.showGrid,
    required this.simulateSize,
    required this.simWidth,
    required this.simHeight,
    required this.onToggleGrid,
    required this.onToggleSim,
    required this.onWidthChanged,
    required this.onHeightChanged,
  });

  final bool showGrid;
  final bool simulateSize;
  final double simWidth;
  final double simHeight;
  final ValueChanged<bool> onToggleGrid;
  final ValueChanged<bool> onToggleSim;
  final ValueChanged<double> onWidthChanged;
  final ValueChanged<double> onHeightChanged;

  @override
  Widget build(BuildContext context) {
    final TextStyle s = Theme.of(context).textTheme.bodyMedium!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: s,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Controls / Controles',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Show grid overlay'),
                      value: showGrid,
                      onChanged: onToggleGrid,
                      dense: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Simulate size (sliders)'),
                      value: simulateSize,
                      onChanged: onToggleSim,
                      dense: true,
                    ),
                  ),
                ],
              ),

              // Sliders visibles solo si activamos el modo de simulación.
              if (simulateSize) ...<Widget>[
                const SizedBox(height: 8),
                const Text('Width'),
                Slider(
                  min: 320,
                  max: 2560,
                  divisions: 224, // paso ~10 px
                  label: simWidth.toStringAsFixed(0),
                  value: simWidth.clamp(320, 2560),
                  onChanged: onWidthChanged,
                ),
                const Text('Height'),
                Slider(
                  min: 480,
                  max: 1600,
                  divisions: 112,
                  label: simHeight.toStringAsFixed(0),
                  value: simHeight.clamp(480, 1600),
                  onChanged: onHeightChanged,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de métricas: muestra en vivo todos los cálculos que hace el bloc.
/// Útil para validar breakpoints y coherencia de grilla en QA/manual testing.
class _MetricsCard extends StatelessWidget {
  const _MetricsCard({
    required this.device,
    required this.size,
    required this.work,
    required this.cols,
    required this.margin,
    required this.gutter,
    required this.colW,
    required this.drawer,
    required this.appBarHeight,
    required this.heightWithoutAppBar,
  });

  final ScreenSizeEnum device;
  final Size size;
  final Size work;
  final int cols;
  final double margin;
  final double gutter;
  final double colW;
  final double drawer;
  final double appBarHeight;
  final double heightWithoutAppBar;

  @override
  Widget build(BuildContext context) {
    final TextStyle s = Theme.of(context).textTheme.bodyMedium!;
    final String deviceName = device.toString().split('.').last.toUpperCase();

    String fmtSize(Size x) =>
        '${x.width.toStringAsFixed(0)} × ${x.height.toStringAsFixed(0)}';
    String px(num v) => '${v.toStringAsFixed(0)} px';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: s,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Metrics / Métricas',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text('Device: $deviceName'),
              Text('Viewport size: ${fmtSize(size)}'),
              Text('Work area: ${fmtSize(work)}  (drawer: ${px(drawer)})'),
              Text('Columns: $cols  •  Column width: ${px(colW)}'),
              Text(
                'Margin width: ${px(margin)}  •  Gutter width: ${px(gutter)}',
              ),
              Text(
                'AppBar height: ${px(appBarHeight)}  •  Height w/o AppBar: ${px(heightWithoutAppBar)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vista previa de la grilla basada en las métricas del bloc.
/// Dibuja columnas y gutters respetando los márgenes; no usa LayoutBuilder
/// porque queremos que las medidas provengan del bloc (fuente de verdad).
class _GridPreview extends StatelessWidget {
  const _GridPreview({
    required this.showGrid,
    required this.cols,
    required this.margin,
    required this.gutter,
    required this.columnWidth,
    required this.workArea,
  });

  final bool showGrid;
  final int cols;
  final double margin;
  final double gutter;
  final double columnWidth;
  final Size workArea;

  @override
  Widget build(BuildContext context) {
    // Altura fija para visualizar sin depender del alto real del viewport.
    const double previewHeight = 180;

    // Construimos la fila: col, gutter, col, gutter, ...
    final List<Widget> rowChildren = <Widget>[];
    for (int i = 0; i < cols; i++) {
      rowChildren.add(
        Container(
          width: columnWidth,
          height: previewHeight,
          decoration: BoxDecoration(
            color: Colors.blueGrey.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.5)),
          ),
        ),
      );
      if (i < cols - 1) {
        rowChildren.add(SizedBox(width: gutter));
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Grid preview / Vista de grilla',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            // Contenedor ancho = workArea + márgenes a cada lado.
            // Esto permite ver claramente cómo influyen los márgenes globales.
            Container(
              width: workArea.width + margin * 2,
              constraints: const BoxConstraints(minHeight: previewHeight + 24),
              decoration: BoxDecoration(
                color: Colors.black12.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: margin),
                child: Stack(
                  children: <Widget>[
                    // Fondo “área de trabajo” para distinguir del viewport.
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    // Fila de columnas + gutters (scroll horizontal por si el ancho no alcanza).
                    if (showGrid)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(children: rowChildren),
                        ),
                      ),

                    // Mensaje cuando se oculta la grilla.
                    if (!showGrid)
                      const Positioned.fill(
                        child: Center(
                          child: Text(
                            'Grid overlay disabled',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
