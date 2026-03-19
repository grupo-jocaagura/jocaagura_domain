# Example App

Aplicación de ejemplo para probar `jocaagura_domain` en un proyecto Flutter real.

## Objetivo

Este ejemplo funciona como un `kitchen sink` del paquete: reúne varias demos pequeñas en una sola app para revisar modelos, BLoCs, flujos y utilidades sin tener que crear un proyecto desde cero.

## Qué incluye

- modelos por defecto del paquete
- demos de onboarding
- ejemplo de `Either`
- gráficos y ledger
- ejemplos de sesión y autenticación
- ejemplo de conectividad
- ejemplo de `BlocWsDatabase`
- validación responsive

La entrada principal está en [`example/lib/main.dart`](lib/main.dart).

## Cómo ejecutarlo

Desde la raíz del repositorio:

```bash
cd example
flutter pub get
flutter run
```

## Archivos útiles

- [`example/lib/main.dart`](lib/main.dart): app principal con navegación a demos
- [`example/lib/onboarding_example.dart`](lib/onboarding_example.dart)
- [`example/lib/onboarding_example_advance.dart`](lib/onboarding_example_advance.dart)
- [`example/lib/bloc_session_example.dart`](lib/bloc_session_example.dart)
- [`example/lib/bloc_ws_db_example.dart`](lib/bloc_ws_db_example.dart)
- [`example/lib/bloc_http_request_example.dart`](lib/bloc_http_request_example.dart)
- [`example/lib/either_flow_example.dart`](lib/either_flow_example.dart)
- [`example/lib/graph_example.dart`](lib/graph_example.dart)
- [`example/lib/ledger_example.dart`](lib/ledger_example.dart)
- [`example/lib/store_model_example.dart`](lib/store_model_example.dart)

## Notas

- El ejemplo usa una dependencia local hacia este repositorio en `example/pubspec.yaml`.
- Su función es demostrar capacidades del paquete, no servir como plantilla de arquitectura definitiva.
- La guía de estructura recomendada para proyectos consumidores está en [`README_STRUCTURE.md`](../README_STRUCTURE.md).
