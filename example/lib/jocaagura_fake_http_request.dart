// main.dart
//
// Copy–paste runnable Flutter app demonstrating a Pet Shop "REST-like" API
// using a simplified Jocaagura-style HTTP flow:
//
//   UI -> BlocHttpRequest -> Facade (usecases) -> Repository -> Gateway -> ServiceHttpRequest
//
// What this example IS
// --------------------
// ✅ A "contract & flow" demo:
// - Shows the complete pipeline running without real networking.
// - Lets you test Either<ErrorItem, ModelConfigHttpRequest> end-to-end.
// - Uses an in-memory VirtualCrudService to simulate a backend with state.
//
// What this example is NOT
// ------------------------
// ❌ Not a networking/caching/auth demo.
// ❌ Not a recommendation of putting metadata inside request bodies in production.
//
// Key roles (important distinction)
// --------------------------------
// 1) JocaaguraFakeHttpRequest (transport simulation):
//    - Dispatches requests to VirtualCrudService in the order they were registered.
//    - Can simulate latency and forced failures (throwOnGet/Post/Put/Delete).
//    - Can inject deterministic failures by route (errorRoutes) or return canned payloads.
//    - Does NOT enforce any payload shape beyond Map<String, dynamic>.
//      (Any {ok: ...} convention is produced by the virtual backend / mapper, not by the fake.)
//
// 2) VirtualCrudService (virtual backend semantics):
//    - Owns routing rules (canHandle) and request interpretation (method, URI, body).
//    - Owns validations and in-memory persistence (POST/PUT/DELETE mutate its "db").
//    - Owns the payload shape returned to the pipeline.
//      If your real backend is NOT {ok: ...}, model that raw payload here and swap the mapper.
//
// 3) ServiceHttpRequestAdapter (contract bridge):
//    - GatewayHttpRequestImpl expects ServiceHttpRequest (Uri in -> Map out).
//    - Our fake transport exposes ServiceHttp (String url in -> Map out; delete is void).
//    - Adapter decides how to serialize metadata and how to represent void methods like DELETE.
//    - This project intentionally does NOT use {ok:true/false} tricks in DELETE via exceptions.
//
// How to test quickly (manual QA)
// ------------------------------
// - Refresh: GET /v1/cats
// - Tap item: GET /v1/cats/:id
// - Create: POST /v1/cats
// - Update selected: PUT /v1/cats/:id
// - Delete selected: DELETE /v1/cats/:id
//
// Suggested scenarios:
// - Create with name=""               -> 422 validation_error
// - Create with name="gato-error"     -> 500 forced_create_error   (NOTE: must be exactly "gato-error")
// - Delete Kira                       -> 409 delete_forbidden
// - Enable config.errorRoutes[...]    -> deterministic route error
//
// Debug note
// ----------
// If you see "ERR_UNEXPECTED", it usually means a transport exception happened
// (throwOnPost/route error/StateError) or the mapper couldn't recognize the payload.
// Start by forcing throwOnPost/Put/Delete to false in FakeHttpRequestConfig.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  runApp(const PetShopApp());
}

/// Adapter that bridges:
/// - Gateway layer expects: ServiceHttpRequest (Uri in, Map out)
/// - Fake transport exposes: ServiceHttp (String url in, Map out; delete is void)
///
/// Why an adapter?
/// --------------
/// We keep the fake transport minimal and dependency-free.
/// This adapter is where you decide how metadata/headers/body are serialized,
/// and how void methods (DELETE) are represented for the upper layers.
///
/// Contract note
/// -------------
/// This example assumes the pipeline expects a "Jocaagura-friendly" payload
/// that can be mapped into ModelConfigHttpRequest and then into Either<ErrorItem,...>.
/// If your backend does NOT use {ok: ...} or similar conventions, you can:
/// - Return raw payloads from VirtualCrudService and plug a different mapper, or
/// - Keep the mapper and make VirtualCrudService emit the expected shape.
class ServiceHttpRequestAdapter implements ServiceHttpRequest {
  ServiceHttpRequestAdapter(this._service);

  final ServiceHttp _service;

  @override
  Future<Map<String, dynamic>> get(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    // Metadata is "out-of-band" information used by the pipeline (feature, operation, ids, etc).
    // In a real HTTP client you might forward it in headers or tracing context.
    // Here we keep the URL clean and place it in an x-tags header just for demo visibility.
    final Map<String, String> mergedHeaders = <String, String>{
      ...?headers,
      if (metadata.isNotEmpty) 'x-tags': metadata.toString(),
    };

    return _service.get(
      url: uri.toString(),
      headers: mergedHeaders.isEmpty ? null : mergedHeaders,
    );
  }

  @override
  Future<Map<String, dynamic>> post(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    // We include metadata in-body to make it available to the VirtualCrudService
    // during simulation. In real apps you might NOT do this.
    final Map<String, dynamic> jsonBody = <String, dynamic>{
      ...?body,
      'metadata': metadata,
    };

    return _service.post(
      url: uri.toString(),
      headers: headers,
      body: jsonBody,
    );
  }

