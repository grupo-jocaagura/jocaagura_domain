"""Read-only source inventory against the resolved core package; no source edits."""
import csv
import difflib
import json
import re
from pathlib import Path
from urllib.parse import unquote, urlparse

ROOT = Path(__file__).resolve().parents[1]
config = json.loads((ROOT / '.dart_tool/package_config.json').read_text())
uri = next(p['rootUri'] for p in config['packages'] if p['name'] == 'jocaagura_domain_core')
path = unquote(urlparse(uri).path).lstrip('/')
CORE = Path(path) / 'lib'
OUT = ROOT / 'doc/migration'
OUT.mkdir(parents=True, exist_ok=True)

def clean(s):
    s = re.sub(r'/\*.*?\*/', '', s, flags=re.S)
    s = re.sub(r'^\s*//.*$', '', s, flags=re.M)
    s = re.sub(r"^\s*part of .*?;", '', s, flags=re.M)
    s = re.sub(r'^\s*@immutable\s*$', '', s, flags=re.M)
    return s

def symbols(s):
    # Column-zero declarations only: excludes members and documentation examples.
    s = clean(s)
    pattern = r'^(?:(?:abstract|base|interface|final|sealed|mixin)\s+)*(?:class|enum|mixin|typedef|extension(?:\s+type)?)\s+([A-Za-z]\w*)'
    names = re.findall(pattern, s, re.M)
    names += re.findall(r'^(?:const|final)\s+(?:[\w<>?, ]+\s+)?(\w+)\s*=', s, re.M)
    return sorted(set(n for n in names if not n.startswith('_')))

def norm(s):
    return re.sub(r'\s+', '', clean(s))

def members(s):
    # Diagnostic candidate delta, not a Dart API compatibility proof.
    s = clean(s)
    return set(re.findall(r'\b(?:factory|get|set)\s+(\w+(?:\.\w+)?)|\b(\w+)\s*\(', s))

entry = (ROOT / 'lib/jocaagura_domain.dart').read_text(encoding='utf-8')
parts = re.findall(r"^part '([^']+)';", entry, re.M)
exports = re.findall(r"^export '([^']+)';", entry, re.M)
parts += [p for p in exports if not p.startswith('package:')]
core_entry = (CORE / 'jocaagura_domain_models.dart').read_text(encoding='utf-8')
core_parts = re.findall(r"^part '([^']+)';", core_entry, re.M)
by_symbol = {}
for name in symbols(core_entry):
    by_symbol[name] = 'jocaagura_domain_models.dart'
for rel in core_parts:
    p = CORE / rel
    for name in symbols(p.read_text(encoding='utf-8')):
        by_symbol[name] = rel
for p in (CORE / 'src').glob('*.dart'):
    for name in symbols(p.read_text(encoding='utf-8')):
        by_symbol.setdefault(name, p.relative_to(CORE).as_posix())

rows = []
for rel in ['jocaagura_domain.dart'] + parts:
    text = (ROOT / 'lib' / rel).read_text(encoding='utf-8')
    names = symbols(text)
    overlaps = [n for n in names if n in by_symbol]
    peers = sorted(set(by_symbol[n] for n in overlaps))
    same = len(peers) == 1 and norm(text) == norm((CORE / peers[0]).read_text(encoding='utf-8'))
    special = rel in ['domain/model_vector.dart', 'domain/ui/model_main_menu_model.dart']
    mixed = rel in ['jocaagura_domain.dart', 'domain/usecases/databases_crud/databases_crud_usecases.dart']
    action = ('ADAPTAR_MIXTO' if mixed else 'ADAPTAR_FLUTTER' if special else 'ELIMINAR_TRAS_VALIDAR' if overlaps else 'CONSERVAR')
    reason = ('Separar conversiones/render/callbacks de datos canonicos' if special else
              'Fuente normalizada identica; sustituir part por export' if same else
              'Hay simbolos canonicos; revisar diferencias de API, JSON, igualdad y defaults antes de retirar' if overlaps else
              'Sin equivalente nominal detectado en los entrypoints core/modelos; conservar responsabilidad actual')
    rows.append(dict(domain='lib/' + rel, symbols='; '.join(names), core='; '.join(peers),
                     overlap='; '.join(overlaps), local_only='; '.join(n for n in names if n not in by_symbol),
                     action=action, normalized_equal=same, reason=reason))

with (OUT / 'core-1.3.0-files.csv').open('w', newline='', encoding='utf-8-sig') as f:
    writer = csv.DictWriter(f, fieldnames=rows[0].keys())
    writer.writeheader()
    writer.writerows(rows)

with (OUT / 'core-1.3.0-symbols.csv').open('w', newline='', encoding='utf-8-sig') as f:
    writer = csv.writer(f)
    writer.writerow(['symbol', 'domain_file', 'core_file', 'action'])
    for row in rows:
        for name in filter(None, row['symbols'].split('; ')):
            writer.writerow([name, row['domain'], by_symbol.get(name, ''), row['action'] if name in by_symbol else 'CONSERVAR'])

with (OUT / 'core-1.3.0-differences.txt').open('w', encoding='utf-8') as f:
    for row in rows:
        if row['overlap'] and not row['normalized_equal']:
            f.write('\n=== ' + row['domain'] + ' [' + row['action'] + '] ===\n')
            if ';' in row['core']:
                f.write('Mixed library: inspect Model/defaultErrorItem separately; do not delete barrel.\n')
                continue
            a = clean((ROOT / row['domain']).read_text(encoding='utf-8'))
            b = clean((CORE / row['core']).read_text(encoding='utf-8'))
            a = [s.strip() for s in a.splitlines() if s.strip()]
            b = [s.strip() for s in b.splitlines() if s.strip()]
            f.writelines(s + '\n' for s in difflib.unified_diff(a, b, fromfile=row['domain'], tofile='core/' + row['core'], n=2))

summary = {a: sum(r['action'] == a for r in rows) for a in sorted(set(r['action'] for r in rows))}
print(json.dumps(summary))
print('Normalized identical:', sum(r['normalized_equal'] for r in rows))
for r in rows:
    if r['overlap'] and (r['local_only'] or r['normalized_equal']):
        print(r['domain'], 'identical=' + str(r['normalized_equal']), 'local_only=' + r['local_only'])
