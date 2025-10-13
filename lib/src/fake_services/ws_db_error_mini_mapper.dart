/// Mini-mapper de errores para Gateways/Repos que consumen [ServiceWsDb].
///
/// ### Objetivo
/// **No** propagar `ArgumentError`/`StateError` hacia la UI. En su lugar, mapear
/// a `ErrorItem` (o su JSON) con códigos y contexto consistentes.
///
/// ### Uso sugerido en Gateway (pseudo):
/// ```dart
/// class GatewayWsDbImpl {
///   GatewayWsDbImpl(this.service, {this.errorMapper = const WsDbErrorMiniMapper()});
///   final ServiceWsDb service;
///   final WsDbErrorMiniMapper errorMapper;
///
///   Future<Either<ErrorItem, Map<String, dynamic>>> read(String c, String id) async {
///     try {
///       final Map<String, dynamic> json = await service.readDocument(collection: c, docId: id);
///       return Right(json);
///     } catch (e, st) {
///       // Opción A: si tienes ErrorItem en esta capa:
///       return Left(errorMapper.toErrorItem(e, st,
///         operation: 'read', collection: c, docId: id));
///
///       // Opción B: si esta capa devuelve JSON y el Repo instancia ErrorItem:
///       // return Left(ErrorItem.fromJson(errorMapper.toJson(e, st, ...)));
///     }
///   }
/// }
/// ```
///
/// ### Campos y códigos
/// - `code`: `wsdb.invalid-argument` | `wsdb.not-found` | `wsdb.unexpected`
/// - `origin`: `'ServiceWsDb'`
/// - `operation`: `'save'|'read'|'watchDoc'|'watchCol'|'delete'`
/// - `metadata`: `{ 'collection': c, 'docId': id }`
/// - `errorLevel`: sugerido `ErrorLevelEnum.error` para fallas operativas.
///
/// > Adapta la construcción de `ErrorItem` a tu firma real.
/// > Si no puedes crear `ErrorItem` aquí, usa `toJson()` y que el Repo lo
/// > convierta en `ErrorItem.fromJson(...)`.
class WsDbErrorMiniMapper {
  const WsDbErrorMiniMapper();

  /// Construye un **JSON** similar al contrato de `ErrorItem`.
  Map<String, dynamic> toErrorItem(
    Object error,
    StackTrace stack, {
    required String operation,
    required String collection,
    String? docId,
  }) {
    final String code = _codeFor(error);
    return <String, dynamic>{
      'title': 'WS DB $operation',
      'code': code,
      'description': error.toString(),
      'origin': 'ServiceWsDb',
      'operation': operation,
      'metadata': <String, dynamic>{
        'collection': collection,
        if (docId != null) 'docId': docId,
      },
      'errorLevel': 'error',
      'stack': stack.toString(),
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
  }

  String _codeFor(Object e) {
    if (e is ArgumentError) {
      return 'wsdb.invalid-argument';
    }
    if (e is StateError) {
      return 'wsdb.not-found';
    }
    return 'wsdb.unexpected';
  }
}
