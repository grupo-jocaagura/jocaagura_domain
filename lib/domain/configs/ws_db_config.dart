part of '../../jocaagura_domain.dart';

/// Enumerates the JSON keys for [WsDbConfig].
enum WsDbConfigEnum {
  latencyMs,
  throwOnSave,
  throwOnDelete,
  emitInitial,
  deepCopies,
  dedupeByContent,
  orderCollectionsByKey,
  idKey,
}

/// Default configuration instance for the fake WebSocket database.
const WsDbConfig defaultWsDbConfig = WsDbConfig();

/// Configuration model for [FakeServiceWsDatabase].
///
/// This model is immutable and can be serialized to/from JSON, enabling
/// persistence or remote toggling in tests.
///
/// ### Fields
/// - [latency]: Simulated latency applied to save/read/delete operations.
/// - [throwOnSave]: When true, `saveDocument` throws a simulated error.
/// - [throwOnDelete]: When true, `deleteDocument` throws a simulated error.
/// - [emitInitial]: If true, streams emit a seed snapshot on subscription.
/// - [deepCopies]: If true, the fake performs defensive deep copies on write
///   and on emission, preventing external mutation leaks.
/// - [dedupeByContent]: If true, streams avoid emitting if content didn't change
///   by value (deep-equality).
/// - [orderCollectionsByKey]: If true, collection snapshots are emitted sorted
///   by document id (deterministic for tests).
/// - [idKey]: The JSON key used to denote the document id in raw payloads.
///
/// ### Example
/// ```dart
/// const WsDbConfig cfg = WsDbConfig(
///   latency: Duration(milliseconds: 5),
///   emitInitial: true,
///   deepCopies: true,
///   dedupeByContent: true,
///   orderCollectionsByKey: true,
/// );
/// ```
@immutable
class WsDbConfig extends Model {
  /// Creates a configuration with sensible defaults for testing.
  const WsDbConfig({
    this.latency = Duration.zero,
    this.throwOnSave = false,
    this.throwOnDelete = false,
    this.emitInitial = true,
    this.deepCopies = true,
    this.dedupeByContent = true,
    this.orderCollectionsByKey = true,
    this.idKey = 'id',
  });

  /// Builds a configuration from JSON. Invalid or missing fields fall back to
  /// defaults.
  factory WsDbConfig.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> j = Utils.mapFromDynamic(json);
    final int ms =
        Utils.getIntegerFromDynamic(j[WsDbConfigEnum.latencyMs.name]);
    return WsDbConfig(
      latency: Duration(milliseconds: ms),
      throwOnSave: Utils.getBoolFromDynamic(j[WsDbConfigEnum.throwOnSave.name]),
      throwOnDelete:
          Utils.getBoolFromDynamic(j[WsDbConfigEnum.throwOnDelete.name]),
      emitInitial: Utils.getBoolFromDynamic(j[WsDbConfigEnum.emitInitial.name]),
      deepCopies: Utils.getBoolFromDynamic(j[WsDbConfigEnum.deepCopies.name]),
      dedupeByContent:
          Utils.getBoolFromDynamic(j[WsDbConfigEnum.dedupeByContent.name]),
      orderCollectionsByKey: Utils.getBoolFromDynamic(
        j[WsDbConfigEnum.orderCollectionsByKey.name],
      ),
      idKey: Utils.getStringFromDynamic(j[WsDbConfigEnum.idKey.name]),
    );
  }

  /// Simulated latency for I/O-like operations.
  final Duration latency;

  /// Simulate failures on save when true.
  final bool throwOnSave;

  /// Simulate failures on delete when true.
  final bool throwOnDelete;

  /// Emit a seed snapshot on stream subscription when true.
  final bool emitInitial;

  /// Perform defensive deep copies on write and emit when true.
  final bool deepCopies;

  /// Avoid re-emitting the same content by deep-equality when true.
  final bool dedupeByContent;

  /// Emit collection snapshots ordered by doc id when true.
  final bool orderCollectionsByKey;

  /// JSON key used for the document id in raw snapshots.
  final String idKey;

  /// Creates a copy of this configuration with optional changes.
  @override
  WsDbConfig copyWith({
    Duration? latency,
    bool? throwOnSave,
    bool? throwOnDelete,
    bool? emitInitial,
    bool? deepCopies,
    bool? dedupeByContent,
    bool? orderCollectionsByKey,
    String? idKey,
  }) {
    return WsDbConfig(
      latency: latency ?? this.latency,
      throwOnSave: throwOnSave ?? this.throwOnSave,
      throwOnDelete: throwOnDelete ?? this.throwOnDelete,
      emitInitial: emitInitial ?? this.emitInitial,
      deepCopies: deepCopies ?? this.deepCopies,
      dedupeByContent: dedupeByContent ?? this.dedupeByContent,
      orderCollectionsByKey:
          orderCollectionsByKey ?? this.orderCollectionsByKey,
      idKey: idKey ?? this.idKey,
    );
  }

  /// Serializes this configuration to JSON.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      WsDbConfigEnum.latencyMs.name: latency.inMilliseconds,
      WsDbConfigEnum.throwOnSave.name: throwOnSave,
      WsDbConfigEnum.throwOnDelete.name: throwOnDelete,
      WsDbConfigEnum.emitInitial.name: emitInitial,
      WsDbConfigEnum.deepCopies.name: deepCopies,
      WsDbConfigEnum.dedupeByContent.name: dedupeByContent,
      WsDbConfigEnum.orderCollectionsByKey.name: orderCollectionsByKey,
      WsDbConfigEnum.idKey.name: idKey,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WsDbConfig &&
          runtimeType == other.runtimeType &&
          latency == other.latency &&
          throwOnSave == other.throwOnSave &&
          throwOnDelete == other.throwOnDelete &&
          emitInitial == other.emitInitial &&
          deepCopies == other.deepCopies &&
          dedupeByContent == other.dedupeByContent &&
          orderCollectionsByKey == other.orderCollectionsByKey &&
          idKey == other.idKey;

  @override
  int get hashCode => Object.hash(
        latency,
        throwOnSave,
        throwOnDelete,
        emitInitial,
        deepCopies,
        dedupeByContent,
        orderCollectionsByKey,
        idKey,
      );

  @override
  String toString() => 'WsDbConfig(${toJson()})';
}
