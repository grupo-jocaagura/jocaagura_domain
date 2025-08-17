import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// Demo page for `BlocOnboarding` with async `onEnter` returning `Either<ErrorItem, Unit>`.
///
/// ─────────────────────────────────────────────────────────────────────────────
/// PURPOSE / PROPÓSITO
/// - Orquestar un flujo de onboarding por pasos, donde cada paso puede ejecutar
///   un side-effect asíncrono (p.ej., pedir permisos, cargar configuración,
///   migraciones locales, fetch remoto inicial, aceptar Términos, etc.).
/// - `onEnter` devuelve Either:
///     • Right(Unit) → éxito; se **agenda** auto-avance si el paso lo define.
///     • Left(ErrorItem) → error de negocio; el flujo se **detiene** en el paso
///       y expone `state.error` para que la UI decida (retry/back/skip).
/// - Si `onEnter` **lanza** una excepción, `ErrorMapper.fromException` la
///   traduce a `ErrorItem` y el flujo se detiene en el paso (sin auto-avance).
///
/// ─────────────────────────────────────────────────────────────────────────────
/// ARCHITECTURE / ARQUITECTURA
/// UI → AppManager → BlocOnboarding → (use cases invocados dentro de onEnter)
/// *El BLoC no mapea dominio ni consume servicios directamente; solo orquesta.*
///
/// ─────────────────────────────────────────────────────────────────────────────
/// COMMON USE CASES / CASOS DE USO
/// 1) Permissions gate: solicitar permisos y continuar solo si son otorgados.
/// 2) Warm-up: precargar Remote Config / Feature Flags / tokens efímeros.
/// 3) Data seed/migrations: inicializar BD local o migrar esquemas.
/// 4) Legal gates: EULA/Privacy/Consent con persistencia y verificación.
/// 5) First-run checks: conectividad mínima, versión soportada, etc.
///
/// ─────────────────────────────────────────────────────────────────────────────
/// ERROR HANDLING / MANEJO DE ERRORES
/// - En fallos **esperados**: devuelve `Left(ErrorItem)` desde `onEnter`.
/// - En fallos **inesperados**: deja que lance → el BLoC usa `ErrorMapper`.
/// - La UI puede: mostrar el error, ofrecer `Retry onEnter`, `Back`, `Skip`.
/// - `retryOnEnter()` no cambia índice; limpia `state.error` y reejecuta el
///   `onEnter` del paso actual. Útil tras resolver la causa (p.ej., usuario
///   habilitó permisos en ajustes, restauró red, etc.).
///
/// ─────────────────────────────────────────────────────────────────────────────
/// TESTING TIPS
/// - Usa delays cortos (20-100ms) para comprobar auto-avance.
/// - Valida: Right → avanza; Left → no avanza + error; throw → mapeado.
/// - Prueba `retryOnEnter()` y navegación `back/next` cancelando timers.
///
/// ─────────────────────────────────────────────────────────────────────────────
class BlocOnboardingDemoPage extends StatefulWidget {
  const BlocOnboardingDemoPage({super.key, this.injected});
  static const String name = 'BlocOnboardingDemoPage';

  /// Optional injection of an existing BlocOnboarding (managed upstream).
  final BlocOnboarding? injected;

  @override
  State<BlocOnboardingDemoPage> createState() => _BlocOnboardingDemoPageState();
}

class _BlocOnboardingDemoPageState extends State<BlocOnboardingDemoPage> {
  late final BlocOnboarding _bloc;
  late final bool _ownsBloc;
  StreamSubscription<OnboardingState>? _sub;

  // Log en pantalla para visualizar el orden de eventos y estados.
  final List<String> _log = <String>[];

  // Simuladores:
  bool _failStep2AsLeft = false; // devuelve Left(ErrorItem) en paso 2
  bool _throwStep2 = false; // lanza excepción en paso 2 (ErrorMapper)

  // Helper para registrar mensajes en la UI.
  void _logMsg(String msg) {
    if (!mounted) {
      return;
    }
    setState(() => _log.add(msg));
  }

