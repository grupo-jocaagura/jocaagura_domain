# Preparación y publicación de releases

La versión 2.0.0 fue preparada por la Action en develop (`40098aa`) y pasó CI
completo y dry-run sin warnings. No está publicada por ese hecho.

La documentación vigente del publisher y del primer upload OIDC está en
[.github/CI_CD.md](../../.github/CI_CD.md). Ese documento distingue la comprobación
OIDC sin publicación de la evidencia de un upload real, y describe el bootstrap
supervisado, los bloqueos y la recuperación sin mover tags ni duplicar versiones.

La preparación atómica de versión/CHANGELOG conserva SHA exacto, CAS, firma
nativa de GitHub y reintentos idempotentes. Inputs: version, expected_head y
changelog_base64. El payload se construye en disco para soportar CHANGELOGs grandes.

La referencia canónica del checkpoint #213 es core develop
`f00f35dc36e7a408f245dffc8d447a05061deb17`. Se conservan los gates adicionales
Flutter, cobertura >=90% y JSON schemas. No se hereda una CP-0 del core.

| Tramo | Core | Adaptación domain |
| --- | --- | --- |
| Preparación | pubspec/CHANGELOG atómicos y firma GitHub | Integrado en #219/#220; SHA obligatorio y fecha America/Bogota |
| PR a master | PR oficial, versión y full CI | Check requerido Validate PR to master conserva su nombre; gates Flutter/schemas |
| Publish | tags, provenance, CP-0 para dispatch, OIDC, CI y release | Flutter 3.50.0, environment pub.dev, claims firmados y recheck de fuente viva |
| CP-0 | Evidencia de upload real del core | Manifiesto propio domain pendiente; primer upload humano autorizado por tag |
| Seguridad | CodeQL de Actions | Workflow CodeQL activo, sin uploader legacy paralelo |
| Tags | Inmutables sin bypass | Ruleset 27088011 activo para v*; verificado por el publisher |

Certificación del consumidor para el código de ec8d831:
https://github.com/grupo-jocaagura/jocaaguraarchetype/blob/01561b2a755bd800d6eced0754c23584c37be32b/doc/workflows/evidence/135/certification-ec8d831.md
La homologación del publisher modifica automatización/metadata/documentación;
no modifica APIs de lib/.
