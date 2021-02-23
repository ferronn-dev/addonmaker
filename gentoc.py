"""Generates a .toc file from build.yaml and downloaded libraries."""
from pathlib import Path
from lxml import etree
from toposort import toposort_flatten
import yaml

cfg = yaml.load(Path('build.yaml').read_text(), Loader=yaml.Loader)

libfiles = [
    f'libs/{lib}/{luafile}'
    for lib in cfg['libs']
    for toc in Path(f'libs/{lib}').glob('*.toc')
    for line in [
        line.replace('\\', '/')
        for line in Path(toc).read_text().splitlines()
    ] if line and not line.startswith('## ')
    for luafile in (
        [line] if line.endswith('.lua') else
        [Path(Path(line).parent, s.replace('\\', '/')) for s in filter(None, [
            script.get('file')
            for script in etree.parse(f'libs/{lib}/{line}').getroot().iter()
        ])] if line.endswith('.xml') else []
    )
]
files = libfiles + toposort_flatten({
    k: set(v)
    for k, v in {
        **{ f: [] for f in cfg['roots'] },
        **cfg['deps'],
    }.items()
})

Path(f'{cfg["addon"]}.toc').write_text('\r\n'.join([
    *[f'## {k}: {v}' for k, v in cfg['toc'].items()],
    *files,
    '',
]))

Path('/tmp/build.dd').write_text('\n'.join([
    'ninja_dyndep_version = 1',
    f'build {cfg["addon"]}.zip: dyndep | ' + ' '.join(files),
    '  restat = 1',
    '',
]))
