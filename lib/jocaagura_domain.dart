/// The `models` library defines a basic abstract class for all domain data.

library jocaagura_domain;

import 'dart:convert';

import 'package:flutter/material.dart';

part 'domain/user_model.dart';
part 'utils.dart';

/// A base class for all domain data models.
///
/// This abstract class provides common methods for JSON serialization,
/// deserialization, copying, and conversion from a string. It also includes
/// utility functions for working with JSON data.
@immutable
abstract class Model {
  /// Creates a new instance of the [Model] class.
  const Model();

  /// Converts a JSON [Map] to an entity model.
  ///
  /// [json] is the JSON [Map] to be converted to an entity model.
  const Model.fromJson(Map<String, dynamic> json);

  /// Converts the entity model to a JSON [Map].
  ///
  /// Returns an empty [Map] by default. Override this method to customize
  /// the JSON conversion for your entity model.
  Map<String, dynamic> toJson();

  /// Creates a copy of the entity model.
  ///
  /// Returns a new instance of the entity model with the same values, changing
  /// some of them.
  Model copyWith();

  /// Converts a JSON string to a list of strings.
  ///
  /// [json] is the JSON string to be converted.
  ///
  /// Returns an empty list if the conversion fails.
  static List<String> convertJsonToList(String? json) {
    json = json.toString();
    try {
      final dynamic decodedJson = jsonDecode(json);
      if (decodedJson == null) {
        return <String>[];
      } else if (decodedJson is String) {
        return <String>[decodedJson];
      } else if (decodedJson is List) {
        if (decodedJson.isEmpty) {
          return <String>[];
        } else {
          return decodedJson.map((dynamic item) => item.toString()).toList();
        }
      } else {
        return <String>[decodedJson.toString()];
      }
    } catch (e) {
      return <String>[];
    }
  }

  /// Checks whether the given [other] object is equal to this entity model.
  ///
  /// Returns `true` if the [other] object is an instance of [Model]
  /// and has the same values as this entity model; otherwise, returns `false`.
  @override
  bool operator ==(Object other);

  /// Gets the hash code for this entity model.
  @override
  int get hashCode;
}
