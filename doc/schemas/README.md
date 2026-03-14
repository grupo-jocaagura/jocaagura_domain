# JSON Schemas

Este directorio contiene los contratos JSON canonicos de `jocaagura_domain`.

## Convenciones base

- Los schemas versionados viven en `doc/schemas/vN/`.
- El schema describe el JSON canonico de intercambio, no las tolerancias historicas de `fromJson()`.
- `fromJson()` puede aceptar formas adicionales por compatibilidad, pero el contrato formal es el schema.
- Los nombres de archivo siguen el nombre del modelo Dart en `snake_case`: `address_model.schema.json`.
- Las fechas se documentan como `string` ISO-8601 cuando aplique.
- Por defecto, los objetos usan `additionalProperties: false` salvo que el contrato del modelo requiera extensibilidad abierta.
- Los examples en `doc/schemas/vN/examples/` son payloads canonicos validos y sirven como fixtures de referencia.

## Estrategia

Cada modelo se normaliza asi:

1. Se define el JSON canonico interoperable.
2. Se compara con `fromJson()` y `toJson()` actuales.
3. Se ajustan los mappers Dart solo si es necesario para converger al contrato.
4. El JSON Schema queda como fuente formal de contrato portable.

## Alcance del contrato

- El contrato canonico prioriza interoperabilidad entre backend, tooling, validadores, mocks y otros consumidores no Dart.
- `toJson()` es la referencia principal para fijar el shape portable, salvo que el proyecto haya decidido explicitamente corregir una forma historica no interoperable.
- Cuando `fromJson()` acepte variantes legacy, esas variantes se documentan como brecha de implementación, no como parte del schema principal.
- Los schemas de esta carpeta no intentan modelar callbacks, tipos UI, estados runtime ni abstracciones de infraestructura.

## Politica de versionado

- `v1` representa la primera linea estable de contratos canonicos.
- Cualquier cambio incompatible en shape, requireds, enums o semantica de campos debe publicarse en una nueva version (`v2`, `v3`, etc.).
- Cambios compatibles, como nuevas descripciones, examples o aclaraciones documentales, pueden hacerse dentro de la misma version.

## Validacion local

### Requisitos del ambiente

- `Node.js` y `npm` instalados localmente
- PowerShell disponible en el sistema
- `tools/jq/jq.exe` disponible en el repo

### Preparacion inicial

Desde la raiz del repo:

```powershell
npm install
```

Notas:

- `package.json` y `package-lock.json` forman parte del tooling reproducible del repo
- `node_modules/` es solo instalación local y no debe versionarse
- el validador usa `ajv-cli` desde `node_modules/.bin` y `jq` vendorizado en `tools/jq/jq.exe`

- Comando principal:

```powershell
npm run validate:schemas
```

- Este flujo valida dos cosas:
  - sintaxis JSON de cada schema y cada example
  - compilación Draft 2020-12 y validación de cada example contra su schema

## Checklist para agregar un nuevo schema

1. Revisar `fromJson()` y `toJson()` del modelo.
2. Definir el payload JSON canónico interoperable.
3. Identificar requireds, opcionales, enums, defaults y formatos.
4. Reutilizar referencias a otros schemas cuando ya exista un contrato estable.
5. Crear `foo.schema.json` y `examples/foo.example.json`.
6. Registrar dependencias y decisiones relevantes en `doc/schemas/vN/README.md`.
7. Actualizar la matriz de cobertura en `plan-de-trabajo.md`.
8. Ejecutar `npm run validate:schemas`.

## Version actual

- `v1`: contratos iniciales canonicos para los modelos prioritarios.

## Decisiones canonicas actuales

- `UserModel.jwt` se representa como `object` JSON, no como `string` con JSON embebido.
- `StoreModel.address` se representa como objeto JSON anidado.
- `AttributeModel.value` representa un valor JSON interoperable, no un tipo Dart.
- `PersonModel.attributes` se representa como diccionario de atributos nombrados.
- `ModelItem.attributes` se representa como arreglo ordenado de `AttributeModel`.

## Brechas conocidas con la implementación Dart

- `UserModel`
  - `fromJson()` acepta `jwt` como mapa.
  - `toJson()` actual serializa `jwt` como `string` JSON embebido.
  - El contrato canónico `v1` fija `jwt` como `object`.
- `PersonModel`
  - `fromJson()` actual no reconstruye `attributes`; hoy devuelve un mapa vacío.
  - `toJson()` actual aplana atributos con `addAll`, lo que no preserva bien el diccionario canónico.
  - El contrato canónico `v1` fija `attributes` como mapa nombrado de `AttributeModel`.
- `DentalConditionModel`
  - `fromJson()` acepta `dentalId` a partir de string y lo normaliza a entero.
  - `toJson()` emite `dentalId` como entero.
  - El contrato canónico `v1` fija `dentalId` como `integer`.

Estas brechas no se resuelven en esta carpeta. Se documentan aqui para preparar la posterior normalización de mappers Dart sin contaminar el contrato portable.
