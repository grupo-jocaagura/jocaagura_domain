import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() => runApp(const JgFlowEducationDemoApp());

/// ---------------------------------------------------------------------------
/// Flutter example: How to use a new model (ModelCompleteFlow) with BlocGeneral
/// ---------------------------------------------------------------------------
///
/// This demo shows the full "jocaagura style" loop:
/// 1) Create a deeply immutable model with `.immutable(...)`
/// 2) Hold it as single source of truth using `BlocGeneral<ModelCompleteFlow>`
/// 3) Mutate only by emitting new values (upsert/remove/copyWith)
/// 4) Export/import JSON snapshots (roundtrip) to prove stability
///
/// Notes:
/// - No external packages.
/// - UI uses StreamBuilder to listen to the bloc.
/// - END semantics: step.index == -1 is reserved; cannot be stored as a step.
/// ---------------------------------------------------------------------------

class JgFlowEducationDemoApp extends StatelessWidget {
  const JgFlowEducationDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jocaagura Flow Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const CompleteFlowHomePage(),
    );
  }
}

// -----------------------------------------------------------------------------
// Page: ModelCompleteFlow + BlocGeneral demo
// -----------------------------------------------------------------------------

class CompleteFlowHomePage extends StatefulWidget {
  const CompleteFlowHomePage({super.key});

  @override
  State<CompleteFlowHomePage> createState() => _CompleteFlowHomePageState();
}

class _CompleteFlowHomePageState extends State<CompleteFlowHomePage> {
  late final BlocGeneral<ModelCompleteFlow> _flowBloc;

  @override
  void initState() {
    super.initState();

    // 1) Create the BLoC (single source of truth).
    _flowBloc = BlocGeneral<ModelCompleteFlow>(defaultModelCompleteFlow);

    // 2) Hydrate an initial diagram (deeply immutable).
    _flowBloc.value = _seedAuthFlow();
  }

  @override
  void dispose() {
    // If your BlocGeneral exposes dispose, call it.
    // _flowBloc.dispose();
    super.dispose();
  }

  ModelCompleteFlow _seedAuthFlow() {
    return ModelCompleteFlow.immutable(
      name: 'AuthFlow',
      description: 'Login and session validation diagram.',
      steps: <ModelFlowStep>[
        ModelFlowStep.immutable(
          index: 10,
          title: 'Authenticate',
          description:
              'Runs auth use case and returns Either<ErrorItem, Session>',
          failureCode: 'AUTH_FAILED',
          nextOnSuccessIndex: 11,
          nextOnFailureIndex: -1,
          constraints: const <String>['requiresInternet'],
          cost: const <String, double>{'latencyMs': 250, 'networkKb': 12.5},
        ),
        ModelFlowStep.immutable(
          index: 11,
          title: 'Load Profile',
          description: 'Loads user profile and finishes.',
          failureCode: 'PROFILE_FAILED',
          nextOnSuccessIndex: -1,
          nextOnFailureIndex: -1,
          cost: const <String, double>{'dbReadsCount': 2},
        ),
      ],
    );
  }

  void _renameFlow() {
    final ModelCompleteFlow current = _flowBloc.value;
    _flowBloc.value = current.copyWith(name: '${current.name}_v2');
  }

  void _upsertNewStep() {
    final ModelCompleteFlow current = _flowBloc.value;

    // In a real app, this comes from a form.
    // Upsert means: create if missing, update if exists.
    final ModelFlowStep newStep = ModelFlowStep.immutable(
      index: 20,
      title: 'Audit Log',
      description: 'Sends audit event and finishes.',
      failureCode: 'AUDIT_FAILED',
      nextOnSuccessIndex: -1,
      nextOnFailureIndex: -1,
      constraints: const <String>['requiresInternet'],
      cost: const <String, double>{'latencyMs': 50, 'networkKb': 2},
    );

    _flowBloc.value = current.upsertStep(newStep);
  }

  void _updateExistingStep10() {
    final ModelCompleteFlow current = _flowBloc.value;
    final ModelFlowStep? step10 = current.stepAt(10);
    if (step10 == null) {
      return;
    }

    // We change only what we need, and upsert the new step.
    final ModelFlowStep updated = step10.copyWith(
      title: 'Authenticate (v2)',
      cost: <String, double>{
        ...step10.cost,
        'latencyMs': 300, // "real units"
      },
    );

    _flowBloc.value = current.upsertStep(updated);
  }

  void _removeEntryStep() {
    final ModelCompleteFlow current = _flowBloc.value;
    if (current.entryIndex < 0) {
      return;
    }

    _flowBloc.value = current.removeStepAt(current.entryIndex);
  }

