import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Demo page for `BlocResponsive`.
///
/// ## What you will see
/// - Visual grid overlay (columns + gutters) driven by `BlocResponsive`.
/// - Switches to toggle: grid overlay, simulated size (sliders), and app bar visibility.
/// - Live metrics: device type, margins, gutters, column width, work area, drawer width.
///
/// ## Wiring
/// - Preferred: inject the bloc from your AppManager: `AppManager.of(context).config.blocResponsive`.
/// - Alternative: let this page create/dispose its own instance (default path).
class BlocResponsiveDemoPage extends StatefulWidget {
  const BlocResponsiveDemoPage({super.key, this.injected});
  static const String name = 'BlocResponsiveDemoPage';

  final BlocResponsive? injected;

  @override
  State<BlocResponsiveDemoPage> createState() => _BlocResponsiveDemoPageState();
}

class _BlocResponsiveDemoPageState extends State<BlocResponsiveDemoPage> {
  late final BlocResponsive _bloc;
  late final bool _ownsBloc;

  bool _showGrid = true;
  bool _simulateSize = false;
  double _simWidth = 1024;
  double _simHeight = 720;

  @override
  void initState() {
    super.initState();
    if (widget.injected != null) {
      _bloc = widget.injected!;
      _ownsBloc = false;
    } else {
      _bloc = BlocResponsive();
      _ownsBloc = true;
    }
  }

  @override
  void dispose() {
    if (_ownsBloc) {
      _bloc.dispose();
    }
    super.dispose();
  }

  void _syncSize(BuildContext context) {
    if (_simulateSize) {
      _bloc.setSizeForTesting(Size(_simWidth, _simHeight));
    } else {
      _bloc.setSizeFromContext(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mantén sincronizado el bloc con el contexto o el tamaño simulado.
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncSize(context));

    return Scaffold(
      appBar: AppBar(
        title: const Text('BlocResponsive Demo'),
        actions: <Widget>[
          // Toggle AppBar visibility policy in the bloc
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
      body: StreamBuilder<Size>(
        stream: _bloc.appScreenSizeStream,
        initialData: _bloc.value,
        builder: (BuildContext context, AsyncSnapshot<Size> _) {
          // Re-sincroniza cada rebuild significativo
          _syncSize(context);

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
              _DocCard(),
              const SizedBox(height: 12),
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
                '1) UI updates the bloc size from context (or simulated sliders).',
              ),
              Text(
                '   Use `setSizeFromContext(context)` in widgets, or `setSize(Size)` in headless tests.',
              ),
              SizedBox(height: 6),
              Text(
                '2) BlocResponsive computes layout: device type, margins, gutters, columns and work area.',
              ),
              Text(
                '   For desktop/TV it uses a percentage of the viewport as work area (config-driven).',
              ),
              SizedBox(height: 6),
              Text(
                '3) The grid preview draws columns respecting margins and gutters.',
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
              if (simulateSize) ...<Widget>[
                const SizedBox(height: 8),
                const Text('Width'),
                Slider(
                  min: 320,
                  max: 2560,
                  divisions: 224, // paso de ~10px
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
    // Altura del preview (constante) para visualizar la grilla
    const double previewHeight = 180;

    // Construye hijos: [col, gutter, col, gutter, ...]
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
            // El contenedor lateral respeta margen y work area
            Container(
              width: workArea.width + margin * 2,
              // Altura limitada para que se vea completo
              constraints: const BoxConstraints(minHeight: previewHeight + 24),
              decoration: BoxDecoration(
                color: Colors.black12.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: margin),
                child: Stack(
                  children: <Widget>[
                    // Línea base de trabajo (fondo)
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    // Fila de columnas + gutters
                    if (showGrid)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(children: rowChildren),
                        ),
                      ),
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
