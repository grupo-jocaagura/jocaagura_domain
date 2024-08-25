# CHANGELOG Jocaagura Domain

Este documento sigue las pautas de [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto se adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.14.0] - 2024-08-25

### added

- `MedicationModel` se agrega modelo, test y documentación en formato dart doc para el modelo de
  citas


## [1.13.0] - 2024-08-25

### added

- `AppointmentModel` se agrega modelo, test y documentación en formato dart doc para el modelo de
  citas
- `ContactModel` se agrega modelo, test y documentación en formato dart doc para el modelo de
  contacto

## [1.12.1] - 2024-08-07

### changed

- `AnimalModel` se agrega documentación en formato dart doc para el modelo

## [1.12.0] - 2024-08-07

### added

- `AnimalModel` se agrega el modelo para iniciar el tratamiento de la clase animal

## [1.11.0] - 2024-08-04

### added

- `AcceptanceModel` se agrega el modelo para aceptar legalmente el tratamiento medico

## [1.10.0] - 2024-08-04

### added

- `TreatmentPlanModel` se agrega el plan de tratamiento para el paciente

## [1.9.0] - 2024-07-28

### added

- `MedicalTreatmentModel` se agrega el modelo para manejar tratamientos a los pacientes

### changed

- `dental_condition_model` `dental_condition_model_test` `medical_diagnosis_model` correcciones
  menores de formato

## [1.8.0] - 2024-07-24

### added

- `DentalConditionModel` se agrega el modelo y la documentación para la condicion dental.

## [1.7.1] - 2024-07-22

### changed

- `MedicalDiagnosisModel` se agrega la documentacion en el archivo para los desarrolladores

## [1.7.0] - 2024-07-22

### added

- `MedicalDiagnosisModel` se agrega para garantizar los diagnosticos

## [1.6.1] - 2024-07-21

### changed

- `medical_diagnosis_tab_model_test` para aumentar el coverage de las pruebas

## [1.6.0] - 2024-07-21

### changed

- `signature_model` para incluir el hascode

### added

- `MedicalDiagnosisTabModel` Se agrega el modelo para la recolección de los diagnosticos medicos y
  sus test unitarios

## [1.5.0] - 2024-07-07

### changed

- `flutter_lints` upgraded to 4.0.0 in dev dependencies

### added

- `SignatureModel` Se agrega el modelo para la firma del usuario con sus test unitarios

## [1.4.2] - 2024-06-30

### Added

- `Colores`: Se agrega un mapa de colores en el diagrama UML y se incluye explicación en el README
  para mejorar la visualización del estado de implementación de los modelos.

### Fixed

- `Diagrama UML`: Actualización para reflejar el estado de implementación de los modelos:
    - `Either`, `Left`, `Right`: Confirmados.
    - `Model`, `UserModel`, `AttributeModel<T>`: Confirmados.
    - `Bloc`, `BlocModule`, `BlocGeneral<T>`, `BlocCore`: Confirmados.
    - `UI`: `ModelMainMenuModel` confirmado.
    - `Connectivity`: `ConnectionTypeEnum`, `ConnectivityModel` confirmados.
    - `Citizen`: `PersonModel` en revisión, `LegalIdModel` confirmado.
    - `Obituary`: `ObituaryModel`, `DeathRecordModel` confirmados.
    - `Shops`: `StoreModel` confirmado.
    - `Geolocation`: `AddressModel` confirmado.

## [1.4.1] - 2024-06-30

### Fixed

- `version` Se corrige a version para iniciar el trabajo con los nuevos modelos.

## [1.4.0] - 2024-06-30

### Added

- `uml_diagrams` con más modelos para trabajar en futuras versiones.

## [1.3.1] - 2024-05-25

### Fixed

- Ajustes de coherencia de tipado en la clase `Either`.

## [1.3.0] - 2024-05-10

### Added

- Clase `ConnectivityModel` y su documentación correspondiente.

## 1.2.1

* Add Debouncer class.
* Add documentation in readme file.

## 1.0.0

* Add Either class.
* Approved for production.

## 0.3.2

* Add DeathRecordModel into ObituaryModel.

## 0.3.1

* Fixed factory fromJson constructor in LegalIdModel.

## 0.3.0

* Add LegalIdModel.

## 0.2.0

* Add DeathRecordModel.

## 0.1.2

* Minor fix to ObituaryModel to cover vigilDate and burialDate in parameters.
* Increase unit test coverage.

## 0.1.01

* Change officially to beta.
* Minor fix to ObituaryModel to cover message in parameters.

## 0.0.9

* Add ObituaryModel.
* Minor fix to PersonModel to cover variable names properly.
* Increase of person model and DateUtils test coverage.

## 0.0.8

* Add DateTime to String utility.

## 0.0.71

* Change attributes in Models for Map<String, AttributeModel<dynamic>>.

## 0.0.7

* PersonModel completed with subModelClass (AttributeModel) for info.

## 0.0.6

* StoreModel completed with formatted options.

## 0.0.5

* StoreModel added.

## 0.0.4

* AddressModel added.

## 0.0.3

* Utils class added for management of JSON conversions.
* Unit test coverage improved.

## 0.0.2

* UserModel and some immutable conditions established.

## 0.0.1

* Initial abstract class Model added.
