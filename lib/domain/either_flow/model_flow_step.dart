part of 'package:jocaagura_domain/jocaagura_domain.dart';

/// Enumerates the serialized fields of [ModelFlowStep].
enum FlowStepEnum {
  indexNumber,
  title,
  description,
  failureCode,
  nextOnSuccessIndex,
  nextOnFailureIndex,
  constraints,
  cost,
}

/// Default instance of [ModelFlowStep] for fallback/testing.
///
/// It represents a minimal END step with safe defaults.
const ModelFlowStep defaultModelFlowStepModel = ModelFlowStep(
  index: 0,
  title: '',
  description: '',
  failureCode: 'UNKNOWN',
  nextOnSuccessIndex: -1,
  nextOnFailureIndex: -1,
);

/// Represent a deterministic flow step that routes by Either outcome.
///
/// A step declares:
/// - Where to go on `Right` (success) via [nextOnSuccessIndex]
/// - Where to go on `Left`  (failure) via [nextOnFailureIndex]
/// - A standardized [failureCode] for traceability
///
/// `cost` is a per-metric map expressed in **real units**.
/// The key must encode the unit (e.g. `latencyMs`, `networkKb`, `dbReadsCount`),
/// and the value is the numeric measurement in that unit.
///
/// Immutability notes:
/// - The default `const` constructor keeps fields `final`, but it does not deep-freeze
///   incoming collections if mutable instances are provided.
/// - Use [ModelFlowStep.immutable] to obtain a deeply immutable instance (unmodifiable collections).
///
/// JSON roundtrip is guaranteed by:
/// - Defensive parsing (`Utils.*FromDynamic`)
/// - Cost values normalized to finite **non-negative** doubles (invalid => `0.0`)
///
/// Example:
/// ```dart
/// void main() {
///   final ModelFlowStep step = ModelFlowStep.immutable(
///     index: 10,
///     title: 'Authenticate',
///     description: 'Runs auth use case and returns Either<ErrorItem, Session>',
///     failureCode: 'AUTH_FAILED',
///     nextOnSuccessIndex: 11,
///     nextOnFailureIndex: 99,
///     constraints: <String>['requiresInternet'],
///     cost: <String, double>{
///       'latencyMs': 250,
///       'networkKb': 12.5,
///       'dbReadsCount': 2,
///     },
///   );
///
///   final Map<String, dynamic> json = step.toJson();
///   final ModelFlowStep roundtrip = ModelFlowStep.fromJson(json);
///   assert(step == roundtrip);
/// }
/// ```
@immutable
class ModelFlowStep extends Model {
  /// Creates a deterministic flow step.
  ///
  /// Note: this constructor does not deep-freeze collection arguments.
  /// Prefer [ModelFlowStep.immutable] when you need unmodifiable collections.
  const ModelFlowStep({
    required this.index,
    required this.title,
    required this.description,
    required this.failureCode,
    required this.nextOnSuccessIndex,
    required this.nextOnFailureIndex,
    this.constraints = const <String>[],
    this.cost = const <String, double>{},
  });

  /// Creates a deeply immutable [ModelFlowStep].
  ///
  /// This factory copies and wraps [constraints] and [cost] into unmodifiable
  /// collections, so the instance remains stable even if the caller mutates
  /// their original inputs after construction.
  ///
  /// Cost normalization:
  /// - Non-finite values (NaN/Infinity) become `0.0`
  /// - Negative values become `0.0`
  factory ModelFlowStep.immutable({
    required int index,
    required String title,
    required String description,
    required String failureCode,
    required int nextOnSuccessIndex,
    required int nextOnFailureIndex,
    List<String> constraints = const <String>[],
    Map<String, double> cost = const <String, double>{},
  }) {
    final List<String> frozenConstraints =
        List<String>.unmodifiable(List<String>.from(constraints));

    final Map<String, double> normalizedCost = <String, double>{};
    for (final MapEntry<String, double> entry in cost.entries) {
      final double value = entry.value;
      final double normalized = value.isFinite && value >= 0.0 ? value : 0.0;
      normalizedCost[entry.key] = normalized;
    }

    final Map<String, double> frozenCost =
        Map<String, double>.unmodifiable(normalizedCost);

    return ModelFlowStep(
      index: index,
      title: title,
      description: description,
      failureCode: failureCode,
      nextOnSuccessIndex: nextOnSuccessIndex,
      nextOnFailureIndex: nextOnFailureIndex,
      constraints: frozenConstraints,
      cost: frozenCost,
    );
  }

