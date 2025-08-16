import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// ---------------------------------------------------------------------------
/// WsDatabaseUserDemoPage
/// ---------------------------------------------------------------------------
///
/// # Propósito de esta demo
///
/// Mostrar, de punta a punta, **cómo orquestar un CRUD + realtime (watch)**
/// sobre documentos con un *stack* por capas:
///
/// 1) **ServiceWsDatabase**  → transporte (aquí, un Fake in-memory con semántica
///    de WebSocket: streams por doc/colección).
/// 2) **GatewayWsDatabase**  → mapea excepciones a ErrorItem, inyecta `id` y
///    multiplexa los watch por docId (un solo stream compartido por doc).
/// 3) **RepositoryWsDatabase<T>** → mapea JSON ↔️ Model (T) y opcionalmente
///    **serializa escrituras por docId** para evitar carreras.
/// 4) **Use cases + Facade** → casos de uso transversales (read, write, watch…)
///    expuestos en una fachada amigable para la UI.
/// 5) **BlocWsDatabase<T>** → capa reactiva para la vista: publica un único
///    `WsDbState<T>` con `loading/error/doc/docId/isWatching`.
///
/// # ¿Por qué esta arquitectura?
///
/// - **Separación de responsabilidades:** cada capa resuelve un problema y la UI
///   solo consume *casos de uso*.
/// - **Reutilizable y testeable:** puedes cambiar Service (REST, WS real, etc.)
///   sin tocar BLoC ni UI; Gateway y Repository tienen unit tests sencillos.
/// - **Streams eficientes:** el Gateway crea **un solo** canal por `docId` y lo
///   comparte entre todos los observadores; libera memoria cuando nadie observa.
/// - **Errores coherentes:** Los errores en transporte/payload se estandariza
///   vía `ErrorItem`, lo que simplifica la UI.
///
/// # Qué puedes hacer desde la UI
///
/// - **Read**, **Write/Upsert**, **Delete**, **Exists**
/// - **Ensure** (crear si falta, actualizar si existe)
/// - **Mutate** (leer → transformar → escribir)
/// - **Patch** (merge parcial de JSON)
/// - **Watch/Stop watch** (realtime)
/// - **Auto +1/sec**: un “motor” que simula cambios en servidor para ver el
///   watch en vivo (incrementa un contador en el documento).
///
/// # Tips de integración en tu app
///
/// - Si compartes Repository/Gateway entre varias pantallas, llama
///   `bloc.dispose()` para cerrar la UI, y `facade.disposeAll()` **solo** si
///   eres dueño del stack (p.ej. al cerrar sesión).
/// - Tras cancelar un `watch`, recuerda llamar a `facade.detach(...)`
///   (el BLoC lo hace por ti en `stopWatch` y `dispose`).
/// - Si tu backend emite snapshots vacíos cuando el doc no existe, configura el
///   Gateway con `treatEmptyAsMissing` en true.
///
class WsDatabaseUserDemoPage extends StatefulWidget {
  const WsDatabaseUserDemoPage({super.key});

  @override
  State<WsDatabaseUserDemoPage> createState() => _WsDatabaseUserDemoPageState();
}

class _WsDatabaseUserDemoPageState extends State<WsDatabaseUserDemoPage> {
  // Capas (5): Service → Gateway → Repository → Facade → Bloc
  late final FakeServiceWsDatabase _service;
  late final GatewayWsDatabaseImpl _gateway;
  late final RepositoryWsDatabaseImpl<UserModel> _repository;
  late final FacadeWsDatabaseUsecases<UserModel> _facade;
  late final BlocWsDatabase<UserModel> _bloc;

  // Un pequeño "motor" para simular cambios en el servidor y ver el watch.
  WsDocTicker? _ticker;

  // Campos de UI para construir un UserModel de prueba.
  final TextEditingController _docIdCtrl =
      TextEditingController(text: 'user_001');
  final TextEditingController _nameCtrl =
      TextEditingController(text: 'John Doe');
  final TextEditingController _emailCtrl =
      TextEditingController(text: 'john.doe@example.com');
  final TextEditingController _photoCtrl =
      TextEditingController(text: 'https://example.com/profile.jpg');

