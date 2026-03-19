# Jocaagura Domain

![CI](https://img.shields.io/github/actions/workflow/status/grupo-jocaagura/jocaagura_domain/validate_pr.yaml?branch=develop)
![Pub](https://img.shields.io/pub/v/jocaagura_domain)
![Coverage](https://img.shields.io/badge/coverage-99%25-brightgreen)

Paquete Flutter con modelos de dominio, utilidades, componentes reactivos, contratos JSON Schema y servicios fake para acelerar implementaciones consistentes dentro del ecosistema Jocaagura.

## Descripción

`jocaagura_domain` centraliza piezas reutilizables para aplicaciones Flutter:

- modelos serializables y utilidades transversales
- BLoCs y componentes de arquitectura
- contratos JSON Schema versionados
- servicios fake para desarrollo, demos y pruebas

El objetivo del paquete es reducir duplicidad y mantener una base compartida entre aplicaciones del ecosistema.

## Inicio rápido

### Requisitos

- Flutter SDK compatible con `sdk: >=3.2.0 <4.0.0`

### Instalación

```yaml
dependencies:
  jocaagura_domain: ^1.39.1
```

### Uso básico

```dart
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  final user = UserModel(
    id: '001',
    displayName: 'Juan Perez',
    photoUrl: 'https://example.com/photo.jpg',
    email: 'juan.perez@example.com',
    jwt: {'token': 'abcd1234'},
  );

  print(user.toJson());

  final updatedUser = user.copyWith(email: 'juan.updated@example.com');
  print(updatedUser.toJson());
}
```

## Mapa de documentación

### Entrada principal

- [Guía de estructura recomendada](README_STRUCTURE.md)
- [Aplicación de ejemplo](example/README.md)
- [CHANGELOG](CHANGELOG.md)

### Contratos JSON

- [Contratos JSON Schema](doc/schemas/README.md)
- [Schemas v1](doc/schemas/v1/README.md)

### Referencias

- [Modelos y utilidades base](doc/reference/core-models-and-utils.md)
- [Componentes avanzados y utilidades reactivas](doc/reference/advanced-components.md)

### Guías

- [Recetas de integración](doc/guides/integration-recipes.md)
- [Documentación HTTP](doc/http-requests-doc.md)
- [Simulación HTTP avanzada](doc/advanced-http-simulation.md)
- [Guía Store](doc/store-doc.md)

### Operación del repositorio

- [Publicación y versionamiento](doc/operations/release-versioning.md)

## Módulos destacados

- Modelos: `UserModel`, `PersonModel`, `StoreModel`, `LedgerModel`, `ConnectivityModel`
- Utilidades: `Utils`, `DateUtils`, `Unit`, `PerKeyFifoExecutor`
- Arquitectura: `BlocGeneral`, `BlocModule`, `BlocSession`, `BlocWsDatabase`, `BlocResponsive`
- Contratos: `doc/schemas/v1/`
- Demos: `example/lib/`

## Notas

- Los diagramas del dominio están en [`uml/uml_diagrams.drawio`](uml/uml_diagrams.drawio).
- El `README` se redujo para funcionar como puerta de entrada; la referencia extensa vive en `doc/`.