  @override
  void initState() {
    super.initState();
    // Preferido: inyectar desde AppManager. Si no hay, se crea localmente
    // (usando DefaultErrorMapper).
    _bloc = widget.injected ?? BlocOnboarding();
    _ownsBloc = widget.injected == null;

    _configureSteps();

    // Escucha del estado para feedback y para loguear transiciones.
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

  /// Define los pasos del onboarding. Reinvocar esta función cuando cambien
  /// flags de simulación para que los closures capturen el nuevo estado.
  void _configureSteps() {
    _bloc.configure(<OnboardingStep>[
      // STEP 1 — Welcome (Right + auto-advance)
      OnboardingStep(
        title: 'Welcome',
        description: 'Short tour starts here',
        onEnter: () async {
          _logMsg('onEnter: Welcome (step 1)');
          await Future<void>.delayed(const Duration(milliseconds: 120));
          return Right<ErrorItem, Unit>(
            Unit.value,
          ); // éxito → permitirá auto-avance
        },
        autoAdvanceAfter: const Duration(milliseconds: 900),
      ),

      // STEP 2 — Permissions (Left o throw según toggles)
      OnboardingStep(
        title: 'Permissions',
        description: 'Request minimal permissions',
        onEnter: () async {
          _logMsg('onEnter: Permissions (step 2)');
          await Future<void>.delayed(const Duration(milliseconds: 120));

          if (_throwStep2) {
            // Fallo inesperado → será mapeado por ErrorMapper
            throw StateError('Simulated thrown exception in step 2');
          }

          if (_failStep2AsLeft) {
            // Fallo esperado de negocio (no lanzar)
            return Left<ErrorItem, Unit>(
              const ErrorItem(
                title: 'Permissions required',
                code: 'PERM_DENIED',
                description: 'User denied permissions (simulated Left)',
                meta: <String, dynamic>{'source': 'demo'},
              ),
            );
          }

          return Right<ErrorItem, Unit>(Unit.value); // éxito
        },
        autoAdvanceAfter: const Duration(milliseconds: 900),
      ),

      // STEP 3 — Finish (Right sin auto-advance)
      OnboardingStep(
        title: 'Finish',
        description: 'You are all set',
        onEnter: () async {
          _logMsg('onEnter: Finish (step 3)');
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return Right<ErrorItem, Unit>(Unit.value);
        },
        // sin auto-avance: el usuario decide finalizar/omitir
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

              // Simuladores de fallo en paso 2
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
                        title: const Text(
                          'Throw in step 2 (mapped by ErrorMapper)',
                        ),
                        value: _throwStep2,
                        onChanged: (bool v) {
                          setState(() => _throwStep2 = v);
                          _configureSteps();
                        },
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tip: Enciende uno u otro (no ambos) para ver la diferencia entre Left(ErrorItem) '
                        'y una excepción mapeada por ErrorMapper.',
                        style: TextStyle(fontSize: 12),
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
                onClearError: () => _bloc.clearError(), // helper explícito
              ),

              const SizedBox(height: 12),

              // Panel de error (podrías cambiar por tu ErrorItemWidget si ya lo tienes)
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

/// Card con una explicación introductoria y reglas clave.
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
                '• Each step defines an optional `onEnter` side-effect returning `Either<ErrorItem, Unit>`.',
              ),
              Text(
                '• On Right(Unit): the step may auto-advance after its configured delay.',
              ),
              Text(
                '• On Left(ErrorItem): the flow stays on the current step and exposes `state.error`.',
              ),
              Text(
                '• If `onEnter` throws: `ErrorMapper.fromException` maps the exception to `ErrorItem`.',
              ),
              SizedBox(height: 12),
              Text(
                'Commands / Comandos',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'start(), next(), back(), skip(), complete(), retryOnEnter(), clearError()',
              ),
              SizedBox(height: 12),
              Text(
                'Concurrency / Concurrencia',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Solo hay un timer de auto-avance activo. Cualquier comando cancela el timer en curso.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card con casos de uso y patrones recomendados.
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
                'Use cases & patterns / Casos de uso y patrones',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                '• Permissions gate: ejecuta un caso de uso que solicite permisos; si el usuario niega → Left(ErrorItem); si acepta → Right(Unit).',
              ),
              Text(
                '• Warm-up (Remote Config / Flags): lee flags; en failure controlado → Left(ErrorItem) y ofrece retry.',
              ),
              Text(
                '• Migrations / Seed: corre migraciones locales; en error controlado → Left; en error inesperado → throw (ErrorMapper).',
              ),
              Text(
                '• Legal gates (EULA/Privacy): si el usuario no acepta → Left(ErrorItem).',
              ),
              Text(
                '• First-run network check: si no hay red mínima → Left para que la UI guíe al usuario.',
              ),
              SizedBox(height: 12),
              Text('UI tips', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '• Usa `retryOnEnter()` tras corregir la causa (p.ej., habilitar permisos).',
              ),
              Text('• Considera exponer botones Back/Skip según tu UX.'),
              Text(
                '• Puedes reemplazar el panel de error por tu `ErrorItemWidget` si ya lo tienes.',
              ),
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
                const Text(
                  'Note: auto-advance occurs only after a successful onEnter (Right(Unit)).',
                ),
              ] else
                const Text('No active step'),
            ],
          ),
        ),
      ),
    );
  }
}
