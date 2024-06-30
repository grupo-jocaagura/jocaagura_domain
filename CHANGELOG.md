# CHANGELOG Jocaagura Domain

Este documento sigue las pautas de [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto se adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.2] - 2024-06-30
### Added
- `Colores`: Se agrega un mapa de colores en el diagrama UML y se incluye explicación en el README para mejorar la visualización del estado de implementación de los modelos.

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
