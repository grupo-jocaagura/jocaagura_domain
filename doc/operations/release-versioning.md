## 🛠️ Publicación y Versionamiento

### Commit firmado
Usamos GPG para firmar todos los commits y garantizar trazabilidad.

1. Generar la clave (solo la primera vez):
   ```bash
   gpg --full-generate-key
    ```

2. Asociar la clave a Git (una sola vez):
   ```bash
   git config --global user.signingkey <KEY_ID>
   ```
3. Crear commits firmados (se te pedirá tu passphrase):
   ```bash
   git commit -S -m "feat(@username): add new password checker (#123)"
   ```
4. Verificar la firma:
   ```bash
   git log --show-signature
   ```

### Etiquetado de PRs
Para automatizar el bump de versión, aplicamos labels en GitHub: `major`, `minor` o `patch`.
* **Título de PR**: debe arrancar con un prefijo semántico, autor y referencia al issue:

  ```
  feat(@username): add new password checker (#123)
  ```
* **Labels**:
  * `major` → bump de versión **mayor**
  * `minor` → bump de versión **menor**
  * `patch` → bump de **parche**

### Actualización automática de `pubspec.yaml`
La Action `validate_pr.yaml` detecta el label y actualiza la versión en `pubspec.yaml`:
# .github/workflows/validate_pr.yaml (fragmento relevante)
```yaml
- name: Bump version
  run: |
    CURRENT_VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
    LABELS=$(gh pr view ${{ github.event.pull_request.number }} --json labels --jq '.labels[].name')
    if echo "$LABELS" | grep -q "major"; then
      UPDATED_VERSION=$(echo $CURRENT_VERSION | awk -F. '{$1+=1; $2=0; $3=0}1' OFS=".")
    elif echo "$LABELS" | grep -q "minor"; then
      UPDATED_VERSION=$(echo $CURRENT_VERSION | awk -F. '{$2+=1; $3=0}1' OFS=".")
    elif echo "$LABELS" | grep -q "patch"; then
      UPDATED_VERSION=$(echo $CURRENT_VERSION | awk -F. '{$3+=1}1' OFS=".")
    else
      echo "❌ No version label found. Please add 'major', 'minor', or 'patch'."
      exit 1
    fi
    sed -i "s/^version:.*/version: $UPDATED_VERSION/" pubspec.yaml
    echo "Updated version: $UPDATED_VERSION"
```

**Ejemplo de diff tras un bump **\`\`** (1.20.0 → 1.21.0):**

```diff
-version: 1.20.0
+version: 1.21.0
```

### Generación automática de `CHANGELOG.md`
Seguimos [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

```markdown
### [1.21.0] - 2025-07-09
- Se crea la clase `FakeServiceHttp` para simular el comportamiento de un servicio HTTP en pruebas unitarias.
- Se actualiza el README para incluir ejemplos de uso de las clases `FakeServiceHttp`, `FakeServiceSesion`, `FakeServiceWsDatabase`, `FakeServiceGeolocation`, `FakeServiceGyroscope`, `FakeServiceNotifications`, `FakeServiceConnectivity` y `FakeServicePreferences`.
```

### Flujo `develop` → `master`

1. Abrir un \*\*issue de actualización de \*\*\`\`, indicando el bump deseado (`major`/`minor`/`patch`).
2. Crear un PR de `maintain-branch` a `develop` con la version propuesta
3. Crear un PR **directo** de `develop` a `master`, mencionando el issue para cierre automático.
4. El PR **no** ejecuta bump: utiliza la versión que ya venía en `develop`.
5. Tras pasar las validaciones automáticas, se fusiona mediante **auto-merge**.
6. (Opcional) Publicar en pub.dev si no se dispara automáticamente.

**NOTA:** El proximo issue debe incluir una actualizacion de `master` obligatoria para que quede en `develope` alineado.

### Creación de tag & publicación

El desarrollador, tras el merge, crea el tag semántico y lo envía al repo:

```bash
git tag -a v1.21.0 -m "Release v1.21.0"
git push origin v1.21.0
```

La publicación en **pub.dev** se dispara automáticamente o puede iniciarse manualmente.

### Badges

Añade en el encabezado del README:

```markdown
![CI](https://img.shields.io/github/actions/workflow/status/grupo-jocaagura/jocaagura_domain/validate_pr.yaml?branch=develop)
![Coverage](https://img.shields.io/codecov/c/github/grupo-jocaagura/jocaagura_domain)
![Pub](https://img.shields.io/pub/v/jocaagura_domain)
```

