import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

/// ###########################################################################
/// # WS Contacts Demo (document + collection)
/// ###########################################################################

void main() {
  runApp(const WsCrudContactsDemoApp());
}

class WsCrudContactsDemoApp extends StatefulWidget {
  const WsCrudContactsDemoApp({super.key});

  @override
  State<WsCrudContactsDemoApp> createState() => _WsCrudContactsDemoAppState();
}

class _WsCrudContactsDemoAppState extends State<WsCrudContactsDemoApp> {
  late final ServiceWsDb _service;

  late final GatewayWsDatabase _contactsGateway;
  late final RepositoryWsDatabase<ContactModel> _contactsRepo;
  late final FacadeWsDatabaseUsecases<ContactModel> _contactsFacade;
  late final BlocWsDatabase<ContactModel> _contactsBloc;

  // NEW: collection BLoC for realtime list of contacts
  late final ContactsCollectionBloc _contactsCollectionBloc;

  @override
  void initState() {
    super.initState();

    // 1) Service (reemplaza aquí por tu servicio real)
    _service = FakeServiceWsDb(
      config: WsDbConfig(
        latency:
            Duration(milliseconds: 250 + Random().nextInt(350)), // 250–600ms
      ),
    );

    // 2) Gateway por colección (document-centric)
    _contactsGateway = GatewayWsDbImpl(
      service: _service,
      collection: 'contacts',
      mapper: const DefaultErrorMapper(),
      readAfterWrite: true,
      treatEmptyAsMissing: true,
    );

    // 3) Repository tipado
    _contactsRepo = RepositoryWsDatabaseImpl<ContactModel>(
      gateway: _contactsGateway,
      fromJson: ContactModel.fromJson,
      mapper: const DefaultErrorMapper(),
      serializeWrites: true,
    );

    // 4) Facade
    _contactsFacade = FacadeWsDatabaseUsecases<ContactModel>.fromRepository(
      repository: _contactsRepo,
      fromJson: ContactModel.fromJson,
    );

    // 5) BLoC document-centric
    _contactsBloc = BlocWsDatabase<ContactModel>(facade: _contactsFacade);

    // 6) NEW: BLoC collection-centric (solo para el demo)
    _contactsCollectionBloc = ContactsCollectionBloc(
      service: _service,
      collection: 'contacts',
      fromJson: ContactModel.fromJson,
    )..start(); // comienza a escuchar la colección
  }

  @override
  void dispose() {
    _contactsBloc.dispose();
    _contactsCollectionBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WS Contacts Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: WsContactsHome(
        contactsBloc: _contactsBloc,
        contactsCollectionBloc: _contactsCollectionBloc,
      ),
    );
  }
}

/// Pantalla con:
/// - Formulario ContactModel (doc-centric)
/// - Acciones CRUD y Watch (doc)
/// - Panel de estado del doc + ledger
/// - NEW: Panel de **colección** en tiempo real (lista)
class WsContactsHome extends StatefulWidget {
  const WsContactsHome({
    required this.contactsBloc,
    required this.contactsCollectionBloc,
    super.key,
  });

  final BlocWsDatabase<ContactModel> contactsBloc;
  final ContactsCollectionBloc contactsCollectionBloc;

  @override
  State<WsContactsHome> createState() => _WsContactsHomeState();
}

class _WsContactsHomeState extends State<WsContactsHome> {
  final TextEditingController _id = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _relationship = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();

  final List<String> _log = <String>[];
  StreamSubscription<WsDbState<ContactModel>>? _sub;
  bool _watching = false;

