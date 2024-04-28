// Importa aquí la ubicación de tu ConnectivityModel y las clases Utils si es necesario

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ConnectivityModel', () {
    test('Debería crear un modelo por defecto sin errores', () {
      expect(defaultConnectivityModel.connectionType, ConnectionTypeEnum.none);
      expect(defaultConnectivityModel.internetSpeed, 0.0);
    });

    test('Debería parsear desde JSON correctamente', () {
      final Map<String, Object> json = <String, Object>{
        'connectionType': 'wifi',
        'internetSpeed': 100.0,
      };

      final ConnectivityModel connectivityModel =
          ConnectivityModel.fromJson(json);

      expect(connectivityModel.connectionType, ConnectionTypeEnum.wifi);
      expect(connectivityModel.internetSpeed, 100.0);
    });

    test('Debería serializar a JSON correctamente', () {
      const ConnectivityModel connectivityModel = ConnectivityModel(
        connectionType: ConnectionTypeEnum.mobile,
        internetSpeed: 50.0,
      );

      final Map<String, dynamic> json = connectivityModel.toJson();

      expect(json['connectionType'], 'mobile');
      expect(json['internetSpeed'], 50.0);
      expect(connectivityModel.isConnected, true);
      expect(connectivityModel.toString().isNotEmpty, true);
    });

    test('Debería copiar con nuevos valores correctamente', () {
      const ConnectivityModel original = ConnectivityModel(
        connectionType: ConnectionTypeEnum.wired,
        internetSpeed: 1000.0,
      );

      final ConnectivityModel copied = original.copyWith(
        internetSpeed: 500.0,
      );
      final ConnectivityModel copiedOriginal = original.copyWith();

      expect(copied == original, false);
      expect(copiedOriginal == original, true);
      expect(copiedOriginal.hashCode == original.hashCode, true);
      expect(copied.connectionType, ConnectionTypeEnum.wired);
      expect(copied.internetSpeed, 500.0);
      expect(
        original.internetSpeed,
        1000.0,
      ); // Asegurarse de que el original no cambió
    });

    test('Debería identificar si hay conexión', () {
      const ConnectivityModel noConnectionModel = ConnectivityModel(
        connectionType: ConnectionTypeEnum.none,
        internetSpeed: 0.0,
      );

      const ConnectivityModel hasConnectionModel = ConnectivityModel(
        connectionType: ConnectionTypeEnum.ethernet,
        internetSpeed: 1000.0,
      );

      expect(noConnectionModel.isConnected, isFalse);
      expect(hasConnectionModel.isConnected, isTrue);
    });

    test('getConnectionTypeEnumFromString debería devolver el tipo correcto',
        () {
      expect(
        ConnectivityModel.getConnectionTypeEnumFromString('mobile'),
        ConnectionTypeEnum.mobile,
      );
      expect(
        ConnectivityModel.getConnectionTypeEnumFromString('nonexistentType'),
        ConnectionTypeEnum.other,
      );
    });
  });
}