  @override
  Future<Map<String, dynamic>> put(
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    final Map<String, dynamic> jsonBody = <String, dynamic>{
      ...?body,
      'metadata': metadata,
    };

    return _service.put(
      url: uri.toString(),
      headers: headers,
      body: jsonBody,
    );
  }

  @override
  Future<Map<String, dynamic>> delete(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) async {
    // ServiceHttp.delete(...) is void.
    // To keep the upper layers consistent (they expect a Map payload),
    // we convert:
    // - success -> a 204 canned response payload
    // - failure (exception) -> a 5xx canned response payload (or a mapping you prefer)
    try {
      await _service.delete(url: uri.toString(), headers: headers);

      return FakeHttpRequestConfig.cannedHttpResponse(
        method: HttpMethodEnum.delete,
        uri: uri,
        statusCode: 204,
        reasonPhrase: 'No Content',
        metadata: <String, dynamic>{'delete': true, ...metadata},
        timeout: timeout,
      );
    } catch (e) {
      // In simulation, DELETE failures are best represented as exceptions thrown by:
      // - FakeHttpRequestConfig throwOnDelete / errorRoutes
      // - or the VirtualCrudService implementation
      //
      // If you want finer control, you can inspect the exception type and map codes.
      return FakeHttpRequestConfig.cannedHttpResponse(
        method: HttpMethodEnum.delete,
        uri: uri,
        statusCode: 500,
        reasonPhrase: 'Virtual Delete Error',
        metadata: <String, dynamic>{
          ...metadata,
          'exception': e.toString(),
          'source': 'ServiceHttpRequestAdapter.delete',
        },
        timeout: timeout,
      );
    }
  }

  void dispose() => _service.dispose();
}

// ============================================================================
// 10) CatPatient REST virtual service + models
// ============================================================================

class CatPatient {
  const CatPatient({
    required this.id,
    required this.name,
    required this.animalType,
    required this.gender,
    required this.weightKg,
    required this.createdAt,
    required this.updatedAt,
    this.breed,
    this.color,
    this.birthDate,
    this.ageYears,
    this.microchipId,
    this.isSterilized,
    this.status = 'active',
    this.owner,
    this.energy,
    this.intelligence,
    this.joyful,
    this.hygiene,
    this.clinical = const <String, dynamic>{},
    this.vaccinations = const <Map<String, dynamic>>[],
    this.visits = const <Map<String, dynamic>>[],
    this.notes,
  });

  final String id;
  final String name;
  final String animalType; // 'feline'
  final String gender; // 'male' | 'female'
  final double weightKg;
  final String createdAt; // date-time
  final String updatedAt; // date-time

  final String? breed;
  final String? color;
  final String? birthDate; // YYYY-MM-DD
  final double? ageYears;
  final String? microchipId;
  final bool? isSterilized;
  final String status; // active|inactive|deceased

  final Map<String, dynamic>? owner;

  final double? energy;
  final double? intelligence;
  final double? joyful;
  final double? hygiene;

  final Map<String, dynamic> clinical;
  final List<Map<String, dynamic>> vaccinations;
  final List<Map<String, dynamic>> visits;

  final String? notes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'animalType': animalType,
      'gender': gender,
      'breed': breed,
      'color': color,
      'birthDate': birthDate,
      'ageYears': ageYears,
      'weightKg': weightKg,
      'microchipId': microchipId,
      'isSterilized': isSterilized,
      'status': status,
      'owner': owner == null ? null : Utils.mapFromDynamic(owner),
      'energy': energy,
      'intelligence': intelligence,
      'joyful': joyful,
      'hygiene': hygiene,
      'clinical': Utils.mapFromDynamic(clinical),
      'vaccinations': vaccinations
          .map((Map<String, dynamic> e) => Utils.mapFromDynamic(e))
          .toList(),
      'visits': visits
          .map((Map<String, dynamic> e) => Utils.mapFromDynamic(e))
          .toList(),
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static CatPatient fromJson(Map<String, dynamic> json) {
    return CatPatient(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      animalType: (json['animalType'] as String?) ?? 'feline',
      gender: (json['gender'] as String?) ?? 'male',
      weightKg: ((json['weightKg'] as num?) ?? 0).toDouble(),
      createdAt:
          (json['createdAt'] as String?) ?? DateTime.now().toIso8601String(),
      updatedAt:
          (json['updatedAt'] as String?) ?? DateTime.now().toIso8601String(),
      breed: json['breed'] as String?,
      color: json['color'] as String?,
      birthDate: json['birthDate'] as String?,
      ageYears: (json['ageYears'] as num?)?.toDouble(),
      microchipId: json['microchipId'] as String?,
      isSterilized: json['isSterilized'] as bool?,
      status: (json['status'] as String?) ?? 'active',
      owner: json['owner'] is Map
          ? Utils.mapFromDynamic(json['owner'] as Map<dynamic, dynamic>)
          : null,
      energy: (json['energy'] as num?)?.toDouble(),
      intelligence: (json['intelligence'] as num?)?.toDouble(),
      joyful: (json['joyful'] as num?)?.toDouble(),
      hygiene: (json['hygiene'] as num?)?.toDouble(),
      clinical: json['clinical'] is Map
          ? Utils.mapFromDynamic(json['clinical'] as Map<dynamic, dynamic>)
          : const <String, dynamic>{},
      vaccinations: (json['vaccinations'] is List)
          ? (json['vaccinations'] as List<dynamic>)
              .whereType<Map<dynamic, dynamic>>()
              .map((Map<dynamic, dynamic> e) => Utils.mapFromDynamic(e))
              .toList()
          : const <Map<String, dynamic>>[],
      visits: (json['visits'] is List)
          ? (json['visits'] as List<dynamic>)
              .whereType<Map<dynamic, dynamic>>()
              .map((Map<dynamic, dynamic> e) => Utils.mapFromDynamic(e))
              .toList()
          : const <Map<String, dynamic>>[],
      notes: json['notes'] as String?,
    );
  }
}

