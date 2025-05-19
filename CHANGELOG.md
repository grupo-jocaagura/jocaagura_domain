# CHANGELOG Jocaagura Domain

This document follows the guidelines of [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.18.1] - 2025-05-18
chore(github): reestructura develop desde master y actualiza workflows


## [1.18.0] - 2025-05-18

### Added
- Nueva estructura estándar de errores:
  - `HttpErrorItems`: Manejo de errores HTTP comunes como 404, 401, 500, con niveles de severidad (`danger`, `severe`, `warning`, `systemInfo`).
  - `WebSocketErrorItems`: Representación de errores típicos de WebSocket como fallos de conexión, cierre inesperado o mensajes malformados.
  - `NetworkErrorItems`: Para errores como sin conexión, timeout o servidor inaccesible.
- Inclusión de métodos estáticos `fromCode()` y `fromStatusCode()` en las clases anteriores.
- Clave estandarizada `meta['source']` y validadores para `meta['httpCode']` y similares.

### Updated
- `ErrorItem` ahora soporta un campo `errorLevel` de tipo `ErrorLevelEnum`.
  - El valor por defecto es `ErrorLevelEnum.systemInfo` para obligar a definirlo explícitamente.
  - Se agregó `toString()` actualizado para incluir el `errorLevel`.
- Documentación de cada clase de error fue ampliada con enlaces a los estándares utilizados (MDN, Flutter API).

### Tests
- Se agregaron pruebas unitarias para `HttpErrorItems`, `WebSocketErrorItems`, y `NetworkErrorItems` incluyendo validación de `errorLevel`, `fromCode()` y fallback `unknown()`.
- Se probaron los casos límite y el mapeo correcto desde códigos conocidos.

### Docs
- Actualizado el `README.md` para reflejar las nuevas capacidades de los modelos de error y sus usos sugeridos.


## [1.17.1] - 2025-05-18

### Updated
- Enhanced the financial movement model to support up to 4 decimal places for mathematical precision and to prevent negative amounts at the model level.

### Fixed
- Minor patches in `analysis_options.yaml` to remove dependencies no longer used in the updated implementation.


## [1.17.0] - 2025-03-25

### Added
- Implemented the financial movement model to manage financial transactions.

## [1.16.0] - 2025-01-25

### Added
- Configured GitHub Actions secrets to securely store sensitive data required for workflows.
- Validated and updated the GitHub maintainers group to ensure proper repository access and management.

### Updated
- Enhanced the `README` file with updated repository details and instructions for contributors.

## [1.15.2] - 2024-12-29

### Fixed

- Translation of the changelog to English.
- Completion and translation of inline documentation to English.
- Extended unit tests.
- Updated linter package.

## [1.15.1] - 2024-08-25

### Fixed

- Minor changes in DartDoc formatting without affecting the code or its functionality.

## [1.15.0] - 2024-08-25

### Added

- `MedicalRecordModel`: Added model, tests, and DartDoc documentation for the patient's state in the dentist app.

## [1.14.0] - 2024-08-25

### Added

- `MedicationModel`: Added model, tests, and DartDoc documentation for the appointment model.

## [1.13.0] - 2024-08-25

### Added

- `AppointmentModel`: Added model, tests, and DartDoc documentation for the appointment model.
- `ContactModel`: Added model, tests, and DartDoc documentation for the contact model.

## [1.12.1] - 2024-08-07

### Changed

- `AnimalModel`: Added DartDoc documentation for the model.

## [1.12.0] - 2024-08-07

### Added

- `AnimalModel`: Added the model to start work on the animal class.

## [1.11.0] - 2024-08-04

### Added

- `AcceptanceModel`: Added model for legally accepting medical treatment.

## [1.10.0] - 2024-08-04

### Added

- `TreatmentPlanModel`: Added treatment plan for the patient.

## [1.9.0] - 2024-07-28

### Added

- `MedicalTreatmentModel`: Added model to manage treatments for patients.

### Changed

