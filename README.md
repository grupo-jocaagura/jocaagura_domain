# Jocaagura Domain
![Coverage](https://img.shields.io/badge/coverage-99%25-brightgreen)

## Descripción
El paquete Jocaagura Domain ofrece una serie de abstracciones de lógica de negocio diseñadas para mantener una coherencia arquitectónica en proyectos Flutter. Al proveer una base sólida y una arquitectura limpia y escalable, facilita la interrelación de desarrollos múltiples, permitiendo que las diferentes aplicaciones converjan en una misma estructura de diseño.

## Características
- **Abstracciones de Modelos**: Contiene modelos fundamentales como `UserModel`, `PersonModel`, entre otros.
- **Arquitectura Limpia**: Fomenta una estructura de código mantenible y organizada.
- **Cobertura de Pruebas**: Incluye pruebas que cubren un amplio rango de escenarios para garantizar la robustez.
- **Independencia**: No tiene dependencias externas más allá del SDK de Flutter.
- **Diagramas UML**: Proporciona diagramas UML para entender las relaciones entre clases.

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