  @override
  void initState() {
    super.initState();

    // (1) Service: fake WebSocket-like DB en memoria (streams por doc/colección).
    _service = FakeServiceWsDatabase();

    // (2) Gateway: mapea excepciones a ErrorItem, inyecta 'id',
    //     multiplexa watch por docId y maneja payload errors.
    _gateway = GatewayWsDatabaseImpl(
      service: _service,
      collection: 'users',
      // idKey/readAfterWrite/treatEmptyAsMissing → defaults conservadores.
    );

    // (3) Repository: mapea JSON ↔️ UserModel y (opcional) serializa writes
    //     por docId para evitar solapamientos (útil con UI impaciente).
    _repository = RepositoryWsDatabaseImpl<UserModel>(
      gateway: _gateway,
      fromJson: UserModel.fromJson,
      serializeWrites: true,
    );

    // (4) Facade: agrupa los casos de uso (read, write, watch, batch, etc.)
    _facade = FacadeWsDatabaseUsecases<UserModel>.fromRepository(
      repository: _repository,
      fromJson: UserModel.fromJson,
    );

    // (5) Bloc: publica WsDbState<T> (loading/error/doc/docId/isWatching)
    _bloc = BlocWsDatabase<UserModel>(facade: _facade);

    // Motor de cambios “servidor”: actualiza un campo contador en el doc.
    // - Usa el Service directamente para simular eventos “externos”
    //   (el Gateway/Repo/Bloc observarán los cambios como en producción).
    _ticker = WsDocTicker(
      service: _service,
      collection: 'users',
      docId: _docIdCtrl.text.trim(),
      seedMode: SeedMode.none, // no crea doc si no existe
    );
  }

  @override
  void dispose() {
    // Buen ciudadano: detiene motor y cierra BLoC/stream de estado.
    _ticker?.stop();
    _bloc.dispose();
    _docIdCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _photoCtrl.dispose();
    super.dispose();
  }

  /// Construye un UserModel desde los campos de UI.
  ///
  /// Nota: en esta demo el `jwt` es vacío; el motor (_ticker_) toca este campo
  /// para simular cambios en caliente (por ejemplo `jwt.countRef`).
  UserModel _buildUser(String id) => UserModel(
        id: id,
        displayName: _nameCtrl.text.trim(),
        photoUrl: _photoCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        jwt: const <String, dynamic>{},
      );

  void _snack(String msg) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WsDatabase Demo — UserModel')),
      // La vista se suscribe al stream de estado del BLoC.
      body: StreamBuilder<WsDbState<UserModel>>(
        stream: _bloc.stream,
        initialData: _bloc.value,
        builder: (BuildContext context, AsyncSnapshot<WsDbState<UserModel>> s) {
          final WsDbState<UserModel> state =
              s.data ?? WsDbState<UserModel>.idle();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _Header(loading: state.loading, isWatching: state.isWatching),
              const SizedBox(height: 12),
              _DocIdField(controller: _docIdCtrl),
              const SizedBox(height: 8),
              _TextField(label: 'Display name', controller: _nameCtrl),
              const SizedBox(height: 8),
              _TextField(label: 'Email', controller: _emailCtrl),
              const SizedBox(height: 8),
              _TextField(label: 'Photo URL', controller: _photoCtrl),
              const SizedBox(height: 16),

              // ----------------------------------------------------------------
              // Botones de acciones (un botón = un caso de uso)
              // ----------------------------------------------------------------
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  // READ: carga un doc por id → actualiza state.doc/docId
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      final Either<ErrorItem, UserModel> res =
                          await _bloc.readDoc(id);
                      res.fold(
                        (ErrorItem e) => _snack('READ error: ${e.code}'),
                        (UserModel u) => _snack('READ ok: ${u.displayName}'),
                      );
                    },
                    child: const Text('Read'),
                  ),

