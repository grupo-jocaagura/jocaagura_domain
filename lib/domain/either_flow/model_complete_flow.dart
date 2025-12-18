part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enumerates the serialized fields of [ModelCompleteFlow].
enum CompleteFlowEnum {
  name,
  description,

  /// Canonical storage/contract: map keyed by step index (as string in JSON).
  stepsByIndex,
}

/// Default instance of [ModelCompleteFlow] for fallback/testing.
const ModelCompleteFlow defaultModelCompleteFlow = ModelCompleteFlow(
  name: '',
  description: '',
  stepsByIndex: <int, ModelFlowStep>{},
);

/// Represent a complete deterministic diagram composed of multiple [ModelFlowStep] items.
///
/// Contract and storage:
/// - Steps are stored in [stepsByIndex], keyed by [ModelFlowStep.index].
/// - JSON uses the same structure: `stepsByIndex` is a map whose keys are the step
///   indices encoded as strings (e.g. `"10"`, `"11"`).
///
/// END semantics:
/// - `index == -1` is reserved for END targets only.
/// - Steps with `index < 0` are ignored (not stored).
///
/// Immutability:
/// - This model is deeply immutable: [stepsByIndex] is unmodifiable.
/// - All inserted steps are normalized to [ModelFlowStep.immutable].
///
/// JSON roundtrip is guaranteed by:
/// - Defensive parsing with safe defaults
/// - Stable serialization order (sorted by index)
///
/// Example:
/// ```dart
/// void main() {
///   final ModelCompleteFlow flow = ModelCompleteFlow.immutable(
///     name: 'AuthFlow',
///     description: 'Login and session validation diagram.',
///     steps: <ModelFlowStep>[
///       ModelFlowStep.immutable(
///         index: 10,
///         title: 'Authenticate',
///         description: 'Runs auth use case',
///         failureCode: 'AUTH_FAILED',
///         nextOnSuccessIndex: 11,
///         nextOnFailureIndex: -1,
///         cost: <String, double>{'latencyMs': 250},
///       ),
///     ],
///   );
///
///   final Map<String, dynamic> json = flow.toJson();
///   final ModelCompleteFlow roundtrip = ModelCompleteFlow.fromJson(json);
///   assert(flow == roundtrip);
/// }
/// ```
@immutable
class ModelCompleteFlow extends Model {
  /// Creates a flow instance.
  ///
  /// Note: this constructor expects already-frozen collections.
  const ModelCompleteFlow({
    required this.name,
    required this.description,
    required this.stepsByIndex,
  });

  /// Creates a deeply immutable [ModelCompleteFlow] from a list of steps.
  ///
  /// Duplicate indices are resolved by "last write wins".
  factory ModelCompleteFlow.immutable({
    required String name,
    required String description,
    List<ModelFlowStep> steps = const <ModelFlowStep>[],
  }) {
    final Map<int, ModelFlowStep> tmp = <int, ModelFlowStep>{};

    for (final ModelFlowStep step in steps) {
      if (step.index < 0) {
        // -1 is END-only; do not store as a real step.
        continue;
      }
      tmp[step.index] = _asImmutableStep(step);
    }

    return ModelCompleteFlow(
      name: name,
      description: description,
      stepsByIndex: Map<int, ModelFlowStep>.unmodifiable(tmp),
    );
  }

  /// Creates a deeply immutable [ModelCompleteFlow] from a map keyed by step index.
  ///
  /// Steps with `index < 0` are ignored.
  factory ModelCompleteFlow.immutableFromMap({
    required String name,
    required String description,
    Map<int, ModelFlowStep> stepsByIndex = const <int, ModelFlowStep>{},
  }) {
    final Map<int, ModelFlowStep> tmp = <int, ModelFlowStep>{};

    for (final MapEntry<int, ModelFlowStep> entry in stepsByIndex.entries) {
      if (entry.key < 0) {
        continue;
      }
      tmp[entry.key] = _asImmutableStep(entry.value);
    }

    return ModelCompleteFlow(
      name: name,
      description: description,
      stepsByIndex: Map<int, ModelFlowStep>.unmodifiable(tmp),
    );
  }

  /// Creates a [ModelCompleteFlow] from a JSON-like map.
  ///
  /// This parser is lenient and never throws; it applies safe defaults.
  ///
  /// Expected JSON shape:
  /// ```json
  /// {
  ///   "name": "AuthFlow",
  ///   "description": "...",
  ///   "stepsByIndex": {
  ///     "10": { ... ModelFlowStep JSON ... },
  ///     "11": { ... }
  ///   }
  /// }
  /// ```
  factory ModelCompleteFlow.fromJson(Map<String, dynamic> json) {
    final String nameTmp =
        Utils.getStringFromDynamic(json[CompleteFlowEnum.name.name]);
    final String descriptionTmp =
        Utils.getStringFromDynamic(json[CompleteFlowEnum.description.name]);

    final dynamic rawStepsByIndex = json[CompleteFlowEnum.stepsByIndex.name];
    final Map<int, ModelFlowStep> tmp = <int, ModelFlowStep>{};

    if (rawStepsByIndex is Map) {
      for (final MapEntry<dynamic, dynamic> entry in rawStepsByIndex.entries) {
        final int indexKey = Utils.getIntegerFromDynamic(entry.key);
        if (indexKey < 0) {
          // END-only; ignore.
          continue;
        }

        final dynamic value = entry.value;

        if (value is Map<String, dynamic>) {
          final ModelFlowStep step = ModelFlowStep.fromJson(value);
          if (step.index < 0) {
            continue;
          }
          tmp[step.index] =
              step; // fromJson already returns immutable in your design
          continue;
        }

        if (value is Map) {
          final Map<String, dynamic> casted = <String, dynamic>{};
          for (final MapEntry<dynamic, dynamic> e in value.entries) {
            casted[e.key.toString()] = e.value;
          }
          final ModelFlowStep step = ModelFlowStep.fromJson(casted);
          if (step.index < 0) {
            continue;
          }
          tmp[step.index] = step;
        }
      }
    }

    return ModelCompleteFlow(
      name: nameTmp,
      description: descriptionTmp,
      stepsByIndex: Map<int, ModelFlowStep>.unmodifiable(tmp),
    );
  }

