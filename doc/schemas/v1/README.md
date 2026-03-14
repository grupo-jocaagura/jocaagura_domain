# Schemas v1

Esta carpeta contiene la primera version de contratos JSON canonicos para `jocaagura_domain`.

## Modelos incluidos

- `address_model.schema.json`
- `attribute_model.schema.json`
- `appointment_model.schema.json`
- `acceptance_clause_model.schema.json`
- `connectivity_model.schema.json`
- `contact_model.schema.json`
- `dental_condition_model.schema.json`
- `death_record_model.schema.json`
- `diagnosis_model.schema.json`
- `error_item_model.schema.json`
- `financial_movement_model.schema.json`
- `ledger_model.schema.json`
- `legal_id_model.schema.json`
- `medication_model.schema.json`
- `medical_diagnosis_tab_model.schema.json`
- `medical_record_model.schema.json`
- `medical_treatment_model.schema.json`
- `model_config_http_request.schema.json`
- `model_assessment.schema.json`
- `model_competency_standard.schema.json`
- `model_graph.schema.json`
- `model_graph_axis_spec.schema.json`
- `model_group.schema.json`
- `model_group_alias.schema.json`
- `model_group_config.schema.json`
- `model_group_dynamic_membership_rule.schema.json`
- `model_group_labels.schema.json`
- `model_group_member.schema.json`
- `model_group_settings.schema.json`
- `model_group_sync_config.schema.json`
- `model_group_sync_job.schema.json`
- `model_learning_goal.schema.json`
- `model_learning_item.schema.json`
- `model_acl.schema.json`
- `user_model.schema.json`
- `person_model.schema.json`
- `onboarding_state.schema.json`
- `signature_model.schema.json`
- `model_vector.schema.json`
- `store_model.schema.json`
- `treatment_plan_model.schema.json`
- `model_category.schema.json`
- `model_price.schema.json`
- `model_item.schema.json`
- `model_app_version.schema.json`
- `model_acl_policy.schema.json`
- `model_crud_metadata.schema.json`
- `model_crud_log_entry.schema.json`
- `model_flow_step.schema.json`
- `model_point.schema.json`
- `model_complete_flow.schema.json`
- `model_performance_indicator.schema.json`
- `ws_db_config.schema.json`

## Dependencias entre schemas

- `store_model.schema.json` referencia `address_model.schema.json`
- `legal_id_model.schema.json` referencia `attribute_model.schema.json`
- `death_record_model.schema.json` referencia `store_model.schema.json`, `person_model.schema.json` y `address_model.schema.json`
- `obituary_model.schema.json` referencia `person_model.schema.json`, `address_model.schema.json` y `death_record_model.schema.json`
- `ledger_model.schema.json` referencia `financial_movement_model.schema.json`
- `acceptance_clause_model.schema.json` referencia `signature_model.schema.json`
- `treatment_plan_model.schema.json` referencia `medical_treatment_model.schema.json`
- `medical_record_model.schema.json` referencia `person_model.schema.json`, `diagnosis_model.schema.json`, `dental_condition_model.schema.json`, `treatment_plan_model.schema.json`, `acceptance_clause_model.schema.json`, `address_model.schema.json`, `legal_id_model.schema.json`, `user_model.schema.json`, `appointment_model.schema.json`, `medication_model.schema.json` y `contact_model.schema.json`
- `onboarding_state.schema.json` referencia `error_item_model.schema.json`
- `model_competency_standard.schema.json` referencia `model_category.schema.json`
- `model_learning_goal.schema.json` referencia `model_competency_standard.schema.json`
- `model_performance_indicator.schema.json` referencia `model_learning_goal.schema.json`
- `model_learning_item.schema.json` referencia `attribute_model.schema.json`, `model_performance_indicator.schema.json` y `model_category.schema.json`
- `model_assessment.schema.json` referencia `model_learning_item.schema.json`
- `person_model.schema.json` referencia `attribute_model.schema.json`
- `model_item.schema.json` referencia `model_category.schema.json`, `model_price.schema.json` y `attribute_model.schema.json`
- `model_complete_flow.schema.json` referencia `model_flow_step.schema.json`
- `model_point.schema.json` referencia `model_vector.schema.json`
- `model_graph.schema.json` referencia `model_graph_axis_spec.schema.json` y `model_point.schema.json`
- `model_group.schema.json` referencia `model_group_labels.schema.json` y `model_crud_metadata.schema.json`
- `model_group_alias.schema.json` referencia `model_crud_metadata.schema.json`
- `model_group_member.schema.json` referencia `model_crud_metadata.schema.json`
- `model_group_config.schema.json` referencia `model_crud_metadata.schema.json`
- `model_group_sync_config.schema.json` referencia `model_crud_metadata.schema.json`

