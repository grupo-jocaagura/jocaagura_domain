/// The `models` library defines a basic abstract class for all domain data.

library jocaagura_domain;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

part 'date_utils.dart';
part 'domain/address_model.dart';
part 'domain/attribute_model.dart';
part 'domain/bloc.dart';
part 'domain/bloc_core.dart';
part 'domain/bloc_general.dart';
part 'domain/bloc_module.dart';
part 'domain/citizen/signature_model.dart';
part 'domain/connectivity_model.dart';
part 'domain/death_record_model.dart';
part 'domain/debouncer.dart';
part 'domain/dentist_app/acceptance_clause_model.dart';
part 'domain/dentist_app/dental_condition_model.dart';
part 'domain/dentist_app/diagnosis_model.dart';
part 'domain/dentist_app/medical_treatment_model.dart';
part 'domain/dentist_app/treatment_plan_model.dart';
part 'domain/either.dart';
part 'domain/entity_bloc.dart';
part 'domain/entity_provider.dart';
part 'domain/entity_service.dart';
part 'domain/entity_util.dart';
part 'domain/legal_id_model.dart';
part 'domain/medical/medical_diagnosis_tab_model.dart';
part 'domain/model_vector.dart';
part 'domain/obituary_model.dart';
part 'domain/person_model.dart';
part 'domain/pet_app/animal_model.dart';
part 'domain/store_model.dart';
part 'domain/ui/model_main_menu_model.dart';
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
