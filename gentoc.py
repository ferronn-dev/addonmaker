"""Generates a .toc file from build.yaml and downloaded libraries."""
from pathlib import Path
from lxml import etree
from toposort import toposort_flatten
import yaml

cfg = yaml.load(Path('build.yaml').read_text(encoding='utf8'), Loader=yaml.Loader)
if 'Interface' in cfg['toc']:
    raise Exception('do not specify Interface in build.yaml toc')

nos = {
  'Mainline': 90205,
  'Wrath': 30400,
  'TBC': 20504,
  'Vanilla': 11403,
}
for v in cfg['versions']:
    if v not in nos:
        raise Exception('bad version')

rawlibfiles = [
    f'libs/{lib}/{luafile}'
    for lib in cfg['libs']
    for toc in Path(f'libs/{lib}').glob('*.toc')
    for line in [
        line.replace('\\', '/')
        for line in Path(toc).read_text(encoding='utf8').splitlines()
    ] if line and not line.startswith('## ')
    for luafile in (
        [line] if line.endswith('.lua') else
        [Path(Path(line).parent, s.replace('\\', '/')) for s in filter(None, [
            script.get('file')
            for script in etree.parse(f'libs/{lib}/{line}').getroot().iter()
        ])] if line.endswith('.xml') else []
    )
]
libfiles = []
for x in rawlibfiles:
    if x not in libfiles:
        libfiles.append(x)
files = libfiles + toposort_flatten({
    k: set(v)
    for k, v in {
        **{ f: [] for f in cfg['roots'] },
        **cfg['deps'],
    }.items()
})

for v in cfg['versions']:
    Path(f'{cfg["addon"]}_{v}.toc').write_text('\r\n'.join([
        f'## Interface: {nos[v]}',
        *[f'## {k}: {v}' for k, v in cfg['toc'].items()],
        *files,
        '',
    ]), encoding='utf8')

Path('/tmp/build.dd').write_text('\n'.join([
    'ninja_dyndep_version = 1',
    f'build {cfg["addon"]}.zip: dyndep | ' + ' '.join(files),
    '  restat = 1',
    '',
]), encoding='utf8')
