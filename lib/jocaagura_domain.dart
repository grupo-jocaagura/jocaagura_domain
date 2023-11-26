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