class VetCatsVirtualCrudService implements VirtualCrudService {
  VetCatsVirtualCrudService({required this.baseUri}) {
    reset();
  }

  final Uri baseUri;

  // In-memory "database".
  //
  // Intentional mutation:
  // - This map represents server-side state.
  // - POST/PUT/DELETE mutate _db so the UI can observe realistic CRUD behavior.
  // - This is NOT the same as mutating returned payloads; it is the simulated backend state.
  final Map<String, CatPatient> _db = <String, CatPatient>{};

  @override
  bool canHandle(RequestContext ctx) {
    // canHandle is a routing guard:
    // - It prevents this service from handling requests outside its baseUri scope.
    // - In bigger simulations you can register multiple VirtualCrudService instances
    //   (cats, dogs, billing, auth, etc.) and the fake will dispatch in order.

    final bool sameHost = ctx.uri.host == baseUri.host;
    final bool sameScheme = ctx.uri.scheme == baseUri.scheme;

    // NOTE: Ports are tricky if your baseUri has no explicit port.
    // Keep baseUri explicit in examples (https://... no port) and compare safely.
    final bool samePort = ctx.uri.port == baseUri.port;

    if (!sameHost || !sameScheme || !samePort) {
      return false;
    }

    // Route namespace:
    // - /v1/cats...
    final List<String> seg = ctx.uri.pathSegments;
    if (seg.length < 2) {
      return false;
    }
    if (seg[0] != 'v1') {
      return false;
    }
    return seg[1] == 'cats';
  }

  @override
  Future<Map<String, dynamic>> handle(RequestContext ctx) async {
    // This is the "virtual backend".
    // All backend semantics live here:
    // - path parsing
    // - validations
    // - in-memory persistence
    // - payload shape
    //
    // If your real backend does NOT return a Jocaagura-friendly shape,
    // you can still model it here and swap the mapper above.

    final String method = ctx.method.toUpperCase();
    final List<String> seg = ctx.uri.pathSegments;

    // Supported routes:
    // GET    /v1/cats
    // GET    /v1/cats/:id
    // POST   /v1/cats
    // PUT    /v1/cats/:id
    // DELETE /v1/cats/:id

    if (seg.length == 2 && seg[0] == 'v1' && seg[1] == 'cats') {
      if (method == 'GET') {
        return _handleList(ctx);
      }
      if (method == 'POST') {
        return _handleCreate(ctx);
      }
    }

    if (seg.length == 3 && seg[0] == 'v1' && seg[1] == 'cats') {
      final String id = seg[2];
      if (method == 'GET') {
        return _handleGet(id);
      }
      if (method == 'PUT') {
        return _handleUpdate(id, ctx);
      }
      if (method == 'DELETE') {
        return _handleDelete(id);
      }
    }

    throw StateError(
      'VetCatsVirtualCrudService cannot handle: ${ctx.method} ${ctx.uri}',
    );
  }