  /// Flow label (human and/or machine).
  final String name;

  /// Diagram description (human and/or machine).
  final String description;

  /// Steps keyed by [ModelFlowStep.index]. This map is unmodifiable.
  final Map<int, ModelFlowStep> stepsByIndex;

  /// Returns steps sorted by index (stable view for UI/exports).
  List<ModelFlowStep> get stepsSorted {
    final List<int> keys = stepsByIndex.keys.toList(growable: false)..sort();
    final List<ModelFlowStep> out = <ModelFlowStep>[];
    for (final int k in keys) {
      final ModelFlowStep? step = stepsByIndex[k];
      if (step != null) {
        out.add(step);
      }
    }
    return List<ModelFlowStep>.unmodifiable(out);
  }

  /// Returns the entry index for this flow.
  ///
  /// Convention: the smallest index in [stepsByIndex], or `-1` if empty.
  int get entryIndex {
    if (stepsByIndex.isEmpty) {
      return -1;
    }
    final List<int> keys = stepsByIndex.keys.toList(growable: false)..sort();
    return keys.first;
  }

  /// Gets a step by index (or `null`).
  ModelFlowStep? stepAt(int index) => stepsByIndex[index];

  /// Returns a deeply immutable copy upserting [step] by its [ModelFlowStep.index].
  ///
  /// If `step.index < 0`, this operation is ignored and returns `this`.
  ModelCompleteFlow upsertStep(ModelFlowStep step) {
    if (step.index < 0) {
      return this;
    }

    final ModelFlowStep frozen = _asImmutableStep(step);
    final ModelFlowStep? current = stepsByIndex[step.index];

    if (current == frozen) {
      return this;
    }

    final Map<int, ModelFlowStep> tmp = <int, ModelFlowStep>{}
      ..addAll(stepsByIndex);
    tmp[step.index] = frozen;

    return ModelCompleteFlow(
      name: name,
      description: description,
      stepsByIndex: Map<int, ModelFlowStep>.unmodifiable(tmp),
    );
  }

  /// Returns a deeply immutable copy removing the step at [index].
  ///
  /// If `index < 0` or it doesn't exist, returns `this`.
  ModelCompleteFlow removeStepAt(int index) {
    if (index < 0 || !stepsByIndex.containsKey(index)) {
      return this;
    }

    final Map<int, ModelFlowStep> tmp = <int, ModelFlowStep>{}
      ..addAll(stepsByIndex);
    tmp.remove(index);

    return ModelCompleteFlow(
      name: name,
      description: description,
      stepsByIndex: Map<int, ModelFlowStep>.unmodifiable(tmp),
    );
  }

  /// Convenience: removes by step index.
  ModelCompleteFlow removeStep(ModelFlowStep step) => removeStepAt(step.index);

  /// Copy with optional new values.
  ///
  /// If a parameter is `null`, the current value is kept.
  @override
  ModelCompleteFlow copyWith({
    String? name,
    String? description,
    Map<int, ModelFlowStep>? stepsByIndex,
  }) {
    final bool noChanges =
        name == null && description == null && stepsByIndex == null;
    if (noChanges) {
      return this;
    }

    return ModelCompleteFlow.immutableFromMap(
      name: name ?? this.name,
      description: description ?? this.description,
      stepsByIndex: stepsByIndex ?? this.stepsByIndex,
    );
  }

  /// Converts this model into a JSON map (roundtrip-safe).
  ///
  /// The `stepsByIndex` map keys are serialized as strings, and steps are emitted
  /// in a stable order (sorted by index).
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> byIndex = <String, dynamic>{};

    for (final ModelFlowStep step in stepsSorted) {
      byIndex[step.index.toString()] = step.toJson();
    }

    return <String, dynamic>{
      CompleteFlowEnum.name.name: name,
      CompleteFlowEnum.description.name: description,
      CompleteFlowEnum.stepsByIndex.name: byIndex,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ModelCompleteFlow &&
        runtimeType == other.runtimeType &&
        name == other.name &&
        description == other.description &&
        Utils.deepEqualsDynamic(stepsByIndex, other.stepsByIndex);
  }

  @override
  int get hashCode => Object.hash(
        name,
        description,
        Utils.deepHash(stepsByIndex),
      );

  @override
  String toString() => '${toJson()}';

  static ModelFlowStep _asImmutableStep(ModelFlowStep step) {
    return ModelFlowStep.immutable(
      index: step.index,
      title: step.title,
      description: step.description,
      failureCode: step.failureCode,
      nextOnSuccessIndex: step.nextOnSuccessIndex,
      nextOnFailureIndex: step.nextOnFailureIndex,
      constraints: step.constraints,
      cost: step.cost,
    );
  }
}