  @override
  void initState() {
    super.initState();
    _sub = widget.contactsBloc.stream.listen((WsDbState<ContactModel> s) {
      setState(() {
        _log.add('[${DateTime.now().toIso8601String()}] $s');
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  ContactModel _fromForm() => ContactModel(
        id: _id.text.trim(),
        name: _name.text.trim(),
        relationship: _relationship.text.trim(),
        phoneNumber: _phone.text.trim(),
        email: _email.text.trim(),
      );

  void _fillForm(ContactModel c) {
    _id.text = c.id;
    _name.text = c.name;
    _relationship.text = c.relationship;
    _phone.text = c.phoneNumber;
    _email.text = c.email;
  }

  Future<void> _read() async {
    if (_id.text.trim().isEmpty) {
      return;
    }
    final Either<ErrorItem, ContactModel> res =
        await widget.contactsBloc.readDoc(_id.text.trim());
    res.fold(
      (ErrorItem e) => _snack('READ error: ${e.code}'),
      (ContactModel c) {
        _fillForm(c);
        _snack('READ ok: ${c.id}');
      },
    );
  }

  Future<void> _write() async {
    final ContactModel c = _fromForm();
    if (c.id.isEmpty) {
      return;
    }
    final Either<ErrorItem, ContactModel> res =
        await widget.contactsBloc.writeDoc(c.id, c);
    res.fold(
      (ErrorItem e) => _snack('WRITE error: ${e.code}'),
      (ContactModel saved) {
        _fillForm(saved);
        _snack('WRITE ok: ${saved.id}');
      },
    );
  }

  Future<void> _delete() async {
    if (_id.text.trim().isEmpty) {
      return;
    }
    final Either<ErrorItem, Unit> res =
        await widget.contactsBloc.deleteDoc(_id.text.trim());
    res.fold(
      (ErrorItem e) => _snack('DELETE error: ${e.code}'),
      (_) => _snack('DELETE ok'),
    );
  }

  Future<void> _toggleWatch() async {
    final String id = _id.text.trim();
    if (id.isEmpty) {
      return;
    }
    if (_watching) {
      await widget.contactsBloc.stopWatch(id);
    } else {
      await widget.contactsBloc.startWatch(id);
    }
    setState(() => _watching = !_watching);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts WS CRUD (JSON-first)'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Clear log',
            onPressed: () => setState(_log.clear),
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _HeaderCard(watching: _watching),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(child: _formCard()),
                const VerticalDivider(width: 1),
                Expanded(child: _stateAndLogAndCollectionCard()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _fabBar(),
    );
  }

  Widget _fabBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FloatingActionButton.extended(
          heroTag: 'read',
          onPressed: _read,
          icon: const Icon(Icons.download),
          label: const Text('Read'),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.extended(
          heroTag: 'write',
          onPressed: _write,
          icon: const Icon(Icons.upload),
          label: const Text('Write/Upsert'),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.extended(
          heroTag: 'delete',
          onPressed: _delete,
          icon: const Icon(Icons.delete),
          label: const Text('Delete'),
          backgroundColor: Colors.redAccent,
        ),
        const SizedBox(height: 8),
        FloatingActionButton.extended(
          heroTag: 'watch',
          onPressed: _toggleWatch,
          icon: Icon(_watching ? Icons.visibility_off : Icons.visibility),
          label: Text(_watching ? 'Stop watch' : 'Start watch'),
          backgroundColor: _watching ? Colors.orange : null,
        ),
      ],
    );
  }

  Widget _formCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: <Widget>[
              const Text('ContactModel form', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              TextField(
                controller: _id,
                decoration: const InputDecoration(
                  labelText: 'id (docId)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _relationship,
                decoration: const InputDecoration(
                  labelText: 'relationship',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'phoneNumber',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              _HelperBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stateAndLogAndCollectionCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 1,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 8),
            const Text(
              'WsDbState<ContactModel>',
              style: TextStyle(fontSize: 18),
            ),
            const Divider(),
            // ---- Doc state ----
            Expanded(
              flex: 2,
              child: StreamBuilder<WsDbState<ContactModel>>(
                stream: widget.contactsBloc.stream,
                initialData: widget.contactsBloc.value,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<WsDbState<ContactModel>> snap,
                ) {
                  final WsDbState<ContactModel> s =
                      snap.data ?? WsDbState<ContactModel>.idle();
                  final ContactModel? c = s.doc;
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _kv('loading', '${s.loading}'),
                        _kv('docId', s.docId),
                        _kv('isWatching', '${s.isWatching}'),
                        _kv('error', s.error?.code ?? 'null'),
                        const Divider(),
                        const Text(
                          'doc snapshot',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              c == null ? 'null' : c.toJson().toString(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            // ---- NEW: Collection view ----
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Contacts collection (realtime)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 3,
              child: StreamBuilder<List<ContactModel>>(
                stream: widget.contactsCollectionBloc.stream,
                initialData: widget.contactsCollectionBloc.value,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<ContactModel>> snap,
                ) {
                  final List<ContactModel> items =
                      snap.data ?? const <ContactModel>[];
                  if (items.isEmpty) {
                    return const Center(child: Text('No contacts yet'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, int i) {
                      final ContactModel c = items[i];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(c.name.isEmpty ? '?' : c.name[0]),
                        ),
                        title: Text(c.name),
                        subtitle: Text(
                          '${c.relationship} • ${c.phoneNumber}\n${c.email}',
                        ),
                        isThreeLine: true,
                        trailing: Text('#${c.id}'),
                        onTap: () {
                          // Autorrellena form al tocar un item
                          _fillForm(c);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            // ---- Ledger simple ----
            const Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 4),
              child: Text('ledger (latest first)'),
            ),
            Expanded(
              flex: 2,
              child: ListView.builder(
                reverse: true,
                itemCount: _log.length,
                itemBuilder: (_, int i) {
                  final int idx = _log.length - 1 - i;
                  return Text(_log[idx], style: const TextStyle(fontSize: 12));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.watching});

  final bool watching;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: <Widget>[
            Icon(Icons.cloud_sync),
            SizedBox(width: 8),
            Text(
              'JSON-first WS flow • Service → Gateway → Repository → Facade → BLoC',
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

class _HelperBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: SelectableText('''
How to swap to your real service:

1) Replace the Fake by your Service implementing ServiceWsDb:
   final ServiceWsDb service = FirestoreServiceWsDb(...);
   // or
   final ServiceWsDb service = GoogleSheetsServiceWsDb(...);

2) Keep the Gateway as-is (JSON-first) for documents:
   GatewayWsDbImpl(
     service: service,
     collection: 'contacts',
     idKey: 'id',
     readAfterWrite: true,
     treatEmptyAsMissing: true,
   );

3) Repository typed + serializeWrites=true (FIFO per docId).
4) UI consumes WsDbState<ContactModel> from BlocWsDatabase<ContactModel>.

Collection note:
- For the demo, the collection list uses service.collectionStream('contacts')
  via a lightweight ContactsCollectionBloc. In production, consider adding a
  dedicated Gateway/Repository/Facade for collections too.
'''),
      ),
    );
  }
}

Widget _kv(String k, String v) {
  return Row(
    children: <Widget>[
      SizedBox(
        width: 120,
        child: Text(k, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      const Text(':  '),
      Expanded(child: Text(v)),
    ],
  );
}

/// ---------------------------------------------------------------------------
/// NEW: BLoC de colección mínimo para el demo (usa ServiceWsDb.collectionStream)
/// ---------------------------------------------------------------------------
class ContactsCollectionBloc extends BlocGeneral<List<ContactModel>> {
  ContactsCollectionBloc({
    required ServiceWsDb service,
    required String collection,
    required ContactModel Function(Map<String, dynamic>) fromJson,
  })  : _service = service,
        _collection = collection,
        _fromJson = fromJson,
        super(const <ContactModel>[]);

  final ServiceWsDb _service;
  final String _collection;
  final ContactModel Function(Map<String, dynamic>) _fromJson;

  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  void start() {
    _sub?.cancel();
    _sub = _service.collectionStream(collection: _collection).listen(
      (List<Map<String, dynamic>> rawList) {
        final List<ContactModel> items = <ContactModel>[];
        for (final Map<String, dynamic> m in rawList) {
          try {
            items.add(_fromJson(m));
          } catch (_) {
            // Swallow mapping errors in demo; in prod, mapea a ErrorItem/log.
          }
        }
        value = items;
      },
      onError: (Object e, StackTrace s) {
        // En demo, solo log. En prod, mapea a ErrorItem y publícalo en estado.
        // print('collection error: $e');
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