- Minor formatting fixes for `dental_condition_model`, `dental_condition_model_test`, and `medical_diagnosis_model`.

## [1.8.0] - 2024-07-24

### Added

- `DentalConditionModel`: Added model and documentation for the dental condition.

## [1.7.1] - 2024-07-22

### Changed

- `MedicalDiagnosisModel`: Added documentation for developers in the file.

## [1.7.0] - 2024-07-22

### Added

- `MedicalDiagnosisModel`: Added model to ensure diagnostics.

## [1.6.1] - 2024-07-21

### Changed

- `medical_diagnosis_tab_model_test`: Increased test coverage.

## [1.6.0] - 2024-07-21

### Changed

- `signature_model`: Updated to include hashCode.

### Added

- `MedicalDiagnosisTabModel`: Added model for medical diagnosis collection and its unit tests.

## [1.5.0] - 2024-07-07

### Changed

- Upgraded `flutter_lints` to version 4.0.0 in dev dependencies.

### Added

- `SignatureModel`: Added model for user signature with its unit tests.

## [1.4.2] - 2024-06-30

### Added

- `Colors`: Added a color map to the UML diagram with an explanation in the README to improve visualization of the implementation state of models.

### Fixed

- `UML Diagram`: Updated to reflect the implementation state of models:
  - `Either`, `Left`, `Right`: Confirmed.
  - `Model`, `UserModel`, `AttributeModel<T>`: Confirmed.
  - `Bloc`, `BlocModule`, `BlocGeneral<T>`, `BlocCore`: Confirmed.
  - `UI`: `ModelMainMenuModel` confirmed.
  - `Connectivity`: `ConnectionTypeEnum`, `ConnectivityModel` confirmed.
  - `Citizen`: `PersonModel` under review, `LegalIdModel` confirmed.
  - `Obituary`: `ObituaryModel`, `DeathRecordModel` confirmed.
  - `Shops`: `StoreModel` confirmed.
  - `Geolocation`: `AddressModel` confirmed.

## [1.4.1] - 2024-06-30

### Fixed

- `version`: Corrected to initialize work with new models.

## [1.4.0] - 2024-06-30

### Added

- `uml_diagrams`: Added diagrams with more models for future work.

## [1.3.1] - 2024-05-25

### Fixed

- Typing consistency adjustments in the `Either` class.

## [1.3.0] - 2024-05-10

### Added

- `ConnectivityModel` class and corresponding documentation.

## [1.2.1]

- Added `Debouncer` class.
- Added documentation in the README file.

## [1.0.0]

- Added `Either` class.
- Approved for production.

## [0.3.2]

- Added `DeathRecordModel` into `ObituaryModel`.

## [0.3.1]

- Fixed `fromJson` factory constructor in `LegalIdModel`.

## [0.3.0]

- Added `LegalIdModel`.

## [0.2.0]

- Added `DeathRecordModel`.

## [0.1.2]

- Minor fix to `ObituaryModel` to include `vigilDate` and `burialDate` in parameters.
- Increased unit test coverage.

## [0.1.01]

- Changed officially to beta.
- Minor fix to `ObituaryModel` to include `message` in parameters.

## [0.0.9]

- Added `ObituaryModel`.
- Minor fix to `PersonModel` to cover variable names properly.
- Increased `PersonModel` and `DateUtils` test coverage.

## [0.0.8]

- Added DateTime-to-String utility.

## [0.0.71]

- Changed attributes in Models to `Map<String, AttributeModel<dynamic>>`.

## [0.0.7]

- Completed `PersonModel` with subModelClass (`AttributeModel`) for information.

## [0.0.6]

- Completed `StoreModel` with formatted options.

## [0.0.5]

- Added `StoreModel`.

## [0.0.4]

- Added `AddressModel`.

## [0.0.3]

- Added `Utils` class for JSON conversion management.
- Improved unit test coverage.

## [0.0.2]

- Added `UserModel` and established some immutable conditions.

## [0.0.1]

- Added initial abstract class `Model`.