## Examples

- La carpeta `examples/` contiene un payload JSON canonico por cada schema de `v1`
- La convención es uno a uno: `foo.schema.json` usa `examples/foo.example.json`
- El validador local compila los schemas y valida estos ejemplos contra su contrato correspondiente

## Validacion de v1

Comando:

```powershell
npm run validate:schemas
```

Resultado esperado:

- todos los `.schema.json` compilan correctamente
- todos los `.example.json` validan contra su schema correspondiente
- las referencias locales entre schemas se resuelven sin errores

## Como consumir v1

- Usa los archivos de `examples/` como payloads mínimos de referencia.
- Si implementas validación en backend o tooling, apunta siempre a la carpeta versionada `v1`.
- Si un consumidor necesita compatibilidad con parseos legacy de Dart, trata esa compatibilidad fuera del schema principal.
- Si aparece una divergencia entre schema y `toJson()` actual, el contrato canónico de esta carpeta tiene prioridad documental.

## Convenciones relevantes de v1

- Las fechas se representan como `string` con `format: date-time`
- `UserModel.jwt` se representa como `object`
- `PersonModel.attributes` se representa como diccionario de atributos
- `ModelItem.attributes` se representa como arreglo de atributos
- Los contratos canónicos priorizan interoperabilidad JSON por encima de tolerancias historicas de parseo en Dart

## Reglas contractuales de v1

- Los `enum` reflejan el valor serializado real del dominio o el valor canónico decidido para interoperabilidad.
- Los enteros y números se modelan como tipos JSON reales, no como strings numerados.
- Los mapas abiertos se usan solo cuando el contrato necesita extensibilidad real, por ejemplo `jwt`, `meta`, `diff`, `body`, `metadata` o diccionarios nombrados.
- Cuando un modelo reutiliza otro contrato ya definido, debe hacerlo mediante `$ref` y no duplicando shape.
- Los examples deben ser internamente consistentes con el resto de contratos reutilizados.

## Brechas conocidas entre contrato y Dart actual

- `user_model.schema.json`
  - `jwt` es `object` canónico.
  - `UserModel.toJson()` hoy serializa `jwt` como string JSON.
- `person_model.schema.json`
  - `attributes` es diccionario canónico.
  - `PersonModel.fromJson()` hoy no restaura ese diccionario y `toJson()` no lo preserva correctamente.
- `dental_condition_model.schema.json`
  - `dentalId` es `integer` canónico.
  - `DentalConditionModel.fromJson()` acepta strings y normaliza a entero.
- `medical_record_model.schema.json`
  - el example se alinea deliberadamente con los contratos canónicos de `UserModel`, `AppointmentModel` y `ContactModel`, no con formas legacy que puedan existir en ejemplos Dart antiguos.

## Compatibilidad esperada

- Los schemas `v1` son compatibles entre sí y sus references ya validan en conjunto.
- Los cambios documentales o examples más precisos pueden seguir entrando en `v1` si no cambian requireds, enums, shape ni semántica.
- Cualquier cambio incompatible en contrato debe abrir una nueva carpeta versionada.

## Criterio de exclusión

Un tipo queda fuera de `v1` cuando cumple una o más de estas condiciones:

- no tiene `fromJson()` y `toJson()` estables
- depende de callbacks, UI o tipos runtime
- es una abstracción de infraestructura y no un payload de intercambio
- su serialización actual no define un contrato JSON útil o reutilizable

## Exclusiones justificadas

- `AnimalModel`: abstracto y sin contrato JSON propio reusable
- `RequestContext`: tipo auxiliar sin `fromJson`/`toJson`
- `SessionState` y subtipos: jerarquía de estado sin contrato JSON estable transversal
- `WsDbState<T>`: genérico de runtime sin serialización JSON formal
- `OnboardingStep`: contiene callbacks y no es portable como JSON
- `ModelMainMenuModel`: `toJson()` no implementa contrato real y depende de tipos UI/callbacks
- blocs, gateways, repositories y services abstractos: infraestructura, no modelos de intercambio