  @override
  void reset() {
    _db.clear();

    final DateTime now = DateTime.now();
    final List<CatPatient> seeded = <CatPatient>[
      CatPatient(
        id: 'cat-001',
        name: 'Mandarina',
        animalType: 'feline',
        gender: 'female',
        weightKg: 3.6,
        breed: 'Mestizo',
        color: 'Orange',
        birthDate: '2023-02-10',
        microchipId: 'MC-ORANGE-0001',
        isSterilized: true,
        owner: <String, dynamic>{
          'id': 'owner-001',
          'fullName': 'Albert',
          'phone': '+57 300 000 0000',
          'email': 'albert@example.com',
          'address': 'Bogotá',
        },
        energy: 80,
        intelligence: 70,
        joyful: 90,
        hygiene: 60,
        clinical: const <String, dynamic>{
          'allergies': <String>[],
          'chronicConditions': <String>[],
          'currentMedications': <Map<String, dynamic>>[],
        },
        vaccinations: const <Map<String, dynamic>>[
          <String, dynamic>{
            'name': 'Rabies',
            'appliedAt': '2025-02-01',
            'expiresAt': '2026-02-01',
            'lot': 'RAB-2025-01',
            'vetId': 'vet-123',
          },
        ],
        visits: const <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'visit-001',
            'visitedAt': '2025-11-10T09:30:00Z',
            'reason': 'Annual checkup',
            'diagnosis': 'Healthy',
            'notes': 'Keep diet balanced.',
            'attachments': <Map<String, dynamic>>[],
          },
        ],
        notes: 'Street cat adopted, very friendly.',
        createdAt: now.subtract(const Duration(days: 250)).toIso8601String(),
        updatedAt: now.toIso8601String(),
      ),
      CatPatient(
        id: 'cat-002',
        name: 'Kira',
        animalType: 'feline',
        gender: 'female',
        weightKg: 4.1,
        breed: 'Mestizo',
        color: 'White with stripes',
        ageYears: 1.0,
        owner: <String, dynamic>{
          'id': 'owner-001',
          'fullName': 'Albert',
        },
        energy: 85,
        intelligence: 95,
        joyful: 88,
        hygiene: 70,
        clinical: const <String, dynamic>{
          'allergies': <String>['Dust'],
          'chronicConditions': <String>[],
          'currentMedications': <Map<String, dynamic>>[],
        },
        createdAt: now.subtract(const Duration(days: 200)).toIso8601String(),
        updatedAt: now.toIso8601String(),
      ),
    ];

    for (final CatPatient c in seeded) {
      _db[c.id] = c;
    }
  }

  Map<String, dynamic> _okHttp({
    required HttpMethodEnum method,
    required Uri uri,
    required int statusCode,
    required String reason,
    required Map<String, dynamic> body,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    // Jocaagura-friendly response: designed to be mapped into ModelConfigHttpRequest
    // and then consumed as Either<ErrorItem, ModelConfigHttpRequest>.
    return FakeHttpRequestConfig.cannedHttpResponse(
      method: method,
      uri: uri,
      statusCode: statusCode,
      reasonPhrase: reason,
      body: body,
      metadata: <String, dynamic>{
        ...metadata,
        'feature': 'vet',
        'resource': 'cats',
      },
    );
  }

  Map<String, dynamic> _failHttp({
    required HttpMethodEnum method,
    required Uri uri,
    required int statusCode,
    required String reason,
    required String code,
    required String message,
  }) {
    // Jocaagura-friendly error payload.
    // IMPORTANT: This is an example contract. If you want "raw backend" style,
    // return whatever your backend returns and adjust the mapper.
    return <String, dynamic>{
      'ok': false,
      'code': code,
      'message': message,
      'statusCode': statusCode,
      'reasonPhrase': reason,
      'method': method.name,
      'uri': uri.toString(),
      'headers': const <String, String>{'content-type': 'application/json'},
      'body': const <String, dynamic>{},
      'metadata': const <String, dynamic>{
        'source': 'VetCatsVirtualCrudService',
      },
      'timeout': null,
      'fake': true,
      'source': 'FakeHttpRequest',
    };
  }

  Map<String, dynamic> _handleList(RequestContext ctx) {
    final List<Map<String, dynamic>> items =
        _db.values.map((CatPatient c) => c.toJson()).toList();
    return _okHttp(
      method: HttpMethodEnum.get,
      uri: ctx.uri,
      statusCode: 200,
      reason: 'OK',
      body: <String, dynamic>{'items': items},
    );
  }

  Map<String, dynamic> _handleGet(String id) {
    final CatPatient? c = _db[id];
    if (c == null) {
      return _failHttp(
        method: HttpMethodEnum.get,
        uri: baseUri.replace(path: '/v1/cats/$id'),
        statusCode: 404,
        reason: 'Not Found',
        code: 'cat_not_found',
        message: 'No cat patient found with id=$id',
      );
    }

    return _okHttp(
      method: HttpMethodEnum.get,
      uri: baseUri.replace(path: '/v1/cats/$id'),
      statusCode: 200,
      reason: 'OK',
      body: <String, dynamic>{'item': c.toJson()},
    );
  }

  Map<String, dynamic> _handleCreate(RequestContext ctx) {
    final Map<String, dynamic> body = ctx.body ?? const <String, dynamic>{};
    final String name = (body['name'] as String?)?.trim() ?? '';
    final String gender = (body['gender'] as String?) ?? 'male';
    final num? weight = body['weightKg'] as num?;
    final String? birthDate = body['birthDate'] as String?;
    final num? ageYears = body['ageYears'] as num?;
    if (name.isEmpty) {
      return _failHttp(
        method: HttpMethodEnum.post,
        uri: ctx.uri,
        statusCode: 422,
        reason: 'Unprocessable Entity',
        code: 'validation_error',
        message: 'name is required',
      );
    }
    if (name.toLowerCase() == 'gato-error') {
      return _failHttp(
        method: HttpMethodEnum.post,
        uri: ctx.uri,
        statusCode: 500,
        reason: 'Internal Server Error',
        code: 'forced_create_error',
        message: 'Forced demo error: cannot create cat with name=gato-error',
      );
    }

    if (weight == null || weight.toDouble() < 0.1) {
      return _failHttp(
        method: HttpMethodEnum.post,
        uri: ctx.uri,
        statusCode: 422,
        reason: 'Unprocessable Entity',
        code: 'validation_error',
        message: 'weightKg must be >= 0.1',
      );
    }
    if (birthDate == null && ageYears == null) {
      return _failHttp(
        method: HttpMethodEnum.post,
        uri: ctx.uri,
        statusCode: 422,
        reason: 'Unprocessable Entity',
        code: 'validation_error',
        message: 'Either birthDate or ageYears must be provided',
      );
    }

    final DateTime now = DateTime.now();
    final String id = 'cat-${100 + _db.length + 1}';

    final CatPatient created = CatPatient(
      id: id,
      name: name,
      animalType: 'feline',
      gender: gender,
      weightKg: weight.toDouble(),
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
      breed: body['breed'] as String?,
      color: body['color'] as String?,
      birthDate: birthDate,
      ageYears: ageYears?.toDouble(),
      microchipId: body['microchipId'] as String?,
      isSterilized: body['isSterilized'] as bool?,
      status: (body['status'] as String?) ?? 'active',
      owner: body['owner'] is Map
          ? Utils.mapFromDynamic(body['owner'] as Map<dynamic, dynamic>)
          : null,
      energy: (body['energy'] as num?)?.toDouble(),
      intelligence: (body['intelligence'] as num?)?.toDouble(),
      joyful: (body['joyful'] as num?)?.toDouble(),
      hygiene: (body['hygiene'] as num?)?.toDouble(),
      clinical: body['clinical'] is Map
          ? Utils.mapFromDynamic(body['clinical'] as Map<dynamic, dynamic>)
          : const <String, dynamic>{},
      notes: body['notes'] as String?,
    );

    _db[id] = created;

    return _okHttp(
      method: HttpMethodEnum.post,
      uri: ctx.uri,
      statusCode: 201,
      reason: 'Created',
      body: <String, dynamic>{'item': created.toJson()},
      metadata: <String, dynamic>{'createdId': id},
    );
  }

  Map<String, dynamic> _handleUpdate(String id, RequestContext ctx) {
    final CatPatient? existing = _db[id];
    if (existing == null) {
      return _failHttp(
        method: HttpMethodEnum.put,
        uri: ctx.uri,
        statusCode: 404,
        reason: 'Not Found',
        code: 'cat_not_found',
        message: 'No cat patient found with id=$id',
      );
    }

    final Map<String, dynamic> patch = ctx.body ?? const <String, dynamic>{};
    final String name = (patch['name'] as String?)?.trim() ?? existing.name;
    final num? weight = patch['weightKg'] as num?;

    if (name.isEmpty) {
      return _failHttp(
        method: HttpMethodEnum.put,
        uri: ctx.uri,
        statusCode: 422,
        reason: 'Unprocessable Entity',
        code: 'validation_error',
        message: 'name cannot be empty',
      );
    }
    if (weight != null && weight.toDouble() < 0.1) {
      return _failHttp(
        method: HttpMethodEnum.put,
        uri: ctx.uri,
        statusCode: 422,
        reason: 'Unprocessable Entity',
        code: 'validation_error',
        message: 'weightKg must be >= 0.1',
      );
    }

    final DateTime now = DateTime.now();
    final CatPatient updated = CatPatient(
      id: existing.id,
      name: name,
      animalType: existing.animalType,
      gender: (patch['gender'] as String?) ?? existing.gender,
      weightKg: weight == null ? existing.weightKg : weight.toDouble(),
      createdAt: existing.createdAt,
      updatedAt: now.toIso8601String(),
      breed: patch.containsKey('breed')
          ? patch['breed'] as String?
          : existing.breed,
      color: patch.containsKey('color')
          ? patch['color'] as String?
          : existing.color,
      birthDate: patch.containsKey('birthDate')
          ? patch['birthDate'] as String?
          : existing.birthDate,
      ageYears: patch.containsKey('ageYears')
          ? (patch['ageYears'] as num?)?.toDouble()
          : existing.ageYears,
      microchipId: patch.containsKey('microchipId')
          ? patch['microchipId'] as String?
          : existing.microchipId,
      isSterilized: patch.containsKey('isSterilized')
          ? patch['isSterilized'] as bool?
          : existing.isSterilized,
      status: (patch['status'] as String?) ?? existing.status,
      owner: patch['owner'] is Map
          ? Utils.mapFromDynamic(patch['owner'] as Map<dynamic, dynamic>)
          : existing.owner,
      energy: (patch['energy'] as num?)?.toDouble() ?? existing.energy,
      intelligence:
          (patch['intelligence'] as num?)?.toDouble() ?? existing.intelligence,
      joyful: (patch['joyful'] as num?)?.toDouble() ?? existing.joyful,
      hygiene: (patch['hygiene'] as num?)?.toDouble() ?? existing.hygiene,
      clinical: patch['clinical'] is Map
          ? Utils.mapFromDynamic(patch['clinical'] as Map<dynamic, dynamic>)
          : existing.clinical,
      vaccinations: existing.vaccinations,
      visits: existing.visits,
      notes: patch.containsKey('notes')
          ? patch['notes'] as String?
          : existing.notes,
    );

    _db[id] = updated;

    return _okHttp(
      method: HttpMethodEnum.put,
      uri: ctx.uri,
      statusCode: 200,
      reason: 'OK',
      body: <String, dynamic>{'item': updated.toJson()},
    );
  }

  Map<String, dynamic> _handleDelete(String id) {
    final CatPatient? existing = _db[id];
    if (existing == null) {
      return _failHttp(
        method: HttpMethodEnum.delete,
        uri: baseUri.replace(path: '/v1/cats/$id'),
        statusCode: 404,
        reason: 'Not Found',
        code: 'cat_not_found',
        message: 'No cat patient found with id=$id',
      );
    }
    // Example of domain constraint:
    // - Kira is protected (cannot be deleted) to demonstrate 409 Conflict.
    // In a real backend this would be enforced by business rules or DB constraints.
    if (existing.name.toLowerCase() == 'kira') {
      return _failHttp(
        method: HttpMethodEnum.delete,
        uri: baseUri.replace(path: '/v1/cats/$id'),
        statusCode: 409,
        reason: 'Conflict',
        code: 'delete_forbidden',
        message: 'Forced demo error: Kira cannot be deleted',
      );
    }

    _db.remove(id);

    return _okHttp(
      method: HttpMethodEnum.delete,
      uri: baseUri.replace(path: '/v1/cats/$id'),
      statusCode: 204,
      reason: 'No Content',
      body: const <String, dynamic>{},
    );
  }
}