                  // WRITE / UPSERT: persiste el doc → devuelve versión autoritativa
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      final UserModel user = _buildUser(id);
                      final Either<ErrorItem, UserModel> res =
                          await _bloc.writeDoc(id, user);
                      res.fold(
                        (ErrorItem e) => _snack('WRITE error: ${e.code}'),
                        (UserModel u) => _snack('WRITE ok: ${u.displayName}'),
                      );
                    },
                    child: const Text('Write / Upsert'),
                  ),

                  // DELETE: elimina por id → si es el doc activo, lo limpia del state
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      final Either<ErrorItem, Unit> res =
                          await _bloc.deleteDoc(id);
                      res.fold(
                        (ErrorItem e) => _snack('DELETE error: ${e.code}'),
                        (_) => _snack('DELETE ok'),
                      );
                    },
                    child: const Text('Delete'),
                  ),

                  // EXISTS: no altera el doc del state, solo informa si existe
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      final Either<ErrorItem, bool> res =
                          await _bloc.existsDoc(id);
                      res.fold(
                        (ErrorItem e) => _snack('EXISTS error: ${e.code}'),
                        (bool exists) => _snack('EXISTS: $exists'),
                      );
                    },
                    child: const Text('Exists'),
                  ),

                  // ENSURE: crea si falta, opcionalmente actualiza si existe
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      final Either<ErrorItem, UserModel> res =
                          await _bloc.ensureDoc(
                        docId: id,
                        create: () => _buildUser(id),
                        updateIfExists: (UserModel u) =>
                            u.copyWith(displayName: '${u.displayName} ✅'),
                      );
                      res.fold(
                        (ErrorItem e) => _snack('ENSURE error: ${e.code}'),
                        (UserModel u) => _snack('ENSURE ok: ${u.displayName}'),
                      );
                    },
                    child: const Text('Ensure'),
                  ),

                  // MUTATE: lectura → transformación pura → escritura
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      final Either<ErrorItem, UserModel> res =
                          await _bloc.mutateDoc(
                        id,
                        (UserModel u) =>
                            u.copyWith(displayName: '${u.displayName} *'),
                      );
                      res.fold(
                        (ErrorItem e) => _snack('MUTATE error: ${e.code}'),
                        (UserModel u) => _snack('MUTATE ok: ${u.displayName}'),
                      );
                    },
                    child: const Text('Mutate name'),
                  ),

                  // PATCH: merge parcial de JSON (útil para “editar por campos”)
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      final Either<ErrorItem, UserModel> res =
                          await _bloc.patchDoc(id, <String, dynamic>{
                        UserEnum.displayName.name:
                            '${_nameCtrl.text.trim()} (patched)',
                      });
                      res.fold(
                        (ErrorItem e) => _snack('PATCH error: ${e.code}'),
                        (UserModel u) => _snack('PATCH ok: ${u.displayName}'),
                      );
                    },
                    child: const Text('Patch name'),
                  ),

                  // WATCH: inicia la observación realtime del doc via Gateway/Repo
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      await _bloc.startWatch(id);
                      _snack('Watch started for $id');
                    },
                    child: const Text('Watch'),
                  ),

                  // STOP WATCH: cancela suscripción y “detach” del canal compartido
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      await _bloc.stopWatch(id);
                      _snack('Watch stopped for $id');
                    },
                    child: const Text('Stop watch'),
                  ),

                  // “Motor” que simula actualizaciones de servidor:
                  // - Asegura doc
                  // - Inicia watch
                  // - Empieza a incrementar un contador cada segundo
                  ElevatedButton(
                    onPressed: () async {
                      final String id = _docIdCtrl.text.trim();
                      await _bloc.ensureDoc(
                        docId: id,
                        create: () => _buildUser(id),
                      );

                      _bloc.startWatch(id); // verás los cambios en vivo
                      await _ticker?.start(id);

                      _snack('Auto +1/sec started on $id');
                    },
                    child: const Text('Auto +1/sec (start)'),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      await _ticker?.stop();
                      _snack('Auto +1/sec stopped');
                    },
                    child: const Text('Auto +1/sec (stop)'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Estado del BLoC (lo que debería consumir tu UI real)
              _StateView(state: state),

              const SizedBox(height: 80),
              const SizedBox(height: 12),

              // Vista de “raw” (desde Service directly) para enseñar el JSON crudo
              // que viaja por la capa de transporte. Útil para depurar el watch.
              _RawCountView(
                service: _service,
                collection: 'users',
                docId: _docIdCtrl.text,
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- UI bits ---------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.loading, required this.isWatching});

  final bool loading;
  final bool isWatching;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (loading)
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        Text('Loading: $loading'),
        const SizedBox(width: 16),
        Text('Watching: $isWatching'),
      ],
    );
  }
}

