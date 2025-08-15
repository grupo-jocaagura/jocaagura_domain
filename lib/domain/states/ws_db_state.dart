part of '../../../jocaagura_domain.dart';

/// Immutable state published by [BlocWsDatabase].
///
/// It keeps **only the essentials** for a document-centric UI:
/// - [loading]: an activity flag for one-shot operations.
/// - [docId]: the logical identifier currently in focus (if any).
/// - [doc]: the latest materialized entity (or `null` if not loaded).
/// - [error]: the last error surfaced (if any).
/// - [isWatching]: whether a realtime watch is active for [docId].
///
/// You can extend this state later to add pagination or collection snapshots
/// without breaking the current contract.
@immutable
class WsDbState<T extends Model> {
  /// Creates a state snapshot.
  const WsDbState({
    required this.loading,
    required this.docId,
    required this.isWatching,
    this.doc,
    this.error,
  });

  /// Idle/empty initial state.
  factory WsDbState.idle() =>
      WsDbState<T>(loading: false, docId: '', isWatching: false);

  /// Whether the BLoC is performing a one-shot operation (read/write/delete).
  final bool loading;

  /// The current logical document id in focus (if any).
  final String docId;

  /// The latest document value (if loaded or received via watch).
  final T? doc;

  /// The last surfaced error (if any).
  final ErrorItem? error;

  /// Whether a realtime watch is active for [docId].
  final bool isWatching;
  static const Unit _u = Unit.value;

  /// Returns a new state with overridden fields.
  WsDbState<T> copyWith({
    bool? loading,
    String? docId,
    Object? doc = _u, // <— usa Object para sentinel
    Object? error = _u,
    bool? isWatching,
  }) {
    return WsDbState<T>(
      loading: loading ?? this.loading,
      docId: docId ?? this.docId,
      isWatching: isWatching ?? this.isWatching,
      doc: doc == _u ? this.doc : doc as T?,
      error: error == _u ? this.error : error as ErrorItem?,
    );
  }

  @override
  String toString() => 'WsDbState{loading: $loading, docId: $docId, '
      'hasDoc: ${doc != null}, hasError: ${error != null}, '
      'isWatching: $isWatching}';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WsDbState<T> &&
            runtimeType == other.runtimeType &&
            loading == other.loading &&
            docId == other.docId &&
            isWatching == other.isWatching &&
            doc == other.doc &&
            error == other.error;
  }

  @override
  int get hashCode => Object.hash(loading, docId, isWatching, doc, error);
}