// ============================================================================
// 11) App wiring + simple UI
// ============================================================================

class PetShopApp extends StatefulWidget {
  const PetShopApp({super.key});

  @override
  State<PetShopApp> createState() => _PetShopAppState();
}

class _PetShopAppState extends State<PetShopApp> {
  late final JocaaguraFakeHttpRequest _fakeHttp;
  late final ServiceHttpRequestAdapter _serviceAdapter;
  late final GatewayHttpRequest _gateway;
  late final RepositoryHttpRequest _repository;
  late final FacadeHttpRequestUsecases _facade;
  late final BlocHttpRequest _bloc;

  final Uri _baseUri = Uri.parse('https://petshop.jocaagura.dev');

  @override
  void initState() {
    super.initState();

    final VetCatsVirtualCrudService catsService =
        VetCatsVirtualCrudService(baseUri: _baseUri);

    // Optional: demonstrate per-route canned errors by config:
    // final FakeHttpRequestConfig config = FakeHttpRequestConfig(
    //   errorRoutes: <String, String>{
    //     'GET ${_baseUri.replace(path: '/v1/cats/cat-002')}': 'Forced route error',
    //   },
    //   latency: const Duration(milliseconds: 250),
    // );

    const FakeHttpRequestConfig config = FakeHttpRequestConfig(
      latency: Duration(milliseconds: 200),
    );

    _fakeHttp = JocaaguraFakeHttpRequest(
      services: <VirtualCrudService>[catsService],
      config: config,
    );

    _serviceAdapter = ServiceHttpRequestAdapter(_fakeHttp);
    _gateway = GatewayHttpRequestImpl(service: _serviceAdapter);
    _repository = RepositoryHttpRequestImpl(_gateway);

    _facade = FacadeHttpRequestUsecases(
      get: UsecaseHttpRequestGet(_repository),
      post: UsecaseHttpRequestPost(_repository),
      put: UsecaseHttpRequestPut(_repository),
      delete: UsecaseHttpRequestDelete(_repository),
      retry: UsecaseHttpRequestRetry(_repository),
    );

    _bloc = BlocHttpRequest(_facade);
  }

