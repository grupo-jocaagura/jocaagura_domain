// main.dart
//
// 🔹 "Kitchen Sink" de jocaagura_domain en un solo archivo para pub.dev
// 🔹 Incluye ejemplos completos, comentados y navegables:
//    1) Onboarding (validación de área de cuadrado)
//    2) Onboarding (Either onEnter)
//    3) Ledger (pastel + barras, sin libs extra)
//    4) Graph (línea precios pizza + tabla, con updates periódicos)
//    5) WS Database (CRUD + watch de ContactModel + colección en vivo)
//    6) Session/Auth (flavors dev/qa/prod con FakeServiceSession)
//    7) Connectivity (flow completo con Either<ErrorItem,...>)
//    8) Loading (single/queue, anti-flicker, FIFO)
//    9) Responsive (grid, métricas, simulación de tamaño)
//
// 📦 Dependencias clave (pubspec.yaml):
//   dependencies:
//     flutter:
//       sdk: flutter
//     jocaagura_domain: ^<versión>
// -----------------------------------------------------------------------------

import 'dart:async';
import 'dart:math' show Random, max, min;

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() => runApp(const KitchenSinkApp());

/// App raíz: muestra un home con lista de demos.
/// Cada demo es una pantalla separada.
class KitchenSinkApp extends StatelessWidget {
  const KitchenSinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'jocaagura_domain • Kitchen Sink',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const _HomePage(),
    );
  }
}

// ╔═══════════════════════════════════════════════════════════════════════════
// ║ HOME
// ╚═══════════════════════════════════════════════════════════════════════════

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demos disponibles')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text('Modelos por defecto (del paquete)'),
          const SizedBox(height: 8),
          const _ModelTile(label: 'UserModel', model: defaultUserModel),
          const _ModelTile(label: 'AddressModel', model: defaultAddressModel),
          const _ModelTile(label: 'StoreModel', model: defaultStoreModel),
          const Divider(height: 32),
          const Text('Demos de features'),
          const SizedBox(height: 8),
          const _NavTile(
            label: 'Onboarding • Área de un cuadrado',
            page: OnboardingSquareAreaValidationPage(),
          ),
          const _NavTile(
            label: 'Onboarding • Either onEnter (3 pasos)',
            page: BlocOnboardingDemoPage(),
          ),
          const _NavTile(
            label: 'Ledger • Ponqué y Barras',
            page: LedgerChartsPage(regionName: 'Colombia'),
          ),
          const _NavTile(
            label: 'Graph • Precios Pizza (línea + tabla)',
            page: PizzaPricesPage(regionName: 'LATAM — Región Andina'),
          ),
          _NavTile(
            label: 'WS DB • CRUD + Watch + Colección (ContactModel)',
            page: WsContactsHome.wrapper(),
          ),
          const _NavTile(
            label: 'Auth/Session • Flavors dev/qa/prod',
            page: SessionFlavorDemoPage(),
          ),
          const _NavTile(
            label: 'Connectivity • Flow con Either',
            page: ConnectivityDemoPage(),
          ),
          const _NavTile(
            label: 'Loading • Single + Queue (FIFO)',
            page: BlocLoadingDemoPage(),
          ),
          const _NavTile(
            label: 'Responsive • Grid + métricas + simulador',
            page: BlocResponsiveDemoPage(),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.label, required this.page});
  final String label;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.arrow_forward_ios),
      title: Text(label),
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => page));
      },
    );
  }
}

class _ModelTile extends StatelessWidget {
  const _ModelTile({required this.label, required this.model});
  final String label;
  final Model model;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(model.toString()),
    );
  }
}

// ╔═══════════════════════════════════════════════════════════════════════════
// ║ WIDGET DE UX CENTRALIZADA PARA ErrorItem (SnackBars automáticos)
// ╚═══════════════════════════════════════════════════════════════════════════

class ErrorItemWidget extends StatefulWidget {
  const ErrorItemWidget({
    required this.state,
    required this.child,
    super.key,
    this.showAsSnackBar = true,
  });

  final Either<ErrorItem, Object> state;
  final Widget child;
  final bool showAsSnackBar;

  @override
  State<ErrorItemWidget> createState() => _ErrorItemWidgetState();
}

class _ErrorItemWidgetState extends State<ErrorItemWidget> {
  String? _lastFingerprint;

  @override
  void initState() {
    super.initState();
    _maybeNotifyError(widget.state);
  }