class _DocIdField extends StatelessWidget {
  const _DocIdField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'docId',
        border: OutlineInputBorder(),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  const _StateView({required this.state});
  final WsDbState<UserModel> state;

  @override
  Widget build(BuildContext context) {
    final ErrorItem? err = state.error;
    final UserModel? user = state.doc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Bloc state:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _kv('docId', state.docId),
        _kv('loading', state.loading.toString()),
        _kv('isWatching', state.isWatching.toString()),
        const SizedBox(height: 12),
        if (err != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.93),
              border: Border.all(color: Colors.red.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Error: ${err.code}\n${err.title}\n${err.description}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (user != null) ...<Widget>[
          const SizedBox(height: 12),
          const Text('User:', style: TextStyle(fontWeight: FontWeight.bold)),
          _kv('id', user.id),
          _kv('displayName', user.displayName),
          _kv('email', user.email),
          _kv('photoUrl', user.photoUrl),
          _kv('jwt(json)', Utils.mapToString(user.jwt)),
        ],
      ],
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 120, child: Text('$k:')),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }
}

/// Cómo sembrar/actualizar el doc para que el watch “se vea”:
///
/// Este motor usa **el Service directamente** para simular cambios producidos por
/// el servidor. Así el Repository/Gateway/Bloc “ven” actualizaciones como en
/// producción.
///
/// - `seedMode` define qué hacer si el doc no existe (no crearlo, crearlo con
///   mínimo, o crearlo con una factoría custom).
/// - En esta variante el contador vive dentro de `jwt.countRef` (clave común
///   que siempre está en los JSON de usuario). Si prefieres un campo de nivel
///   superior (`count`), adapta `_ensureCountField/_tick` y la UI de `_RawCountView`.
enum SeedMode {
  /// No crea el documento si no existe. El ticker solo incrementa si ya hay doc.
  none,

  /// Crea un doc mínimo: solo {'count': 0} o el campo que decidas.
  minimalCountOnly,

  /// Crea usando una factoría custom (por ejemplo, traer un JSON externo).
  customFactory,
}

/// Tiny engine que incrementa cada [interval] un contador dentro del JSON.
///
/// - Garantiza que el doc tenga el campo contador.
/// - Cada tick: lee el JSON actual, incrementa y guarda.
/// - Usa **ServiceWsDatabase** para simular backend y que el *watch* dispare.
///
/// Si decides mover el contador a otra ruta (p.ej. `count` toplevel),
/// ajusta el merge en `_ensureCountField/_tick` y la vista `_RawCountView`.
class WsDocTicker {
  WsDocTicker({
    required ServiceWsDatabase<Map<String, dynamic>> service,
    required String collection,
    required String docId,
    this.interval = const Duration(seconds: 1),
    this.seedMode = SeedMode.minimalCountOnly,
    this.seedFactory,
  })  : _service = service,
        _collection = collection,
        _docId = docId;

  final ServiceWsDatabase<Map<String, dynamic>> _service;
  final String _collection;
  String _docId;
  final Duration interval;

  /// Estrategia para crear doc si está ausente.
  final SeedMode seedMode;