  @override
  void dispose() {
    _bloc.dispose();
    _serviceAdapter.dispose();
    _fakeHttp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Shop Vet API Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: VetCatsHome(
        baseUri: _baseUri,
        bloc: _bloc,
      ),
    );
  }
}

class VetCatsHome extends StatefulWidget {
  const VetCatsHome({
    required this.baseUri,
    required this.bloc,
    super.key,
  });

  final Uri baseUri;
  final BlocHttpRequest bloc;

  @override
  State<VetCatsHome> createState() => _VetCatsHomeState();
}

class _VetCatsHomeState extends State<VetCatsHome> {
  // UI testing guide:
  // - Refresh: calls GET /v1/cats (list)
  // - Tap item: calls GET /v1/cats/:id (detail)
  // - Create: calls POST /v1/cats (validations inside virtual service)
  // - Update: calls PUT /v1/cats/:id
  // - Delete: calls DELETE /v1/cats/:id
  //
  // Try these scenarios:
  // - Create with name="" to see 422 validation error
  // - Create with name="gato-error" to force a 500 demo error
  // - Delete "Kira" to see 409 conflict
  // - Add config.errorRoutes to force deterministic failures by route

  List<CatPatient> _cats = <CatPatient>[];
  String? _selectedId;
  String? _error;
  ModelConfigHttpRequest? _lastConfig;

