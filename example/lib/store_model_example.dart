import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  runApp(const PetStoreApp());
}

/// Top-level Jocaagura Pet Store demo app.
/// UI in Spanish; public DartDoc in English as per Jocaagura docs.
/// Suggested flow illustrated inside this single file:
/// UI → AppManager → Bloc → UseCase → Repository → Gateway → Service
class PetStoreApp extends StatefulWidget {
  const PetStoreApp({super.key});

  @override
  State<PetStoreApp> createState() => _PetStoreAppState();
}

class _PetStoreAppState extends State<PetStoreApp> {
  late final PetStoreAppManager _app;

  @override
  void initState() {
    super.initState();
    _app = PetStoreAppManager();
    _app.bootstrap(); // seed store, catalog, empty ledger/cart
  }

  @override
  void dispose() {
    _app.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jocaagura Pet Store',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: PetStoreHome(app: _app),
    );
  }
}

/* ──────────────────────────────────────────────────────────────────────────
 * UI (Pages & Widgets)
 * ────────────────────────────────────────────────────────────────────────── */

class PetStoreHome extends StatefulWidget {
  const PetStoreHome({required this.app, super.key});

  final PetStoreAppManager app;

  @override
  State<PetStoreHome> createState() => _PetStoreHomeState();
}

class _PetStoreHomeState extends State<PetStoreHome> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final PetStoreAppManager app = widget.app;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jocaagura Pet Store'),
        actions: <Widget>[
          // Botón carrito con indicador de cantidad (sin paquetes externos)
          StreamBuilder<List<ModelItem>>(
            stream: app.cartBloc.stream,
            builder: (BuildContext _, AsyncSnapshot<List<ModelItem>> snap) {
              final int count = snap.data?.length ?? 0;
              return Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  IconButton(
                    tooltip: 'Carrito',
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CartPage(app: app),
                        ),
                      );
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 10,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Header de tienda
          StreamBuilder<StoreModel>(
            stream: app.storeBloc.stream,
            builder: (_, AsyncSnapshot<StoreModel> snap) {
              final StoreModel store = snap.data ?? defaultStoreModel;
              return StoreHeader(store: store);
            },
          ),
          // Buscador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o categoría...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (String v) => setState(() => _query = v.trim()),
            ),
          ),
          // Lista de productos (filtrada por _query)
          Expanded(
            child: StreamBuilder<List<ModelItem>>(
              stream: app.itemsBloc.stream,
              builder: (_, AsyncSnapshot<List<ModelItem>> snap) {
                final List<ModelItem> all = snap.data ?? <ModelItem>[];
                final String q = _query.toLowerCase();
                final List<ModelItem> filtered = q.isEmpty
                    ? all
                    : all.where((ModelItem e) {
                        return e.name.toLowerCase().contains(q) ||
                            e.type.category.toLowerCase().contains(q);
                      }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('Sin resultados. Intenta con otro término.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (_, int i) {
                    final ModelItem item = filtered[i];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(item.name.characters.first.toUpperCase()),
                      ),
                      title: Text(item.name),
                      subtitle: Text(
                        '${item.type.category} • ${item.price}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        tooltip: 'Agregar al carrito',
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () => app.addToCart(item),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                ItemDetailPage(app: app, item: item),
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: filtered.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StoreHeader extends StatelessWidget {
  const StoreHeader({required this.store, super.key});

  final StoreModel store;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Nombre + Alias como subtítulo
            Text(
              store.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              store.alias,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            // NIT con dígito de verificación
            Text('NIT: ${store.nitNumber}'),
            // Teléfonos formateados
            Text('Tel 1: ${store.formatedPhoneNumber1}'),
            Text('Tel 2: ${store.formatedPhoneNumber2}'),
          ],
        ),
      ),
    );
  }
}

class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({required this.app, required this.item, super.key});

  final PetStoreAppManager app;
  final ModelItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => app.addToCart(item),
        label: const Text('Agregar al carrito'),
        icon: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text(item.name),
              subtitle: Text(item.description),
            ),
            const SizedBox(height: 8),
            Text('Categoría: ${item.type.category}'),
            const SizedBox(height: 4),
            Text('Precio: ${item.price}'),
            const SizedBox(height: 12),
            Text(
              'Atributos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            for (final ModelAttribute<dynamic> a in item.attributes)
              Text('• ${a.name}: ${a.value}'),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({required this.app, super.key});

  final PetStoreAppManager app;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: StreamBuilder<List<ModelItem>>(
        stream: app.cartBloc.stream,
        builder: (_, AsyncSnapshot<List<ModelItem>> snap) {
          final List<ModelItem> cart = snap.data ?? <ModelItem>[];
          if (cart.isEmpty) {
            return const Center(child: Text('Tu carrito está vacío.'));
          }

          final int minorTotal =
              cart.fold<int>(0, (int acc, ModelItem e) => acc + e.price.amount);
          final double decimalTotal =
              minorTotal / pow(10, ModelPrice.defaultMathprecision).toDouble();

          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (_, int i) {
                    final ModelItem item = cart[i];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text('${item.type.category} • ${item.price}'),
                      trailing: IconButton(
                        tooltip: 'Quitar',
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => app.removeFromCart(item),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: cart.length,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Expanded(child: Text('Total')),
                        Text('💰 ${decimalTotal.toStringAsFixed(
                          ModelPrice.defaultMathprecision,
                        )} COP'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Confirmar compra'),
                        onPressed: () async {
                          await app.confirmPurchase();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Compra registrada como ingreso.'),
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/* ──────────────────────────────────────────────────────────────────────────
 * AppManager (ties Blocs + UseCases together)
 * ────────────────────────────────────────────────────────────────────────── */

/// Central coordinator for Pet Store demo.
/// Holds the reactive blocs and orchestrates use cases.
class PetStoreAppManager {
  PetStoreAppManager()
      : storeBloc = BlocGeneral<StoreModel>(defaultStoreModel),
        itemsBloc = BlocGeneral<List<ModelItem>>(<ModelItem>[]),
        cartBloc = BlocGeneral<List<ModelItem>>(<ModelItem>[]),
        ledgerBloc = BlocGeneral<LedgerModel>(
          defaultLedgerModel(), // starts empty-ish; we will append incomes on purchase
        ) {
    // Wiring use cases with repository pipeline
    _service = FakePetStoreService();
    _gateway = PetStoreGatewayImpl(_service);
    _repository = PetStoreRepositoryImpl(_gateway);

    loadStore = LoadStoreUseCase(_repository, storeBloc);
    loadCatalog = LoadCatalogUseCase(_repository, itemsBloc);
    addItemToCart = AddToCartUseCase(cartBloc);
    removeItemFromCart = RemoveFromCartUseCase(cartBloc);
    registerSale = RegisterSaleUseCase(ledgerBloc);
  }

  // Reactive blocs (domain's BlocGeneral)
  final BlocGeneral<StoreModel> storeBloc;
  final BlocGeneral<List<ModelItem>> itemsBloc;
  final BlocGeneral<List<ModelItem>> cartBloc;
  final BlocGeneral<LedgerModel> ledgerBloc;

  // Pipeline: Service → Gateway → Repository
  late final PetStoreService _service;
  late final PetStoreGateway _gateway;
  late final PetStoreRepository _repository;

  // Use cases
  late final LoadStoreUseCase loadStore;
  late final LoadCatalogUseCase loadCatalog;
  late final AddToCartUseCase addItemToCart;
  late final RemoveFromCartUseCase removeItemFromCart;
  late final RegisterSaleUseCase registerSale;

  /// Bootstraps initial data and emits into blocs.
  Future<void> bootstrap() async {
    await loadStore();
    await loadCatalog();
  }

  /// Convenience methods (UI-friendly)
  void addToCart(ModelItem item) => addItemToCart(item);

  void removeFromCart(ModelItem item) => removeItemFromCart(item);

  /// Confirms purchase: creates a single income FinancialMovement and updates ledger.
  Future<void> confirmPurchase() async {
    final List<ModelItem> cart = cartBloc.value;
    if (cart.isEmpty) {
      return;
    }

    final int minorTotal =
        cart.fold<int>(0, (int acc, ModelItem e) => acc + e.price.amount);

    await registerSale(
      concept: 'Venta',
      decimalAmount:
          minorTotal / pow(10, ModelPrice.defaultMathprecision).toDouble(),
      when: DateTime.now(),
    );

    // Clear cart
    cartBloc.value = <ModelItem>[];
  }

  void dispose() {
    storeBloc.dispose();
    itemsBloc.dispose();
    cartBloc.dispose();
    ledgerBloc.dispose();
  }
}

/* ──────────────────────────────────────────────────────────────────────────
 * Use Cases
 * ────────────────────────────────────────────────────────────────────────── */

/// Loads the current store and publishes into [storeBloc].
class LoadStoreUseCase {
  LoadStoreUseCase(this._repo, this._storeBloc);

  final PetStoreRepository _repo;
  final BlocGeneral<StoreModel> _storeBloc;

  /// Executes the use case.
  Future<void> call() async {
    final StoreModel store = await _repo.getStore();
    _storeBloc.value = store;
  }
}

/// Loads catalog items and publishes into [itemsBloc].
class LoadCatalogUseCase {
  LoadCatalogUseCase(this._repo, this._itemsBloc);

  final PetStoreRepository _repo;
  final BlocGeneral<List<ModelItem>> _itemsBloc;

  Future<void> call() async {
    final List<ModelItem> items = await _repo.getItems();
    _itemsBloc.value = items;
  }
}

/// Adds an item to the [cartBloc] keeping immutability semantics.
class AddToCartUseCase {
  AddToCartUseCase(this._cartBloc);

  final BlocGeneral<List<ModelItem>> _cartBloc;

  void call(ModelItem item) {
    final List<ModelItem> next = <ModelItem>[..._cartBloc.value, item];
    _cartBloc.value = List<ModelItem>.unmodifiable(next);
  }
}

/// Removes the first occurrence of an item from the [cartBloc].
class RemoveFromCartUseCase {
  RemoveFromCartUseCase(this._cartBloc);

  final BlocGeneral<List<ModelItem>> _cartBloc;

  void call(ModelItem item) {
    final List<ModelItem> copy = <ModelItem>[..._cartBloc.value];
    final int idx = copy.indexWhere((ModelItem e) => e == item);
    if (idx >= 0) {
      copy.removeAt(idx);
      _cartBloc.value = List<ModelItem>.unmodifiable(copy);
    }
  }
}

/// Registers a sale as an income movement into [ledgerBloc] with precision 2.
///
/// We align ledger precision with [ModelPrice.defaultMathprecision] (2)
/// to keep a coherent, extensible representation with prices.
class RegisterSaleUseCase {
  RegisterSaleUseCase(this._ledgerBloc);

  final BlocGeneral<LedgerModel> _ledgerBloc;

  Future<void> call({
    required String concept,
    required double decimalAmount,
    required DateTime when,
  }) async {
    final FinancialMovementModel movement = FinancialMovementModel.fromDecimal(
      id: 'sale-${when.microsecondsSinceEpoch}',
      decimalAmount: decimalAmount,
      date: when,
      concept: concept,
      category: 'Income',
      createdAt: when,
      precision: ModelPrice.defaultMathprecision, // 2
    );

    final LedgerModel current = _ledgerBloc.value;
    final List<FinancialMovementModel> incomes = <FinancialMovementModel>[
      ...current.incomeLedger,
      movement,
    ];

    _ledgerBloc.value = current.copyWith(
      incomeLedger: List<FinancialMovementModel>.unmodifiable(incomes),
    );
  }
}

/* ──────────────────────────────────────────────────────────────────────────
 * Repository
 * ────────────────────────────────────────────────────────────────────────── */

/// Repository contract for the Pet Store demo.
/// In a real app, this would live in the `Repository` layer.
abstract class PetStoreRepository {
  Future<StoreModel> getStore();

  Future<List<ModelItem>> getItems();
}

/// Simple repository implementation delegating to [PetStoreGateway].
class PetStoreRepositoryImpl implements PetStoreRepository {
  PetStoreRepositoryImpl(this._gateway);

  final PetStoreGateway _gateway;

  @override
  Future<StoreModel> getStore() => _gateway.fetchStore();

  @override
  Future<List<ModelItem>> getItems() => _gateway.fetchItems();
}

/* ──────────────────────────────────────────────────────────────────────────
 * Gateway
 * ────────────────────────────────────────────────────────────────────────── */

/// Gateway contract responsible for translating raw service JSON into domain models.
abstract class PetStoreGateway {
  Future<StoreModel> fetchStore();

  Future<List<ModelItem>> fetchItems();
}

/// Minimal gateway implementation using a JSON-first fake service.
class PetStoreGatewayImpl implements PetStoreGateway {
  PetStoreGatewayImpl(this._service);

  final PetStoreService _service;

  @override
  Future<StoreModel> fetchStore() async {
    final Map<String, dynamic> json = await _service.getStoreJson();
    return StoreModel.fromJson(json);
  }

  @override
  Future<List<ModelItem>> fetchItems() async {
    final List<Map<String, dynamic>> raw = await _service.getItemsJson();
    return raw.map(ModelItem.fromJson).toList(growable: false);
  }
}

/* ──────────────────────────────────────────────────────────────────────────
 * Service (Fake / In-memory)
 * ────────────────────────────────────────────────────────────────────────── */

/// Fake service that returns JSON shaped by the domain enums `.name`.
/// This mimics a backend returning canonical JSON for the gateway.
abstract class PetStoreService {
  Future<Map<String, dynamic>> getStoreJson();

  Future<List<Map<String, dynamic>>> getItemsJson();
}

/// In-memory fake service with seed data for "Jocaagura Pet Store".
class FakePetStoreService implements PetStoreService {
  @override
  Future<Map<String, dynamic>> getStoreJson() async {
    // Using defaultAddressModel from the domain.
    const StoreModel store = StoreModel(
      id: 'store_001',
      nit: 987654321,
      photoUrl: 'https://example.com/photo.jpg',
      coverPhotoUrl: 'https://example.com/cover.jpg',
      email: 'store@jocaagura.dev',
      ownerEmail: 'owner@jocaagura.dev',
      name: 'Jocaagura Pet Store',
      alias: 'Pet Store',
      address: defaultAddressModel,
      phoneNumber1: 3001234567,
      phoneNumber2: 6017654321,
    );
    return store.toJson();
  }

  @override
  Future<List<Map<String, dynamic>>> getItemsJson() async {
    // Seed: 6 productos típicos (algunos con id vacío para mostrar fallback de categoría)
    final List<ModelItem> items = <ModelItem>[
      _item(
        id: '',
        name: 'Comida Premium Gato 1Kg',
        desc: 'Alimento balanceado para gato adulto.',
        cat: 'cat-food',
        priceMinor: 42000,
        attrs: <ModelAttribute<dynamic>>[
          AttributeModel.from<String>('Sabor', 'Pollo')!,
          AttributeModel.from<int>('Stock', 25)!,
        ],
      ),
      _item(
        id: 'SKU-ARENA-CLASICA',
        name: 'Arena Sanitaria 10Kg',
        desc: 'Bentonita aglomerante.',
        cat: 'cat-sand',
        priceMinor: 38000,
        attrs: <ModelAttribute<dynamic>>[
          AttributeModel.from<String>('Fragancia', 'Neutra')!,
          AttributeModel.from<int>('Stock', 15)!,
        ],
      ),
      _item(
        id: '',
        name: 'Juguete Ratón',
        desc: 'Juguete interactivo para gato.',
        cat: 'toys',
        priceMinor: 15000,
        attrs: <ModelAttribute<dynamic>>[
          AttributeModel.from<String>('Color', 'Azul')!,
          AttributeModel.from<int>('Stock', 50)!,
        ],
      ),
      _item(
        id: 'SKU-CAMA-M',
        name: 'Cama Mediana',
        desc: 'Cama acolchada para mascota mediana.',
        cat: 'beds',
        priceMinor: 69000,
        attrs: <ModelAttribute<dynamic>>[
          AttributeModel.from<String>('Color', 'Gris')!,
          AttributeModel.from<int>('Stock', 8)!,
        ],
      ),
      _item(
        id: '',
        name: 'Correa Nylon',
        desc: 'Correa resistente 1.5m.',
        cat: 'accessories',
        priceMinor: 22000,
        attrs: <ModelAttribute<dynamic>>[
          AttributeModel.from<String>('Color', 'Roja')!,
          AttributeModel.from<int>('Stock', 30)!,
        ],
      ),
      _item(
        id: 'SKU-SNACK-01',
        name: 'Snacks de Pollo 100g',
        desc: 'Premios blandos.',
        cat: 'snacks',
        priceMinor: 12000,
        attrs: <ModelAttribute<dynamic>>[
          AttributeModel.from<String>('Tamaño', '100g')!,
          AttributeModel.from<int>('Stock', 40)!,
        ],
      ),
    ];

    return items.map((ModelItem e) => e.toJson()).toList(growable: false);
  }

  static ModelItem _item({
    required String id,
    required String name,
    required String desc,
    required String cat,
    required int priceMinor,
    required List<ModelAttribute<dynamic>> attrs,
  }) {
    return ModelItem(
      id: id,
      name: name,
      description: desc,
      type: ModelCategory(category: cat, description: 'Pet store category'),
      price: ModelPrice(
        amount: priceMinor,
        currency: CurrencyEnum.COP,
      ),
      attributes: attrs,
    );
  }
}