  void _exportJson(BuildContext context) {
    final Map<String, dynamic> json = _flowBloc.value.toJson();
    final String pretty = json.toString();

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export JSON (roundtrip-safe)'),
        content: SingleChildScrollView(
          child: Text(pretty, style: const TextStyle(fontSize: 12)),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _importRoundtrip(BuildContext context) {
    // Demonstrates the "contract proof":
    // export -> fromJson -> equals
    final ModelCompleteFlow current = _flowBloc.value;
    final Map<String, dynamic> json = current.toJson();
    final ModelCompleteFlow restored = ModelCompleteFlow.fromJson(json);

    final bool ok =
        restored == current && restored.hashCode == current.hashCode;

    _flowBloc.value = restored;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Roundtrip OK ✅ (== and hashCode)' : 'Roundtrip mismatch ❌',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ModelCompleteFlow>(
      // The BLoC is the only source of truth.
      stream: _flowBloc.stream,
      initialData: _flowBloc.value,
      builder:
          (BuildContext context, AsyncSnapshot<ModelCompleteFlow> snapshot) {
        final ModelCompleteFlow flow =
            snapshot.data ?? defaultModelCompleteFlow;
        final List<ModelFlowStep> steps = flow.stepsSorted;

        return Scaffold(
          appBar: AppBar(
            title: Text(flow.name.isEmpty ? 'Flow Demo' : flow.name),
            actions: <Widget>[
              IconButton(
                tooltip: 'Export JSON',
                icon: const Icon(Icons.code),
                onPressed: () => _exportJson(context),
              ),
              IconButton(
                tooltip: 'Import Roundtrip',
                icon: const Icon(Icons.cached),
                onPressed: () => _importRoundtrip(context),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  flow.name.isEmpty ? 'Unnamed Flow' : flow.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  flow.description.isEmpty
                      ? 'No description.'
                      : flow.description,
                ),
                const SizedBox(height: 12),
                _FlowStatsCard(flow: flow),
                const SizedBox(height: 12),
                Text('Steps', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Expanded(
                  child: steps.isEmpty
                      ? const Center(child: Text('No steps yet.'))
                      : ListView.separated(
                          itemCount: steps.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, int i) => _FlowStepTile(
                            step: steps[i],
                            onRemove: () => _flowBloc.value =
                                flow.removeStepAt(steps[i].index),
                          ),
                        ),
                ),
                const SizedBox(height: 12),
                _HelperNote(flow: flow),
              ],
            ),
          ),
          floatingActionButton: _FabMenu(
            onRename: _renameFlow,
            onUpsertNew: _upsertNewStep,
            onUpdateStep10: _updateExistingStep10,
            onRemoveEntry: _removeEntryStep,
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// UI Components
// -----------------------------------------------------------------------------

class _FlowStatsCard extends StatelessWidget {
  const _FlowStatsCard({required this.flow});

  final ModelCompleteFlow flow;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            const Icon(Icons.account_tree_outlined, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Entry index: ${flow.entryIndex}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Steps: ${flow.stepsByIndex.length} • JSON keys are indices as strings',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowStepTile extends StatelessWidget {
  const _FlowStepTile({
    required this.step,
    required this.onRemove,
  });

  final ModelFlowStep step;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final String costLabel = step.cost.isEmpty
        ? '—'
        : step.cost.entries
            .map((MapEntry<String, double> e) => '${e.key}: ${e.value}')
            .join(' • ');

    return ListTile(
      leading: CircleAvatar(child: Text('${step.index}')),
      title: Text(step.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 4),
          Text(step.description),
          const SizedBox(height: 6),
          Text(
            'Failure code: ${step.failureCode}',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            'On Right → ${step.nextOnSuccessIndex}  |  On Left → ${step.nextOnFailureIndex}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            'Cost (real units): $costLabel',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      trailing: IconButton(
        tooltip: 'Remove step',
        icon: const Icon(Icons.delete_outline),
        onPressed: onRemove,
      ),
    );
  }
}

class _FabMenu extends StatelessWidget {
  const _FabMenu({
    required this.onRename,
    required this.onUpsertNew,
    required this.onUpdateStep10,
    required this.onRemoveEntry,
  });

  final VoidCallback onRename;
  final VoidCallback onUpsertNew;
  final VoidCallback onUpdateStep10;
  final VoidCallback onRemoveEntry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FloatingActionButton.small(
          heroTag: 'rename',
          onPressed: onRename,
          tooltip: 'Rename flow',
          child: const Icon(Icons.drive_file_rename_outline),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.small(
          heroTag: 'upsertNew',
          onPressed: onUpsertNew,
          tooltip: 'Upsert new step',
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.small(
          heroTag: 'update10',
          onPressed: onUpdateStep10,
          tooltip: 'Update step #10',
          child: const Icon(Icons.edit),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.small(
          heroTag: 'removeEntry',
          onPressed: onRemoveEntry,
          tooltip: 'Remove entry step',
          child: const Icon(Icons.remove_circle_outline),
        ),
      ],
    );
  }
}

class _HelperNote extends StatelessWidget {
  const _HelperNote({required this.flow});

  final ModelCompleteFlow flow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Tip: In our approach, the model is a value object (immutable + JSON roundtrip).\n'
          'The BlocGeneral<ModelCompleteFlow> is the single source of truth.\n'
          'Mutations are expressed as new values via copyWith/upsert/remove.\n'
          '\n'
          'Current entryIndex: ${flow.entryIndex} • steps: ${flow.stepsByIndex.length}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
