# Jocaagura Domain
![Coverage](https://img.shields.io/badge/coverage-99%25-brightgreen)
![Coverage](https://img.shields.io/badge/Author-@albertjjimenezp-brightgreen)
-------------------------------![Author](https://avatars.githubusercontent.com/u/35118534?s=200&u=80708c1558e4e482d52d31490959442f618a2d62&v=4)----------🐱‍👤

## Descripción
El paquete Jocaagura Domain ofrece una serie de abstracciones de lógica de negocio diseñadas para mantener una coherencia arquitectónica en proyectos Flutter. Al proveer una base sólida y una arquitectura limpia y escalable, facilita la interrelación de desarrollos múltiples, permitiendo que las diferentes aplicaciones converjan en una misma estructura de diseño.

## Características
- **Abstracciones de Modelos**: Contiene modelos fundamentales como `UserModel`, `PersonModel`, entre otros.
- **Arquitectura Limpia**: Fomenta una estructura de código mantenible y organizada.
- **Cobertura de Pruebas**: Incluye pruebas que cubren un amplio rango de escenarios para garantizar la robustez.
- **Independencia**: No tiene dependencias externas más allá del SDK de Flutter.
- **Diagramas UML**: Proporciona diagramas UML para entender las relaciones entre clases.

## Contratos JSON Schema
El repositorio incluye contratos JSON canonicos y versionados en `doc/schemas/`.

- Guia general: `doc/schemas/README.md`
- Version actual: `doc/schemas/v1/`

Estos schemas documentan el contrato JSON interoperable del dominio y sirven como base para validacion externa, tooling y futuras integraciones backend.

Puntos clave:

- el schema describe el contrato canonico de intercambio, no todas las tolerancias legacy de `fromJson()`
- los examples en `doc/schemas/v1/examples/` son payloads canonicos validos
- el setup local del ambiente de validacion esta documentado en `doc/schemas/README.md`
- la validacion local se ejecuta con `npm run validate:schemas`
- las brechas conocidas entre contrato canónico y mappers Dart actuales estan documentadas en `doc/schemas/README.md` y `doc/schemas/v1/README.md`

## Prerrequisitos y Comienzo Rápido
Para utilizar el paquete, se requiere la instalación del SDK de Flutter. No hay dependencias de terceros y todas las clases necesarias están contenidas dentro del paquete. Se sigue un enfoque "plug and play" para una fácil integración.

# Índice

- [Model](#model)
- [Utils](#utils)
- [DateUtils](#dateutils)
- [AddressModel](#addressmodel)
- [AttributeModel](#attributemodel)
- [DeathRecordModel](#deathrecordmodel)
- [LegalIdModel](#legalidmodel)
- [ModelVector](#modelvector)
- [ObituaryModel](#obituarymodel)
- [PersonModel](#personmodel)
- [StoreModel](#storemodel)
- [Bloc](#bloc)
- [BlocCore](#bloccore)
- [BlocGeneral](#blocgeneral)
- [BlocModule](#blocmodule)
- [Either, Left, and Right](#either-left-and-right)
- [EntityBloc](#EntityBloc-and-RepeatLastValueExtension)
- [EntityProvider, EntityService, and EntityUtil](#entityprovider-entityservice-and-entityutil)
- [ErrorItemModel](lib/domain/error_item_model.dart)
- [Errores estandar](lib/domain/common_errors)
- [ConnectivityModel](#ConnectivityModel)
- [ModelMainMenuModel](#modelmainmenumodel)
- [Debouncer](#debouncer)
- [Documentacion de modelos](#documentación-de-modelos)
- [SignatureModel](lib/domain/citizen/signature_model.dart)
- [MedicalDiagnosisTabModel](lib/domain/medical/medical_diagnosis_tab_model.dart)
- [DiagnosisModel](lib/domain/dentist_app/diagnosis_model.dart)
- [DentalConditionModel](lib/domain/dentist_app/dental_condition_model.dart)
- [MedicalTreatmentModel](lib/domain/dentist_app/medical_treatment_model.dart)
- [TreatmentPlanModel](lib/domain/dentist_app/treatment_plan_model.dart)
- [AcceptanceClausePlanModel](lib/domain/dentist_app/acceptance_clause_model.dart)
- [AnimalModel](lib/domain/pet_app/animal_model.dart)
- [AppointmentModel](lib/domain/calendar/appointment_model.dart)
- [ContactModel](lib/domain/calendar/contact_model.dart)
- [MedicationModel](lib/domain/medical/medication_model.dart)
- [MedicalRecordModel](lib/domain/dentist_app/medical_record_model.dart)
- [FinancialMovement](lib/domain/financial/financial_movement.dart)
- [LedgerModel](lib/domain/financial/ledger_model.dart)
- [Unit](#Unit)
- [PerKeyFifoExecutor](#PerKeyFifoExecutor)
- [Connectivity](#Connectivity)
- [BlocOnboarding](#BlocOnboarding)
- [BlocResponsive](#BlocResponsive)
-
    - [Flujo Store (ModelStore + Item + Category + Price)](#ModelStore-Flow)

Cada sección proporciona detalles sobre la implementación y el uso de las clases, ofreciendo ejemplos de código y explicaciones de cómo se integran dentro de tu arquitectura de dominio.

## Uso
Aquí se muestra cómo utilizar la clase `UserModel` para crear una nueva instancia de usuario y manipular sus datos.

```dart
import 'path_to_jocaagura_domain/user_model.dart';

void main() {
  // Crear una instancia de UserModel con valores predeterminados.
  var user = UserModel(
    id: '001',
    displayName: 'Juan Perez',
    photoUrl: 'https://example.com/photo.jpg',
    email: 'juan.perez@example.com',
    jwt: {'token': 'abcd1234'},
  );

  // Imprimir la instancia del usuario.
  print(user.toString());

  // Actualizar la instancia del usuario utilizando el método copyWith.
  var updatedUser = user.copyWith(email: 'juan.updated@example.com');
  print(updatedUser.toString());
}
```
# Información Adicional

Para contribuir al paquete o reportar problemas, los usuarios pueden dirigirse al repositorio del proyecto. En la carpeta raíz /uml, encontrarán un archivo uml_diagrams.drawio con diagramas detallados, como el proporcionado en el screenshot, que describen las clases y sus interrelaciones.

# Model

## Descripción
`Model` es una clase abstracta base para todos los modelos de datos del dominio en el paquete Jocaagura Domain. Proporciona métodos comunes para la serialización y deserialización de JSON, métodos para crear copias de la entidad, y herramientas para la comparación y generación de hash de instancias. Esta clase facilita la manipulación y el manejo uniforme de los modelos de datos a lo largo de la aplicación.

## Caso de uso en Dart
Dado que `Model` es una clase abstracta, no se puede instanciar directamente. En su lugar, se utiliza como base para crear modelos concretos. A continuación, se muestra un ejemplo de cómo podría ser una subclase de `Model` que representa un modelo de usuario, junto con su uso:

```dart
import 'jocaagura_domain.dart';

class UserModel extends Model {
  final String id;
  final String name;

  const UserModel({required this.id, required this.name});

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  UserModel copyWith({String? id, String? name}) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

void main() {
  UserModel user = UserModel(id: '123', name: 'John Doe');

  // Convertir a JSON
  Map<String, dynamic> userJson = user.toJson();
  print('Usuario en formato JSON: $userJson');

  // Crear una copia con diferentes datos
  UserModel updatedUser = user.copyWith(name: 'Jane Doe');
  print('Usuario actualizado: ${updatedUser.toJson()}');
}
```

# Utils

## Descripción
La clase `Utils` proporciona una colección de métodos estáticos utilitarios que facilitan la manipulación de datos comunes en la lógica de negocio. Incluye funciones para convertir estructuras de datos a y desde formatos JSON, validación de strings como emails o URLs, transformación de números de teléfono y más. Es una clase esencial que proporciona operaciones de utilidad para el manejo de datos a lo largo de toda la aplicación.

## Caso de uso en Dart
El siguiente ejemplo demuestra cómo utilizar algunos de los métodos de `Utils` para manejar y validar datos comunes:

```dart
void main() {
  // Conversión de Map a String JSON
  Map<String, dynamic> userInfo = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
  };
  String userInfoJson = Utils.mapToString(userInfo);
  print('Información de usuario en formato JSON: $userInfoJson');

  // Validación de un email
  String email = 'john.doe@example.com';
  bool isEmailValid = Utils.isEmail(email);
  print('¿Es el email válido? $isEmailValid');

  // Formateo de un número de teléfono
  int phoneNumber = 1234567890;
  String formattedPhone = Utils.getFormatedPhoneNumber(phoneNumber);
  print('Número de teléfono formateado: $formattedPhone');

  // Conversión segura de un dynamic a int
  dynamic dynamicValue = '10';
  int intValue = Utils.getIntegerFromDynamic(dynamicValue);
  print('Valor entero obtenido de dynamic: $intValue');
}
```

# DateUtils

## Descripción
`DateUtils` es una clase dedicada a la conversión y manejo de fechas dentro del paquete Jocaagura Domain. Ofrece métodos estáticos para convertir dinámicamente valores de diferentes tipos a objetos `DateTime` y para transformar objetos `DateTime` a su representación en cadena conforme al estándar ISO 8601. Esta clase es crucial para asegurar la correcta manipulación de fechas y horas en la aplicación, especialmente cuando se interactúa con diferentes fuentes de datos y formatos.

## Caso de uso en Dart
Aquí se muestra cómo usar `DateUtils` para convertir valores dinámicos a `DateTime` y cómo obtener una representación en string de una fecha:

```dart
void main() {
  // Convertir un timestamp en milisegundos a DateTime
  int timestamp = 1650915600000;
  DateTime dateTimeFromTimestamp = DateUtils.dateTimeFromDynamic(timestamp);
  print('DateTime de timestamp: $dateTimeFromTimestamp');

  // Convertir una cadena ISO 8601 a DateTime
  String isoDate = '2022-04-25T14:30:00Z';
  DateTime dateTimeFromString = DateUtils.dateTimeFromDynamic(isoDate);
  print('DateTime de string ISO: $dateTimeFromString');

  // Convertir un objeto DateTime a una cadena ISO 8601
  String dateTimeString = DateUtils.dateTimeToString(DateTime.now());
  print('String ISO de DateTime: $dateTimeString');
}
```
# AddressModel

## Descripción
`AddressModel` es un modelo que representa una dirección física dentro del dominio de la aplicación. Incluye detalles como país, área administrativa, ciudad, localidad, dirección específica, código postal y notas adicionales. Este modelo extiende la clase `Model`, lo que significa que hereda métodos para la serialización a JSON, copia y comparación de instancias. `AddressModel` es fundamental para gestionar la información de ubicación que es frecuentemente requerida en aplicaciones que manejan envíos, perfiles de usuario y más.

## Caso de uso en Dart
El ejemplo siguiente ilustra cómo crear una instancia de `AddressModel` a partir de un JSON y cómo generar una nueva instancia modificando algunos atributos:

```dart
import 'path_to_jocaagura_domain/address_model.dart';

void main() {
  // Crear una instancia de AddressModel a partir de un mapa JSON
  Map<String, dynamic> addressJson = {
    'id': '1',
    'postalCode': 12345,
    'country': 'USA',
    'administrativeArea': 'CA',
    'city': 'San Francisco',
    'locality': 'SOMA',
    'address': '123 Main St',
    'notes': 'Some notes',
  };

  AddressModel address = AddressModel.fromJson(addressJson);
  print('AddressModel: ${address.toString()}');

  // Actualizar la ciudad y la localidad de la dirección existente
  AddressModel updatedAddress = address.copyWith(city: 'Los Angeles', locality: 'Downtown');
  print('Updated AddressModel: ${updatedAddress.toString()}');
}
```

#### ModelStore-Flow

## Flujo Store (ModelStore) {#flujo-store-modelstore}

Esta sección resume el **flujo mínimo** de tienda usando **solo modelos** del dominio:
[StoreModel](#storemodel), [ModelItem](#modelitem), [ModelCategory](#modelcategory)
y [ModelPrice](#modelprice).

> **Contexto arquitectónico sugerido (Clean)**  
> UI → AppManager → Bloc → UseCase → Repository → Gateway → Service  
> (Este bloque documenta exclusivamente los **modelos** del flujo Store; el cableado a capas se
> muestra en otras secciones del README).

### Objetivos

- Crear una tienda (`StoreModel`) con NIT y teléfonos formateados.
- Definir categorías (`ModelCategory`) y precios (`ModelPrice`).
- Construir ítems (`ModelItem`) que usen esas categorías y precios.
- Demostrar **roundtrip JSON** y la **normalización de id** cuando `ModelItem.id` está vacío.

### Notas clave de contrato

- `StoreModel.nitNumber` calcula el dígito de verificación (Colombia).
- `StoreModel.formatedPhoneNumber1/2` aplican formateo de teléfono.
- `ModelPrice.defaultMathprecision == 2` y `toString()` muestra el valor decimal (ej.
  `💰 12.50 COP`).
- `ModelItem.id` vacío ⇒ en `toJson()` se usa `ModelCategory.normalizeCategory(type.category)` como
  **id lógico** (útil para persistencia).

### Ejemplo mínimo (copiar/pegar)

```dart
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  // 1) Tienda (usa defaultAddressModel del dominio)
  const StoreModel store = StoreModel(
    id: 'store_001',
    nit: 900123456,
    // ejemplo CO
    photoUrl: 'https://example.com/store.png',
    coverPhotoUrl: 'https://example.com/cover.png',
    email: 'store@example.com',
    ownerEmail: 'owner@example.com',
    name: 'Jocaagura Pet Store',
    alias: 'Pet Store',
    address: defaultAddressModel,
    phoneNumber1: 3001234567,
    phoneNumber2: 6017654321,
  );

  // 2) Categorías (se normalizan en toJson: espacios -> '-', minúsculas, etc.)
  const ModelCategory catFood = ModelCategory(
    category: 'Cat Food',
    description: 'Food for cats',
  );
  const ModelCategory toys = ModelCategory(
    category: 'Toys',
    description: 'Pet toys and fun stuff',
  );

  // 3) Precios (minor units + precision=2 -> 1250 == 12.50)
  const ModelPrice priceFood = ModelPrice(
    amount: 42500,
    currency: CurrencyEnum.COP,
    mathPrecision: ModelPrice.defaultMathprecision, // 2
  );
  const ModelPrice priceToy = ModelPrice(
    amount: 15000,
    currency: CurrencyEnum.COP,
  );

  // 4) Ítems (si id='', toJson() usará la categoría normalizada como id)
  final ModelItem itemFood = ModelItem(
    id: '',
    // <- demostración del fallback de id
    name: 'Comida Premium Gato 1Kg',
    description: 'Alimento balanceado para gato adulto',
    type: catFood,
    price: priceFood,
  );

  final ModelItem itemToy = ModelItem(
    id: 'SKU-TOY-001',
    name: 'Juguete Ratón',
    description: 'Juguete interactivo para gato',
    type: toys,
    price: priceToy,
  );

  // 5) Roundtrip JSON + evidencias de contratos
  final Map<String, dynamic> jsonFood = itemFood.toJson();
  final ModelItem fromFood = ModelItem.fromJson(jsonFood);

  print('--- STORE ---');
  print('Nombre: ${store.name} (${store.alias})');
  print('NIT: ${store.nitNumber}');
  print('Tel 1: ${store.formatedPhoneNumber1}');
  print('Tel 2: ${store.formatedPhoneNumber2}');

  print('\n--- ITEMS ---');
  print('Item A (id vacío → normalizado): ${jsonFood['id']}'); // ej. "cat-food"
  print('Item A (precio): ${itemFood.price}'); // ej. 💰 425.00 COP si amount=42500
  print('Item B (id): ${itemToy.id}');
  print('Item B (precio): ${itemToy.price}');

  // Verifica que el roundtrip conserve datos
  assert(fromFood == itemFood.copyWith(id: itemFood.id)); // igualdad estructural
}
````

### Referencias rápidas (solo modelos de este flujo)

#### ModelItem {#modelitem}

* Ítem inmutable con `id`, `name`, `description`, `type: ModelCategory`, `price: ModelPrice`.
* `toJson()` aplica `trim` a `name/description` y serializa `type/price` como mapas JSON.

#### ModelCategory {#modelcategory}

* `category` funciona como **id lógico**.
* `toJson()` usa `normalizeCategory(category)` (snake/kebab seguro y estable).

#### ModelPrice {#modelprice}

* `amount` en **unidades menores**; `decimalAmount = amount / 10^mathPrecision`.
* `currency` serializa por `enum.name` (ej. `"COP"`). `toString()` ya devuelve texto legible.

```
# AttributeModel

## Descripción
`AttributeModel` es una clase genérica que se utiliza para representar un atributo con un valor asociado de cualquier tipo que sea compatible con los tipos de datos de Firebase. La clase asegura que los valores utilizados puedan ser manejados por Firestore, lo que incluye tipos como String, Number, Boolean, Map, Array, Null, Timestamp, puntos geográficos y blobs binarios. La clase `AttributeModel` es útil para modelar datos dinámicos y flexibles en aplicaciones que interactúan con bases de datos como Firestore.

Se proporciona el `enum AttributeEnum` para manejar las claves de los atributos y `attributeModelfromJson` como una función auxiliar para la deserialización.
```dart
import 'path_to_jocaagura_domain/attribute_model.dart';

void main() {
  // Crear una instancia de AttributeModel
  AttributeModel<int> ageAttribute = AttributeModel(name: 'age', value: 30);
  print('AttributeModel: ${ageAttribute.toString()}');

  // Parsear un JSON a AttributeModel utilizando la función auxiliar
  Map<String, dynamic> attributeJson = {
    'name': 'height',
    'value': '175',
  };

  AttributeModel<double> heightAttribute = attributeModelfromJson<double>(
    attributeJson,
        (dynamic value) => double.tryParse(value.toString()) ?? 0.0,
  );
  print('AttributeModel from JSON: ${heightAttribute.toString()}');
}
```
Además, es importante mencionar el uso de clases y valores predeterminados como `defaultAddressModel`, que proporcionan un punto de partida para la creación de instancias de modelos cuando se necesiten valores por defecto.
```dart
// Modelo de dirección predeterminado
const AddressModel defaultAddressModel = AddressModel(
  id: '1',
  postalCode: 12345,
  country: 'USA',
  administrativeArea: 'CA',
  city: 'San Francisco',
  locality: 'SOMA',
  address: '123 Main St',
  notes: 'Some notes',
);
```
El uso adecuado de `AttributeModel` junto con las herramientas auxiliares proporciona una gran flexibilidad y potencia para manejar datos estructurados en aplicaciones de Flutter, haciendo que el manejo de datos de diferentes tipos sea más sencillo y mantenible.
# DeathRecordModel

## Descripción
`DeathRecordModel` es una clase que representa un registro de defunción. Incluye detalles como la identificación de la notaría, información de la persona fallecida, dirección de la notaría, y un identificador único para el registro. Viene con un modelo predeterminado `defaultDeathRecord` que puede ser utilizado cuando se necesiten valores por defecto. La inmutabilidad de la clase garantiza que los registros de defunción sean siempre consistentes una vez creados.
```dart
import 'path_to_jocaagura_domain/death_record_model.dart';

void main() {
  // Crear una instancia de DeathRecordModel con valores por defecto
  DeathRecordModel deathRecord = defaultDeathRecord;
  print('DeathRecordModel: ${deathRecord.toString()}');

  // Actualizar el registro con nuevos datos
  DeathRecordModel updatedRecord = deathRecord.copyWith(recordId: '123456');
  print('Updated DeathRecordModel: ${updatedRecord.toString()}');
}

```
Este modelo es esencial para aplicaciones que necesitan representar y manejar información sensible y específica relacionada con actos civiles como son los registros de defunción. Su diseño garantiza que se maneje de manera adecuada la integridad de los datos.
```dart
// Modelo de registro de defunción predeterminado
const DeathRecordModel defaultDeathRecord = DeathRecordModel(
  notaria: defaultStoreModel,
  person: defaultPersonModel,
  address: defaultAddressModel,
  recordId: '9807666',
  id: 'gx86GyNM',
);
```
Al utilizar `DeathRecordModel`, las aplicaciones se benefician de un manejo estructurado de los datos relacionados con registros de defunción, lo cual es crítico para el correcto funcionamiento de los servicios relacionados con el manejo de actos de defunción y certificados correspondientes.

# LegalIdModel

## Descripción
`LegalIdModel` representa un modelo de identificación legal de una persona. Incluye el tipo de identificación, nombres, apellidos, número de identificación y atributos adicionales que pueden ser necesarios según el tipo de documento. La clase utiliza un `enum` para definir los tipos de identificación legal y garantiza que todos los datos se almacenen y gestionen de manera coherente. Además, `defaultLegalIdModel` proporciona un conjunto predeterminado de valores para instancias donde se requieran valores por defecto.
```dart
import 'path_to_jocaagura_domain/legal_id_model.dart';

void main() {
  // Utilizar el modelo de identificación legal predeterminado
  LegalIdModel legalId = defaultLegalIdModel;
  print('LegalIdModel predeterminado: ${legalId.toString()}');

  // Crear una nueva instancia con algunos valores personalizados
  LegalIdModel updatedLegalId = legalId.copyWith(
    names: 'Juan Carlos',
    lastNames: 'Gonzalez',
    legalIdNumber: '654321',
  );
  print('LegalIdModel actualizado: ${updatedLegalId.toString()}');
}
```
La flexibilidad de `LegalIdModel` lo hace adecuado para sistemas que requieren una gestión detallada de diferentes tipos de documentos de identificación, proporcionando una forma estructurada de acceder y manipular estos datos importantes.
```dart
// Enum para tipos de documento de identificación legal
enum LegalIdTypeEnum {
  registroCivil,
  tarjetaIdentidad,
  cedula,
  cedulaExtranjeria,
  pasaporte,
  licenciaConduccion,
  certificadoNacidoVivo,
}

// Extensión para obtener descripciones amigables de los tipos de documento
extension LegalIdTypeExtension on LegalIdTypeEnum {
  String get description {
    switch (this) {
    // Aquí irían todos los casos
    }
  }
}

// Función para obtener un valor enum a partir de una descripción de string
LegalIdTypeEnum getEnumValueFromString(String description) {
  // Aquí iría la lógica de conversión
}
```
```dart
// Modelo de identificación legal predeterminado
const LegalIdModel defaultLegalIdModel = LegalIdModel(
  id: 'vHi05635G',
  idType: LegalIdTypeEnum.cedula,
  names: 'pedro luis',
  lastNames: 'manjarrez paez',
  legalIdNumber: '123456',
  attributes: <String, AttributeModel<dynamic>>{
    'rh': AttributeModel<String>(value: 'O+', name: 'rh'),
    'fechaExpedición': AttributeModel<String>(
      value: '1979-09-04T00:00:00.000',
      name: 'fechaExpedición',
    ),
  },
);
```
Al implementar `LegalIdModel` en una aplicación, se simplifica la tarea de manejar la diversidad de documentos de identidad, cada uno con su propio conjunto de atributos específicos, y se promueve una manipulación de datos coherente y segura.

# ModelVector

## Descripción
`ModelVector` es una clase que representa un vector en dos dimensiones con componentes `dx` (desplazamiento en el eje x) y `dy` (desplazamiento en el eje y). La clase es útil para representar direcciones o velocidades en un plano bidimensional, típicamente en simulaciones, animaciones o en cualquier contexto gráfico dentro de una aplicación. Incluye métodos para la creación a partir de objetos JSON, copias modificadas del vector, y la conversión a `Offset`, que es comúnmente usado en Flutter para posiciones y movimientos.
```dart
import 'path_to_jocaagura_domain/model_vector.dart';

void main() {
  // Crear un ModelVector usando valores predeterminados
  ModelVector vector = defaultModelVector;
  print('ModelVector predeterminado: ${vector.toString()}');

  // Actualizar el vector
  ModelVector updatedVector = vector.copyWith(dx: 2.0, dy: 3.0);
  print('ModelVector actualizado: ${updatedVector.toString()}');

  // Convertir un ModelVector a Offset para uso en UI
  Offset offset = updatedVector.offset;
  print('Offset derivado: $offset');
}
```
Este modelo es fundamental cuando se trabaja con gráficos o interfaces que requieren una representación clara y matemática de movimientos o direcciones en el plano.
```dart
// Vector modelo predeterminado para inicializaciones rápidas
const ModelVector defaultModelVector = ModelVector(1.0, 1.0);

```
Utilizar `ModelVector` facilita la manipulación de coordenadas y vectores en una gran variedad de aplicaciones, desde juegos hasta aplicaciones de gráficos avanzados, proporcionando una interfaz intuitiva y flexible para trabajar con datos espaciales.

# ObituaryModel

## Descripción
`ObituaryModel` es una clase que representa un obituario en una aplicación. Contiene información detallada como la identidad de la persona fallecida, fechas y direcciones de vigilias y entierros, así como un mensaje de condolencia. Es esencial en aplicaciones que manejan anuncios de obituarios o servicios relacionados con funerales. Además, esta clase utiliza datos de otras clases como `PersonModel` y `AddressModel`, y puede incluir un enlace a un `DeathRecordModel`.
```dart
import 'path_to_jocaagura_domain/obituary_model.dart';

void main() {
  // Utilizar el obituario predeterminado
  ObituaryModel obituary = defaultObituary;
  print('ObituaryModel predeterminado: ${obituary.toString()}');

  // Crear una nueva instancia modificando algunos valores
  ObituaryModel updatedObituary = obituary.copyWith(
    message: 'Su legado perdurará en nuestras memorias.',
    photoUrl: 'https://example.com/new-photo.jpg',
  );
  print('ObituaryModel actualizado: ${updatedObituary.toString()}');
}
```
Este modelo ayuda a gestionar de manera efectiva la información crítica asociada con los procedimientos de un funeral, garantizando que todos los detalles relevantes sean accesibles y estén organizados adecuadamente.
```dart
// Obituario modelo predeterminado para uso rápido
final ObituaryModel defaultObituary = ObituaryModel(
  id: 'qwerty',
  person: defaultPersonModel,
  creationDate: DateTime(2023, 12, 18),
  vigilDate: DateTime(2023, 07, 05, 14, 30),
  burialDate: DateTime(2023, 07, 05, 16, 30),
  vigilAddress: defaultAddressModel,
  burialAddress: defaultAddressModel,
  message:
  'Lamentamos profundamente tu perdida. Esperamos que tu memoria perdure como una fuente de inspiración y amor.',
);
```
La implementación de `ObituaryModel` en aplicaciones facilita la creación, gestión y visualización de obituarios, proporcionando una estructura coherente para almacenar y presentar esta información sensible y significativa.

# PersonModel

## Descripción
`PersonModel` es una clase que representa a una persona en el dominio de la aplicación. Almacena información como identificador único, nombres, apellidos, URL de foto y atributos adicionales en un formato clave-valor. Esta clase es fundamental en aplicaciones que requieren un manejo detallado de la información personal de los usuarios o clientes.
```dart
import 'path_to_jocaagura_domain/person_model.dart';

void main() {
  // Utilizar el modelo de persona predeterminado
  PersonModel person = defaultPersonModel;
  print('PersonModel predeterminado: ${person.toString()}');

  // Crear una nueva instancia modificando algunos valores
  PersonModel updatedPerson = person.copyWith(
      names: 'Maria',
      lastNames: 'Gonzalez',
      photoUrl: 'https://example.com/new-photo.jpg'
  );
  print('PersonModel actualizado: ${updatedPerson.toString()}');
}
```
Este modelo permite una gestión eficiente y estructurada de los datos de las personas, siendo crucial para sistemas que gestionan información de clientes, empleados o cualquier otro grupo de personas.
```dart
// Modelo de persona predeterminado para uso rápido
const PersonModel defaultPersonModel = PersonModel(
  id: '',
  names: 'J.J.',
  photoUrl: '',
  lastNames: 'Last Names',
  attributes: <String, AttributeModel<dynamic>>{},
);
```
Implementar `PersonModel` en una aplicación facilita la normalización y el acceso a los datos personales a través de diversas funcionalidades del sistema, asegurando que toda la información esté centralizada y sea fácilmente accesible.
# StoreModel

## Descripción
`StoreModel` es una clase que representa una tienda o un establecimiento comercial dentro del dominio de la aplicación. Almacena detalles como el identificador único, NIT, URLs de fotos, correos electrónicos, nombre, alias, dirección y números de teléfono. Esta clase es esencial en aplicaciones que gestionan información sobre tiendas, facilitando operaciones como el marketing, la gestión de inventarios, o el servicio al cliente.
```dart
import 'path_to_jocaagura_domain/store_model.dart';

void main() {
  // Utilizar el modelo de tienda predeterminado
  StoreModel store = defaultStoreModel;
  print('StoreModel predeterminado: ${store.toString()}');

  // Crear una nueva instancia modificando algunos valores
  StoreModel updatedStore = store.copyWith(
      name: 'New Store Name',
      email: 'newstore@example.com',
      phoneNumber1: 987654,
      phoneNumber2: 321098
  );
  print('StoreModel actualizado: ${updatedStore.toString()}');
}
```
Este modelo ayuda a las aplicaciones a manejar de manera eficiente y organizada la información relevante de las tiendas, permitiendo una fácil integración con sistemas de CRM, ERP y otros sistemas de gestión empresarial.
```dart
// Modelo de tienda predeterminado para uso rápido
const StoreModel defaultStoreModel = StoreModel(
  id: 'store_id',
  nit: 12345,
  photoUrl: 'https://example.com/photo.jpg',
  coverPhotoUrl: 'https://example.com/cover.jpg',
  email: 'store@example.com',
  ownerEmail: 'owner@example.com',
  name: 'My Store',
  alias: 'Store',
  address: defaultAddressModel,
  phoneNumber1: 123456,
  phoneNumber2: 789012,
);
```
Implementar `StoreModel` en una aplicación comercial proporciona una base sólida para la gestión de datos de tiendas, mejorando la accesibilidad y la manipulación de la información crítica para las operaciones del negocio.
# Bloc

## Descripción
La clase abstracta `Bloc` implementa el patrón de programación reactiva utilizando Streams en Dart. Es esencial para manejar el estado de la aplicación de manera reactiva, permitiendo que los componentes de la interfaz se actualicen automáticamente en respuesta a cambios en el estado. `Bloc` es utilizado para encapsular la lógica de negocio y garantizar que las actualizaciones de estado sean predecibles y manejables.
```dart
// Ejemplo de implementación de un Bloc personalizado
class MyBloc extends Bloc<String> {
  MyBloc(String initialValue) : super(initialValue);
}

void main() {
  final myBloc = MyBloc('initial value');
  print(myBloc.value); // 'initial value'

  myBloc.stream.listen((value) {
    print(value); // Imprime 'initial value' seguido de 'new value'
  });

  myBloc.value = 'new value';
}
```
`Bloc` facilita la creación de una arquitectura limpia y escalable, donde los componentes de la UI reaccionan a los cambios de estado sin estar directamente acoplados a la lógica de negocio.
```dart
abstract class Bloc<T> {
  Bloc(T initialValue) {
    _value = initialValue;
  }

  late T _value;
  final StreamController<T> _streamController = StreamController<T>.broadcast();

  T get value => _value;
  Stream<T> get stream => _streamController.stream;

  set value(T val) {
    if (!_streamController.isClosed) {
      _streamController.sink.add(val);
    }
    _value = val;
  }

  void dispose() {
    _streamController.close();
  }
}
```
Al usar `Bloc`, se mejora la gestión del estado en aplicaciones Dart y Flutter, proporcionando una forma eficaz y eficiente de actualizar y mantener sincronizadas las interfaces de usuario con el estado subyacente de la aplicación.
# BlocCore

## Descripción
`BlocCore` es una clase central encargada de gestionar `BlocGenerals` y `BlocModules` dentro de una aplicación. Funciona como un contenedor e inyector de dependencias para los BLoCs, facilitando la organización y el acceso a los mismos a través de claves únicas. Esta clase es crucial para manejar múltiples instancias de BLoCs y módulos de BLoC de manera eficiente, permitiendo una arquitectura más limpia y modular en aplicaciones complejas.
```dart
class MyBloc extends Bloc<String> {
  MyBloc(String initialValue) : super(initialValue);
}

class MyModule extends BlocModule {
  // Imaginary BlocModule class definition
}

void main() {
  final blocCore = BlocCore();

  final myBloc = MyBloc('initial value');
  blocCore.addBlocGeneral('myBloc', myBloc);

  final myModule = MyModule();
  blocCore.addBlocModule('myModule', myModule);

  // Obtener instancias
  final myBlocInstance = blocCore.getBloc<MyBloc>('myBloc');
  final myModuleInstance = blocCore.getBlocModule<MyModule>('myModule');

  print(myBlocInstance.value);  // 'initial value'
  // Perform operations with myModuleInstance
}
```
`BlocCore` permite una administración centralizada de los BLoCs, lo que simplifica el control sobre el ciclo de vida de los mismos y ayuda a mantener la consistencia en el estado de la aplicación.
```dart
class BlocCore<T> {
  BlocCore([Map<String, BlocModule> map = const <String, BlocModule>{}]) {
    map.forEach((String key, BlocModule blocModule) {
      addBlocModule(key, blocModule);
    });
  }

  final Map<String, BlocGeneral<T>> _injector = <String, BlocGeneral<T>>{};
  final Map<String, BlocModule> _moduleInjector = <String, BlocModule>{};

  void dispose() {
    _injector.forEach((key, value) {
      value.dispose();
    });
    _moduleInjector.forEach((key, value) {
      value.dispose();
    });
    _injector.clear();
    _moduleInjector.clear();
  }
}
```
Utilizar `BlocCore` mejora la escalabilidad de aplicaciones Flutter al facilitar la segregación de la lógica de negocio en BLoCs, haciendo el código más limpio, fácil de mantener y de probar.

# BlocGeneral

## Descripción
`BlocGeneral` es una extensión de la clase `Bloc` que añade funcionalidad para manejar múltiples funciones que se ejecutan en respuesta a cambios en el valor del BLoC. Está diseñada para facilitar la gestión de eventos reactivos complejos donde múltiples operaciones pueden necesitar ser ejecutadas en respuesta a un cambio de estado. Es ideal para aplicaciones que necesitan realizar varias acciones en diferentes partes de la aplicación en respuesta al mismo cambio de datos.
```dart
class MyBlocGeneral extends BlocGeneral<String> {
  MyBlocGeneral(String initialValue) : super(initialValue);
}

void main() {
  final myBlocGeneral = MyBlocGeneral('Hello');

  myBlocGeneral.addFunctionToProcessTValueOnStream('print', (val) {
    print('Current value: $val');
  }, executeNow: true);

  myBlocGeneral.value = 'World';  // This will trigger the print function
}
```
`BlocGeneral` permite una fácil extensión del patrón BLoC, proporcionando un medio para que múltiples partes de una aplicación reaccionen a cambios en los BLoCs sin tener que acoplarlas directamente al BLoC o entre ellas.
```dart
class BlocGeneral<T> extends Bloc<T> {
  BlocGeneral(super.initialValue) {
    _setStreamSubscription((T event) {
      for (final void Function(T val) element in _functionsMap.values) {
        element(event);
      }
    });
  }

  final Map<String, void Function(T val)> _functionsMap =
  <String, void Function(T val)>{};

  void addFunctionToProcessTValueOnStream(
      String key,
      Function(T val) function, [
        bool executeNow = false,
      ]) {
    _functionsMap[key.toLowerCase()] = function;
    if (executeNow) {
      function(value);
    }
  }

  void deleteFunctionToProcessTValueOnStream(String key) {
    _functionsMap.remove(key);
  }

  void dispose() {
    super.dispose();
    _functionsMap.clear();
  }
}
```
Esta flexibilidad hace que `BlocGeneral` sea especialmente útil en aplicaciones grandes y complejas donde el estado debe ser manejado de manera reactiva y eficiente en múltiples contextos sin causar acoplamiento excesivo.
# BlocModule

## Descripción
`BlocModule` es una clase abstracta diseñada para encapsular un módulo dentro de la arquitectura de una aplicación que utiliza BLoCs. Esta clase sirve como base para crear módulos que agrupen funcionalidades específicas y que potencialmente contengan sus propios BLoCs o recursos que necesiten ser gestionados de manera cohesiva, especialmente en términos de disposición de recursos y limpieza.
```dart
abstract class MyBlocModule extends BlocModule {
  final MyBloc myBloc;

  MyBlocModule(this.myBloc);

  @override
  void dispose() {
    myBloc.dispose();
    // Dispose other resources or BLoCs
  }
}

void main() {
  final myBloc = MyBloc('initial value');
  final myModule = MyBlocModule(myBloc);

  // Use the module in your application

  // When done, ensure proper disposal
  myModule.dispose();
}
```
`BlocModule` ofrece un patrón para estructurar el código de manera que se facilite la gestión y el mantenimiento de los recursos y BLoCs dentro de un módulo, ayudando a prevenir fugas de memoria y otros problemas de manejo de recursos en aplicaciones grandes.
```dart
abstract class BlocModule {
  const BlocModule();
  void dispose();
}
```
Al implementar subclases de `BlocModule`, se garantiza que todos los BLoCs y otros recursos asociados puedan ser creados, utilizados y destruidos de manera ordenada y controlada, lo que es esencial para el mantenimiento a largo plazo y la escalabilidad de las aplicaciones complejas.
# BlocModule

## Descripción
`BlocModule` es una clase abstracta diseñada para encapsular un módulo dentro de la arquitectura de una aplicación que utiliza BLoCs. Esta clase sirve como base para crear módulos que agrupen funcionalidades específicas y que potencialmente contengan sus propios BLoCs o recursos que necesiten ser gestionados de manera cohesiva, especialmente en términos de disposición de recursos y limpieza.
```dart
abstract class MyBlocModule extends BlocModule {
  final MyBloc myBloc;

  MyBlocModule(this.myBloc);

  @override
  void dispose() {
    myBloc.dispose();
    // Dispose other resources or BLoCs
  }
}

void main() {
  final myBloc = MyBloc('initial value');
  final myModule = MyBlocModule(myBloc);

  // Use the module in your application

  // When done, ensure proper disposal
  myModule.dispose();
}
```
`BlocModule` ofrece un patrón para estructurar el código de manera que se facilite la gestión y el mantenimiento de los recursos y BLoCs dentro de un módulo, ayudando a prevenir fugas de memoria y otros problemas de manejo de recursos en aplicaciones grandes.
```dart
abstract class BlocModule {
  const BlocModule();
  void dispose();
}
```
Al implementar subclases de `BlocModule`, se garantiza que todos los BLoCs y otros recursos asociados puedan ser creados, utilizados y destruidos de manera ordenada y controlada, lo que es esencial para el mantenimiento a largo plazo y la escalabilidad de las aplicaciones complejas.

# Either, Left, and Right

## Descripción
`Either` es una clase abstracta que representa un tipo de dato que puede contener un valor de dos posibles tipos: `Left` o `Right`. Esta estructura es útil para manejar operaciones que pueden resultar en dos tipos de resultados, típicamente usada en programación funcional para representar un éxito o un fallo sin usar excepciones. `Left` generalmente se utiliza para representar un fallo o un valor no deseado, mientras que `Right` representa un éxito o un valor deseado.
```dart
void main() {
  Either<int, String> eitherValue = Right<int, String>('hello');
  String result = eitherValue.when(
        (leftValue) => 'Error code: $leftValue',  // not executed
        (rightValue) => 'Greeting: ${rightValue.toUpperCase()}',  // executed
  );

  print(result);  // Outputs: Greeting: HELLO
}
```
El uso de `Either` permite una gestión clara de los flujos de control en aplicaciones donde los errores deben ser tratados como parte del flujo normal sin recurrir a excepciones, lo que ayuda a mantener un código más limpio y predecible.
```dart
abstract class Either<L, R> {
  T when<T>(
      T Function(L) left,
      T Function(R) right,
      ) {
    if (this is Left<L, R>) {
      return left((this as Left<L, R>).value);
    }
    return right((this as Right<L, R>).value);
  }
}

class Left<L, R> extends Either<L, R> {
  final L value;
  Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  Right(this.value);
}
```
Estas clases son particularmente útiles en aplicaciones que requieren un manejo robusto de errores y estados sin comprometer la legibilidad y la funcionalidad del código. Utilizar `Either`, `Left`, y `Right` proporciona un enfoque formal y consistente para gestionar diferentes resultados de una operación, facilitando la implementación de lógica condicional compleja de manera más estructurada y mantenible.
# EntityBloc and RepeatLastValueExtension

## Descripción
`EntityBloc` es una clase abstracta diseñada para ser la base de todos los BLoCs que manejan entidades dentro de una aplicación. Su único método, `dispose`, se utiliza para limpiar recursos cuando el BLoC ya no es necesario, ayudando a prevenir fugas de memoria.

La extensión `RepeatLastValueExtension` sobre la clase `Stream` proporciona una funcionalidad adicional para que cualquier stream pueda repetir el último valor emitido a cualquier nuevo suscriptor. Esto es particularmente útil en situaciones donde los suscriptores necesitan recibir inmediatamente el estado actual cuando se suscriben a un stream.
```dart
class MyEntityBloc extends EntityBloc {
  // Implementation details
  @override
  void dispose() {
    // Cleanup logic here
  }
}

void main() {
  final myStream = Stream.fromIterable([1, 2, 3]);
  final repeatingStream = myStream.repeatLastValue(0);

  repeatingStream.listen(
          (value) => print(value),  // Prints 0, 1, 2, 3
      onDone: () => print('Done')
  );
}
```
La extensión `RepeatLastValueExtension` es una herramienta poderosa para los desarrolladores que trabajan con flujos de datos reactivos, garantizando que los nuevos suscriptores puedan recibir el estado más reciente sin tener que esperar a que se emita el próximo valor.
```dart
extension RepeatLastValueExtension<T> on Stream<T> {
  Stream<T> repeatLastValue(T lastValue) {
    // Implementation as provided above
  }
}
```
Utilizando `EntityBloc` y `RepeatLastValueExtension`, los desarrolladores pueden crear aplicaciones más robustas y responsivas, manejando los estados y sus cambios de manera más eficiente y efectiva.

# EntityProvider, EntityService, and EntityUtil

## Descripción
`EntityProvider`, `EntityService`, y `EntityUtil` son clases abstractas diseñadas para ser la base de componentes específicos en una arquitectura de aplicación orientada a servicios o proveedores de datos. Estas clases facilitan la estructuración de la lógica y el acceso a los datos, promoviendo una separación clara del código y una mejor organización.

### EntityProvider
`EntityProvider` es la base para clases que suministran entidades a otras partes de la aplicación. Esta clase puede ser extendida para implementar patrones como Repository o Factory, proporcionando una forma consistente de acceder a datos de entidades.

### EntityService
`EntityService` actúa como una base para servicios que operan sobre entidades. Esta clase es típicamente extendida para incluir lógica de negocio que manipula o transforma datos antes de que sean consumidos por la aplicación o antes de que se realicen cambios en la base de datos.

### EntityUtil
`EntityUtil` ofrece una base para clases que proporcionan métodos de utilidad relacionados con entidades. Estos pueden incluir conversiones, validaciones y otras operaciones que son comunes a varias partes de la aplicación.

Estas clases son fundamentales en el diseño y la implementación de un sistema robusto, permitiendo un mantenimiento y una expansión eficientes del código base.

# ConnectivityModel

## Descripción
`ConnectivityModel` representa el estado de la conexión a internet de un dispositivo. Mantiene información sobre el tipo de conexión y la velocidad de internet actual. Extiende de `Model`, lo que le permite ser serializable y comparable fácilmente.

## Parámetros
- `connectionType`: Especifica el tipo de conexión de red, representado por el `enum ConnectionTypeEnum`. Puede ser `none`, `wifi`, `wired`, `sim`, entre otros, para representar la ausencia de conexión o los diferentes tipos de conexiones disponibles.
- `internetSpeed`: Un `double` que indica la velocidad actual de la conexión a internet en Mbps.

## Métodos
- `copyWith`: Permite crear una copia del modelo con algunos valores cambiados.
- `toJson`: Convierte el modelo en un mapa para su serialización JSON.
- `hashCode` y `==`: Permiten comparar instancias de `ConnectivityModel` para determinar si son iguales.
- `getConnectionTypeEnumFromString`: Un método estático que convierte una cadena en un valor correspondiente de `ConnectionTypeEnum`.
- `isConnected`: Un getter que devuelve `true` si la conexión actual no es `none`.
- `toString`: Proporciona una representación en cadena del modelo.

## Ejemplo de Uso en Dart
El siguiente ejemplo ilustra cómo puedes crear una nueva instancia de `ConnectivityModel` y trabajar con sus métodos.
```dart
void main() {
  final connectivity = ConnectivityModel(
    connectionType: ConnectionTypeEnum.wifi,
    internetSpeed: 100.0,
  );

  // Crear una copia con velocidad de internet actualizada
  final updatedConnectivity = connectivity.copyWith(internetSpeed: 50.0);

  // Convertir el modelo a JSON
  final json = updatedConnectivity.toJson();

  // Imprimir el modelo
  print(updatedConnectivity);
}
```
Utiliza `ConnectivityModel` para gestionar y representar el estado de la conexión de red en tus aplicaciones, aprovechando su estructura inmutable y sus métodos de ayuda.


# UI

# ModelMainMenuModel

## Descripción
`ModelMainMenuModel` es una clase diseñada para representar un elemento de menú en la interfaz de usuario de una aplicación. Esta clase extiende `Model` y añade características específicas para manejar elementos de menú, incluyendo iconos, etiquetas, descripciones y acciones asociadas con cada elemento. Es ideal para construir menús dinámicos donde cada elemento puede tener una acción diferente.

### Características
- **IconData**: Representa el icono del menú.
- **OnPressed**: Una función que se ejecuta cuando el elemento del menú es presionado.
- **Label**: La etiqueta de texto del menú.
- **Description**: Una descripción opcional del elemento del menú.
```dart
import 'package:flutter/material.dart';
import 'path_to_jocaagura_domain/model_main_menu_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Main Menu'),
        ),
        body: ListView(
          children: [
            MainMenuTile(
              model: ModelMainMenuModel(
                  iconData: Icons.home,
                  onPressed: () {
                    print('Home pressed');
                  },
                  label: 'Home',
                  description: 'Return to the home screen'
              ),
            ),
            MainMenuTile(
              model: ModelMainMenuModel(
                  iconData: Icons.settings,
                  onPressed: () {
                    print('Settings pressed');
                  },
                  label: 'Settings',
                  description: 'Adjust your settings'
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainMenuTile extends StatelessWidget {
  final ModelMainMenuModel model;

  const MainMenuTile({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(model.iconData),
      title: Text(model.label),
      subtitle: Text(model.description),
      onTap: model.onPressed,
    );
  }
}
```
`ModelMainMenuModel` facilita la creación de menús interactivos en aplicaciones Flutter, permitiendo a los desarrolladores configurar fácilmente los elementos del menú con acciones específicas, mejorando la interactividad y la experiencia del usuario.

# Debouncer

## Descripción
`Debouncer` es una clase utilitaria diseñada para limitar la tasa a la que se ejecuta una función. Esto es útil en situaciones donde ciertas operaciones no deben dispararse repetidamente en respuesta a eventos frecuentes, como la entrada de texto en una búsqueda o el redimensionamiento de una ventana. La clase permite especificar un intervalo en milisegundos durante el cual, después de llamarse, cualquier invocación posterior a la función se postergará hasta que pase el intervalo.
```dart
class Debouncer {
  Debouncer({this.milliseconds = 500});

  final int milliseconds;
  Timer? _timer;

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
```
## Ejemplo de Uso en Dart
El siguiente ejemplo muestra cómo utilizar `Debouncer` para optimizar las operaciones en un campo de texto, reduciendo el número de operaciones ejecutadas mientras el usuario está escribiendo.
```dart
class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final Debouncer debouncer = Debouncer(milliseconds: 300);

  void _onSearchChanged(String query) {
    debouncer(() {
      print('Searching for: $query');
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        labelText: 'Search',
      ),
    );
  }
}
```
Este uso de `Debouncer` asegura que las operaciones como la búsqueda se optimicen para mejorar la performance y la experiencia del usuario, evitando una sobrecarga innecesaria en el procesamiento y las solicitudes de red.


# Documentación de Modelos

Los diagramas UML de este proyecto utilizan colores para indicar el estado de implementación de cada modelo:
- **Verde:** El modelo ha sido completamente implementado y está incluido en el paquete actual.
- **Blanco/Gris:** El modelo está pendiente de implementación o en proceso de desarrollo.
- **Naranja:** El modelo está revisión y/o proceso de transformación.

  Una legenda correspondiente se encuentra incluida en cada diagrama para facilitar la interpretación de estos colores.

## 🧰 Servicios disponibles

Seccion en la que se listan los servicios disponibles en el dominio de la aplicación. Cada servicio tiene su implementación abstracta y una versión fake para pruebas unitarias. Los nombres de los archivos siguen un patrón consistente para facilitar su identificación y uso.
Esta seccion esta en evolución y se ira actualizando conforme se vayan implementando nuevos servicios o se modifiquen los existentes.

| Servicio                  | Abstracto (`lib/domain/services/`) | Fake (`lib/src/fakes/`)           |
|---------------------------|------------------------------------|-----------------------------------|
| 🗄️ Base de datos NoSQL   | `service_ws_database.dart`         | `fake_service_ws_database.dart`   |
| 🔐 Sesión / Autenticación | `service_session.dart`             | `fake_service_session.dart`       |
| 📍 Geolocalización        | `service_location.dart`            | `fake_service_location.dart`      |
| 🌀 Giroscopio             | `service_gyroscope.dart`           | `fake_service_gyroscope.dart`     |
| 🔔 Notificaciones         | `service_notifications.dart`       | `fake_service_notifications.dart` |
| 🧠 Preferencias locales   | `service_preferences.dart`         | `fake_service_preferences.dart`   |
| 📡 Conectividad           | `service_connectivity.dart`        | `fake_service_connectivity.dart`  |
| 🌐 HTTP genérico          | `service_http.dart`                | `fake_service_http.dart`          |

# Cómo integrar BlocSession (con FakeServiceSession para desarrollo)

Este fragmento muestra el cableado completo **UI → AppManager → Bloc → UseCase → Repository → Gateway → Service**, usando `BlocSession` y un `FakeServiceSession` para ambientes de **desarrollo/test**. Ajusta nombres si tu proyecto usa implementaciones distintas.

## 1) Infraestructura (Service → Gateway → Repository)

```dart
import 'package:jocaagura_domain/jocaagura_domain.dart';

final ServiceSession service = FakeServiceSession(
  latency: const Duration(milliseconds: 250), // simula red
  // Opcional: arrancar ya autenticado
  // initialUserJson: {
  //   'id': 'seed',
  //   'displayName': 'Seed',
  //   'photoUrl': 'https://fake.com/photo.png',
  //   'email': 'seed@x.com',
  //   'jwt': {
  //     'accessToken': 'seed-token',
  //     'issuedAt': DateTime.now().toIso8601String(),
  //     'expiresAt': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
  //   },
  // },
  // Opcional: forzar fallos de login/signin/google
  // throwOnSignIn: true,
);

// Implementación base sugerida (usa tu mapper y clases reales)
final ErrorMapper errorMapper = DefaultErrorMapper();
final GatewayAuth gateway = GatewayAuthBasic(
  service: service,
  errorMapper: errorMapper,
);
final RepositoryAuth repository = RepositoryAuthImpl(
  gateway: gateway,
  errorMapper: errorMapper,
);
```

## 2) Use cases + watcher de auth

```dart
final SessionUsecases usecases = SessionUsecases(
  logInUserAndPassword: LogInUserAndPasswordUsecase(repository),
  logOutUsecase: LogOutUsecase(repository),
  signInUserAndPassword: SignInUserAndPasswordUsecase(repository),
  recoverPassword: RecoverPasswordUsecase(repository),
  logInSilently: LogInSilentlyUsecase(repository),
  loginWithGoogle: LoginWithGoogleUsecase(repository),
  refreshSession: RefreshSessionUsecase(repository),
  getCurrentUser: GetCurrentUserUsecase(repository),
  watchAuthStateChangesUsecase: WatchAuthStateChangesUsecase(repository),
);
final WatchAuthStateChangesUsecase watchUC =
    WatchAuthStateChangesUsecase(repository);
```

## 3) Crear el BlocSession

```dart
final BlocSession sessionBloc = BlocSession(
  usecases: usecases,
  watchAuthStateChanges: watchUC,
  // Debouncers para prevenir doble tap (UI rápida)
  authDebouncer: Debouncer(milliseconds: 250),
  refreshDebouncer: Debouncer(milliseconds: 250),
);

// No fuerza silent-login: solo se suscribe a cambios del repo
await sessionBloc.boot()
```

## 4) Usarlo en la UI

```
// Leer estado reactivo
StreamBuilder<SessionState>(
  stream: sessionBloc.sessionStream,
  initialData: const Unauthenticated(),
  builder: (_, snap) {
    final s = snap.data ?? const Unauthenticated();
    if (s is Authenticating) return const Text('Authenticating...');
    if (s is Refreshing) return const Text('Refreshing...');
    if (s is SessionError) return Text('Error: ${s.message.code}');
    if (s is Authenticated) return Text('Hi ${s.user.email}');
    return const Text('Signed out');
  },
);

// Acciones
final result = await sessionBloc.logIn(email: 'me@mail.com', password: 'secret');
result.fold(
  (err) => debugPrint('Login failed: ${err.code}'),
  (user) => debugPrint('Welcome ${user.email}'),
);

// Helpers
final bool isAuthed = sessionBloc.isAuthenticated;
final UserModel me = sessionBloc.currentUser; // defaultUserModel si no hay sesión
```

## 5) Recomendaciones y matices

* **Estado inicial:** `Unauthenticated`. `boot()` solo **escucha** `authStateChanges` del repo; no realiza `silent-login` automáticamente.
* **Errores:** `Left(ErrorItem)` → `SessionError(err)`. La UI decide si reintentar, mostrar modal, etc.
* **Silent/Refresh:** si no hay sesión previa, devuelven `null` y el BLoC permanece/queda en `Unauthenticated`.
* **Debouncer:** evita doble tap en botones. Si necesitas *concurrencia estricta*, puedes reemplazar por flags “in-flight”.
* **Secuencias rápidas:** para verificar `Refreshing → Authenticated` en tests, suscríbete **antes** de llamar a `refreshSession()` (los estados pueden emitirse muy seguido).
* **Dispose:** llama `sessionBloc.dispose()` en `dispose()` de tu widget/app.

## 6) FakeServiceSession (para desarrollo/test)

El `FakeServiceSession` es un **service** de bajo nivel que:

* Trabaja con `Map<String, dynamic>` (sin modelos del dominio).
* Emite `authStateChanges()` con el payload de usuario o `null`.
* Simula latencia (`latency`) y puede **arrancar logueado** (`initialUserJson`).
* Puede forzar error en flujos de login (`throwOnSignIn: true`).
* **Lanza** excepciones crudas (`ArgumentError`, `StateError`): el **Gateway** debe capturarlas y mapear a `ErrorItem`.

### Ejemplos rápidos

```dart
// Arrancar logueado
final svc = FakeServiceSession(
  latency: const Duration(milliseconds: 150),
  initialUserJson: {
    'id': 'seed',
    'displayName': 'Seed',
    'photoUrl': 'https://fake.com/photo.png',
    'email': 'seed@x.com',
    'jwt': {
      'accessToken': 'seed-token',
      'issuedAt': DateTime.now().toIso8601String(),
      'expiresAt': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
    },
  },
);

// Forzar fallo de login
final svcFail = FakeServiceSession(throwOnSignIn: true);
```

> ⚠️ El fake es **solo** para desarrollo/pruebas. En producción, usa un `ServiceSession` real (SDK/REST), con su `GatewayAuth` mapeando errores a `ErrorItem` (apóyate en `SessionErrorItems`/`HttpErrorItems` para códigos estándar).

---
## Cómo integrar `BlocWsDatabase` (con `FakeServiceWsDatabase` para desarrollo)

Esta guía muestra el **cableado completo UI → BLoC → Facade → Repository → Gateway → Service** usando el **fake** de base de datos por WebSocket incluido en el paquete. Con esto puedes hacer **CRUD** y **watch (realtime)** sobre un documento sin depender aún de tu backend real.

> Flujo de capas  
> `UI` → `BlocWsDatabase<T>` → `FacadeWsDatabaseUsecases<T>` → `RepositoryWsDatabase<T>` → `GatewayWsDatabase` → `ServiceWsDatabase<Map<String,dynamic>>` *(Fake)*

---

### 1) Infraestructura (Service → Gateway → Repository → Facade → BLoC)

```dart
import 'package:jocaagura_domain/jocaagura_domain.dart';

// 1) Transporte (fake en memoria con streams por doc/colección)
final FakeServiceWsDatabase service = FakeServiceWsDatabase(
  // Opcional: simula latencia de red
  // latency: const Duration(milliseconds: 150),
);

// 2) Gateway (mapea errores, inyecta id, multiplexa watch por docId)
final GatewayWsDatabaseImpl gateway = GatewayWsDatabaseImpl(
  service: service,
  collection: 'users', // <- tu tabla/colección
);

// 3) Repository (JSON <-> Model + serialización de writes opcional)
final RepositoryWsDatabaseImpl<UserModel> repository =
    RepositoryWsDatabaseImpl<UserModel>(
  gateway: gateway,
  fromJson: UserModel.fromJson,
  serializeWrites: true, // evita solapes de escrituras por docId
);

// 4) Facade (agrupa todos los casos de uso: read/write/delete/watch/etc.)
final FacadeWsDatabaseUsecases<UserModel> facade =
    FacadeWsDatabaseUsecases<UserModel>.fromRepository(
  repository: repository,
  fromJson: UserModel.fromJson,
);

// 5) BLoC (publica WsDbState<T>: loading/error/doc/docId/isWatching)
final BlocWsDatabase<UserModel> bloc = BlocWsDatabase<UserModel>(facade: facade);
````

---

### 2) UI mínima (leer, escribir y observar un documento)

```dart
class UserDocPage extends StatefulWidget {
  const UserDocPage({super.key});
  @override
  State<UserDocPage> createState() => _UserDocPageState();
}

class _UserDocPageState extends State<UserDocPage> {
  final TextEditingController _id = TextEditingController(text: 'user_001');

  @override
  void dispose() {
    bloc.dispose(); // cierra stream de estado del BLoC
    _id.dispose();
    super.dispose();
  }

  UserModel _buildUser(String id) => UserModel(
        id: id,
        displayName: 'John Doe',
        photoUrl: 'https://example.com/profile.jpg',
        email: 'john.doe@example.com',
        jwt: const <String, dynamic>{},
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WsDatabase — Demo')),
      body: StreamBuilder<WsDbState<UserModel>>(
        stream: bloc.stream,
        initialData: bloc.value,
        builder: (_, snap) {
          final s = snap.data ?? WsDbState<UserModel>.idle();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _id,
                decoration: const InputDecoration(labelText: 'docId'),
              ),
              const SizedBox(height: 12),
              if (s.loading) const LinearProgressIndicator(),
              if (s.error != null) Text('Error: ${s.error!.code}'),
              if (s.doc != null) ...[
                Text('id: ${s.doc!.id}'),
                Text('name: ${s.doc!.displayName}'),
                Text('email: ${s.doc!.email}'),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () => bloc.readDoc(_id.text.trim()),
                    child: const Text('Read'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final id = _id.text.trim();
                      bloc.writeDoc(id, _buildUser(id));
                    },
                    child: const Text('Write / Upsert'),
                  ),
                  ElevatedButton(
                    onPressed: () => bloc.startWatch(_id.text.trim()),
                    child: const Text('Watch'),
                  ),
                  ElevatedButton(
                    onPressed: () => bloc.stopWatch(_id.text.trim()),
                    child: const Text('Stop watch'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
```

---

### 3) (Opcional) Smoke test de realtime sin backend

Para “ver” el `watch` en vivo, puedes simular que el servidor actualiza el documento cada segundo con el **ticker** (usa el *Service* directamente, como si fuese el backend):

```
// Simula cambios del servidor incrementando un contador en jwt.countRef
final WsDocTicker ticker = WsDocTicker(
  service: service,
  collection: 'users',
  docId: 'user_001',
  seedMode: SeedMode.minimalCountOnly, // crea si falta
);

// Arranca (y detén) el motor cuando quieras
await ticker.start();       // incrementa cada segundo
// await ticker.stop();
```

---

### 4) Buenas prácticas y matices

* **Colecciones:** el `GatewayWsDatabaseImpl` está **anclado a una colección** (`collection: 'users'`). Si necesitas otra tabla, crea **otro gateway** (y normalmente su repo/facade/bloc).
* **Watch eficiente:** el gateway **multiplexa** por `docId` (un solo canal compartido). Tras cancelar un watch, el BLoC llama a `detach()` para liberar recursos.
* **Errores coherentes:** todo devuelve `Either<ErrorItem, …>`. En UI, si llega `Left`, muestra `error.code/title/description`.
* **Serialización de escrituras:** `serializeWrites: true` evita condiciones de carrera si la UI dispara varios writes rápidos al mismo doc.
* **Dispose:** llama `bloc.dispose()` al cerrar la pantalla. Si **eres dueño** de toda la pila, puedes además invocar `facade.disposeAll()` en un punto global (p. ej., logout).
* **Migración a backend real:** reemplaza `FakeServiceWsDatabase` por tu `ServiceWsDatabase` real (WS/SDK), manteniendo Gateway/Repository/Facade/BLoC **idénticos**.
* **REST sin realtime:** si tu backend es sincrónico, usa la `FacadeCrudDatabaseUsecases<T>` (sin `watch`) con tu propio repositorio/servicio.

> Con este patrón mantienes UI limpia, capas testeables y un camino directo de “**fake en desarrollo** → **backend real en producción**” sin reescribir la app.

----
# Unit
## `Unit`: éxito sin carga útil (type-safe)

`Unit` representa *la ausencia de un valor significativo* de forma **segura para tipos**.  
Úsalo cuando una operación **sucede** pero **no tiene nada que devolver**. Es equivalente al “`void` con valor”, ideal para *genéricos* (`Either`, `Future`, `Stream`, `UseCase`, etc.).

### ¿Por qué no `void`, `Null` o `bool`?
- **`void`** no puede ser usado como valor (no cabe en `Either`, `Future.value`, colecciones, etc.).
- **`Null`** introduce ambigüedad con null-safety y no expresa éxito.
- **`bool`** confunde éxito/fracaso con *estado lógico*; los errores deberían viajar en un `Left(ErrorItem)` y no como `false`.

`Unit` evita esos problemas y mantiene la semántica clara:  
**Right(unit) = éxito sin datos**.

---

### API
```dart
@immutable
class Unit {
  const Unit._();
  static const Unit value = Unit._();
  @override String toString() => 'unit';
  @override bool operator ==(Object other) => other is Unit;
  @override int get hashCode => 0;
}
const Unit unit = Unit.value;
````

---

### Casos de uso comunes

1. **Comandos** (crear/actualizar/eliminar) que no retornan entidad

```dart
Future<Either<ErrorItem, Unit>> deleteUser(String id) async {
  try {
    await api.delete('/users/$id');
    return Right(unit); // éxito sin payload
  } catch (e, s) {
    return Left(mapper.fromException(e, s));
  }
}
```

2. **Use cases** sin retorno

```dart
class DetachWatchUseCase<T> implements UseCase<Either<ErrorItem, Unit>, DeleteParams> {
  DetachWatchUseCase(this.repo);
  final RepositoryWsDatabase<T> repo;

  @override
  Future<Either<ErrorItem, Unit>> call(DeleteParams p) async {
    repo.detachWatch(p.docId);
    return Right(unit);
  }
}
```

3. **Batch/operaciones por id** (map de resultados)

```dart
Future<Either<ErrorItem, Map<String, Either<ErrorItem, Unit>>>> deleteMany(List<String> ids) async {
  final Map<String, Either<ErrorItem, Unit>> out = {};
  for (final id in ids) {
    out[id] = await deleteUser(id);
  }
  return Right(out);
}
```

4. **Streams/eventos** donde solo importa la *señal*

```
final StreamController<Unit> tick = StreamController<Unit>.broadcast();
// emitir una señal
tick.add(unit);
// escuchar señales
tick.stream.listen((_) => print('tick!'));
```

5. **Adaptar APIs** para composición

```
// convertir Future<void> -> Future<Either<ErrorItem, Unit>>
Future<Either<ErrorItem, Unit>> wrap(Future<void> f) async {
  try { await f; return Right(unit); }
  catch (e, s) { return Left(mapper.fromException(e, s)); }
}
```

---

### Patrones con `Either`

```
final Either<ErrorItem, Unit> res = await deleteUser('u1');

res.fold(
  (err) => logger.error(err.code),
  (_)   => logger.info('Deleted!'),
);

// map / flatMap siguen funcionando (el valor es estable)
final Either<ErrorItem, Unit> chained = res.map((_) => unit);
```

---

### En BLoC

```dart
Future<void> onStopWatch(String id) async {
  value = value.copyWith(loading: true);
  final result = await facade.detach(id); // Either<ErrorItem, Unit>
  result.fold(
    (err) => value = value.copyWith(error: err),
    (_)    => value = value.copyWith(isWatching: false, error: null),
  );
  value = value.copyWith(loading: false);
}
```

---

### Testing con `Unit`

```
test('delete returns Right(unit)', () async {
  final r = await deleteUser('u1');
  expect(r, isA<Right<ErrorItem, Unit>>());
  // o más explícito:
  r.fold(
    (_) => fail('expected Right'),
    (u) => expect(u, unit),
  );
});
```

---

### Recomendaciones

* Devuelve `Either<ErrorItem, Unit>` en **comandos**; usa `Either<ErrorItem, T>` en **queries**.
* Evita mezclar `Unit` con significados como “sin cambios” o “cancelado”; si necesitas distinguirlos, crea **tipos específicos** (`CommandResult` con variantes, por ejemplo).
* Prefiere el alias `unit` para escribir menos y mantener consistencia.


## 🛠️ Publicación y Versionamiento

### Commit firmado
Usamos GPG para firmar todos los commits y garantizar trazabilidad.

1. Generar la clave (solo la primera vez):
   ```bash
   gpg --full-generate-key
    ```

2. Asociar la clave a Git (una sola vez):
   ```bash
   git config --global user.signingkey <KEY_ID>
   ```
3. Crear commits firmados (se te pedirá tu passphrase):
   ```bash
   git commit -S -m "feat(@username): add new password checker (#123)"
   ```
4. Verificar la firma:
   ```bash
   git log --show-signature
   ```

### Etiquetado de PRs
Para automatizar el bump de versión, aplicamos labels en GitHub: `major`, `minor` o `patch`.
* **Título de PR**: debe arrancar con un prefijo semántico, autor y referencia al issue:

  ```
  feat(@username): add new password checker (#123)
  ```
* **Labels**:
  * `major` → bump de versión **mayor**
  * `minor` → bump de versión **menor**
  * `patch` → bump de **parche**

### Actualización automática de `pubspec.yaml`
La Action `validate_pr.yaml` detecta el label y actualiza la versión en `pubspec.yaml`:
# .github/workflows/validate_pr.yaml (fragmento relevante)
```yaml
- name: Bump version
  run: |
    CURRENT_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
    LABELS=$(gh pr view ${{ github.event.pull_request.number }} --json labels --jq '.labels[].name')
    if echo "$LABELS" | grep -q "major"; then
      UPDATED_VERSION=$(echo $CURRENT_VERSION | awk -F. '{$1+=1; $2=0; $3=0}1' OFS=".")
    elif echo "$LABELS" | grep -q "minor"; then
      UPDATED_VERSION=$(echo $CURRENT_VERSION | awk -F. '{$2+=1; $3=0}1' OFS=".")
    elif echo "$LABELS" | grep -q "patch"; then
      UPDATED_VERSION=$(echo $CURRENT_VERSION | awk -F. '{$3+=1}1' OFS=".")
    else
      echo "❌ No version label found. Please add 'major', 'minor', or 'patch'."
      exit 1
    fi
    sed -i "s/^version:.*/version: $UPDATED_VERSION/" pubspec.yaml
    echo "Updated version: $UPDATED_VERSION"
```

**Ejemplo de diff tras un bump **\`\`** (1.20.0 → 1.21.0):**

```diff
-version: 1.20.0
+version: 1.21.0
```

### Generación automática de `CHANGELOG.md`
Seguimos [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

```markdown
### [1.21.0] - 2025-07-09
- Se crea la clase `FakeServiceHttp` para simular el comportamiento de un servicio HTTP en pruebas unitarias.
- Se actualiza el README para incluir ejemplos de uso de las clases `FakeServiceHttp`, `FakeServiceSesion`, `FakeServiceWsDatabase`, `FakeServiceGeolocation`, `FakeServiceGyroscope`, `FakeServiceNotifications`, `FakeServiceConnectivity` y `FakeServicePreferences`.
```

### Flujo `develop` → `master`

1. Abrir un \*\*issue de actualización de \*\*\`\`, indicando el bump deseado (`major`/`minor`/`patch`).
2. Crear un PR de `maintain-branch` a `develop` con la version propuesta
3. Crear un PR **directo** de `develop` a `master`, mencionando el issue para cierre automático.
4. El PR **no** ejecuta bump: utiliza la versión que ya venía en `develop`.
5. Tras pasar las validaciones automáticas, se fusiona mediante **auto-merge**.
6. (Opcional) Publicar en pub.dev si no se dispara automáticamente.

**NOTA:** El proximo issue debe incluir una actualizacion de `master` obligatoria para que quede en `develope` alineado.

### Creación de tag & publicación

El desarrollador, tras el merge, crea el tag semántico y lo envía al repo:

```bash
git tag -a v1.21.0 -m "Release v1.21.0"
git push origin v1.21.0
```

La publicación en **pub.dev** se dispara automáticamente o puede iniciarse manualmente.

### Badges

Añade en el encabezado del README:

```markdown
![CI](https://img.shields.io/github/actions/workflow/status/grupo-jocaagura/jocaagura_domain/validate_pr.yaml?branch=develop)
![Coverage](https://img.shields.io/codecov/c/github/grupo-jocaagura/jocaagura_domain)
![Pub](https://img.shields.io/pub/v/jocaagura_domain)
```

# PerKeyFifoExecutor
## `PerKeyFifoExecutor`: serializa tareas asíncronas **por clave** (FIFO)

Ejecutor liviano para garantizar **orden y exclusión** por *clave lógica* (p. ej. `docId`, `userId`, `cartId`).  
Las acciones con **la misma clave** se ejecutan **una detrás de otra** (FIFO). Acciones con **claves distintas** pueden correr **en paralelo**.

> Útil cuando debes **evitar carreras** de `write/update/delete` sobre el mismo recurso sin bloquear toda la app.

---

### TL;DR

- **FIFO por clave**: `A(k1) → B(k1) → C(k1)` se ejecutan en ese orden; `A(k1)` y `X(k2)` pueden solaparse.
- **No reentrante por clave**: no llames `withLock(k)` *desde dentro* de otra acción `withLock(k)` (crea espera circular).
- **Errores no rompen la cola**: se propagan al caller y la cola sigue con el siguiente item.
- **Dispose no cancela**: limpia colas futuras; lo que esté en vuelo termina normalmente.

---

### API (resumen)

```dart
class PerKeyFifoExecutor<K extends Object> {
  Future<R> withLock<R>(K key, Future<R> Function() action);
  void dispose();
}
````

---

### Ejemplo básico

```dart
final PerKeyFifoExecutor<String> exec = PerKeyFifoExecutor<String>();

Future<void> saveUser(String userId, Future<void> Function() ioSave) {
  return exec.withLock<void>(userId, () async {
    await ioSave(); // ¡serializado por userId!
  });
}
```

---

### Devuelve valores y propaga errores

```dart
final res = await exec.withLock<int>('u1', () async {
  // ... I/O ...
  return 42;
});
// res == 42

try {
  await exec.withLock('u1', () async => throw StateError('boom'));
} catch (e) {
  // recibes el error tal cual; la cola 'u1' sigue funcionando
}
```

---

### Paralelismo entre claves

```dart
Future.wait([
  exec.withLock('doc:1', () => writeDoc('1')), // A
  exec.withLock('doc:1', () => writeDoc('1')), // B (espera A)
  exec.withLock('doc:2', () => writeDoc('2')), // C (corre en paralelo con A)
]);
```

---

### Caso de uso: **Repository** con escrituras serializadas por `docId`

Si tu repo ya expone un flag como `serializeWrites`, reemplaza la lógica manual de colas por `PerKeyFifoExecutor`:

```dart
class RepositoryWsDatabaseImpl<T extends Model> implements RepositoryWsDatabase<T> {
  RepositoryWsDatabaseImpl({
    required this.gateway,
    required this.fromJson,
    bool serializeWrites = false,
  }) : _exec = serializeWrites ? PerKeyFifoExecutor<String>() : null;

  final GatewayWsDatabase gateway;
  final T Function(Map<String, dynamic>) fromJson;
  final PerKeyFifoExecutor<String>? _exec;

  @override
  Future<Either<ErrorItem, T>> write(String docId, T entity) {
    Future<Either<ErrorItem, T>> task() async {
      final res = await gateway.write(docId, entity.toJson());
      return res.fold(Left.new, (json) => Right(fromJson(json)));
    }
    return _exec == null ? task() : _exec!.withLock(docId, task);
  }

  @override
  Future<Either<ErrorItem, Unit>> delete(String docId) {
    Future<Either<ErrorItem, Unit>> task() => gateway.delete(docId);
    return _exec == null ? task() : _exec!.withLock(docId, task);
  }

  void dispose() => _exec?.dispose();
}
```

**Ventajas**:

* Código más legible.
* Aísla la política de concurrencia (puedes cambiarla o desactivarla).
* Menos riesgo de fugas al manejar `Completer`s/`Future` en mapas.

---

### Patrón de *mutación segura* (read–modify–write)

```dart
Future<Either<ErrorItem, T>> mutate(String docId, Future<T> Function(T) f) {
  return exec.withLock(docId, () async {
    final cur = await repo.read(docId);            // 1) read
    final next = await f(cur.getOrElse(defaultT)); // 2) pure transform
    return repo.write(docId, next);                // 3) write
  });
}
```

Evitas que dos mutaciones competitivas sobre el mismo `docId` se pisen entre sí.

---

### Anti-patrones y buenas prácticas

* ❌ **Reentrancia por misma clave**:

  ```dart
  await exec.withLock('k', () async {
    // NO llames exec.withLock('k') aquí dentro
  });
  ```

  ✅ En su lugar: compón los pasos dentro **de la misma acción** o dispara otra acción **fuera**.

* ❌ **Usar `bool` para “estado de en vuelo”** como “lock manual” por clave → frágil ante errores.
  ✅ Usa `PerKeyFifoExecutor`: libera el lock en `finally` siempre.

* ✅ **Claves estables**: garantiza `==`/`hashCode` correctos (p. ej. usa `String`/`int` o value-objects bien definidos).

* ✅ **Time-outs** (si un backend puede bloquear): aplica un wrapper:

  ```dart
  await exec.withLock('k', () => action().timeout(const Duration(seconds: 8)));
  ```

* ✅ **Observabilidad**: si necesitas métricas, envuelve `withLock`:

  ```dart
  Future<R> instrumented<R>(String k, Future<R> Function() f) {
    final t0 = DateTime.now();
    return exec.withLock(k, () async {
      try { return await f(); }
      finally { log('$k took ${DateTime.now().difference(t0)}'); }
    });
  }
  ```

---

### Comparación rápida

| Problema                       | Sin executor                      | Con `PerKeyFifoExecutor`           |
|--------------------------------|-----------------------------------|------------------------------------|
| Dos `write(docId)` simultáneas | Posible **race** (última gana)    | **Orden garantizado** por `docId`  |
| Manejo de errores              | Fácil romper la cola              | `try/finally` embebido             |
| Complejidad                    | Mapas de `Completer`s, edge-cases | API única (`withLock`)             |
| Paralelismo entre claves       | Difícil de orquestar              | **Natural** (colas independientes) |

---

### Testing sugerido

```dart
test('serializa por clave y permite paralelo entre claves', () async {
  final exec = PerKeyFifoExecutor<String>();
  final List<String> log = [];

  Future<void> job(String k, String tag, int ms) async {
    await exec.withLock(k, () async {
      log.add('start $tag');
      await Future<void>.delayed(Duration(milliseconds: ms));
      log.add('end $tag');
    });
  }

  await Future.wait([
    job('A', 'A1', 50),
    job('A', 'A2', 10),
    job('B', 'B1', 30),
  ]);

  // A1 debe terminar antes que A2 (FIFO por A)
  final a1End = log.indexOf('end A1');
  final a2End = log.indexOf('end A2');
  expect(a1End, lessThan(a2End));

  // B1 puede intercalar con A1/A2 (paralelo por clave)
  expect(log.contains('end B1'), isTrue);
});
```

---

### Integración con BLoCs

* **Repository** serializa `write/delete`; el **BLoC** permanece simple (no necesita locks).
* En **streams realtime**, la serialización evita “rebote” de lecturas/escrituras sobre el mismo `docId`.

---

### Limpieza

* `dispose()` limpia las colas registradas.
  **Nota**: no cancela lo que ya corre; se usa para liberar memoria/referencias y que nuevas acciones no encadenen con anteriores.

---

### Caso extra: *per-user throttling* (misma idea, otra semántica)

```dart
final exec = PerKeyFifoExecutor<int>(); // userId

Future<void> updateSettings(int userId, Settings s) =>
    exec.withLock(userId, () => api.saveSettings(userId, s));
```

> Mismo patrón, diferente dominio: *evitas saturar el backend y garantizas orden por entidad*.

# Connectivity
## Conectividad (Service → Gateway → Repository → UseCases → Bloc)

## Objetivo

Exponer el estado de conectividad de forma **reactiva**, con **errores como datos** (`Either<ErrorItem, ConnectivityModel>`) y capas bien separadas, siguiendo la guía de estructura de Jocaagura.

```
UI → AppManager → Bloc → UseCase → Repository → Gateway → Service
```

> 🔗 Estructura y convenciones:
> [https://github.com/grupo-jocaagura/jocaagura\_domain/raw/refs/heads/develop/README\_STRUCTURE.md](https://github.com/grupo-jocaagura/jocaagura_domain/raw/refs/heads/develop/README_STRUCTURE.md)

---

## Modelo de dominio

```dart
// Ya incluido en jocaagura_domain
class ConnectivityModel extends Model {
  final ConnectionTypeEnum connectionType;
  final double internetSpeed; // Mbps
  bool get isConnected => connectionType != ConnectionTypeEnum.none;
}
```

---

## Paso a paso de la integración

### 1) Service (fuente de datos “baja”)

Responsable de hablar con la plataforma y entregar **tipo de conexión**, **velocidad**, y un **stream** de `ConnectivityModel`.

* En dev/tests: `FakeServiceConnectivity` (sin paquetes externos).
* En producción: implementa tu propio `ServiceConnectivity` (ej. usando plugins).

```dart
final service = FakeServiceConnectivity(
  latencyConnectivity: const Duration(milliseconds: 80),
  latencySpeed: const Duration(milliseconds: 120),
  initial: const ConnectivityModel(
    connectionType: ConnectionTypeEnum.wifi,
    internetSpeed: 40,
  ),
);
```

### 2) Gateway (I/O crudo + manejo de excepciones)

Convierte el Service a **payloads crudos** (`Map<String, dynamic>`) y **nunca lanza**: siempre retorna `Either<ErrorItem, Map>`.

```dart
final gateway = GatewayConnectivityImpl(service, DefaultErrorMapper());
```

### 3) Repository (mapeo a dominio + errores de negocio)

Convierte `Map` → `ConnectivityModel` y detecta **errores de negocio** en el payload con `ErrorMapper`.

```dart
final repo = RepositoryConnectivityImpl(
  gateway,
  errorMapper: DefaultErrorMapper(),
);
```

### 4) UseCases (APIs de aplicación)

* `GetConnectivitySnapshotUseCase`
* `WatchConnectivityUseCase`
* `CheckConnectivityTypeUseCase`
* `CheckInternetSpeedUseCase`

```dart
final watch     = WatchConnectivityUseCase(repo);
final snapshot  = GetConnectivitySnapshotUseCase(repo);
final checkType = CheckConnectivityTypeUseCase(repo);
final checkSpeed= CheckInternetSpeedUseCase(repo);
```
### 5) Bloc (reactivo y **puro**)

El BLoC **no conoce la UI**. Emite `Either<ErrorItem, ConnectivityModel>`.

```dart
final bloc = BlocConnectivity(
  watch: watch,
  snapshot: snapshot,
  checkType: checkType,
  checkSpeed: checkSpeed,
);

await bloc.loadInitial();
bloc.startWatching();
// ...
bloc.dispose();
```

### 6) UI (presentación y UX de errores)

La UI **decide** cómo mostrar los errores. Recomendamos envolver la vista con un `ErrorItemWidget` (SnackBar/Banner) y renderizar el `ConnectivityModel` cuando `Right`.

```dart
StreamBuilder<Either<ErrorItem, ConnectivityModel>>(
  stream: bloc.stream,
  initialData: bloc.value,
  builder: (context, snap) {
    final either = snap.data ?? bloc.value;
    return ErrorItemWidget( // muestra SnackBar cuando Left(ErrorItem)
      state: either as Either<ErrorItem, Object>,
      child: either.isRight
        ? Text('Type: ${ (either as Right).value.connectionType.name }')
        : const SizedBox.shrink(), // conserva último estado bueno si quieres
    );
  },
);
```

### 7) Contrato de Error (semántica)

* **Gateway**: mapea **excepciones** del Service → `Left(ErrorItem)`.
* **Repository**: detecta **errores de negocio** en el payload (`{'error': {...}}`, `ok:false`, etc.) → `Left(ErrorItem)`.
* **Bloc**: **no lanza**; re-emite `Left(ErrorItem)` o `Right(ConnectivityModel)`.

> Usa `DefaultErrorMapper()` si no necesitas uno específico.
> En producción, define códigos/semántica de `ErrorItem` y su mapping visual (warning/info/error).

---

## Ejemplo rápido (AppManager / DI)

```dart
class ConnectivityModule {
  late final ServiceConnectivity service;
  late final GatewayConnectivity gateway;
  late final RepositoryConnectivity repo;
  late final BlocConnectivity bloc;

  ConnectivityModule() {
    service  = FakeServiceConnectivity(); // prod: tu Service real
    gateway  = GatewayConnectivityImpl(service, DefaultErrorMapper());
    repo     = RepositoryConnectivityImpl(gateway, errorMapper: DefaultErrorMapper());
    bloc     = BlocConnectivity(
      watch: WatchConnectivityUseCase(repo),
      snapshot: GetConnectivitySnapshotUseCase(repo),
      checkType: CheckConnectivityTypeUseCase(repo),
      checkSpeed: CheckInternetSpeedUseCase(repo),
    );
  }

  Future<void> init() async {
    await bloc.loadInitial();
    bloc.startWatching();
  }

  void dispose() {
    bloc.dispose();
    service.dispose();
  }
}
```

---

## Tests (solo `flutter_test`)

Se incluyen suites de ejemplo:

* `fake_service_connectivity_test.dart`
* `gateway_connectivity_impl_test.dart`
* `repository_connectivity_impl_test.dart`
* `bloc_connectivity_test.dart`

Ejecuta:

```bash
flutter test
```

---

## Consejos de producción

* Reemplaza `FakeServiceConnectivity` por un Service real (plugins/SDK).
* Centraliza la presentación de errores en un widget reusable o notificador global.
* Define códigos de error (`ErrorItem.code`) y su mapeo visual para UX consistente.
* Revisa linters y convenciones:
  [https://github.com/grupo-jocaagura/jocaagura\_domain/raw/refs/heads/develop/analysis\_options.yaml](https://github.com/grupo-jocaagura/jocaagura_domain/raw/refs/heads/develop/analysis_options.yaml)

---

# BlocOnboarding
## Propósito y flujo

`BlocOnboarding` orquesta un **flujo de onboarding por pasos** (tour inicial, permisos, configuración mínima). Cada paso puede ejecutar un **side-effect al entrar** (`onEnter`) que retorna `FutureOr<Either<ErrorItem, Unit>>`.

* Si `onEnter` retorna `Right(Unit)`, el paso es válido y puede **auto-avanzar** usando `autoAdvanceAfter`.
* Si `onEnter` retorna `Left(ErrorItem)` **o lanza una excepción**, el BLoC **no avanza** y expone el error en `state.error`. Las excepciones se mapean a `ErrorItem` usando `ErrorMapper` (por defecto `DefaultErrorMapper`).

**Flujo propuesto (Clean Architecture):**

```
UI → AppManager → BlocOnboarding
```

> Onboarding es **orquestación de UI**; típicamente no requiere Repository/Gateway/Service. Si necesitas I/O (p.ej. guardar bandera “onboardingDone”), hazlo dentro de `onEnter` del paso o en un UseCase invocado desde allí.

---

### Escenarios principales a implementar

* **Tour inicial de la app** (3–5 pantallas con mensajes).
* **Solicitud de permisos** (ubicación, notificaciones) con validación por paso.
* **Configuración mínima** (selección de idioma/tema, aceptación de T\&C).
* **Chequeos previos** (descarga de configuración remota, migraciones locales).

---

### Semántica de errores

* `onEnter` → `Either<ErrorItem, Unit>`

    * `Right(Unit)`: paso OK → si `autoAdvanceAfter` > 0, **programa avance**.
    * `Left(ErrorItem)`: **permanece** en el paso y setea `state.error`.
    * **Throw**: se mapea con `ErrorMapper` → `state.error`.
* La UI puede llamar `clearError()` y luego `retryOnEnter()` para reintentar el paso actual.

---

### Concurrencia y temporizadores

* **Solo un timer activo** a la vez (para `autoAdvanceAfter`).
* Cualquier comando (`start/next/back/skip/complete/retryOnEnter`) **cancela** el timer en curso.
* Protección contra **completions obsoletos**: el BLoC usa un “epoch” interno para **ignorar** resultados tardíos de `onEnter` si el usuario ya navegó a otro paso.

---

## API en breve

* `configure(List<OnboardingStep>)` — define los pasos.
* `start()` — entra a `stepIndex=0` (o `completed` si no hay pasos).
* `next() / back()` — navegación manual.
* `skip()` / `complete()` — termina el flujo (saltado o completado).
* `clearError()` — borra `state.error` sin cambiar paso.
* `retryOnEnter()` — re-ejecuta el `onEnter` del paso actual.
* `stateStream` / `state` — acceso reactivo y snapshot del estado.

`OnboardingStep`:

* `title`, `description` (opcionales).
* `autoAdvanceAfter?: Duration` — auto-avance tras éxito de `onEnter`.
* `onEnter?: FutureOr<Either<ErrorItem, Unit>> Function()` — side-effect al entrar.

---

## Ejemplo rápido

```dart
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:flutter/material.dart';

class OnboardingExample extends StatefulWidget {
  const OnboardingExample({super.key});

  @override
  State<OnboardingExample> createState() => _OnboardingExampleState();
}

class _OnboardingExampleState extends State<OnboardingExample> {
  late final BlocOnboarding bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocOnboarding(); // o inyéctalo vía AppManager

    Either<ErrorItem, Unit> ok() => Right<ErrorItem, Unit>(Unit.value);
    Either<ErrorItem, Unit> err(String msg) => Left<ErrorItem, Unit>(
      ErrorItem(message: msg, code: 'ONB-STEP', severity: ErrorSeverity.blocking),
    );

    FutureOr<Either<ErrorItem, Unit>> requestNotifications() async {
      // Simula pedir permisos…
      final bool granted = true; // reemplaza con lógica real
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return granted ? ok() : err('Notifications are required');
    }

    FutureOr<Either<ErrorItem, Unit>> seedRemoteConfig() async {
      // Simula I/O (descarga de configuración)
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return ok();
    }

    bloc.configure(<OnboardingStep>[
      OnboardingStep(
        title: 'Welcome',
        description: 'Quick tour',
        onEnter: () => ok(),
        autoAdvanceAfter: const Duration(milliseconds: 700),
      ),
      OnboardingStep(
        title: 'Notifications',
        description: 'We will ask permission to keep you informed',
        onEnter: requestNotifications, // puede devolver Left(ErrorItem)
        autoAdvanceAfter: const Duration(milliseconds: 600),
      ),
      OnboardingStep(
        title: 'Setup',
        description: 'Loading remote config',
        onEnter: seedRemoteConfig,
        // sin autoAdvance: el usuario verá "Next"
      ),
    ]);

    // Arranca el flujo
    WidgetsBinding.instance.addPostFrameCallback((_) => bloc.start());
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OnboardingState>(
      stream: bloc.stateStream,
      initialData: bloc.state,
      builder: (BuildContext context, AsyncSnapshot<OnboardingState> snap) {
        final OnboardingState s = snap.data ?? OnboardingState.idle();

        // Muestra error bloqueante (si lo hay)
        final Widget errorBanner = (s.error != null)
            ? MaterialBanner(
                content: Text(s.error!.message),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      bloc.clearError();
                      bloc.retryOnEnter(); // reintenta el paso
                    },
                    child: const Text('Retry'),
                  ),
                ],
              )
            : const SizedBox.shrink();

        return Scaffold(
          appBar: AppBar(title: const Text('Onboarding')),
          body: Column(
            children: <Widget>[
              errorBanner,
              Expanded(
                child: Center(
                  child: Text(
                    'Step ${s.stepIndex + 1} / ${s.totalSteps}\n'
                    'Status: ${s.status}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: <Widget>[
                    Expanded(child: OutlinedButton(onPressed: bloc.back, child: const Text('Back'))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton(onPressed: bloc.next, child: const Text('Next'))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton(onPressed: bloc.skip, child: const Text('Skip'))),
                    const SizedBox(width: 8),
                    Expanded(child: FilledButton(onPressed: bloc.complete, child: const Text('Complete'))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

**Notas del ejemplo**

* El segundo paso simula pedir permisos y puede fallar → la UI muestra el `MaterialBanner` con “Retry”.
* `autoAdvanceAfter` solo se agenda cuando `onEnter` finaliza con `Right(Unit)`.
* Los botones manuales siempre **cancelan timers** activos antes de navegar.

---

### Buenas prácticas

* Mantén `onEnter` **rápido**; si requiere I/O, muestra feedback de carga en la UI (por ejemplo, con tu `BlocLoading`) mientras esperas el `Either`.
* Usa `ErrorMapper` custom si deseas enriquecer `location`, `code` o `severity`.
* Prueba el flujo con **pasos que fallan** y valida `retryOnEnter()` en la UI.

---

### Pruebas (incluidas en el paquete)

* **Core**: estados iniciales, `configure/start/next/back/skip/complete`.
* **Timers**: auto-avance condicionado por éxito, cancelación y reprogramación en navegación.
* **onEnter (async & errors)**: lanzamientos mapeados a `ErrorItem`, `clearError + retryOnEnter`, y protección contra completions obsoletos (epoch guard).

---
# BlocResponsive

## BlocResponsive — validación visual de breakpoints (microsección)

**Objetivo.** Verificar y documentar cómo la app adapta layout (márgenes, gutters, columnas, área de trabajo y tipo de dispositivo) según el ancho del viewport, usando `BlocResponsive` y su demo.

### Cómo usar la Demo

1. Registra y abre `BlocResponsiveDemoPage` (incluida en `example/`).
2. Usa los **switches**:

    * **Show grid overlay**: muestra/oculta columnas y gutters.
    * **Simulate size (sliders)**: mueve `Width/Height` para probar distintos anchos sin cambiar de dispositivo.
    * **Show AppBar** (en la AppBar): alterna la política y observa `screenHeightWithoutAppbar`.
3. Observa en **Metrics**:

    * `Device` cambia entre **MOBILE / TABLET / DESKTOP / TV** según los umbrales de `ScreenSizeConfig`.
    * `Columns`, `Margin`, `Gutter`, `Column width`, `Work area` y `Drawer` se actualizan en vivo.
    * En **DESKTOP/TV** el `Work area` aplica el porcentaje configurado (no ocupa el 100% del viewport).

### Checklist de QA (aceptación)

* [ ] Al cruzar los breakpoints de `ScreenSizeConfig` cambia `Device` y `Columns` correctamente.
* [ ] `marginWidth` y `gutterWidth` se recalculan al variar el ancho; la grilla se mantiene alineada.
* [ ] `columnWidth` = `(workArea − márgenes − gutters) / columns` (sin valores negativos).
* [ ] En **DESKTOP/TV**, `workArea.width` respeta el **porcentaje** configurado; en **MOBILE/TABLET** usa el ancho total.
* [ ] `widthByColumns(n)` incluye gutters entre columnas y nunca supera `workArea.width`.
* [ ] Con “Show AppBar” desactivado, `screenHeightWithoutAppbar` = `size.height`.
* [ ] No hay “parpadeos”: al mover sliders, métricas y grilla cambian de forma estable.

### Integración recomendada (app real)

```dart
class MyLayout extends StatelessWidget {
  const MyLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final BlocResponsive responsive = AppManager.of(context).config.blocResponsive;

    // Mantén sincronizado el tamaño del viewport con el bloc.
    responsive.setSizeFromContext(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.marginWidth),
      child: SizedBox(
        width: responsive.widthByColumns(4).clamp(0, responsive.workAreaSize.width),
        child: Text('Device: ${responsive.deviceType} • Cols: ${responsive.columnsNumber}'),
      ),
    );
  }
}
```

### Pruebas sin Flutter (headless)

```dart
final bloc = BlocResponsive();
bloc.setSizeForTesting(const Size(1280, 800));
expect(bloc.isDesktop, isTrue);
expect(bloc.columnsNumber, bloc.sizeConfig.desktopColumnsNumber);
expect(bloc.widthByColumns(3) <= bloc.workAreaSize.width, isTrue);
bloc.dispose();
```

> 🧭 Arquitectura: **UI → AppManager → BlocResponsive** (infra de presentación, sin I/O).
> 🔧 Configuración: todos los umbrales y porcentajes provienen de `ScreenSizeConfig` (config-driven, sin “magic numbers”).
