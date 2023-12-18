import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

void main() {
  group('AttributeModel tests', () {
    // Constructor tests
    test('Constructor creates AttributeModel', () {
      const AttributeModel<String> model =
          AttributeModel<String>(value: 'test', name: 'name');

      expect(model.value, 'test');
      expect(model.name, 'name');
    });

    // CopyWith tests
    test('copyWith creates new AttributeModel with updated values', () {
      const AttributeModel<String> originalModel =
          AttributeModel<String>(value: 'test', name: 'name');
      final AttributeModel<String> cloneModel = originalModel.copyWith();
      final AttributeModel<String> newModel =
          originalModel.copyWith(value: 'new value');
      expect(cloneModel == originalModel, true);
      expect(newModel.value, 'new value');
      expect(newModel.name, originalModel.name);
    });

    // toJson tests
    test('toJson returns JSON representation of AttributeModel', () {
      const AttributeModel<String> model =
          AttributeModel<String>(value: 'test', name: 'name');
      final Map<String, dynamic> json = model.toJson();

      expect(json, <String, String>{'value': 'test', 'name': 'name'});
    });

    test('fromJson parses JSON string and creates AttributeModel', () {
      const Map<String, dynamic> json = <String, dynamic>{
        'value': 'test',
        'name': 'name',
      };
      final AttributeModel<String> model =
          attributeModelfromJson<String>(json, Utils.getStringFromDynamic);

      expect(model.value, 'test');
      expect(model.name, 'name');
    });

    test('fromJson handles DateTime values', () {
      const Map<String, String> json = <String, String>{
        'value': '2023-10-27T00:00:00.000Z',
        'name': 'date',
      };

      final AttributeModel<DateTime> model =
          attributeModelfromJson<DateTime>(json, DateUtils.dateTimeFromDynamic);

      expect(model.value, DateTime.parse('2023-10-27T00:00:00.000Z'));
      expect(model.name, 'date');
    });

    test('fromJson handles int values', () {
      const Map<String, dynamic> json = <String, dynamic>{
        'value': 123,
        'name': 'age',
      };
      final AttributeModel<int> model =
          attributeModelfromJson<int>(json, Utils.getIntegerFromDynamic);

      expect(model.value, 123);
      expect(model.name, 'age');
    });

    // Equality tests
    test('AttributeModel instances are equal if values are equal', () {
      const AttributeModel<String> model1 =
          AttributeModel<String>(value: 'test', name: 'name');
      const AttributeModel<String> model2 =
          AttributeModel<String>(value: 'test', name: 'name');

      expect(model1 == model2, true);
      expect(model1 == Object(), false);
    });

    // hashCode tests
    test('AttributeModel instances with same values have the same hashCode',
        () {
      const AttributeModel<String> model1 =
          AttributeModel<String>(value: 'test', name: 'name');
      const AttributeModel<String> model2 =
          AttributeModel<String>(value: 'test', name: 'name');

      expect(model1.hashCode == model2.hashCode, true);
    });

    // toString tests
    test('toString returns JSON representation of AttributeModel', () {
      const AttributeModel<String> model =
          AttributeModel<String>(value: 'test', name: 'name');
      final String expectedString =
          jsonEncode(<String, String>{'value': 'test', 'name': 'name'});

      expect(model.toString(), expectedString);
    });
  });
}
