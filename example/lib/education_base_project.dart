// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
// *****************************************************************************
// * Jocaagura — Education Assessment Demo (Using jocaagura_domain models)
// *
// * This single-file Flutter app demonstrates how to BUILD and RUN an assessment
// * using the education models that ALREADY exist in `jocaagura_domain`:
// *   - ModelAssessment
// *   - ModelLearningItem
// *   - ModelLearningGoal
// *   - ModelPerformanceIndicator
// *   - ModelCompetencyStandard
// *   - PerformanceLevel (enum)
// *   - ModelCategory
// *
// * Scenario
// * - 5 basic math questions (add/subtract) for ~3rd grade.
// * - Items/options can be shuffled, progress is shown, result + review screen.
// *
// * How to run
// * 1) Place this file as `lib/main.dart` in a Flutter app that depends on
// *    `jocaagura_domain` (your local package or from source).
// * 2) `flutter run`
// *
// * Clean Architecture alignment (Jocaagura style)
// * UI → AppManager → Bloc → UseCase → Repository → Gateway → Service
// * In this small demo we focus on UI + Domain models only. For production,
// * plug these models into your UseCases/BLoCs and persistence layers.
// *****************************************************************************

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() => runApp(const JgEducationDemoApp());

// -----------------------------------------------------------------------------
// App Shell
// -----------------------------------------------------------------------------

/// Top-level app that wires a fixed [ModelAssessment] into a playable flow.
class JgEducationDemoApp extends StatelessWidget {
  const JgEducationDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jocaagura Education Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: AssessmentHome(assessment: _buildMathAssessment()),
    );
  }
}

// -----------------------------------------------------------------------------
// Dataset (uses jocaagura_domain models exactly as defined in your library)
// -----------------------------------------------------------------------------

/// Creates a 3rd-grade friendly math assessment (sums & subtracts).
///
/// Implementation notes:
/// - Uses `ModelLearningItem.optionsShuffled([seed])` for deterministic shuffles.
/// - Each item references a shared [ModelLearningGoal] and [ModelPerformanceIndicator].
/// - `passScore` is 60.
ModelAssessment _buildMathAssessment() {
  // MEN-aligned competency (example; adjust to your mapping as needed).
  final ModelCompetencyStandard std = ModelCompetencyStandard(
    id: 'STD-MATH-OPS-3',
    label: 'Resuelve operaciones básicas de suma y resta (3°)',
    area: const ModelCategory(category: 'math', description: 'Matemáticas'),
    cineLevel: 1,
    code: 'MATH.OPS.L1',
  );

  final ModelLearningGoal goal = ModelLearningGoal(
    id: 'GOAL-MATH-OPS-3',
    standard: std,
    label: 'Aplica sumas y restas con números pequeños.',
    code: 'MATH.OPS.GOAL.3',
  );

  final ModelPerformanceIndicator indicator = ModelPerformanceIndicator(
    id: 'PI-ACCURACY',
    modelLearningGoal: goal,
    label: 'Selecciona respuestas correctas con consistencia.',
    level: PerformanceLevel.basic,
    code: 'MATH.OPS.PI.1',
  );

  // Helper to construct a learning item quickly.
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
// Home Page
// -----------------------------------------------------------------------------

/// Landing page: shows a JSON snapshot and a button to start.
class AssessmentHome extends StatelessWidget {
  const AssessmentHome({required this.assessment, super.key});

  /// Immutable assessment defined above.
  final ModelAssessment assessment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Education Assessment (Domain Models)')),
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
            Text(
              'Preguntas: ${assessment.items.length} • Aprobación: ${assessment.passScore}%',
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'JSON (enum keys, roundtrip estable):\n${assessment.toJson()}',
                  style: const TextStyle(fontSize: 12),
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
// Runner
// -----------------------------------------------------------------------------

/// Step-by-step runner that uses:
/// - `assessment.shuffleItems` to (optionally) shuffle questions, and
/// - `item.optionsShuffled(seed)` to (optionally) shuffle options.
class AssessmentRunnerPage extends StatefulWidget {
  const AssessmentRunnerPage({required this.assessment, super.key});

  final ModelAssessment assessment;

  @override
  State<AssessmentRunnerPage> createState() => _AssessmentRunnerPageState();
}

class _AssessmentRunnerPageState extends State<AssessmentRunnerPage> {
  late final List<ItemInstance> _instances;
  int _index = 0;
  final Map<String, String> _answers = <String, String>{}; // itemId -> chosen

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
      final int seed = it.id.hashCode; // deterministic per item
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

// -----------------------------------------------------------------------------
// Result & Review
// -----------------------------------------------------------------------------

/// Shows pass/fail status, numeric score, and per-question review using
/// the same domain objects (no copies).
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
                  onPressed: () => Navigator.of(context).pop(),
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
