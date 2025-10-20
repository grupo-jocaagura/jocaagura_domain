import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() => runApp(const JgEducationDemoApp());

class JgEducationDemoApp extends StatelessWidget {
  const JgEducationDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jocaagura Education Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const AssessmentChooserPage(),
    );
  }
}

// -----------------------------------------------------------------------------
// Selector de evaluación
// -----------------------------------------------------------------------------

class AssessmentChooserPage extends StatelessWidget {
  const AssessmentChooserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ModelAssessment math = _buildMathAssessment();
    final ModelAssessment art = _buildDigitalArtAssessmentAdvanced();

    return Scaffold(
      appBar: AppBar(title: const Text('Elige una evaluación')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            _AssessmentCard(
              title: math.title,
              subtitle: 'Preguntas: ${math.items.length} • '
                  'Tiempo: ${math.timeLimit == Duration.zero ? 'sin límite' : '${math.timeLimit.inMinutes} min'} • '
                  'Aprobación: ${math.passScore}%',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AssessmentHome(assessment: math),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _AssessmentCard(
              title: art.title,
              subtitle: 'Preguntas: ${art.items.length} • '
                  'Tiempo: ${art.timeLimit.inMinutes} min • '
                  'Aprobación: ${art.passScore}%',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AssessmentHome(assessment: art),
                ),
              ),
            ),
            const Spacer(),
            const _HelperNote(),
          ],
        ),
      ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              const Icon(Icons.quiz, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelperNote extends StatelessWidget {
  const _HelperNote();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'Tip: Este demo usa los modelos existentes de jocaagura_domain.\n'
          'Para producción, conéctalo a UseCases/BLoCs y persistencia.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Dataset #1 — Matemáticas (3°) — 5 sumas/restas
// -----------------------------------------------------------------------------

ModelAssessment _buildMathAssessment() {
  const ModelCompetencyStandard std = ModelCompetencyStandard(
    id: 'STD-MATH-OPS-3',
    label: 'Resuelve operaciones básicas de suma y resta (3°)',
    area: ModelCategory(category: 'math', description: 'Matemáticas'),
    cineLevel: 1,
    code: 'MATH.OPS.L1',
  );

  const ModelLearningGoal goal = ModelLearningGoal(
    id: 'GOAL-MATH-OPS-3',
    standard: std,
    label: 'Aplica sumas y restas con números pequeños.',
    code: 'MATH.OPS.GOAL.3',
  );

  const ModelPerformanceIndicator indicator = ModelPerformanceIndicator(
    id: 'PI-ACCURACY',
    modelLearningGoal: goal,
    label: 'Selecciona respuestas correctas con consistencia.',
    level: PerformanceLevel.basic,
    code: 'MATH.OPS.PI.1',
  );

  ModelLearningItem q({
    required String id,
    required String label,
    required String correct,
    required String w1,
    required String w2,
    required String w3,
  }) {
    return ModelLearningItem(
      id: id,
      label: label,
      correctAnswer: correct,
      wrongAnswerOne: w1,
      wrongAnswerTwo: w2,
      wrongAnswerThree: w3,
      explanation: '',
      attributes: const <ModelAttribute<dynamic>>[],
      achievementOne: indicator,
      estimatedTimeForAnswer: const Duration(minutes: 1),
      category:
          const ModelCategory(category: 'math', description: 'Matemáticas'),
      cineLevel: 1,
    );
  }

  final List<ModelLearningItem> items = <ModelLearningItem>[
    q(id: 'Q1', label: '2 + 3 = ?', correct: '5', w1: '4', w2: '6', w3: '7'),
    q(id: 'Q2', label: '7 - 4 = ?', correct: '3', w1: '2', w2: '4', w3: '1'),
    q(id: 'Q3', label: '5 + 6 = ?', correct: '11', w1: '10', w2: '12', w3: '9'),
    q(id: 'Q4', label: '9 - 5 = ?', correct: '4', w1: '3', w2: '5', w3: '6'),
    q(
      id: 'Q5',
      label: '8 + 7 = ?',
      correct: '15',
      w1: '14',
      w2: '16',
      w3: '13',
    ),
  ];

  return ModelAssessment(
    id: 'ASMT-MATH-3RD-OPS',
    title: 'Matemáticas 3° — Sumas y Restas',
    items: items,
    shuffleItems: true,
    shuffleOptions: true,
    timeLimit: const Duration(minutes: 10),
    passScore: 60,
  );
}

// -----------------------------------------------------------------------------
// Dataset #2 — Arte Digital (Avanzado) — 10 preguntas, 5 minutos
// -----------------------------------------------------------------------------

ModelAssessment _buildDigitalArtAssessmentAdvanced() {
  const ModelCompetencyStandard std = ModelCompetencyStandard(
    id: 'STD-ART-DIG-ADV',
    label:
        'Domina conceptos avanzados de arte digital y gráficos por computadora',
    area: ModelCategory(category: 'art', description: 'Arte Digital'),
    cineLevel: 3,
    code: 'ART.DIG.ADV',
  );

  const ModelLearningGoal goal = ModelLearningGoal(
    id: 'GOAL-ART-DIG-ADV',
    standard: std,
    label: 'Aplica conocimientos avanzados en flujos de arte digital.',
    code: 'ART.DIG.GOAL.ADV',
  );

  const ModelPerformanceIndicator indicator = ModelPerformanceIndicator(
    id: 'PI-ADV-MASTERY',
    modelLearningGoal: goal,
    label: 'Domina terminología y decisiones técnicas correctas.',
    level: PerformanceLevel.high,
    code: 'ART.DIG.PI.MASTERY',
  );

  ModelLearningItem q({
    required String id,
    required String label,
    required String correct,
    required String w1,
    required String w2,
    required String w3,
  }) {
    return ModelLearningItem(
      id: id,
      label: label,
      correctAnswer: correct,
      wrongAnswerOne: w1,
      wrongAnswerTwo: w2,
      wrongAnswerThree: w3,
      explanation: '',
      attributes: const <ModelAttribute<dynamic>>[],
      achievementOne: indicator,
      estimatedTimeForAnswer: const Duration(seconds: 20),
      category:
          const ModelCategory(category: 'art', description: 'Arte Digital'),
      cineLevel: 3,
    );
  }

  final List<ModelLearningItem> items = <ModelLearningItem>[
    q(
      id: 'A1',
      label: '¿Ventaja clave del vector frente al raster?',
      correct: 'Escala sin pérdida',
      w1: 'Mejor fotos',
      w2: 'Más bits de color',
      w3: 'Anti-aliasing automático',
    ),
    q(
      id: 'A2',
      label: 'Lienzo 300 DPI y 3000 px de alto ≈ ¿cuántas pulgadas?',
      correct: '10 pulgadas',
      w1: '5',
      w2: '15',
      w3: '30',
    ),
    q(
      id: 'A3',
      label: 'Modo de fusión que aclara sin afectar sombras:',
      correct: 'Trama (Screen)',
      w1: 'Multiplicar',
      w2: 'Superponer',
      w3: 'Luz dura',
    ),
    q(
      id: 'A4',
      label: 'Espacio de color adecuado para offset:',
      correct: 'CMYK',
      w1: 'RGB',
      w2: 'HSV',
      w3: 'LAB solo',
    ),
    q(
      id: 'A5',
      label: 'Anti-aliasing:',
      correct: 'Suaviza bordes dentados',
      w1: 'Sube saturación',
      w2: 'BN automático',
      w3: 'Duplica resolución',
    ),
    q(
      id: 'A6',
      label: 'Curva Bézier cúbica:',
      correct: '2 controles + 2 extremos',
      w1: '1 control + 1 extremo',
      w2: '4 extremos',
      w3: '3 controles + 1 extremo',
    ),
    q(
      id: 'A7',
      label: 'Alpha premultiplicado:',
      correct: 'Colores ya multiplicados por alpha',
      w1: 'Alpha separado',
      w2: 'Sin transparencia',
      w3: 'Sin corrección gamma',
    ),
    q(
      id: 'A8',
      label: '¿Cuál NO es ventaja de capas de ajuste?',
      correct: 'Duplican píxeles y pesan más',
      w1: 'No destructivas',
      w2: 'Reordenables y enmascarables',
      w3: 'Cambios globales rápidos',
    ),
    q(
      id: 'A9',
      label: '“Resolución independiente” se asocia con:',
      correct: 'Vectorial',
      w1: 'Raster 8-bit',
      w2: 'Bitmap escalado',
      w3: 'Spritesheet baja res',
    ),
    q(
      id: 'A10',
      label: 'En PBR, mapa que controla especular directo:',
      correct: 'Rugosidad (Roughness)',
      w1: 'Albedo',
      w2: 'Normal',
      w3: 'Altura',
    ),
  ];

  return ModelAssessment(
    id: 'ASMT-ART-DIG-ADV',
    title: 'Arte Digital (Avanzado) — Conceptos Clave',
    items: items,
    shuffleItems: true,
    shuffleOptions: true,
    timeLimit: const Duration(minutes: 5),
    // límite solicitado
    passScore: 70,
  );
}

// -----------------------------------------------------------------------------
// Home por evaluación (snapshot + botón iniciar)
// -----------------------------------------------------------------------------

class AssessmentHome extends StatelessWidget {
  const AssessmentHome({required this.assessment, super.key});

  final ModelAssessment assessment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(assessment.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              assessment.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Preguntas: ${assessment.items.length} • '
                'Tiempo: ${assessment.timeLimit == Duration.zero ? 'sin límite' : '${assessment.timeLimit.inMinutes} min'} • '
                'Aprobación: ${assessment.passScore}%'),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: double.maxFinite,
                    height: 250.0,
                    child: Text(
                      'JSON (enum.name estable):\n${assessment.toJson()}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar evaluación'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          AssessmentRunnerPage(assessment: assessment),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Runner + Resultado (mínimo, sin forzar temporizador; solo informativo)
// -----------------------------------------------------------------------------

class AssessmentRunnerPage extends StatefulWidget {
  const AssessmentRunnerPage({required this.assessment, super.key});
  final ModelAssessment assessment;

  @override
  State<AssessmentRunnerPage> createState() => _AssessmentRunnerPageState();
}

class _AssessmentRunnerPageState extends State<AssessmentRunnerPage> {
  late final List<ItemInstance> _instances;
  int _index = 0;
  final Map<String, String> _answers = <String, String>{};

  @override
  void initState() {
    super.initState();
    _instances = _createInstances(widget.assessment);
  }

  List<ItemInstance> _createInstances(ModelAssessment a) {
    final List<ModelLearningItem> items = List<ModelLearningItem>.from(a.items);
    if (a.shuffleItems) {
      items.shuffle(Random(a.id.hashCode));
    }
    return items.map((ModelLearningItem it) {
      final int seed = it.id.hashCode;
      final List<String> opts = it.optionsShuffled(seed);
      return ItemInstance(item: it, options: opts);
    }).toList(growable: false);
  }

  void _choose(String itemId, String option) {
    setState(() {
      _answers[itemId] = option;
    });
  }

  void _nextOrFinish() {
    if (_index + 1 < _instances.length) {
      setState(() => _index++);
    } else {
      final Result r = _computeResult();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => AssessmentResultPage(
            assessment: widget.assessment,
            instances: _instances,
            answers: _answers,
            result: r,
          ),
        ),
      );
    }
  }

  Result _computeResult() {
    int correct = 0;
    for (final ItemInstance inst in _instances) {
      final String? chosen = _answers[inst.item.id];
      if (chosen != null && chosen == inst.item.correctAnswer) {
        correct++;
      }
    }
    final int total = _instances.length;
    final int percent = ((correct / total) * 100).round();
    final bool passed = percent >= widget.assessment.passScore;
    return Result(
      correct: correct,
      total: total,
      percent: percent,
      passed: passed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ItemInstance instance = _instances[_index];
    final String? chosen = _answers[instance.item.id];

    return Scaffold(
      appBar: AppBar(title: Text(widget.assessment.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            LinearProgressIndicator(value: (_index + 1) / _instances.length),
            const SizedBox(height: 12),
            Text(
              'Pregunta ${_index + 1} de ${_instances.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (widget.assessment.timeLimit != Duration.zero) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                'Tiempo límite: ${widget.assessment.timeLimit.inMinutes} min (informativo)',
                style: const TextStyle(fontSize: 12),
              ),
            ],
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  instance.item.label,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...instance.options.map((String opt) {
              final bool isSelected = chosen == opt;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  title: Text(opt),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () => _choose(instance.item.id, opt),
                ),
              );
            }),
            const Spacer(),
            Row(
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed:
                      _index == 0 ? null : () => setState(() => _index--),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Atrás'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: chosen == null ? null : _nextOrFinish,
                  icon: Icon(
                    _index + 1 < _instances.length
                        ? Icons.arrow_forward
                        : Icons.flag,
                  ),
                  label: Text(
                    _index + 1 < _instances.length ? 'Siguiente' : 'Finalizar',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ItemInstance {
  const ItemInstance({required this.item, required this.options});
  final ModelLearningItem item;
  final List<String> options;
}

class Result {
  const Result({
    required this.correct,
    required this.total,
    required this.percent,
    required this.passed,
  });
  final int correct;
  final int total;
  final int percent;
  final bool passed;
}

class AssessmentResultPage extends StatelessWidget {
  const AssessmentResultPage({
    required this.assessment,
    required this.instances,
    required this.answers,
    required this.result,
    super.key,
  });

  final ModelAssessment assessment;
  final List<ItemInstance> instances;
  final Map<String, String> answers;
  final Result result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  result.passed ? Icons.verified : Icons.error_outline,
                  size: 32,
                  color: result.passed
                      ? Colors.green
                      : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  result.passed ? 'Aprobado' : 'No aprobado',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Text('${result.percent}%  (${result.correct}/${result.total})'),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: instances.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, int i) {
                  final ItemInstance inst = instances[i];
                  final String? chosen = answers[inst.item.id];
                  final bool isRight = chosen == inst.item.correctAnswer;
                  return ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text(inst.item.label),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 4),
                        Text('Tu respuesta: ${chosen ?? '-'}'),
                        Text('Respuesta correcta: ${inst.item.correctAnswer}'),
                        if (inst.item.explanation.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 8),
                          Text('Explicación: ${inst.item.explanation}'),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Meta: ${inst.item.achievementOne.modelLearningGoal.label} '
                          '• Estándar: ${inst.item.achievementOne.modelLearningGoal.standard.code}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      isRight ? Icons.check_circle : Icons.cancel,
                      color: isRight
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          AssessmentRunnerPage(assessment: assessment),
                    ),
                  ),
                  icon: const Icon(Icons.replay),
                  label: const Text('Reintentar'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context)
                      .popUntil((Route<dynamic> r) => r.isFirst),
                  icon: const Icon(Icons.home),
                  label: const Text('Inicio'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
