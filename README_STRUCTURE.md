# 🧱 Project Structure Guide for `jocaagura_domain`

[Ir a la versión en español](#guía-de-estructura-del-proyecto-para-jocaagura_domain)

This guide describes the recommended base folder and architecture setup when initializing a Flutter project using the [`jocaagura_domain`](https://pub.dev/packages/jocaagura_domain) package. It is aligned with Clean Architecture principles, and is intended to enforce scalability, testability, and clarity from the start.

---

## 📁 Recommended Folder Structure

```text
lib
├── infrastructure                # 🔌 INFRASTRUCTURE LAYER
│   ├── services                  # Low-level platform integrations (e.g., Firebase, HTTP, fake)
│   ├── gateways                  # Gateway implementations (external APIs)
│   └── repositories              # Concrete repository implementations
├── domain                        # 📌 DOMAIN LAYER (pure logic)
│   ├── entities                  # Business entities
│   ├── services                  # Abstract contracts for infrastructure services
│   ├── gateways                  # Abstract interfaces for external systems
│   ├── repositories              # Abstract repository interfaces
│   └── use_cases                 # Business logic use cases
├── app                           # ⚙️ APPLICATION LAYER
│   ├── blocs                     # Controllers using `BlocGeneral`
│   └── app_state_manager.dart   # Central manager that exposes all blocs
├── presentation                  # 🎨 UI LAYER
│   ├── pages                     # Screens
│   ├── widgets                   # Reusable components
│   └── theme                    # Optional: Global ThemeConfig (light/dark)
├── shared                        # ♻️ Utilities with only static methods
│   └── [example] game_utils.dart
├── main.dart                     # Entry point
```

---

## 📦 Dependencies

### Required

```yaml
dependencies:
  jocaagura_domain: ^<latest>
```

* No external packages are required for testing or mocking.
* Fake services like `FakeWsDatabaseServiceImpl` are provided for robust test scenarios.

---

## ✅ Recommended Linting

Use the official analysis rules from `jocaagura_domain`:

```yaml
include: https://raw.githubusercontent.com/grupo-jocaagura/jocaagura_domain/develop/analysis_options.yaml
```

You may add project-specific rules on top.

---

## 📄 Main Setup and State Management

App initialization is flexible but should ensure `AppManager` and all `BlocModule` instances are registered:

### 🔰 Suggested Flow

```
UI → AppManager → Bloc → UseCase → Repository → Gateway → Service
```

You can register everything in `main.dart` for small apps, or use `config.dart` and split by environment in large apps.

### 🧠 Example `AppStateManager`

```dart
class AppStateManager extends InheritedWidget {
  const AppStateManager({
    required super.child,
    required this.blocTheme,
    super.key,
  });

  final BlocTheme blocTheme;

  static AppStateManager of(BuildContext context) {
    final AppStateManager? result =
        context.dependOnInheritedWidgetOfExactType<AppStateManager>();
    assert(result != null, 'No AppStateManager found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppStateManager old) => false;

  void dispose() => blocTheme.dispose();
}
```

---

## 🧪 Testing Recommendations

* Mirror the app folder structure in `test/`
* Group mocks and test widgets by context (`test/shared/`, `test/app/blocs/`, etc.)
* Prefer `Fake*ServiceImpl` from `jocaagura_domain` for most tests

---

## 🚀 GitHub Actions (Optional but Recommended)

You may include GitHub Actions for:

* Format/lint checks
* Running tests
* (Optionally) Publishing to pub.dev

Example config: [Workflow example](https://github.com/grupo-jocaagura/jocaagura_domain/blob/develop/.github/workflows/validate_pr.yaml)

---

## 🧰 Naming Conventions

| Layer        | Naming Example                           |
|--------------|------------------------------------------|
| Service      | `ServiceFakeWsDatabase`                  |
| Gateway      | `GatewayUser`, `GatewayUserImpl`         |
| Repository   | `RepositoryTheme`, `RepositoryThemeImpl` |
| Bloc         | `BlocCounter`, `BlocTheme`               |
| Widget       | `ProfileCardWidget`, `LoginViewWidget`   |
| Shared utils | `UtilGameDeck` (static-only class)       |

---

## 📚 Recommended Documentation Practices

* Place this file in your project root as `README_STRUCTURE.md`
* Link to it from your main `README.md`
* Provide inline DartDoc in every core class

---

## 👇 Minimal Working Example (Pseudo-code)

```dart
class CounterBloc implements BlocModule {
  final BlocGeneral<int> _bloc = BlocGeneral<int>(0);

  Stream<int> get stream => _bloc.stream;
  int get value => _bloc.value;

  void increment() => _bloc.value += 1;

  @override
  void dispose() => _bloc.dispose();
}

class CounterView extends StatelessWidget {
  final CounterBloc bloc;

  const CounterView(this.bloc, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: bloc.stream,
      initialData: bloc.value,
      builder: (_, snapshot) => Text('Value: ${snapshot.data}'),
    );
  }
}
```

> Use the `AppStateManager` to expose all your blocs. Your test harness can wrap widgets with a mocked AppStateManager.

---

## ✅ Summary

This structure enforces separation of concerns and testability, while remaining flexible. You can scale it up to complex apps or keep it lean for MVPs.

Enjoy building with `jocaagura_domain` 🐱‍👤

---
# 🇨🇴 🇪🇸
# Guía de estructura del proyecto para `jocaagura_domain`

Esta guía describe la estructura de carpetas y la arquitectura recomendada al iniciar un proyecto Flutter usando el paquete [`jocaagura_domain`](https://pub.dev/packages/jocaagura_domain). Está alineada con los principios de Clean Architecture y busca garantizar escalabilidad, testabilidad y claridad desde el inicio.

---

## 📁 Estructura de carpetas recomendada

```text
lib
├── infrastructure                # 🔌 CAPA DE INFRAESTRUCTURA
│   ├── services                  # Integraciones de bajo nivel (ej: Firebase, HTTP y Fake)
│   ├── gateways                  # Implementaciones de gateways (APIs externas)
│   └── repositories              # Implementaciones concretas de repositorios
├── domain                        # 📌 CAPA DE DOMINIO (lógica pura)
│   ├── entities                  # Entidades de negocio
│   ├── services                  # Contratos abstractos para servicios de infraestructura
│   ├── gateways                  # Interfaces abstractas para sistemas externos
│   ├── repositories              # Interfaces abstractas de repositorios
│   └── use_cases                 # Casos de uso de la lógica de negocio
├── app                           # ⚙️ CAPA DE APLICACIÓN
│   ├── blocs                     # Controladores usando `BlocGeneral`
│   └── app_state_manager.dart    # Gestor central que expone todos los blocs
├── presentation                  # 🎨 CAPA DE UI
│   ├── pages                     # Pantallas
│   ├── widgets                   # Componentes reutilizables
│   └── theme                     # Opcional: Configuración global de tema (claro/oscuro)
├── shared                        # ♻️ Utilidades solo con métodos estáticos
│   └── [ejemplo] game_utils.dart
├── main.dart                     # Punto de entrada
```

---

## 📦 Dependencias

### Requeridas

```yaml
dependencies:
  jocaagura_domain: ^<latest>
```

* No se requieren paquetes externos para pruebas o mocks.
* Se proveen servicios falsos como `FakeWsDatabaseServiceImpl` para escenarios de test robustos.

---

## ✅ Linting recomendado

Usa las reglas oficiales de análisis de `jocaagura_domain`:

```yaml
include: https://raw.githubusercontent.com/grupo-jocaagura/jocaagura_domain/develop/analysis_options.yaml
```

Puedes agregar reglas específicas del proyecto encima.

---

## 📄 Configuración principal y gestión de estado

La inicialización de la app es flexible, pero debe asegurar que `AppManager` y todas las instancias de `BlocModule` estén registradas.

### 🔰 Flujo sugerido

```
UI → AppManager → Bloc → UseCase → Repository → Gateway → Service
```

Puedes registrar todo en `main.dart` para apps pequeñas, o usar `config.dart` y dividir por entorno en apps grandes.

### 🧠 Ejemplo de `AppStateManager`

```dart
class AppStateManager extends InheritedWidget {
  const AppStateManager({
    required super.child,
    required this.blocTheme,
    super.key,
  });

  final BlocTheme blocTheme;

  static AppStateManager of(BuildContext context) {
    final AppStateManager? result =
        context.dependOnInheritedWidgetOfExactType<AppStateManager>();
    assert(result != null, 'No se encontró AppStateManager en el contexto');
    return result!;
  }

  @override
  bool updateShouldNotify(AppStateManager old) => false;

  void dispose() => blocTheme.dispose();
}
```

---

## 🧪 Recomendaciones para testing

* Refleja la estructura de carpetas de la app en `test/`
* Agrupa mocks y widgets de prueba por contexto (`test/shared/`, `test/app/blocs/`, etc.)
* Prefiere los servicios falsos `Fake*ServiceImpl` incluidos en `jocaagura_domain` para la mayoría de los tests, si están disponibles. Si tu proyecto requiere lógica específica o mayor control, se recomienda crear implementaciones propias de servicios falsos dentro del mismo proyecto.

---

## 🚀 GitHub Actions (opcional pero recomendado)

Puedes incluir GitHub Actions para:

* Chequeos de formato/lint
* Ejecución de tests
* (Opcional) Publicar en pub.dev

Ejemplo de configuración: [Ejemplo de workflow](https://github.com/grupo-jocaagura/jocaagura_domain/blob/develop/.github/workflows/validate_pr.yaml)

---

## 🧰 Convenciones de nombres

| Layer        | Naming Example                           |
|--------------|------------------------------------------|
| Service      | `ServiceFakeWsDatabase`                  |
| Gateway      | `GatewayUser`, `GatewayUserImpl`         |
| Repository   | `RepositoryTheme`, `RepositoryThemeImpl` |
| Bloc         | `BlocCounter`, `BlocTheme`               |
| Widget       | `ProfileCardWidget`, `LoginViewWidget`   |
| Shared utils | `UtilGameDeck` (static-only class)       |

---

## 📚 Prácticas recomendadas de documentación

* Coloca este archivo en la raíz del proyecto como `README_STRUCTURE.md`
* Enlázalo desde tu `README.md` principal
* Provee DartDoc en línea en cada clase principal

---

## 👇 Ejemplo mínimo funcional (pseudo-código)

```dart
class CounterBloc implements BlocModule {
  final BlocGeneral<int> _bloc = BlocGeneral<int>(0);

  Stream<int> get stream => _bloc.stream;
  int get value => _bloc.value;

  void increment() => _bloc.value += 1;

  @override
  void dispose() => _bloc.dispose();
}

class CounterView extends StatelessWidget {
  final CounterBloc bloc;

  const CounterView(this.bloc, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: bloc.stream,
      initialData: bloc.value,
      builder: (_, snapshot) => Text('Valor: 	${snapshot.data}'),
    );
  }
}
```

> Usa el `AppStateManager` para exponer todos tus blocs. Tu test harness puede envolver widgets con un AppStateManager simulado.

---

## ✅ Resumen

Esta estructura promueve la separación de responsabilidades y la testabilidad, manteniéndose flexible. Puedes escalarla para apps complejas o mantenerla simple para MVPs.

¡Disfruta construyendo con `jocaagura_domain`! 🐱‍👤