  /// Factoría opcional para SeedMode.customFactory. Recibe `docId` y devuelve el JSON base.
  final Map<String, dynamic> Function(String docId)? seedFactory;

  Timer? _timer;
  bool get isRunning => _timer != null;

  Future<void> start([String? docId]) async {
    if (docId != null) {
      _docId = docId;
    }
    if (_timer != null) {
      return;
    }

    await _ensureCountField();
    _timer = Timer.periodic(interval, (_) => _tick());
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _ensureCountField() async {
    try {
      final Map<String, dynamic> json = await _service.readDocument(
        collection: _collection,
        docId: _docId,
      );

      // Contador embebido en jwt.countRef — cambia aquí si usas otra ruta.
      final Map<String, dynamic> jwt = Utils.mapFromDynamic(json['jwt']);
      if (!jwt.containsKey('countRef')) {
        final Map<String, dynamic> merged = <String, dynamic>{
          ...json,
          'jwt': <String, dynamic>{...jwt, 'countRef': 0},
        };
        await _service.saveDocument(
          collection: _collection,
          docId: _docId,
          document: merged,
        );
      }
    } catch (_) {
      // Doc ausente
      if (seedMode == SeedMode.none) {
        return;
      }

      Map<String, dynamic> base = const <String, dynamic>{};
      if (seedMode == SeedMode.customFactory) {
        base = seedFactory?.call(_docId) ?? const <String, dynamic>{};
      }

      await _service.saveDocument(
        collection: _collection,
        docId: _docId,
        document: <String, dynamic>{
          ...base,
          'jwt': <String, dynamic>{'countRef': 0},
        },
      );
    }
  }

  Future<void> _tick() async {
    try {
      final Map<String, dynamic> json = await _service.readDocument(
        collection: _collection,
        docId: _docId,
      );

      final Map<String, dynamic> jwt = Utils.mapFromDynamic(json['jwt']);
      final int current = Utils.getIntegerFromDynamic(jwt['countRef']);

      final Map<String, dynamic> next = <String, dynamic>{
        ...json,
        'jwt': <String, dynamic>{...jwt, 'countRef': current + 1},
      };

      await _service.saveDocument(
        collection: _collection,
        docId: _docId,
        document: next,
      );
    } catch (_) {
      if (seedMode == SeedMode.none) {
        return;
      }

      Map<String, dynamic> base = const <String, dynamic>{};
      if (seedMode == SeedMode.customFactory) {
        base = seedFactory?.call(_docId) ?? const <String, dynamic>{};
      }
      await _service.saveDocument(
        collection: _collection,
        docId: _docId,
        document: <String, dynamic>{
          ...base,
          'jwt': <String, dynamic>{'countRef': 0},
        },
      );
    }
  }
}

/// Vista auxiliar que muestra el **JSON crudo** que emite el Service al hacer
/// watch del documento. Es útil para depurar si las actualizaciones llegan.
///
/// **Nota:** En esta demo el ticker incrementa `jwt.countRef`. Si decides
/// mostrar ese valor, extrae `raw['jwt']['countRef']`. Aquí se deja el ejemplo
/// simple con `raw['count']` para ilustrar que puedes adaptar el render a la
/// ruta que uses en tu payload.
class _RawCountView extends StatelessWidget {
  const _RawCountView({
    required this.service,
    required this.collection,
    required this.docId,
  });

  final ServiceWsDatabase<Map<String, dynamic>> service;
  final String collection;
  final String docId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: service.documentStream(collection: collection, docId: docId),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snap) {
        final Map<String, dynamic> raw = snap.data ?? const <String, dynamic>{};

        // Si usas jwt.countRef:
        // final int count = Utils.getIntegerFromDynamic(
        //   Utils.mapFromDynamic(raw['jwt'])['countRef'],
        // );
        // Para mantener el ejemplo original, se deja 'count' toplevel:
        final int count = Utils.getIntegerFromDynamic(raw['count']);

        return Row(
          children: <Widget>[
            const Text(
              'Raw count: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('$raw : $count'),
          ],
        );
      },
    );
  }
}