  final TextEditingController _nameCtrl =
      TextEditingController(text: 'Michi Nuevo');
  final TextEditingController _weightCtrl = TextEditingController(text: '3.2');
  final TextEditingController _genderCtrl =
      TextEditingController(text: 'female');
  final TextEditingController _ageYearsCtrl = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    _genderCtrl.dispose();
    _ageYearsCtrl.dispose();
    super.dispose();
  }

  Uri _catsUri([String? id]) {
    final String path = id == null ? '/v1/cats' : '/v1/cats/$id';
    return widget.baseUri.replace(path: path);
  }

  Future<void> _loadList() async {
    setState(() {
      _error = null;
    });

    final Either<ErrorItem, ModelConfigHttpRequest> r = await widget.bloc.get(
      requestKey: 'vet.cats.list',
      uri: _catsUri(),
      metadata: const <String, dynamic>{
        'feature': 'vet',
        'operation': 'listCats',
      },
    );

    r.fold(
      (ErrorItem e) {
        setState(() {
          _error = e.toString();
        });
      },
      (ModelConfigHttpRequest cfg) {
        _lastConfig = cfg;

        // The fake returns ModelConfigHttpRequest as payload, with its "body"
        // containing the service response. In our virtual service we used
        // cannedHttpResponse body = {'items': [...]}
        final Object? itemsObj = cfg.body['items'];
        final List<CatPatient> cats = (itemsObj is List)
            ? itemsObj
                .whereType<Map<dynamic, dynamic>>()
                .map(
                  (Map<dynamic, dynamic> m) =>
                      CatPatient.fromJson(Utils.mapFromDynamic(m)),
                )
                .toList()
            : <CatPatient>[];

        setState(() {
          _cats = cats;
          if (_selectedId == null && _cats.isNotEmpty) {
            _selectedId = _cats.first.id;
          }
        });
      },
    );
  }

  Future<void> _loadOne(String id) async {
    setState(() {
      _error = null;
    });

    final Either<ErrorItem, ModelConfigHttpRequest> r = await widget.bloc.get(
      requestKey: 'vet.cats.get.$id',
      uri: _catsUri(id),
      metadata: <String, dynamic>{
        'feature': 'vet',
        'operation': 'getCat',
        'id': id,
      },
    );

    r.fold(
      (ErrorItem e) => setState(() => _error = e.toString()),
      (ModelConfigHttpRequest cfg) {
        _lastConfig = cfg;

        final Object? itemObj = cfg.body['item'];
        if (itemObj is Map) {
          final CatPatient c =
              CatPatient.fromJson(Utils.mapFromDynamic(itemObj));
          final int idx = _cats.indexWhere((CatPatient x) => x.id == id);
          setState(() {
            if (idx >= 0) {
              final List<CatPatient> next = List<CatPatient>.from(_cats);
              next[idx] = c;
              _cats = next;
            }
          });
        }
      },
    );
  }

  Future<void> _create() async {
    setState(() => _error = null);

    final double? weight = double.tryParse(_weightCtrl.text.trim());
    final double? ageYears = double.tryParse(_ageYearsCtrl.text.trim());
    final Map<String, dynamic> body = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'gender': _genderCtrl.text.trim(),
      'weightKg': weight,
      'ageYears': ageYears,
      'owner': <String, dynamic>{'id': 'owner-001', 'fullName': 'Albert'},
      'status': 'active',
      'notes': 'Created from Flutter demo',
    };

    final Either<ErrorItem, ModelConfigHttpRequest> r = await widget.bloc.post(
      requestKey: 'vet.cats.create',
      uri: _catsUri(),
      body: body,
      metadata: const <String, dynamic>{
        'feature': 'vet',
        'operation': 'createCat',
      },
    );

    r.fold(
      (ErrorItem e) => setState(() => _error = e.toString()),
      (ModelConfigHttpRequest cfg) {
        _lastConfig = cfg;
        final Object? itemObj = cfg.body['item'];
        if (itemObj is Map) {
          final CatPatient created =
              CatPatient.fromJson(Utils.mapFromDynamic(itemObj));
          setState(() {
            _cats = <CatPatient>[created, ..._cats];
            _selectedId = created.id;
          });
        }
      },
    );
  }

  Future<void> _updateSelected() async {
    final String? id = _selectedId;
    if (id == null) {
      return;
    }

    setState(() => _error = null);

    final double? weight = double.tryParse(_weightCtrl.text.trim());
    final Map<String, dynamic> patch = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      if (weight != null) 'weightKg': weight,
      'updatedBy': 'flutter-demo',
    };

    final Either<ErrorItem, ModelConfigHttpRequest> r = await widget.bloc.put(
      requestKey: 'vet.cats.update.$id',
      uri: _catsUri(id),
      body: patch,
      metadata: <String, dynamic>{
        'feature': 'vet',
        'operation': 'updateCat',
        'id': id,
      },
    );

    r.fold(
      (ErrorItem e) => setState(() => _error = e.toString()),
      (ModelConfigHttpRequest cfg) async {
        _lastConfig = cfg;
        await _loadOne(id);
      },
    );
  }

  Future<void> _deleteSelected() async {
    final String? id = _selectedId;
    if (id == null) {
      return;
    }

    setState(() => _error = null);

    final Either<ErrorItem, ModelConfigHttpRequest> r =
        await widget.bloc.delete(
      requestKey: 'vet.cats.delete.$id',
      uri: _catsUri(id),
      metadata: <String, dynamic>{
        'feature': 'vet',
        'operation': 'deleteCat',
        'id': id,
      },
    );

    r.fold(
      (ErrorItem e) => setState(() => _error = e.toString()),
      (ModelConfigHttpRequest cfg) {
        _lastConfig = cfg;
        setState(() {
          _cats = _cats.where((CatPatient c) => c.id != id).toList();
          _selectedId = _cats.isEmpty ? null : _cats.first.id;
        });
      },
    );
  }

  Future<void> _retryLast() async {
    final ModelConfigHttpRequest? last = _lastConfig;
    if (last == null) {
      return;
    }

    setState(() => _error = null);

    final Either<ErrorItem, ModelConfigHttpRequest> r = await widget.bloc.retry(
      requestKey: 'vet.retry.${Random().nextInt(9999)}',
      previousConfig: last,
      extraMetadata: const <String, dynamic>{'retry': true},
    );

    r.fold(
      (ErrorItem e) => setState(() => _error = e.toString()),
      (ModelConfigHttpRequest cfg) async {
        _lastConfig = cfg;
        // In this demo, retry is mostly to show the flow.
        // Refresh list to reflect any changes.
        await _loadList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final CatPatient? selected = _selectedId == null
        ? null
        : _cats.cast<CatPatient?>().firstWhere(
              (CatPatient? c) => c?.id == _selectedId,
              orElse: () => null,
            );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vet API • Cat Patients'),
        actions: <Widget>[
          StreamBuilder<Set<String>>(
            stream: widget.bloc.stream,
            initialData: widget.bloc.activeRequests,
            builder: (BuildContext context, AsyncSnapshot<Set<String>> snap) {
              final bool busy = (snap.data ?? const <String>{}).isNotEmpty;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: AnimatedOpacity(
                    opacity: busy ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          // Left: list
          SizedBox(
            width: 320,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 30,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _loadList,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _retryLast,
                          icon: const Icon(Icons.replay),
                          label: const Text('Retry last'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      height: 50.0,
                      child: Card(
                        color: Colors.red.withValues(alpha: 0.90),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _cats.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (BuildContext context, int i) {
                      final CatPatient c = _cats[i];
                      final bool selected = c.id == _selectedId;
                      return ListTile(
                        selected: selected,
                        title: Text(c.name),
                        subtitle:
                            Text('${c.id} • ${c.gender} • ${c.weightKg}kg'),
                        onTap: () async {
                          setState(() => _selectedId = c.id);
                          await _loadOne(c.id);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(width: 1),

          // Right: details + actions
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: selected == null
                  ? const Center(
                      child: Text('Select a cat patient from the list.'),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          selected.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text('ID: ${selected.id} • Status: ${selected.status}'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            Chip(
                              label: Text('Energy: ${selected.energy ?? '-'}'),
                            ),
                            Chip(
                              label: Text(
                                'Intelligence: ${selected.intelligence ?? '-'}',
                              ),
                            ),
                            Chip(
                              label: Text('Joyful: ${selected.joyful ?? '-'}'),
                            ),
                            Chip(
                              label: Text(
                                'Hygiene: ${selected.hygiene ?? '-'}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Quick editor',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 140,
                              child: TextField(
                                controller: _weightCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Weight (kg)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 160,
                              child: TextField(
                                controller: _genderCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Gender (male/female)',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 120,
                              child: TextField(
                                controller: _ageYearsCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Age years',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: <Widget>[
                            ElevatedButton.icon(
                              onPressed: _create,
                              icon: const Icon(Icons.add),
                              label: const Text('Create'),
                            ),
                            ElevatedButton.icon(
                              onPressed: _updateSelected,
                              icon: const Icon(Icons.save),
                              label: const Text('Update selected'),
                            ),
                            OutlinedButton.icon(
                              onPressed: _deleteSelected,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete selected'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: SingleChildScrollView(
                                child: Text(
                                  _prettyJson(selected.toJson()),
                                  style:
                                      const TextStyle(fontFamily: 'monospace'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

String _prettyJson(Map<String, dynamic> json) {
  final StringBuffer sb = StringBuffer();
  void writeAny(Object? v, int indent) {
    final String pad = '  ' * indent;
    if (v is Map) {
      sb.writeln('{');
      final List<MapEntry<dynamic, dynamic>> entries = v.entries.toList();
      for (int i = 0; i < entries.length; i++) {
        final MapEntry<dynamic, dynamic> e = entries[i];
        sb.write('$pad  "${e.key}": ');
        writeAny(e.value, indent + 1);
        sb.writeln(i == entries.length - 1 ? '' : ',');
      }
      sb.write('$pad}');
      return;
    }
    if (v is List) {
      sb.writeln('[');
      for (int i = 0; i < v.length; i++) {
        sb.write('$pad  ');
        writeAny(v[i], indent + 1);
        sb.writeln(i == v.length - 1 ? '' : ',');
      }
      sb.write('$pad]');
      return;
    }
    if (v is String) {
      sb.write('"${v.replaceAll('"', r'\"')}"');
      return;
    }
    sb.write(v);
  }

  writeAny(json, 0);
  return sb.toString();
}
