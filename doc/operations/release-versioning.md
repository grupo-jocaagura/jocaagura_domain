# Preparación y publicación de releases

La versión 2.0.0 se publicó y tiene evidencia CP-0 integrada. Su preparación
histórica escribió en develop (`40098aa`); las nuevas preparaciones se revisan
mediante un PR y no escriben directamente en la rama protegida.

La documentación vigente del publisher y del primer upload OIDC está en
[.github/CI_CD.md](../../.github/CI_CD.md). Ese documento distingue la comprobación
OIDC sin publicación de la evidencia de un upload real, y describe el bootstrap
supervisado, los bloqueos y la recuperación sin mover tags ni duplicar versiones.

La preparación atómica de versión/CHANGELOG conserva SHA exacto, CAS, firma
nativa de GitHub y reintentos idempotentes. Inputs: version, expected_head y
changelog_base64. El payload se construye en disco para soportar CHANGELOGs grandes.
La Action crea `codex/prepare-version-<version>-<sha-prefix>` y abre el PR a
develop, sin aprobarlo ni fusionarlo. Los reintentos idénticos reutilizan la
propuesta; las divergencias se bloquean sin sobrescribirla. El resultado
`VERSION_PR_READY` indica que existe una propuesta, no una versión integrada.

El repositorio debe permitir a GitHub Actions crear PR en Settings -> Actions ->
General (opción conjunta de crear y aprobar PR). Un colaborador debe pulsar
**Approve workflows to run** cuando GitHub retenga las ejecuciones creadas por
`GITHUB_TOKEN`; después deben pasar CI/CodeQL, revisión independiente y reglas de
base actualizada. No hay bypass, PAT ni publicación en esta Action. Tras integrar
la propuesta se toma el nuevo SHA de develop para continuar hacia master.

La referencia canónica del checkpoint #213 es core develop
`f00f35dc36e7a408f245dffc8d447a05061deb17`. Se conservan los gates adicionales
Flutter, cobertura >=90% y JSON schemas. No se hereda una CP-0 del core.

| Tramo | Core | Adaptación domain |
| --- | --- | --- |
| Preparación | pubspec/CHANGELOG atómicos y firma GitHub | SHA obligatorio, fecha America/Bogota y rama/PR para respetar los rulesets |
| PR a master | PR oficial, versión y full CI | Check requerido Validate PR to master conserva su nombre; gates Flutter/schemas |
| Publish | tags, provenance, CP-0 para dispatch, OIDC, CI y release | Flutter 3.50.0, environment pub.dev, claims firmados y recheck de fuente viva |
| CP-0 | Evidencia de upload real del core | Manifiesto propio domain aprobado para 2.0.0, integrado mediante #224 |
| Seguridad | CodeQL de Actions | Workflow CodeQL activo, sin uploader legacy paralelo |
| Tags | Inmutables sin bypass | Ruleset 27088011 activo para v*; verificado por el publisher |

Certificación del consumidor para el código de ec8d831:
https://github.com/grupo-jocaagura/jocaaguraarchetype/blob/01561b2a755bd800d6eced0754c23584c37be32b/doc/workflows/evidence/135/certification-ec8d831.md
La homologación del publisher modifica automatización/metadata/documentación;
no modifica APIs de lib/.
