import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  runApp(const MyApp());
}

/// Demo didáctico:
/// - Pasos con auto-advance (Bienvenida, Explicación)
/// - Paso manual de input (Ingresa el lado)
/// - Paso de Validación con onEnter que puede fallar (Left(ErrorItem))
/// - Resultado y paso Final con "Ver de nuevo"
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onboarding Square Area (con validación)',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const OnboardingSquareAreaValidationPage(),
    );
  }
}

class OnboardingSquareAreaValidationPage extends StatefulWidget {
  const OnboardingSquareAreaValidationPage({super.key});

  @override
  State<OnboardingSquareAreaValidationPage> createState() =>
      _OnboardingSquareAreaValidationPageState();
}

class _OnboardingSquareAreaValidationPageState
    extends State<OnboardingSquareAreaValidationPage> {
  late final BlocOnboarding bloc;

  // Guardamos el lado ingresado en estado local de UI
  double? side;

  // Controlador para no recrearse en cada build
  final TextEditingController sideController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bloc = BlocOnboarding();
    _configureSteps();
    bloc.start();
  }

  @override
  void dispose() {
    sideController.dispose();
    bloc.dispose();
    super.dispose();
  }

  // Configura los pasos del onboarding
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
        autoAdvanceAfter: Duration(milliseconds: 2000),
      ),
      OnboardingStep(
        title: 'Ingresa el lado',
        description:
            'Ingresa un número mayor que 0 y como máximo 100, luego confirma.',
        onEnter: () async => Right<ErrorItem, Unit>(Unit.value),
      ),
      OnboardingStep(
        title: 'Validación',
        description:
            'Validamos tu valor. Si hay un error, te lo mostramos aquí.',
        // onEnter valida el valor actual de `side` (capturado desde el State)
        onEnter: () async {
          final double? s = side;
          // Reglas intencionalmente estrictas para demostrar manejo de errores:
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
          // Éxito → Right
          return Right<ErrorItem, Unit>(Unit.value);
        },
        // Si la validación fue exitosa, auto-avanzamos a "Resultado"
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
        builder:
            (BuildContext context, AsyncSnapshot<OnboardingState> snapshot) {
          final OnboardingState state = snapshot.data!;
          final OnboardingStep? step = bloc.currentStep;

          if (step == null) {
            return const Center(child: Text('No hay pasos configurados.'));
          }

          // Banner de error si existe
          final Widget errorBanner = _buildErrorBannerIfAny(state);

          // Ramas de contenido por paso
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

  // =======================
  // Secciones de UI por paso
  // =======================

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
            // Si no hay auto-advance, ofrecemos botón manual de "Siguiente"
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
                'Ingresa el lado del cuadrado (0 < lado ≤ 100):',
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
                        const SnackBar(
                          content: Text('Se limpió el valor ingresado.'),
                        ),
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
    // En este paso, onEnter ya corrió: si hubo error, state.error != null
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
                    ? 'Encontramos un problema con el valor ingresado.'
                    : '¡Todo correcto! Avanzaremos automáticamente.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  // Si hay error: permitir corregir (back) o reintentar (retryOnEnter)
                  if (hasError)
                    ElevatedButton.icon(
                      onPressed: () {
                        // Volver al input para corregir
                        bloc.back();
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Corregir'),
                    ),
                  if (hasError)
                    OutlinedButton.icon(
                      onPressed: () {
                        // Si ya corregiste el valor (por ejemplo volviste, cambiaste y regresaste),
                        // puedes reintentar la validación
                        bloc.retryOnEnter();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar validación'),
                    ),
                  // Si NO hay error, no mostramos botón: auto-advance se encargará
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
                  // Reiniciar el flujo: limpiamos lado y reconfiguramos
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

  // =======================
  // Helpers de UI
  // =======================

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
        TextButton(
          onPressed: bloc.clearError,
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
