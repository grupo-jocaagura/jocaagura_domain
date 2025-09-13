import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() => runApp(const RiceRecipeApp());

class RiceRecipeApp extends StatelessWidget {
  const RiceRecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receta de arroz blanco',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const RiceOnboardingPage(),
    );
  }
}

/// Tutorial de arroz blanco con auto-advance + navegación manual.
class RiceOnboardingPage extends StatefulWidget {
  const RiceOnboardingPage({super.key});

  @override
  State<RiceOnboardingPage> createState() => _RiceOnboardingPageState();
}

class _RiceOnboardingPageState extends State<RiceOnboardingPage> {
  late final BlocOnboarding bloc;

  // dato que captura la UI y lee el onEnter de "Validación"
  int? servings;
  final TextEditingController servingsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    bloc = BlocOnboarding();
    _configureSteps();
    bloc.start();
  }

  @override
  void dispose() {
    servingsCtrl.dispose();
    bloc.dispose();
    super.dispose();
  }

  void _configureSteps() {
    bloc.configure(<OnboardingStep>[
      const OnboardingStep(
        title: 'Bienvenida',
        description:
            'Prepararemos arroz blanco paso a paso. Puedes avanzar/volver cuando quieras.',
        autoAdvanceAfter: Duration(milliseconds: 1600),
      ),
      const OnboardingStep(
        title: 'Sobre la receta',
        description:
            'Regla base: ~½ taza de arroz crudo por persona. Agua ~2× el volumen de arroz.',
        autoAdvanceAfter: Duration(milliseconds: 2200),
      ),
      OnboardingStep(
        title: '¿Para cuántas personas?',
        description: 'Ingresa un número entre 1 y 20 y confirma.',
        onEnter: () async => Right<ErrorItem, Unit>(Unit.value),
      ),
      OnboardingStep(
        title: 'Validación de porciones',
        description: 'Verificamos que el número sea válido.',
        onEnter: () async {
          final int? n = servings;
          if (n == null) {
            return Left<ErrorItem, Unit>(
              const ErrorItem(
                title: 'Dato faltante',
                code: 'ERR_NO_SERVINGS',
                description: 'Debes ingresar el número de personas.',
                errorLevel: ErrorLevelEnum.warning,
              ),
            );
          }
          if (n < 1 || n > 20) {
            return Left<ErrorItem, Unit>(
              const ErrorItem(
                title: 'Valor inválido',
                code: 'ERR_RANGE',
                description: 'El número debe estar entre 1 y 20.',
                errorLevel: ErrorLevelEnum.warning,
              ),
            );
          }
          return Right<ErrorItem, Unit>(Unit.value);
        },
        // si es Right, avanza solo
        autoAdvanceAfter: const Duration(milliseconds: 900),
      ),
      OnboardingStep(
        title: 'Ingredientes',
        description: 'Cantidades ajustadas a tus porciones.',
        onEnter: () async => Right<ErrorItem, Unit>(Unit.value),
      ),
      const OnboardingStep(
        title: 'Cocción',
        description:
            'Enjuaga el arroz, sofríe opcionalmente, agrega agua y sal, hierve, baja fuego y tapa 15–18 min.',
        autoAdvanceAfter: Duration(milliseconds: 2000),
      ),
      const OnboardingStep(
        title: 'Listo',
        description: '¡A disfrutar! Puedes ver el tutorial otra vez.',
      ),
    ]);
  }

  // ===== helpers de cálculo (proporciones simples y didácticas) =====
  double _cupsRicePerPerson() => 0.5; // taza por persona
  double _cupsWaterPerCupRice() => 2.0;

  double _tspSaltPerCupRice() => 0.25; // cucharadita
  double _tbspOilPerCupRice() => 0.5; // cucharada

  Map<String, String> _scaledIngredients(int people) {
    final double cupsRice = people * _cupsRicePerPerson();
    final double cupsWater = cupsRice * _cupsWaterPerCupRice();
    final double tspSalt = cupsRice * _tspSaltPerCupRice();
    final double tbspOil = cupsRice * _tbspOilPerCupRice();
    String f(double v) => v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);

    return <String, String>{
      'Arroz': '${f(cupsRice)} tazas',
      'Agua': '${f(cupsWater)} tazas',
      'Sal': '${f(tspSalt)} cditas',
      'Aceite (opcional)': '${f(tbspOil)} cdas',
    };
  }

  // ========================== UI ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arroz blanco – Onboarding'),
        actions: <Widget>[
          // indicador de paso
          StreamBuilder<OnboardingState>(
            stream: bloc.stateStream,
            initialData: bloc.state,
            builder: (_, AsyncSnapshot<OnboardingState> snap) {
              final OnboardingState s = snap.data!;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Text('Paso ${s.stepNumber}/${s.totalSteps}'),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<OnboardingState>(
        stream: bloc.stateStream,
        initialData: bloc.state,
        builder:
            (BuildContext context, AsyncSnapshot<OnboardingState> snapshot) {
          final OnboardingState state = snapshot.data!;
          final OnboardingStep? step = bloc.currentStep;

          if (step == null) {
            return const Center(child: Text('Sin pasos configurados.'));
          }

          final Widget errorBanner = _buildErrorBannerIfAny(state);

          Widget content;
          switch (step.title) {
            case '¿Para cuántas personas?':
              content = _buildServingsStep(state);
              break;
            case 'Validación de porciones':
              content = _buildValidationStep(state);
              break;
            case 'Ingredientes':
              content = _buildIngredientsStep(state);
              break;
            case 'Cocción':
              content = _buildSimpleTextStep(step);
              break;
            case 'Listo':
              content = _buildFinalStep(step);
              break;
            default:
              content = _buildSimpleTextStep(step);
          }

          return Column(
            children: <Widget>[
              if (errorBanner != const SizedBox.shrink()) errorBanner,
              Expanded(child: content),
              _buildNavBar(state),
            ],
          );
        },
      ),
    );
  }

  // ------- barras / secciones -------
  Widget _buildNavBar(OnboardingState state) {
    final bool canBack =
        state.status == OnboardingStatus.running && state.stepIndex > 0;
    final bool canNext = state.status == OnboardingStatus.running;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Row(
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: canBack ? () => bloc.back() : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Atrás'),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: canNext ? () => bloc.next() : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Siguiente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTextStep(OnboardingStep step) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
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
              const SizedBox(height: 8),
              if (step.autoAdvanceAfter != null)
                const Text(
                  'Avance automático activado…',
                  style: TextStyle(fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServingsStep(OnboardingState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '¿Para cuántas personas?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: servingsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Entre 1 y 20',
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  final int? n = int.tryParse(servingsCtrl.text.trim());
                  if (n == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ingresa un número válido.'),
                      ),
                    );
                    return;
                  }
                  setState(() => servings = n);
                  bloc.next(); // va a "Validación de porciones"
                },
                icon: const Icon(Icons.check),
                label: const Text('Confirmar'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tip: luego puedes usar Atrás/Siguiente además del auto-avance.',
                style: TextStyle(fontSize: 12),
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
        padding: const EdgeInsets.all(20),
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
                    ? 'Hubo un problema con el número de personas.'
                    : '¡Todo correcto! Avanzaremos automáticamente.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (hasError)
                Wrap(
                  spacing: 12,
                  children: <Widget>[
                    ElevatedButton.icon(
                      onPressed: () {
                        bloc.clearError();
                        bloc.back(); // vuelve a ingresar
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Corregir'),
                    ),
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

  Widget _buildIngredientsStep(OnboardingState state) {
    final int n = servings ?? 0;
    final Map<String, String> map =
        n > 0 ? _scaledIngredients(n) : <String, String>{};

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Ingredientes',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Para $n persona${n == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (map.isEmpty) const Text('—'),
              if (map.isNotEmpty)
                ...map.entries.map(
                  (MapEntry<String, String> e) => ListTile(
                    dense: true,
                    title: Text(e.key),
                    trailing: Text(e.value),
                  ),
                ),
              const SizedBox(height: 8),
              const Text(
                'Puedes continuar con Siguiente o esperar auto-avance en pasos informativos.',
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
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
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
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  servings = null;
                  servingsCtrl.clear();
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

  // ------- banner de error -------
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