  /// Creates a [ModelFlowStep] from a JSON-like map.
  ///
  /// This parser is lenient and never throws; it applies safe defaults.
  factory ModelFlowStep.fromJson(Map<String, dynamic> json) {
    final int indexTmp =
        Utils.getIntegerFromDynamic(json[FlowStepEnum.indexNumber.name]);
    final String titleTmp =
        Utils.getStringFromDynamic(json[FlowStepEnum.title.name]);
    final String descriptionTmp =
        Utils.getStringFromDynamic(json[FlowStepEnum.description.name]);

    final String failureCodeRaw =
        Utils.getStringFromDynamic(json[FlowStepEnum.failureCode.name]);
    final String failureCodeTmp = failureCodeRaw.isEmpty
        ? defaultModelFlowStepModel.failureCode
        : failureCodeRaw;

    final int nextOnSuccessTmp =
        Utils.getIntegerFromDynamic(json[FlowStepEnum.nextOnSuccessIndex.name]);
    final int nextOnFailureTmp =
        Utils.getIntegerFromDynamic(json[FlowStepEnum.nextOnFailureIndex.name]);

    final List<String> constraintsTmp =
        Utils.stringListFromDynamic(json[FlowStepEnum.constraints.name])
            .cast<String>();

    final Map<dynamic, dynamic> costRaw =
        Utils.mapFromDynamic(json[FlowStepEnum.cost.name])
            .cast<dynamic, dynamic>();

    final Map<String, double> costTmp = <String, double>{};
    for (final MapEntry<dynamic, dynamic> entry in costRaw.entries) {
      final String key = entry.key.toString();
      final double parsed = Utils.getDouble(entry.value, 0.0);
      final double normalized = parsed.isFinite && parsed >= 0.0 ? parsed : 0.0;
      costTmp[key] = normalized;
    }

    return ModelFlowStep.immutable(
      index: indexTmp,
      title: titleTmp,
      description: descriptionTmp,
      failureCode: failureCodeTmp,
      nextOnSuccessIndex: nextOnSuccessTmp,
      nextOnFailureIndex: nextOnFailureTmp,
      constraints: constraintsTmp,
      cost: costTmp,
    );
  }

  /// Step unique identifier inside a flow.
  final int index;

  /// Short label for architects and UI mapping.
  final String title;

  /// Human-readable description of what this step does.
  final String description;

  /// Standardized failure code for traceability (ideally aligned to ErrorItem.code).
  final String failureCode;

  /// Next index when execution returns `Right`. Use `-1` to represent END.
  final int nextOnSuccessIndex;

  /// Next index when execution returns `Left`. Use `-1` to represent END.
  final int nextOnFailureIndex;

  /// Optional constraints (e.g., "requiresInternet", "role:admin").
  final List<String> constraints;

  /// Optional per-metric costs expressed in real units.
  ///
  /// Keys should encode the unit (e.g., `latencyMs`, `networkKb`, `dbReadsCount`).
  final Map<String, double> cost;

  /// Creates a copy of this [ModelFlowStep] with optional new values.
  ///
  /// If a parameter is `null`, the current value is kept.
  @override
  ModelFlowStep copyWith({
    int? index,
    String? title,
    String? description,
    String? failureCode,
    int? nextOnSuccessIndex,
    int? nextOnFailureIndex,
    List<String>? constraints,
    Map<String, double>? cost,
  }) {
    final bool noChanges = index == null &&
        title == null &&
        description == null &&
        failureCode == null &&
        nextOnSuccessIndex == null &&
        nextOnFailureIndex == null &&
        constraints == null &&
        cost == null;
    if (noChanges) {
      return this;
    }
    return ModelFlowStep.immutable(
      index: index ?? this.index,
      title: title ?? this.title,
      description: description ?? this.description,
      failureCode: failureCode ?? this.failureCode,
      nextOnSuccessIndex: nextOnSuccessIndex ?? this.nextOnSuccessIndex,
      nextOnFailureIndex: nextOnFailureIndex ?? this.nextOnFailureIndex,
      constraints: constraints ?? this.constraints,
      cost: cost ?? this.cost,
    );
  }

  /// Converts this model into a JSON map (roundtrip-safe).
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      FlowStepEnum.indexNumber.name: index,
      FlowStepEnum.title.name: title,
      FlowStepEnum.description.name: description,
      FlowStepEnum.failureCode.name: failureCode,
      FlowStepEnum.nextOnSuccessIndex.name: nextOnSuccessIndex,
      FlowStepEnum.nextOnFailureIndex.name: nextOnFailureIndex,
      FlowStepEnum.constraints.name: constraints,
      FlowStepEnum.cost.name: cost,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ModelFlowStep &&
        runtimeType == other.runtimeType &&
        index == other.index &&
        title == other.title &&
        description == other.description &&
        failureCode == other.failureCode &&
        nextOnSuccessIndex == other.nextOnSuccessIndex &&
        nextOnFailureIndex == other.nextOnFailureIndex &&
        Utils.listEquals(constraints, other.constraints) &&
        Utils.deepEqualsDynamic(cost, other.cost);
  }

  @override
  int get hashCode => Object.hash(
        index,
        title,
        description,
        failureCode,
        nextOnSuccessIndex,
        nextOnFailureIndex,
        Utils.listHash(constraints),
        Utils.deepHash(cost),
      );

  @override
  String toString() => '${toJson()}';
}
