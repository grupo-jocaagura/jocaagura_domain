# Preparación y publicación de releases

## Estado del checkpoint #213

La migración #212 entró a `develop` mediante PR #218, merge
`0fbb7ccbac6e73a2647fb79681b5279124ba8b49`. Su Base validation terminó en SUCCESS:
https://github.com/grupo-jocaagura/jocaagura_domain/actions/runs/43131224163

Este checkpoint prepara la homologación del versionado; todavía no materializa
`2.0.0`, no crea tags y no certifica ni ejecuta publicación real. La versión
actual sigue siendo `1.43.2`. No se debe fusionar hacia `master` antes de completar
la separación y certificación del publisher descritas abajo.

## Referencia canónica y discovery

Referencia congelada: `grupo-jocaagura/jocaagura_domain_core`, rama `develop`,
SHA `f00f35dc36e7a408f245dffc8d447a05061deb17`.
Se revisaron CI_CD.md, prepare_version, prepare_promotion, publish,
release_after_merge y los scripts de política/dispatch y tests asociados.

| Componente | Core | Domain | Acción |
| --- | --- | --- | --- |
| Preparación | pubspec + CHANGELOG atómicos, reintentos idempotentes | solo pubspec en CP3-B | Homologar en este checkpoint |
| Fuente | develop y control de expected head | expected_sha obligatorio | Mantener SHA obligatorio también en dispatch/reusable |
| CI previo a preparar | reusable validate_pr | no se ejecutaba en prepare | Reutilizar CI Flutter completo, read-only |
| Firma | GraphQL createCommitOnBranch, expectedHeadOid | ya certificado en CP3-B | Conservar, actualizar ambos archivos juntos |
| PR CI | Dart puro | Flutter, cobertura >=90%, schemas, dry-run | Conservar los controles adicionales |
| Triggers base | pushes develop/master y PR | pushes de cualquier rama | Alinear pushes a develop/master; conservar PR y dispatch |
| Promoción | minor/major, consolidación de patches | intención major 2.0.0 explícita | Preparar notas; promoción automática posterior |
| Release a master | orquestación, PR oficial y fuente exacta | validación legacy develop a master | Homologación pendiente |
| Publicación | tag inmutable y OIDC, CI completo, no duplicados | push master, condición por actor/mensaje | Reemplazo pendiente; no certificar legacy |
| Seguridad | CodeQL Actions YAML y workflow lint | codeql.txt no ejecutable | Homologación pendiente; actionlint local pasa |
| Permisos | read global, write solo en jobs que mutan/publican | prepare tenía write global | Reducir en preparación |
| Concurrency | preparar serializado; publisher global | prepare serializado, publisher sin grupo | Mantener prepare; publisher pendiente |
| Evidencia previa | CP-0 propia del paquete | no hay CP-0 automatizada de domain | No copiar evidencia del core; certificar domain |

## Protecciones observadas (solo lectura)

- Ruleset master `3408754`, activo: PR, una aprobación, conversaciones según
  configuración, commits firmados, historia lineal y squash; exige el check
  `Validate PR to master` y base actualizada. Se conserva ese nombre.
- Ruleset develop `3408756`, deshabilitado; API de branch protection devuelve 404.
  La ausencia de protección efectiva no equivale a política homologada.
- Ruleset `7940792`, activo para ramas distintas de develop/master: firma y
  prohibición de force push.
- Environment `pub.dev` existe sin protection_rules. Su existencia no demuestra
  autorización OIDC en pub.dev ni aprobación humana del despliegue.
- No se cambiaron rulesets, environments ni credenciales en este checkpoint.

## Preparación de versión (tras integrar este checkpoint)

Los PR ordinarios son read-only: sus labels no modifican versiones ni generan
commits. Mantener una sola sección `## Unreleased` con notas sustanciales.

1. Integrar el checkpoint y validar el SHA de `develop` con CI completo.
2. Preparar notas canónicas UTF-8 Markdown a partir del contenido de Unreleased.
   No incluir encabezados de versión ni otro `## Unreleased` dentro de las notas.
3. Ejecutar `prepare_version.yaml` desde `develop` con inputs:
   `version=2.0.0`, `expected_head=<SHA exacto>` y `changelog_base64=<notas Base64>`.
   Los nombres anteriores `target_version` y `expected_sha` dejan de aplicarse.
4. El workflow exige repositorio/ref/SHA correctos, ejecuta el CI completo,
   comprueba de nuevo develop y construye pubspec + CHANGELOG. Solo entonces
   crea un commit atómico firmado por GitHub mediante expectedHeadOid.
   El payload se construye en disco y curl lo lee desde un archivo: el tamaño
   del CHANGELOG no se transmite como argumento de jq/curl ni como variable de
   entorno. Esto corrige el fallo previo a mutación observado en run 43138945052.
5. Verifica firma, versión, una sección fechada y el hash de las notas.
   Repetir con la misma versión y notas no crea otro commit; entradas incoherentes
   o SHA obsoleto fallan cerradas. Tras una primera preparación, un reintento debe
   autorizar explícitamente el nuevo SHA actual de develop.
6. La fecha del CHANGELOG utiliza America/Bogota (UTC-05:00), en lugar del UTC del
   core. Esta adaptación evita presentar una fecha del día siguiente localmente.
7. Los commits hechos con GITHUB_TOKEN pueden no disparar push CI. Ejecutar y
   revisar la validación manual del SHA materializado; no asumir que la creación
   del commit equivale a CI aprobado.

CI conserva: firmas, policy tests Python, dependencias, rechazo de overrides,
formato, análisis Flutter, tests/cobertura >=90%, npm/AJV y publish dry-run.
El workflow de preparación no publica, no crea tags ni modifica master.
No usar keys externas ni PATs para imitar commits de otra persona.

## Pendientes antes de publicar 2.0.0

- Homologar release validation y publisher con el estándar del core: tag/ref,
  PR oficial develop/master, origen inmutable y versión elegible en pub.dev.
- Configurar/verificar OIDC de este paquete y certificar su primera publicación
  automatizada. La evidencia de CP-0 del core no autoriza este paquete.
- Validar mínimo privilegio, concurrency y ausencia de publishers competidores.
- Alinear protecciones/checks, seguridad y environment con el diseño definitivo.
- Probar contextos inválidos, versión ya publicada y drift de fuente sin subir
  versiones artificiales. Registrar evidencias end-to-end y fail-closed.
- Preparar 2.0.0 con el workflow integrado, validar SHA final, abrir PR oficial
  develop -> master y exigir los controles de release antes de fusionarlo.
- Confirmar publicación real y evidencia final; después el consumidor sustituye
  el pin Git por hosted y repite resolución/análisis/tests.

La certificación publicada de JocaaguraArchetype cubre el código de ec8d831:
https://github.com/grupo-jocaagura/jocaaguraarchetype/blob/01561b2a755bd800d6eced0754c23584c37be32b/doc/workflows/evidence/135/certification-ec8d831.md
Este checkpoint modifica automatización y documentación, no APIs del paquete.
