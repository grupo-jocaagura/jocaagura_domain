import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('ModelVehicle', () {
    const ModelCategory vehicleCategory = ModelCategory(
      category: 'Cargo Van',
      description: 'Light cargo vehicle',
    );
    const ModelCategory fleetTag = ModelCategory(
      category: 'Fleet A',
      description: 'Primary fleet',
    );
    const ModelCategory urbanTag = ModelCategory(
      category: 'Urban Route',
      description: 'Urban operation',
    );
    const AttributeModel<String> colorAttribute = AttributeModel<String>(
      name: 'color',
      value: 'white',
    );
    const AttributeModel<int> passengerAttribute = AttributeModel<int>(
      name: 'passengerCapacity',
      value: 2,
    );

    const ModelVehicle model = ModelVehicle(
      id: 'vehicle-001',
      displayName: 'Van 01',
      plate: 'ABC123',
      brand: 'Renault',
      model: 'Kangoo',
      year: 2024,
      description: 'Urban delivery van',
      isActive: true,
      vehicleCategory: vehicleCategory,
      tags: <ModelCategory>[
        fleetTag,
        urbanTag,
      ],
      attributes: <String, AttributeModel<dynamic>>{
        'color': colorAttribute,
        'passengerCapacity': passengerAttribute,
      },
    );

    test(
      'Given canonical payload When fromJson then reconstructs the full model',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelVehicleEnum.id.name: 'vehicle-001',
          ModelVehicleEnum.displayName.name: 'Van 01',
          ModelVehicleEnum.plate.name: 'ABC123',
          ModelVehicleEnum.brand.name: 'Renault',
          ModelVehicleEnum.model.name: 'Kangoo',
          ModelVehicleEnum.year.name: 2024,
          ModelVehicleEnum.description.name: 'Urban delivery van',
          ModelVehicleEnum.isActive.name: true,
          ModelVehicleEnum.vehicleCategory.name: vehicleCategory.toJson(),
          ModelVehicleEnum.tags.name: <Map<String, dynamic>>[
            fleetTag.toJson(),
            urbanTag.toJson(),
          ],
          ModelVehicleEnum.attributes.name: <String, dynamic>{
            'color': colorAttribute.toJson(),
            'passengerCapacity': passengerAttribute.toJson(),
          },
        };

        final ModelVehicle parsed = ModelVehicle.fromJson(json);

        expect(parsed, equals(model));
        expect(
          parsed.attributes['color']?.toJson(),
          equals(colorAttribute.toJson()),
        );
        expect(
          parsed.attributes['passengerCapacity']?.toJson(),
          equals(passengerAttribute.toJson()),
        );
      },
    );

    test(
      'Given model When toJson and fromJson then preserves canonical roundtrip',
      () {
        final Map<String, dynamic> json = model.toJson();
        final ModelVehicle roundtrip = ModelVehicle.fromJson(json);

        expect(roundtrip, equals(model));
        expect(roundtrip.toJson(), equals(json));
      },
    );

    test(
      'Given missing optional collections When fromJson then defaults to empty collections and active state',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelVehicleEnum.id.name: 'vehicle-002',
          ModelVehicleEnum.displayName.name: 'Vehicle 02',
          ModelVehicleEnum.plate.name: '',
          ModelVehicleEnum.brand.name: 'Toyota',
          ModelVehicleEnum.model.name: 'Hilux',
          ModelVehicleEnum.year.name: 0,
          ModelVehicleEnum.description.name: '',
          ModelVehicleEnum.vehicleCategory.name: defaultModelCategory.toJson(),
        };

        final ModelVehicle parsed = ModelVehicle.fromJson(json);

        expect(parsed.tags, isEmpty);
        expect(parsed.attributes, isEmpty);
        expect(parsed.isActive, isTrue);
        expect(parsed.toJson()[ModelVehicleEnum.tags.name], isEmpty);
        expect(parsed.toJson()[ModelVehicleEnum.attributes.name], isEmpty);
      },
    );

    test(
      'Given legacy-ish raw attributes map When fromJson then normalizes into AttributeModel dictionary',
      () {
        final Map<String, dynamic> json = <String, dynamic>{
          ModelVehicleEnum.id.name: 'vehicle-003',
          ModelVehicleEnum.displayName.name: 'Vehicle 03',
          ModelVehicleEnum.plate.name: 'XYZ987',
          ModelVehicleEnum.brand.name: 'Kia',
          ModelVehicleEnum.model.name: 'Picanto',
          ModelVehicleEnum.year.name: 2020,
          ModelVehicleEnum.description.name: 'Compact urban vehicle',
          ModelVehicleEnum.isActive.name: false,
          ModelVehicleEnum.vehicleCategory.name: vehicleCategory.toJson(),
          ModelVehicleEnum.tags.name: const <Map<String, dynamic>>[],
          ModelVehicleEnum.attributes.name: <String, dynamic>{
            'color': 'red',
            'batteryLevel': <String, dynamic>{
              'name': 'batteryLevel',
              'value': 87,
            },
          },
        };

        final ModelVehicle parsed = ModelVehicle.fromJson(json);

        expect(parsed.isActive, isFalse);
        expect(
          parsed.attributes['color'],
          equals(const AttributeModel<dynamic>(name: 'color', value: 'red')),
        );
        expect(
          parsed.attributes['batteryLevel'],
          equals(
            const AttributeModel<dynamic>(name: 'batteryLevel', value: 87),
          ),
        );
      },
    );

    test(
      'Given model When copyWith overrides some fields then preserves the rest',
      () {
        final Map<String, AttributeModel<dynamic>> attributes =
            <String, AttributeModel<dynamic>>{
          'fuelType': const AttributeModel<String>(
            name: 'fuelType',
            value: 'electric',
          ),
        };

        final ModelVehicle copy = model.copyWith(
          displayName: 'Van 01 Updated',
          year: 2025,
          isActive: false,
          attributes: attributes,
        );

        expect(copy.id, equals(model.id));
        expect(copy.displayName, equals('Van 01 Updated'));
        expect(copy.year, equals(2025));
        expect(copy.isActive, isFalse);
        expect(copy.vehicleCategory, equals(model.vehicleCategory));
        expect(copy.tags, equals(model.tags));
        expect(copy.attributes, same(attributes));
        final ModelVehicle copyII = model.copyWith();
        expect(copyII.toString(), equals(model.toString()));
      },
    );

    test(
      'Given equal vehicles with distinct map instances When compared then equality and hashCode stay stable',
      () {
        const ModelVehicle same = ModelVehicle(
          id: 'vehicle-001',
          displayName: 'Van 01',
          plate: 'ABC123',
          brand: 'Renault',
          model: 'Kangoo',
          year: 2024,
          description: 'Urban delivery van',
          isActive: true,
          vehicleCategory: ModelCategory(
            category: 'cargo-van',
            description: 'Different description but same normalized category',
          ),
          tags: <ModelCategory>[
            ModelCategory(
              category: 'fleet-a',
              description: 'Another description',
            ),
            ModelCategory(
              category: 'urban-route',
              description: 'Another tag description',
            ),
          ],
          attributes: <String, AttributeModel<dynamic>>{
            'color': AttributeModel<dynamic>(name: 'color', value: 'white'),
            'passengerCapacity': AttributeModel<dynamic>(
              name: 'passengerCapacity',
              value: 2,
            ),
          },
        );

        expect(same, equals(model));
        expect(same.hashCode, equals(model.hashCode));
      },
    );

    test('defaultModelVehicle stays useful for tests', () {
      expect(defaultModelVehicle.isActive, isTrue);
      expect(defaultModelVehicle.tags, isEmpty);
      expect(defaultModelVehicle.attributes, isEmpty);
      expect(
        defaultModelVehicle.toJson()[ModelVehicleEnum.vehicleCategory.name],
        equals(defaultModelCategory.toJson()),
      );
    });
  });
  group('ModelVehicle.fromJson attributes list normalization', () {
    test(
      'Given empty attributes list When parsing Then returns an empty immutable attributes map',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelVehicleEnum.id.name: 'vehicle-1',
          ModelVehicleEnum.displayName.name: 'Vehicle 1',
          ModelVehicleEnum.plate.name: 'ABC123',
          ModelVehicleEnum.brand.name: 'Brand',
          ModelVehicleEnum.model.name: 'Model',
          ModelVehicleEnum.year.name: 2024,
          ModelVehicleEnum.description.name: 'Description',
          ModelVehicleEnum.isActive.name: true,
          ModelVehicleEnum.vehicleCategory.name: defaultModelCategory.toJson(),
          ModelVehicleEnum.attributes.name: <dynamic>[],
        };

        // Act
        final ModelVehicle result = ModelVehicle.fromJson(json);

        // Assert
        expect(result.attributes, isEmpty);
        expect(
          () => result.attributes['newKey'] = const AttributeModel<String>(
            name: 'newKey',
            value: 'value',
          ),
          throwsUnsupportedError,
        );
      },
    );

    test(
      'Given attributes list with valid names When parsing Then stores each attribute by its name',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelVehicleEnum.id.name: 'vehicle-1',
          ModelVehicleEnum.displayName.name: 'Vehicle 1',
          ModelVehicleEnum.plate.name: 'ABC123',
          ModelVehicleEnum.brand.name: 'Brand',
          ModelVehicleEnum.model.name: 'Model',
          ModelVehicleEnum.year.name: 2024,
          ModelVehicleEnum.description.name: 'Description',
          ModelVehicleEnum.isActive.name: true,
          ModelVehicleEnum.vehicleCategory.name: defaultModelCategory.toJson(),
          ModelVehicleEnum.attributes.name: <Map<String, dynamic>>[
            <String, dynamic>{
              AttributeEnum.name.name: 'fuelLevel',
              AttributeEnum.value.name: 0.75,
            },
            <String, dynamic>{
              AttributeEnum.name.name: 'passengers',
              AttributeEnum.value.name: 4,
            },
          ],
        };

        // Act
        final ModelVehicle result = ModelVehicle.fromJson(json);

        // Assert
        expect(result.attributes.length, 2);
        expect(result.attributes.containsKey('fuelLevel'), isTrue);
        expect(result.attributes.containsKey('passengers'), isTrue);
        expect(result.attributes['fuelLevel']?.name, 'fuelLevel');
        expect(result.attributes['fuelLevel']?.value, 0.75);
        expect(result.attributes['passengers']?.name, 'passengers');
        expect(result.attributes['passengers']?.value, 4);
      },
    );

    test(
      'Given attributes list with empty names When parsing Then skips unnamed attributes',
      () {
        // Arrange
        final Map<String, dynamic> json = <String, dynamic>{
          ModelVehicleEnum.id.name: 'vehicle-1',
          ModelVehicleEnum.displayName.name: 'Vehicle 1',
          ModelVehicleEnum.plate.name: 'ABC123',
          ModelVehicleEnum.brand.name: 'Brand',
          ModelVehicleEnum.model.name: 'Model',
          ModelVehicleEnum.year.name: 2024,
          ModelVehicleEnum.description.name: 'Description',
          ModelVehicleEnum.isActive.name: true,
          ModelVehicleEnum.vehicleCategory.name: defaultModelCategory.toJson(),
          ModelVehicleEnum.attributes.name: <Map<String, dynamic>>[
            <String, dynamic>{
              AttributeEnum.name.name: '',
              AttributeEnum.value.name: 'ignored',
            },
            <String, dynamic>{
              AttributeEnum.name.name: 'cargoCapacity',
              AttributeEnum.value.name: 1200,
            },
          ],
        };

        // Act
        final ModelVehicle result = ModelVehicle.fromJson(json);

        // Assert
        expect(result.attributes.length, 1);
        expect(result.attributes.containsKey('cargoCapacity'), isTrue);
        expect(result.attributes.containsKey(''), isFalse);
        expect(result.attributes['cargoCapacity']?.value, 1200);
      },
    );
  });
}
