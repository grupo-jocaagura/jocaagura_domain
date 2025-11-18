/// The `models` library defines a basic abstract class for all domain data.

library jocaagura_domain;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

export 'src/fake_services/fake_http_request_config.dart';
export 'src/fake_services/fake_service_connectivity.dart';
export 'src/fake_services/fake_service_geolocation.dart';
export 'src/fake_services/fake_service_gyroscope.dart';
export 'src/fake_services/fake_service_http.dart';
export 'src/fake_services/fake_service_http_request.dart';
export 'src/fake_services/fake_service_notifications.dart';
export 'src/fake_services/fake_service_preferences.dart';
export 'src/fake_services/fake_service_session.dart';
export 'src/fake_services/fake_service_ws_database.dart';
export 'src/fake_services/fake_service_ws_db.dart';
export 'src/fake_services/ws_db_error_mini_mapper.dart';
export 'src/gateways/gateway_auth_impl.dart';
export 'src/gateways/gateway_connectivity_impl.dart';
export 'src/gateways/gateway_http_request_impl.dart';
export 'src/gateways/gateway_ws_database_impl.dart';
export 'src/gateways/gateway_ws_db_impl.dart';
export 'src/repositories/repository_auth_impl.dart';
export 'src/repositories/repository_connectivity_impl.dart';
export 'src/repositories/repository_http_request_impl.dart';
export 'src/repositories/repository_ws_database_impl.dart';

part 'date_utils.dart';
part 'domain/address_model.dart';
part 'domain/apps/model_app_version.dart';
part 'domain/attribute_model.dart';
part 'domain/bloc.dart';
part 'domain/bloc_core.dart';
part 'domain/bloc_general.dart';
part 'domain/bloc_module.dart';
part 'domain/blocs/bloc_connectivity.dart';

part 'domain/blocs/bloc_http_request.dart';
part 'domain/blocs/bloc_loading.dart';
part 'domain/blocs/bloc_onboarding.dart';
part 'domain/blocs/bloc_responsive.dart';
part 'domain/blocs/bloc_session.dart';
part 'domain/blocs/bloc_ws_database.dart';
part 'domain/calendar/appointment_model.dart';
part 'domain/calendar/contact_model.dart';
part 'domain/citizen/signature_model.dart';
part 'domain/common_errors/database_error_items.dart';
part 'domain/common_errors/error_mapper.dart';
part 'domain/common_errors/http_error_items.dart';
part 'domain/common_errors/network_error_items.dart';
part 'domain/common_errors/session_error_items.dart';
part 'domain/common_errors/web_socket_error_items.dart';
part 'domain/configs/ws_db_config.dart';
part 'domain/connectivity_model.dart';
part 'domain/death_record_model.dart';
part 'domain/debouncer.dart';
part 'domain/dentist_app/acceptance_clause_model.dart';
part 'domain/dentist_app/dental_condition_model.dart';
part 'domain/dentist_app/diagnosis_model.dart';
part 'domain/dentist_app/medical_record_model.dart';
part 'domain/dentist_app/medical_treatment_model.dart';
part 'domain/dentist_app/treatment_plan_model.dart';
part 'domain/education/model_assessment.dart';
part 'domain/education/model_competency_standard.dart';
part 'domain/education/model_learning_goal.dart';
part 'domain/education/model_learning_item.dart';
part 'domain/education/model_performance_indicator.dart';
part 'domain/either.dart';
part 'domain/entity_bloc.dart';
part 'domain/entity_provider.dart';
part 'domain/entity_service.dart';
part 'domain/entity_util.dart';
part 'domain/error_item_model.dart';
part 'domain/financial/financial_movement.dart';
part 'domain/financial/ledger_model.dart';
part 'domain/gateways/gateway_auth.dart';
part 'domain/gateways/gateway_connectivity.dart';

part 'domain/gateways/gateway_http_request.dart';
part 'domain/gateways/gateway_ws_database.dart';
part 'domain/graphics/model_graph.dart';
part 'domain/graphics/model_graph_axis_spec.dart';
part 'domain/graphics/model_point.dart';

part 'domain/http/adapter_http_client.dart';

part 'domain/http/helper_http_request_id.dart';

part 'domain/http/http_enums.dart';

part 'domain/http/http_request_life_cycle.dart';

part 'domain/http/http_request_state.dart';

part 'domain/http/model_config_http_request.dart';

part 'domain/http/model_response_raw.dart';

part 'domain/http/model_trace_http_request.dart';

part 'domain/http/model_trace_http_request_step.dart';

part 'domain/http/telemetry_helper.dart';
part 'domain/legal_id_model.dart';
part 'domain/medical/medical_diagnosis_tab_model.dart';
part 'domain/medical/medication_model.dart';
part 'domain/model_vector.dart';
part 'domain/obituary_model.dart';
part 'domain/person_model.dart';
part 'domain/pet_app/animal_model.dart';
part 'domain/repositories/repository_auth.dart';
part 'domain/repositories/repository_connectivity.dart';

part 'domain/repositories/repository_http_request.dart';
part 'domain/repositories/repository_ws_database.dart';
part 'domain/services/service_connectivity.dart';
part 'domain/services/service_geolocation.dart';
part 'domain/services/service_gyroscope.dart';
part 'domain/services/service_http.dart';

part 'domain/services/service_http_request.dart';
part 'domain/services/service_notifications.dart';
part 'domain/services/service_preferences.dart';
part 'domain/services/service_session.dart';
part 'domain/services/service_ws_database.dart';
part 'domain/services/service_ws_db.dart';
part 'domain/states/onboarding_state.dart';
part 'domain/states/onboarding_step.dart';
part 'domain/states/session_state.dart';
part 'domain/states/ws_db_state.dart';
part 'domain/store/model_category.dart';
part 'domain/store/model_item.dart';
part 'domain/store/model_price.dart';
part 'domain/store_model.dart';
part 'domain/ui/model_main_menu_model.dart';
part 'domain/ui/screen_size_config.dart';
part 'domain/usecases/connectivity/connectivity_usecases.dart';
part 'domain/usecases/databases_crud/databases_crud_usecases.dart';
part 'domain/usecases/databases_crud/facade_crud_database.dart';
part 'domain/usecases/databases_crud/facade_ws_database_usecases.dart';

part 'domain/usecases/http_request/http_request_usecases.dart';
part 'domain/usecases/no_params.dart';
part 'domain/usecases/session/get_current_user_usecase.dart';
part 'domain/usecases/session/log_in_silently_usecase.dart';
part 'domain/usecases/session/log_in_user_and_password_usecase.dart';
part 'domain/usecases/session/log_in_with_google_usecase.dart';
part 'domain/usecases/session/log_out_usecase.dart';
part 'domain/usecases/session/recover_password_usecase.dart';
part 'domain/usecases/session/refresh_session_usecase.dart';
part 'domain/usecases/session/session_usecases.dart';
part 'domain/usecases/session/sign_in_user_and_password_usecase.dart';
part 'domain/usecases/session/watch_auth_state_changes_usecases.dart';
part 'domain/usecases/usecase.dart';
part 'domain/user_model.dart';
part 'domain/utils/money_utils.dart';
part 'per_key_fifo_executor.dart';
part 'unit.dart';
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