  @override
  void didUpdateWidget(covariant ErrorItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _maybeNotifyError(widget.state);
    }
  }

  void _maybeNotifyError(Either<ErrorItem, Object> either) {
    if (!either.isLeft) {
      return;
    }
    final ErrorItem e = (either as Left<ErrorItem, Object>).value;
    final String fp = '${e.code}:${e.description.hashCode}';
    if (_lastFingerprint == fp) {
      return;
    }
    _lastFingerprint = fp;

    if (widget.showAsSnackBar && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${e.title}: ${e.description}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ╔═══════════════════════════════════════════════════════════════════════════
// ║ 1) ONBOARDING — ÁREA DE CUADRADO (con validación en onEnter)
// ╚═══════════════════════════════════════════════════════════════════════════
//
// Implementación guiada:
//  - bloc = BlocOnboarding()
//  - configure([...]) con pasos: Bienvenida(auto), Explicación(auto),
//    Input(manual), Validación(onEnter con Left/Right), Resultado, Final.
//  - En Validación: Left(ErrorItem) si side inválido; Right(Unit) si ok.
//  - UI llama bloc.start() al iniciar.

class OnboardingSquareAreaValidationPage extends StatefulWidget {
  const OnboardingSquareAreaValidationPage({super.key});

  @override
  State<OnboardingSquareAreaValidationPage> createState() =>
      _OnboardingSquareAreaValidationPageState();
}

class _OnboardingSquareAreaValidationPageState
    extends State<OnboardingSquareAreaValidationPage> {
  late final BlocOnboarding bloc;

  double? side; // estado local: lado ingresado
  final TextEditingController sideController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bloc = BlocOnboarding();
    _configureSteps();
    bloc.start(); // arranca el flujo
  }

  @override
  void dispose() {
    sideController.dispose();
    bloc.dispose();
    super.dispose();
  }

  void _configureSteps() {
    bloc.configure(<OnboardingStep>[
      const OnboardingStep(
        title: 'Bienvenida',
        description: 'Vamos a calcular el área de un cuadrado paso a paso.',
        autoAdvanceAfter: Duration(milliseconds: 1500),
      ),
      const OnboardingStep(
        title: 'Explicación',
        description:
            'El área de un cuadrado es lado × lado. Ingresarás un valor y lo validaremos.',
        autoAdvanceAfter: Duration(milliseconds: 3000),
      ),
      OnboardingStep(
        title: 'Ingresa el lado',
        description:
            'Ingresa un número mayor que 0 y como máximo 100, luego confirma.',
        onEnter: () async => Right<ErrorItem, Unit>(Unit.value),
      ),
      OnboardingStep(
        title: 'Validación',
        description: 'Validamos tu valor. Si hay un error, te lo mostramos.',
        onEnter: () async {
          final double? s = side;
          if (s == null || s <= 0) {
            return Left<ErrorItem, Unit>(
              const ErrorItem(
                title: 'Lado inválido',
                code: 'ERR_SIDE_NON_POSITIVE',
                description: 'El lado debe ser mayor que 0.',
                errorLevel: ErrorLevelEnum.warning,
              ),
            );
          }
          if (s > 100) {
            return Left<ErrorItem, Unit>(
              const ErrorItem(
                title: 'Lado demasiado grande',
                code: 'ERR_SIDE_TOO_BIG',
                description: 'El lado no puede ser mayor que 100.',
                errorLevel: ErrorLevelEnum.warning,
              ),
            );
          }
          return Right<ErrorItem, Unit>(Unit.value);
        },
        autoAdvanceAfter: const Duration(milliseconds: 800),
      ),
      OnboardingStep(
        title: 'Resultado',
        description: 'Mostramos el área calculada y puedes finalizar.',
        onEnter: () async => Right<ErrorItem, Unit>(Unit.value),
      ),
      const OnboardingStep(
        title: 'Final',
        description: '¡Has completado el tutorial! 🎉',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Área de un cuadrado – Onboarding')),
      body: StreamBuilder<OnboardingState>(
        stream: bloc.stateStream,
        initialData: bloc.state,
        builder: (BuildContext context, AsyncSnapshot<OnboardingState> snap) {
          final OnboardingState state = snap.data!;
          final OnboardingStep? step = bloc.currentStep;
          if (step == null) {
            return const Center(child: Text('No hay pasos.'));
          }

          final Widget errorBanner = _buildErrorBannerIfAny(state);

          Widget content;
          switch (step.title) {
            case 'Ingresa el lado':
              content = _buildInputStep(state);
              break;
            case 'Validación':
              content = _buildValidationStep(state);
              break;
            case 'Resultado':
              final String area =
                  side != null ? (side! * side!).toStringAsFixed(2) : '--';
              content = _buildResultStep(area);
              break;
            case 'Final':
              content = _buildFinalStep(step);
              break;
            default:
              content = _buildSimpleStep(step, state);
              break;
          }

          return Column(
            children: <Widget>[
              if (errorBanner != const SizedBox.shrink()) errorBanner,
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }

  // --- UI helpers para onboarding cuadrado ---

  Widget _buildSimpleStep(OnboardingStep step, OnboardingState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(step.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            if (step.description != null)
              Text(step.description!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (state.status == OnboardingStatus.running &&
                bloc.currentStep?.autoAdvanceAfter == null)
              ElevatedButton(
                onPressed: bloc.next,
                child: const Text('Siguiente'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputStep(OnboardingState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Paso ${state.stepNumber} de ${state.totalSteps}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'Ingresa el lado (0 < lado ≤ 100):',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sideController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ej: 12.5',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: () {
                      final double? value =
                          double.tryParse(sideController.text.trim());
                      if (value != null) {
                        setState(() => side = value);
                        bloc.next(); // pasa a Validación
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ingresa un número válido.'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Confirmar'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      sideController.clear();
                      setState(() => side = null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Se limpió el valor.')),
                      );
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidationStep(OnboardingState state) {
    final bool hasError = state.error != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Validación',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                hasError
                    ? 'Encontramos un problema con el valor.'
                    : '¡Todo correcto! Avanzaremos automáticamente.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  if (hasError)
                    ElevatedButton.icon(
                      onPressed: () {
                        bloc.clearError();
                        bloc.back();
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Corregir'),
                    ),
                  if (hasError)
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reintentando validación…'),
                          ),
                        );
                        bloc.retryOnEnter();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultStep(String area) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Resultado',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Área = $area',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: bloc.next,
                icon: const Icon(Icons.flag),
                label: const Text('Finalizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalStep(OnboardingStep step) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                step.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              if (step.description != null)
                Text(step.description!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  sideController.clear();
                  side = null;
                  _configureSteps();
                  bloc.start();
                },
                icon: const Icon(Icons.replay),
                label: const Text('Ver de nuevo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBannerIfAny(OnboardingState state) {
    final ErrorItem? err = state.error;
    if (err == null) {
      return const SizedBox.shrink();
    }
    return MaterialBanner(
      backgroundColor: Colors.red.shade50,
      content: Text(
        '${err.title} (${err.code})\n${err.description}',
        style: TextStyle(color: Colors.red.shade900),
      ),
      actions: <Widget>[
        TextButton.icon(
          onPressed: () {
            bloc.clearError();
            bloc.back();
          },
          icon: const Icon(Icons.edit),
          label: const Text('Corregir'),
        ),
        TextButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reintentando validación…')),
            );
            bloc.retryOnEnter();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      ],
    );
  }
}

// ╔═══════════════════════════════════════════════════════════════════════════
// ║ 2) ONBOARDING — DEMO Either onEnter (3 pasos)
// ╚═══════════════════════════════════════════════════════════════════════════

class BlocOnboardingDemoPage extends StatefulWidget {
  const BlocOnboardingDemoPage({super.key, this.injected});
  static const String name = 'BlocOnboardingDemoPage';
  final BlocOnboarding? injected;

  @override
  State<BlocOnboardingDemoPage> createState() => _BlocOnboardingDemoPageState();
}

class _BlocOnboardingDemoPageState extends State<BlocOnboardingDemoPage> {
  late final BlocOnboarding _bloc;
  late final bool _ownsBloc;
  StreamSubscription<OnboardingState>? _sub;
  final List<String> _log = <String>[];

  bool _failStep2AsLeft = false;
  bool _throwStep2 = false;

  void _logMsg(String msg) {
    if (!mounted) {
      return;
    }
    setState(() => _log.add(msg));
  }

  @override
  void initState() {
    super.initState();
    _bloc = widget.injected ?? BlocOnboarding();
    _ownsBloc = widget.injected == null;
    _configureSteps();
    _sub = _bloc.stateStream.listen((OnboardingState s) {
      if (!mounted) {
        return;
      }
      _logMsg(
        'STATE → status=${s.status}, step=${s.stepIndex}/${s.totalSteps}, error=${s.error != null}',
      );
      if (s.status == OnboardingStatus.completed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Onboarding completed')),
        );
      } else if (s.status == OnboardingStatus.skipped) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Onboarding skipped')),
        );
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    if (_ownsBloc) {
      _bloc.dispose();
    }
    super.dispose();
  }

  void _configureSteps() {
    _bloc.configure(<OnboardingStep>[
      OnboardingStep(
        title: 'Welcome',
        description: 'Short tour starts here',
        onEnter: () async {
          _logMsg('onEnter: Welcome (step 1)');
          await Future<void>.delayed(const Duration(milliseconds: 120));
          return Right<ErrorItem, Unit>(Unit.value);
        },
        autoAdvanceAfter: const Duration(milliseconds: 900),
      ),
      OnboardingStep(
        title: 'Permissions',
        description: 'Request minimal permissions',
        onEnter: () async {
          _logMsg('onEnter: Permissions (step 2)');
          await Future<void>.delayed(const Duration(milliseconds: 120));
          if (_throwStep2) {
            throw StateError('Simulated thrown exception in step 2');
          }
          if (_failStep2AsLeft) {
            return Left<ErrorItem, Unit>(
              const ErrorItem(
                title: 'Permissions required',
                code: 'PERM_DENIED',
                description: 'User denied permissions (simulated Left)',
              ),
            );
          }
          return Right<ErrorItem, Unit>(Unit.value);
        },
        autoAdvanceAfter: const Duration(milliseconds: 900),
      ),
      OnboardingStep(
        title: 'Finish',
        description: 'You are all set',
        onEnter: () async {
          _logMsg('onEnter: Finish (step 3)');
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return Right<ErrorItem, Unit>(Unit.value);
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BlocOnboarding Demo (Either onEnter)')),
      body: StreamBuilder<OnboardingState>(
        stream: _bloc.stateStream,
        initialData: _bloc.state,
        builder: (BuildContext context, AsyncSnapshot<OnboardingState> snap) {
          final OnboardingState s = snap.data ?? OnboardingState.idle();
          final OnboardingStep? step = _bloc.currentStep;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _DocCardIntro(),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Simulators / Simuladores',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Fail step 2 as Left(ErrorItem)'),
                        value: _failStep2AsLeft,
                        onChanged: (bool v) {
                          setState(() => _failStep2AsLeft = v);
                          _configureSteps();
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Throw in step 2 (ErrorMapper)'),
                        value: _throwStep2,
                        onChanged: (bool v) {
                          setState(() => _throwStep2 = v);
                          _configureSteps();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _ControlsRow(
                state: s,
                onStart: _bloc.start,
                onNext: _bloc.next,
                onBack: _bloc.back,
                onSkip: _bloc.skip,
                onComplete: _bloc.complete,
                onRetryOnEnter: _bloc.retryOnEnter,
                onClearError: _bloc.clearError,
              ),
              const SizedBox(height: 12),
              if (s.error != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Error: ${s.error?.title ?? ''} '
                            '${s.error?.code != null ? '(${s.error!.code})' : ''}\n'
                            '${s.error?.description ?? s.error.toString()}',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              _StateCard(state: s, step: step),
              const SizedBox(height: 12),
              _DocCardUseCases(),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Execution log / Registro de ejecución',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      if (_log.isEmpty) const Text('No events yet.'),
                      if (_log.isNotEmpty)
                        ..._log.map((String e) => Text('• $e')),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DocCardIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextStyle base = Theme.of(context).textTheme.bodyMedium!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: base,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'How it works / Cómo funciona',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                '• Cada paso puede tener `onEnter` → Either<ErrorItem, Unit>.',
              ),
              Text('• Right(Unit) → puede auto-avanzar si está configurado.'),
              Text('• Left(ErrorItem) → se detiene y expone `state.error`.'),
              Text('• Si onEnter lanza → ErrorMapper lo mapea a ErrorItem.'),
              SizedBox(height: 12),
              Text('Comandos', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                'start(), next(), back(), skip(), complete(), retryOnEnter(), clearError()',
              ),
              SizedBox(height: 12),
              Text(
                'Concurrencia',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Un solo timer de auto-avance activo; un comando cancela el actual.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocCardUseCases extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextStyle base = Theme.of(context).textTheme.bodyMedium!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: base,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Use cases & patrones',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text('• Permissions gate → Left si niega; Right si acepta.'),
              Text('• Warm-up (Flags) → Left controlado + retry.'),
              Text('• Migrations/Seed → Left o throw (mapeado).'),
              Text('• EULA/Privacy → Left si no acepta.'),
              Text('• First-run network check → Left si insuficiente.'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlsRow extends StatelessWidget {
  const _ControlsRow({
    required this.state,
    required this.onStart,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    required this.onComplete,
    required this.onRetryOnEnter,
    required this.onClearError,
  });

  final OnboardingState state;
  final VoidCallback onStart;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onComplete;
  final VoidCallback onRetryOnEnter;
  final VoidCallback onClearError;

  @override
  Widget build(BuildContext context) {
    final bool running = state.status == OnboardingStatus.running;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        FilledButton(
          onPressed: running ? null : onStart,
          child: const Text('Start'),
        ),
        OutlinedButton(
          onPressed: running && state.stepIndex > 0 ? onBack : null,
          child: const Text('Back'),
        ),
        OutlinedButton(
          onPressed: running ? onNext : null,
          child: const Text('Next'),
        ),
        OutlinedButton(
          onPressed: running ? onSkip : null,
          child: const Text('Skip'),
        ),
        OutlinedButton(
          onPressed: running || state.totalSteps == 0 ? onComplete : null,
          child: const Text('Complete'),
        ),
        FilledButton.tonal(
          onPressed: running && state.error != null ? onRetryOnEnter : null,
          child: const Text('Retry onEnter'),
        ),
        OutlinedButton(
          onPressed: running && state.error != null ? onClearError : null,
          child: const Text('Clear error'),
        ),
      ],
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.state, required this.step});
  final OnboardingState state;
  final OnboardingStep? step;

  @override
  Widget build(BuildContext context) {
    final String statusText =
        state.status.toString().split('.').last.toUpperCase();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyMedium!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Status: $statusText',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text('Steps: ${state.totalSteps}'),
              Text('Index: ${state.stepIndex}  (1-based: ${state.stepNumber})'),
              const SizedBox(height: 12),
              if (step != null) ...<Widget>[
                const Text(
                  'Current step',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text('• Title: ${step!.title}'),
                Text('• Description: ${step!.description ?? '-'}'),
                Text(
                  '• Auto-advance: ${step!.autoAdvanceAfter?.inMilliseconds ?? 0} ms',
                ),
                const SizedBox(height: 8),
                const Text('Note: auto-advance solo tras Right(Unit).'),
              ] else
                const Text('No active step'),
            ],
          ),
        ),
      ),
    );
  }
}

// ╔═══════════════════════════════════════════════════════════════════════════
// ║ 3) LEDGER — Pastel por categoría + Barras por mes (COP)
// ╚═══════════════════════════════════════════════════════════════════════════

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
      BlocGeneral<ModelGraph>(defaultModelGraph());

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
    _barsBloc.value = _buildMonthlyExpensesGraph(ledger2024);
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
      appBar:
          AppBar(title: Text('Resumen financiero 2024 • ${widget.regionName}')),
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

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
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
      ),
    );
  }

  LedgerModel _buildDemoLedger2024(String region) =>
      _buildDemoLedger2024Full(region: region);

  LedgerModel _buildDemoLedger2024Full({required String region}) {
    final Random rng = Random(2024);
    final List<FinancialMovementModel> incomes = <FinancialMovementModel>[];
    final List<FinancialMovementModel> expenses = <FinancialMovementModel>[];

    for (int m = 1; m <= 12; m++) {
      incomes.add(
        FinancialMovementModel(
          id: 'inc-sal-$m',
          amount: 3500000,
          date: DateTime(2024, m, 25),
          concept: 'Salario',
          detailedDescription: 'Salario mensual',
          category: 'Salario',
          createdAt: DateTime(2024, m, 25),
        ),
      );
      if (<int>{3, 7, 11}.contains(m)) {
        final int sale = 300000 + rng.nextInt(400000);
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
      final int utilities = 220000 + rng.nextInt(60000);
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

    for (int m = 1; m <= 12; m++) {
      for (int k = 0; k < 4; k++) {
        final int groceries = 220000 + rng.nextInt(80000);
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
      for (int d = 1; d <= 20; d++) {
        final int transport = 8000 + rng.nextInt(3000);
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
      for (int e = 0; e < 2; e++) {
        final int fun = 60000 + rng.nextInt(120000);
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

    return LedgerModel(
      incomeLedger: List<FinancialMovementModel>.unmodifiable(incomes),
      expenseLedger: List<FinancialMovementModel>.unmodifiable(expenses),
      nameOfLedger: 'My ledger',
    );
  }

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

    return ModelGraph.fromTable(
      rows,
      xLabelKey: 'label',
      yValueKey: 'value',
      title: 'Gasto mensual 2024',
      subtitle: 'Totales por mes (COP)',
      description: 'Fuente: ledger demo',
      xTitle: 'Mes',
      yTitle: 'COP',
    );
  }
}

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

    final Paint hole = Paint()..color = Colors.white.withValues(alpha: 0.9);
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
  bool shouldRepaint(covariant _PiePainter oldDelegate) =>
      oldDelegate.totals != totals;
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
    const double padLeft = 24, padRight = 16, padTop = 8, padBottom = 40;
    final Rect plot = Rect.fromLTWH(
      padLeft,
      padTop,
      size.width - padLeft - padRight,
      size.height - padTop - padBottom,
    );

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

    final double xMin = graph.xAxis.min,
        xMax = graph.xAxis.max,
        yMin = 0,
        yMax = graph.yAxis.max <= 0 ? 1 : graph.yAxis.max;
    double sx(double x) => plot.left + (x - xMin) * plot.width / (xMax - xMin);
    double sy(double y) =>
        plot.bottom - (y - yMin) * plot.height / (yMax - yMin);

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

      tp.text = TextSpan(
        text: p.label,
        style: const TextStyle(fontSize: 10, color: Colors.black87),
      );
      tp.layout(maxWidth: band);
      tp.paint(canvas, Offset(cx - tp.width / 2, plot.bottom + 8));
    }

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

String _fmtCOP(double v) {
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

// ===== Graph • Pizza Prices (línea + tabla) =====

class PizzaPricesPage extends StatefulWidget {
  const PizzaPricesPage({required this.regionName, super.key});

  final String regionName;

  @override
  State<PizzaPricesPage> createState() => _PizzaPricesPageState();
}

class _PizzaPricesPageState extends State<PizzaPricesPage> {
  final BlocGeneral<ModelGraph> _bloc =
      BlocGeneral<ModelGraph>(defaultModelGraph());
  Timer? _timer;
  final Random _rng = Random(2024);
  int _futureMonthsAppended = 0;

  @override
  void initState() {
    super.initState();
    _bloc.value = _buildInitialGraph(widget.regionName);
    _timer = Timer.periodic(const Duration(seconds: 5), _onTick);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bloc.dispose();
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
      appBar: AppBar(title: Text('Pizza Prices 2024 • ${widget.regionName}')),
      body: StreamBuilder<ModelGraph>(
        stream: _bloc.stream,
        initialData: _bloc.value,
        builder: (BuildContext context, AsyncSnapshot<ModelGraph> snap) {
          final ModelGraph? graph = snap.data;
          if (graph == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                _PizzaHeader(graph: graph),
                const SizedBox(height: 12),
                Expanded(flex: 2, child: _GraphCard(graph: graph)),
                const SizedBox(height: 12),
                Expanded(flex: 3, child: _TableCard(graph: graph)),
              ],
            ),
          );
        },
      ),
    );
  }

  ModelGraph _buildInitialGraph(String region) {
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

  ModelGraph _appendNextMonth(ModelGraph current, String region) {
    final List<ModelPoint> pts = List<ModelPoint>.from(current.points);
    final int nextIndex = pts.isEmpty ? 1 : (pts.last.vector.dx.round() + 1);
    final String label = _labelForIndex(nextIndex);
    final double lastY = pts.isEmpty ? 60000.0 : pts.last.vector.dy;
    final double delta = (_rng.nextDouble() * 4000.0) - 1000.0;
    final double nextY = (lastY + delta).clamp(50000.0, 90000.0);
    pts.add(
      ModelPoint(
        label: label,
        vector: ModelVector(nextIndex.toDouble(), nextY),
      ),
    );

    final double minX = pts.map((ModelPoint p) => p.vector.dx).reduce(min);
    final double maxX = pts.map((ModelPoint p) => p.vector.dx).reduce(max);
    final double minY = pts.map((ModelPoint p) => p.vector.dy).reduce(min);
    final double maxY = pts.map((ModelPoint p) => p.vector.dy).reduce(max);

    return ModelGraph(
      xAxis:
          ModelGraphAxisSpec(title: current.xAxis.title, min: minX, max: maxX),
      yAxis:
          ModelGraphAxisSpec(title: current.yAxis.title, min: minY, max: maxY),
      points: pts,
      title: current.title.isEmpty ? 'Precio Pizza — $region' : current.title,
      subtitle: 'Serie mensual 2024 (+ futuro simulado)',
      description: current.description,
    );
  }

  String _labelForIndex(int index) {
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
    final int zeroBased = (index - 1) % 12;
    final int yearOffset = (index - 1) ~/ 12;
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

class _PizzaHeader extends StatelessWidget {
  const _PizzaHeader({required this.graph});

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
              DataCell(Text(p.vector.dy.toStringAsFixed(0))),
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

class _SimpleLineChartPainter extends CustomPainter {
  _SimpleLineChartPainter({required this.graph});

  final ModelGraph graph;

  @override
  void paint(Canvas canvas, Size size) {
    const double padLeft = 48, padRight = 16, padTop = 16, padBottom = 32;
    final Rect plot = Rect.fromLTWH(
      padLeft,
      padTop,
      size.width - padLeft - padRight,
      size.height - padTop - padBottom,
    );
    final Paint axisPaint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(plot.left, plot.bottom),
      Offset(plot.right, plot.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(plot.left, plot.top),
      Offset(plot.left, plot.bottom),
      axisPaint,
    );

    if (graph.points.length < 2 ||
        !graph.xAxis.min.isFinite ||
        !graph.xAxis.max.isFinite ||
        !graph.yAxis.min.isFinite ||
        !graph.yAxis.max.isFinite ||
        graph.xAxis.max == graph.xAxis.min ||
        graph.yAxis.max == graph.yAxis.min) {
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
      return;
    }

    final double xMin = graph.xAxis.min,
        xMax = graph.xAxis.max,
        yMin = graph.yAxis.min,
        yMax = graph.yAxis.max;
    double sx(double x) => plot.left + (x - xMin) * plot.width / (xMax - xMin);
    double sy(double y) =>
        plot.bottom - (y - yMin) * plot.height / (yMax - yMin);

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

    final TextPainter tp = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
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

  @override
  bool shouldRepaint(covariant _SimpleLineChartPainter oldDelegate) =>
      oldDelegate.graph != graph;
}

// ===== WS DB • CRUD + Watch + Colección (ContactModel) =====

class WsContactsHome extends StatefulWidget {
  const WsContactsHome({
    required this.contactsBloc,
    required this.contactsCollectionBloc,
    super.key,
  });

  // Helper para crear toda la pila (Service → Gateway → Repo → Facade → Blocs)
  factory WsContactsHome.wrapper() {
    final ServiceWsDb service = FakeServiceWsDb(
      config: const WsDbConfig(latency: Duration(milliseconds: 300)),
    );
    final GatewayWsDatabase gateway = GatewayWsDbImpl(
      service: service,
      collection: 'contacts',
      mapper: const DefaultErrorMapper(),
      readAfterWrite: true,
      treatEmptyAsMissing: true,
    );
    final RepositoryWsDatabase<ContactModel> repo =
        RepositoryWsDatabaseImpl<ContactModel>(
      gateway: gateway,
      fromJson: ContactModel.fromJson,
      mapper: const DefaultErrorMapper(),
      serializeWrites: true,
    );
    final FacadeWsDatabaseUsecases<ContactModel> facade =
        FacadeWsDatabaseUsecases<ContactModel>.fromRepository(
      repository: repo,
      fromJson: ContactModel.fromJson,
    );
    final BlocWsDatabase<ContactModel> docBloc =
        BlocWsDatabase<ContactModel>(facade: facade);
    final ContactsCollectionBloc collBloc = ContactsCollectionBloc(
      service: service,
      collection: 'contacts',
      fromJson: ContactModel.fromJson,
    )..start();
    return WsContactsHome(
      contactsBloc: docBloc,
      contactsCollectionBloc: collBloc,
    );
  }

  final BlocWsDatabase<ContactModel> contactsBloc;
  final ContactsCollectionBloc contactsCollectionBloc;

  @override
  State<WsContactsHome> createState() => _WsContactsHomeState();
}

class _WsContactsHomeState extends State<WsContactsHome> {
  final TextEditingController _id = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _relationship = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();

  final List<String> _log = <String>[];
  StreamSubscription<WsDbState<ContactModel>>? _sub;
  bool _watching = false;

  @override
  void initState() {
    super.initState();
    _sub = widget.contactsBloc.stream.listen((WsDbState<ContactModel> s) {
      setState(() {
        _log.add('[${DateTime.now().toIso8601String()}] $s');
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  ContactModel _fromForm() => ContactModel(
        id: _id.text.trim(),
        name: _name.text.trim(),
        relationship: _relationship.text.trim(),
        phoneNumber: _phone.text.trim(),
        email: _email.text.trim(),
      );

  void _fillForm(ContactModel c) {
    _id.text = c.id;
    _name.text = c.name;
    _relationship.text = c.relationship;
    _phone.text = c.phoneNumber;
    _email.text = c.email;
  }

  Future<void> _read() async {
    if (_id.text.trim().isEmpty) {
      return;
    }
    final Either<ErrorItem, ContactModel> res =
        await widget.contactsBloc.readDoc(_id.text.trim());
    res.fold(
      (ErrorItem e) => _snack('READ error: ${e.code}'),
      (ContactModel c) {
        _fillForm(c);
        _snack('READ ok: ${c.id}');
      },
    );
  }

  Future<void> _write() async {
    final ContactModel c = _fromForm();
    if (c.id.isEmpty) {
      return;
    }
    final Either<ErrorItem, ContactModel> res =
        await widget.contactsBloc.writeDoc(c.id, c);
    res.fold(
      (ErrorItem e) => _snack('WRITE error: ${e.code}'),
      (ContactModel saved) {
        _fillForm(saved);
        _snack('WRITE ok: ${saved.id}');
      },
    );
  }

  Future<void> _delete() async {
    if (_id.text.trim().isEmpty) {
      return;
    }
    final Either<ErrorItem, Unit> res =
        await widget.contactsBloc.deleteDoc(_id.text.trim());
    res.fold(
      (ErrorItem e) => _snack('DELETE error: ${e.code}'),
      (_) => _snack('DELETE ok'),
    );
  }

  Future<void> _toggleWatch() async {
    final String id = _id.text.trim();
    if (id.isEmpty) {
      return;
    }
    if (_watching) {
      await widget.contactsBloc.stopWatch(id);
    } else {
      await widget.contactsBloc.startWatch(id);
    }
    setState(() => _watching = !_watching);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts WS CRUD (JSON-first)'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Clear log',
            onPressed: () => setState(_log.clear),
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _HeaderCard(watching: _watching),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(child: _formCard()),
                const VerticalDivider(width: 1),
                Expanded(child: _stateAndLogAndCollectionCard()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _fabBar(),
    );
  }

  Widget _fabBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FloatingActionButton.extended(
          heroTag: 'read',
          onPressed: _read,
          icon: const Icon(Icons.download),
          label: const Text('Read'),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.extended(
          heroTag: 'write',
          onPressed: _write,
          icon: const Icon(Icons.upload),
          label: const Text('Write/Upsert'),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.extended(
          heroTag: 'delete',
          onPressed: _delete,
          icon: const Icon(Icons.delete),
          label: const Text('Delete'),
          backgroundColor: Colors.redAccent,
        ),
        const SizedBox(height: 8),
        FloatingActionButton.extended(
          heroTag: 'watch',
          onPressed: _toggleWatch,
          icon: Icon(_watching ? Icons.visibility_off : Icons.visibility),
          label: Text(_watching ? 'Stop watch' : 'Start watch'),
          backgroundColor: _watching ? Colors.orange : null,
        ),
      ],
    );
  }

  Widget _formCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: <Widget>[
              const Text('ContactModel form', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              TextField(
                controller: _id,
                decoration: const InputDecoration(
                  labelText: 'id (docId)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _relationship,
                decoration: const InputDecoration(
                  labelText: 'relationship',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'phoneNumber',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              _HelperBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stateAndLogAndCollectionCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 1,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 8),
            const Text(
              'WsDbState<ContactModel>',
              style: TextStyle(fontSize: 18),
            ),
            const Divider(),
            Expanded(
              flex: 2,
              child: StreamBuilder<WsDbState<ContactModel>>(
                stream: widget.contactsBloc.stream,
                initialData: widget.contactsBloc.value,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<WsDbState<ContactModel>> snap,
                ) {
                  final WsDbState<ContactModel> s =
                      snap.data ?? WsDbState<ContactModel>.idle();
                  final ContactModel? c = s.doc;
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _kv('loading', '${s.loading}'),
                        _kv('docId', s.docId),
                        _kv('isWatching', '${s.isWatching}'),
                        _kv('error', s.error?.code ?? 'null'),
                        const Divider(),
                        const Text(
                          'doc snapshot',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              c == null ? 'null' : c.toJson().toString(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Contacts collection (realtime)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 3,
              child: StreamBuilder<List<ContactModel>>(
                stream: widget.contactsCollectionBloc.stream,
                initialData: widget.contactsCollectionBloc.value,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<ContactModel>> snap,
                ) {
                  final List<ContactModel> items =
                      snap.data ?? const <ContactModel>[];
                  if (items.isEmpty) {
                    return const Center(child: Text('No contacts yet'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, int i) {
                      final ContactModel c = items[i];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(c.name.isEmpty ? '?' : c.name[0]),
                        ),
                        title: Text(c.name),
                        subtitle: Text(
                          '${c.relationship} • ${c.phoneNumber}\n${c.email}',
                        ),
                        isThreeLine: true,
                        trailing: Text('#${c.id}'),
                        onTap: () => _fillForm(c),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 4),
              child: Text('ledger (latest first)'),
            ),
            Expanded(
              flex: 2,
              child: ListView.builder(
                reverse: true,
                itemCount: _log.length,
                itemBuilder: (_, int i) {
                  final int idx = _log.length - 1 - i;
                  return Text(_log[idx], style: const TextStyle(fontSize: 12));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.watching});

  final bool watching;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: <Widget>[
            Icon(Icons.cloud_sync),
            SizedBox(width: 8),
            Text(
              'JSON-first WS flow • Service → Gateway → Repository → Facade → BLoC',
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class _HelperBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: SelectableText('''
How to swap to your real service:

1) Replace the Fake by your Service implementing ServiceWsDb:
   final ServiceWsDb service = FirestoreServiceWsDb(...);
   // or
   final ServiceWsDb service = GoogleSheetsServiceWsDb(...);

2) Keep the Gateway as-is (JSON-first) for documents:
   GatewayWsDbImpl(
     service: service,
     collection: 'contacts',
     idKey: 'id',
     readAfterWrite: true,
     treatEmptyAsMissing: true,
   );

3) Repository typed + serializeWrites=true (FIFO per docId).
4) UI consumes WsDbState<ContactModel> from BlocWsDatabase<ContactModel>.

Collection note:
- For the demo, the collection list uses service.collectionStream('contacts')
  via a lightweight ContactsCollectionBloc. In production, consider adding a
  dedicated Gateway/Repository/Facade for collections too.
'''),
      ),
    );
  }
}

Widget _kv(String k, String v) {
  return Row(
    children: <Widget>[
      SizedBox(
        width: 120,
        child: Text(k, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      const Text(':  '),
      Expanded(child: Text(v)),
    ],
  );
}

class ContactsCollectionBloc extends BlocGeneral<List<ContactModel>> {
  ContactsCollectionBloc({
    required ServiceWsDb service,
    required String collection,
    required ContactModel Function(Map<String, dynamic>) fromJson,
  })  : _service = service,
        _collection = collection,
        _fromJson = fromJson,
        super(const <ContactModel>[]);

  final ServiceWsDb _service;
  final String _collection;
  final ContactModel Function(Map<String, dynamic>) _fromJson;
  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  void start() {
    _sub?.cancel();
    _sub = _service.collectionStream(collection: _collection).listen(
      (List<Map<String, dynamic>> rawList) {
        final List<ContactModel> items = <ContactModel>[];
        for (final Map<String, dynamic> m in rawList) {
          try {
            items.add(_fromJson(m));
          } catch (_) {}
        }
        value = items;
      },
      onError: (Object _, StackTrace __) {},
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// ===== Session/Auth • Flavors dev/qa/prod =====

const String kFlavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

ServiceSession _buildServiceForFlavor(String flavor) {
  switch (flavor) {
    case 'dev':
      return FakeServiceSession(latency: const Duration(milliseconds: 300));
    case 'qa':
      return FakeServiceSession(latency: const Duration(milliseconds: 150));
    case 'prod':
      return FakeServiceSession(latency: const Duration(milliseconds: 80));
    default:
      return FakeServiceSession(latency: const Duration(milliseconds: 200));
  }
}

BlocSession _buildBlocSession() {
  final ServiceSession svc = _buildServiceForFlavor(kFlavor);
  final GatewayAuth gateway =
      GatewayAuthImpl(svc, errorMapper: const DefaultErrorMapper());
  final RepositoryAuth repository = RepositoryAuthImpl(
    gateway: gateway,
    errorMapper: const DefaultErrorMapper(),
  );
  return BlocSession.fromRepository(repository: repository);
}

class SessionFlavorDemoPage extends StatefulWidget {
  const SessionFlavorDemoPage({super.key});

  @override
  State<SessionFlavorDemoPage> createState() => _SessionFlavorDemoPageState();
}

class _SessionFlavorDemoPageState extends State<SessionFlavorDemoPage> {
  late final BlocSession session;
  final TextEditingController email =
      TextEditingController(text: 'user@fake.com');
  final TextEditingController pass = TextEditingController(text: 'secret');

  @override
  void initState() {
    super.initState();
    session = _buildBlocSession();
    session.boot(); // escucha cambios auth
  }

  @override
  void dispose() {
    session.dispose();
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
    );

    return MaterialApp(
      theme: theme,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Auth flow • Jocaagura (FakeService)'),
          actions: const <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  'FLAVOR: $kFlavor',
                  style: TextStyle(
                    fontFeatures: <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: StreamBuilder<SessionState>(
          stream: session.stream,
          initialData: session.stateOrDefault,
          builder: (BuildContext context, AsyncSnapshot<SessionState> snap) {
            final SessionState s = snap.data ?? session.stateOrDefault;

            Widget statusChip;
            if (s is Authenticating) {
              statusChip = const Chip(label: Text('Authenticating...'));
            } else if (s is Refreshing) {
              statusChip = const Chip(label: Text('Refreshing...'));
            } else if (s is SessionError) {
              statusChip = Chip(
                label: Text('Error: ${s.error.code}'),
                backgroundColor: Colors.red.withValues(alpha: .15),
              );
            } else if (s is Authenticated) {
              statusChip = const Chip(label: Text('Authenticated'));
            } else {
              statusChip = const Chip(label: Text('Unauthenticated'));
            }

            final String emailLabel = (s is Authenticated) ? s.user.email : '—';

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    statusChip,
                    const SizedBox(width: 12),
                    Text(
                      'isAuthenticated: ${session.isAuthenticated}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Credentials',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'you@mail.com',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: pass,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () async {
                                final Either<ErrorItem, UserModel> r =
                                    await session.logIn(
                                  email: email.text,
                                  password: pass.text,
                                );
                                r.fold(
                                  (ErrorItem e) => _toast(
                                    context,
                                    'Login error: ${e.code}',
                                  ),
                                  (UserModel u) =>
                                      _toast(context, 'Hello ${u.email}'),
                                );
                              },
                              child: const Text('Log In (email/pass)'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final Either<ErrorItem, UserModel> r =
                                    await session.signIn(
                                  email: email.text,
                                  password: pass.text,
                                );
                                r.fold(
                                  (ErrorItem e) => _toast(
                                    context,
                                    'Sign In error: ${e.code}',
                                  ),
                                  (UserModel u) =>
                                      _toast(context, 'Welcome ${u.email}'),
                                );
                              },
                              child: const Text('Sign In (create)'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final Either<ErrorItem, UserModel> r =
                                    await session.logInWithGoogle();
                                r.fold(
                                  (ErrorItem e) => _toast(
                                    context,
                                    'Google error: ${e.code}',
                                  ),
                                  (UserModel u) =>
                                      _toast(context, 'Google: ${u.email}'),
                                );
                              },
                              child: const Text('Log In with Google'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final Either<ErrorItem, void> r = await session
                                    .recoverPassword(email: email.text);
                                r.fold(
                                  (ErrorItem e) => _toast(
                                    context,
                                    'Recover error: ${e.code}',
                                  ),
                                  (_) => _toast(
                                    context,
                                    'Recovery sent to ${email.text}',
                                  ),
                                );
                              },
                              child: const Text('Recover password'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Session',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Current user: $emailLabel'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () async {
                                final Either<ErrorItem, UserModel>? r =
                                    await session.logInSilently();
                                if (r == null && context.mounted) {
                                  _toast(context, 'No session to restore');
                                  return;
                                }
                                r?.fold(
                                  (ErrorItem e) => _toast(
                                    context,
                                    'Silent error: ${e.code}',
                                  ),
                                  (UserModel u) =>
                                      _toast(context, 'Restored ${u.email}'),
                                );
                              },
                              child: const Text('Log In silently'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final Either<ErrorItem, UserModel>? r =
                                    await session.refreshSession();
                                if (r == null && context.mounted) {
                                  _toast(context, 'Nothing to refresh');
                                  return;
                                }
                                r?.fold(
                                  (ErrorItem e) => _toast(
                                    context,
                                    'Refresh error: ${e.code}',
                                  ),
                                  (UserModel u) => _toast(
                                    context,
                                    'Refreshed for ${u.email}',
                                  ),
                                );
                              },
                              child: const Text('Refresh session'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final Either<ErrorItem, void>? r =
                                    await session.logOut();
                                if (r == null && context.mounted) {
                                  _toast(context, 'Already signed out');
                                  return;
                                }
                                r?.fold(
                                  (ErrorItem e) => _toast(
                                    context,
                                    'Logout error: ${e.code}',
                                  ),
                                  (_) => _toast(context, 'Signed out'),
                                );
                              },
                              child: const Text('Log out'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _toast(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ===== Connectivity • Flow con Either =====

class ConnectivityDemoPage extends StatefulWidget {
  const ConnectivityDemoPage({super.key});

  static const String name = 'ConnectivityDemoPage';

  @override
  State<ConnectivityDemoPage> createState() => _ConnectivityDemoPageState();
}

class _ConnectivityDemoPageState extends State<ConnectivityDemoPage> {
  late final FakeServiceConnectivity _service;
  late final GatewayConnectivity _gateway;
  late final RepositoryConnectivity _repo;
  late final BlocConnectivity _bloc;

  ConnectivityModel _lastGood = const ConnectivityModel(
    connectionType: ConnectionTypeEnum.none,
    internetSpeed: 0,
  );

  @override
  void initState() {
    super.initState();
    _service = FakeServiceConnectivity(
      latencyConnectivity: const Duration(milliseconds: 80),
      latencySpeed: const Duration(milliseconds: 120),
      initial: const ConnectivityModel(
        connectionType: ConnectionTypeEnum.wifi,
        internetSpeed: 40,
      ),
    );
    _gateway = GatewayConnectivityImpl(_service, const DefaultErrorMapper());
    _repo = RepositoryConnectivityImpl(
      _gateway,
      errorMapper: const DefaultErrorMapper(),
    );
    _bloc = BlocConnectivity(
      watch: WatchConnectivityUseCase(_repo),
      snapshot: GetConnectivitySnapshotUseCase(_repo),
      checkType: CheckConnectivityTypeUseCase(_repo),
      checkSpeed: CheckInternetSpeedUseCase(_repo),
    );
    _bloc.loadInitial();
    _bloc.startWatching();
  }

  @override
  void dispose() {
    _bloc.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connectivity Demo')),
      body: StreamBuilder<Either<ErrorItem, ConnectivityModel>>(
        stream: _bloc.stream,
        initialData: _bloc.value,
        builder: (
          BuildContext context,
          AsyncSnapshot<Either<ErrorItem, ConnectivityModel>> snap,
        ) {
          final Either<ErrorItem, ConnectivityModel> either =
              snap.data ?? _bloc.value;
          final ConnectivityModel m = either.isRight
              ? (either as Right<ErrorItem, ConnectivityModel>).value
              : _lastGood;
          if (either.isRight) {
            _lastGood = (either as Right<ErrorItem, ConnectivityModel>).value;
          }

          return ErrorItemWidget(
            state: either as Either<ErrorItem, Object>,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Type:  ${m.connectionType.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Speed: ${m.internetSpeed.toStringAsFixed(1)} Mbps'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () => _service
                            .simulateConnection(ConnectionTypeEnum.none),
                        child: const Text('Go Offline'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service
                            .simulateConnection(ConnectionTypeEnum.wifi),
                        child: const Text('Wi-Fi'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service
                            .simulateConnection(ConnectionTypeEnum.mobile),
                        child: const Text('Mobile'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service.simulateSpeed(
                          (((m.internetSpeed + 10).clamp(0.0, 9999.0)) as num)
                              .toDouble(),
                        ),
                        child: const Text('+10 Mbps'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service.simulateSpeed(
                          (((m.internetSpeed - 10).clamp(0.0, 9999.0)) as num)
                              .toDouble(),
                        ),
                        child: const Text('−10 Mbps'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service.startSpeedJitter(),
                        child: const Text('Start Jitter'),
                      ),
                      ElevatedButton(
                        onPressed: () => _service.stopSpeedJitter(),
                        child: const Text('Stop Jitter'),
                      ),
                      ElevatedButton(
                        onPressed: _bloc.refreshType,
                        child: const Text('Refresh Type'),
                      ),
                      ElevatedButton(
                        onPressed: _bloc.refreshSpeed,
                        child: const Text('Refresh Speed'),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          _service.simulateErrorOnCheckConnectivityOnce();
                          _bloc.refreshType();
                        },
                        child: const Text('Sim error: check type'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _service.simulateErrorOnCheckSpeedOnce();
                          _bloc.refreshSpeed();
                        },
                        child: const Text('Sim error: check speed'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _service.simulateStreamErrorOnce();
                          _service.simulateSpeed(m.internetSpeed + 1);
                        },
                        child: const Text('Sim error: stream'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===== Loading • Single + Queue (FIFO) =====

class BlocLoadingDemoPage extends StatefulWidget {
  const BlocLoadingDemoPage({super.key, this.injected});
  static const String name = 'BlocLoadingDemoPage';
  final BlocLoading? injected;

  @override
  State<BlocLoadingDemoPage> createState() => _BlocLoadingDemoPageState();
}

class _BlocLoadingDemoPageState extends State<BlocLoadingDemoPage> {
  late final BlocLoading _bloc;
  late final bool _ownsBloc;
  final List<String> _log = <String>[];

  @override
  void initState() {
    super.initState();
    if (widget.injected != null) {
      _bloc = widget.injected!;
      _ownsBloc = false;
    } else {
      _bloc = BlocLoading();
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

  Future<void> _runSingleAction() async {
    final int result = await _bloc.loadingWhile<int>(
      'Loading single action… / Cargando acción única…',
      () async {
        await Future<void>.delayed(const Duration(milliseconds: 220));
        return 42;
      },
      minShow: const Duration(milliseconds: 480),
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Single action done. Result = $result')),
    );
  }

  Future<void> _runQueuedActions() async {
    setState(() {
      _log.clear();
      _log.add('Queue started…');
    });

    final Future<int> t1 = _bloc.queueLoadingWhile<int>(
      'Step 1/3 — Preparing… / Paso 1/3 — Preparando…',
      () async {
        setState(() => _log.add('Task 1 started'));
        await Future<void>.delayed(const Duration(milliseconds: 650));
        setState(() => _log.add('Task 1 finished'));
        return 1;
      },
      minShow: const Duration(milliseconds: 160),
    );

    final Future<int> t2 = _bloc.queueLoadingWhile<int>(
      'Step 2/3 — Processing… / Paso 2/3 — Procesando…',
      () async {
        setState(() => _log.add('Task 2 started'));
        await Future<void>.delayed(const Duration(milliseconds: 180));
        setState(() => _log.add('Task 2 finished'));
        return 2;
      },
      minShow: const Duration(milliseconds: 160),
    );

    final Future<int> t3 = _bloc.queueLoadingWhile<int>(
      'Step 3/3 — Finalizing… / Paso 3/3 — Finalizando…',
      () async {
        setState(() => _log.add('Task 3 started'));
        await Future<void>.delayed(const Duration(milliseconds: 320));
        setState(() => _log.add('Task 3 finished'));
        return 3;
      },
      minShow: const Duration(milliseconds: 160),
    );

    final List<int> results = await Future.wait(<Future<int>>[t1, t2, t3]);
    if (!mounted) {
      return;
    }
    setState(() => _log.add('Queue done. Results = $results'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Queued actions completed (FIFO)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BlocLoading Demo')),
      body: Stack(
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'How this demo works / Cómo funciona esta demo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '1) Single action — `loadingWhile` con `minShow` anti-flicker.',
                      ),
                      Text(
                        '   • Si ya hay loading, no sobreescribe UI, pero ejecuta la acción igualmente.',
                      ),
                      SizedBox(height: 8),
                      Text(
                        '2) Queued actions — `queueLoadingWhile` serializa tareas (FIFO).',
                      ),
                      Text('   • Mensaje progresivo “Step 1/3”, “Step 2/3”…'),
                      Text('   • Overlay visible mientras dura la cola.'),
                      SizedBox(height: 8),
                      Text(
                        '3) Streams: `isLoadingStream` (bool) + `loadingMsgStream` (String).',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _runSingleAction,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Run single action'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _runQueuedActions,
                      icon: const Icon(Icons.queue),
                      label: const Text('Run queued actions (FIFO)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Execution log / Registro de ejecución',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_log.isEmpty)
                        const Text('No events yet / Aún no hay eventos.'),
                      if (_log.isNotEmpty)
                        ..._log.map((String e) => Text('• $e')),
                    ],
                  ),
                ),
              ),
            ],
          ),
          StreamBuilder<bool>(
            stream: _bloc.isLoadingStream,
            initialData: _bloc.isLoading,
            builder: (BuildContext context, AsyncSnapshot<bool> snap) {
              final bool active = snap.data ?? false;
              if (!active) {
                return const SizedBox.shrink();
              }
              return Positioned.fill(
                child: ColoredBox(
                  color: Colors.black54,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const CircularProgressIndicator(),
                              const SizedBox(height: 12),
                              StreamBuilder<String>(
                                stream: _bloc.loadingMsgStream,
                                initialData: _bloc.loadingMsg,
                                builder: (
                                  BuildContext context,
                                  AsyncSnapshot<String> s2,
                                ) {
                                  final String msg = s2.data ?? '';
                                  return Text(
                                    msg.isEmpty ? 'Loading…' : msg,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ===== Responsive • Grid + métricas + simulador =====

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncSize(context));

    return Scaffold(
      appBar: AppBar(
        title: const Text('BlocResponsive Demo'),
        actions: <Widget>[
          Row(
            children: <Widget>[
              const Text('Show AppBar', style: TextStyle(fontSize: 12)),
              Switch(
                value: _bloc.showAppbar,
                onChanged: (bool v) => setState(() => _bloc.showAppbar = v),
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
              Text('1) La UI sincroniza el bloc con el tamaño del viewport.'),
              Text(
                '   Usa setSizeFromContext(context) en widgets o setSize(Size) en tests.',
              ),
              SizedBox(height: 6),
              Text(
                '2) Calcula device type, margins, gutters, columns y work area según config.',
              ),
              Text(
                '3) La vista previa dibuja columnas + gutters respetando márgenes.',
              ),
              SizedBox(height: 12),
              Text('Clean Architecture: UI → AppManager → BlocResponsive'),
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
                  divisions: 224,
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
    const double previewHeight = 180;
    final List<Widget> rowChildren = <Widget>[];
    for (int i = 0; i < cols; i++) {
      rowChildren.add(
        Container(
          width: columnWidth,
          height: previewHeight,
          decoration: BoxDecoration(
            color: Colors.blueGrey.withValues(alpha: .25),
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
            Container(
              width: workArea.width + margin * 2,
              constraints: const BoxConstraints(minHeight: previewHeight + 24),
              decoration: BoxDecoration(
                color: Colors.black12.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: margin),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
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
