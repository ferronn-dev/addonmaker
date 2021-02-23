import argparse
from lxml import etree
from pathlib import Path
from toposort import toposort_flatten
import subprocess
import sys
import yaml
import zipfile

def filelist(config):
    for lib, repo in config['libs'].items():
        if not Path(f'libs/{lib}').is_dir():
            subprocess.run(
                args=(
                    ['svn', 'checkout', repo, f'libs/{lib}'] if '/trunk' in repo else
                    ['git', 'clone', '--recurse-submodules', repo, f'libs/{lib}']),
                check=True,
                stderr=sys.stderr,
                stdout=sys.stderr)
    libfiles = [
        f'libs/{lib}/{luafile}'
        for lib in config['libs']
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
    return libfiles + toposort_flatten({
        k: set(v)
        for k, v in {
            **{ f: [] for f in config['roots'] },
            **config['deps'],
        }.items()
    })

def toc(config):
    with open(f'{config["addon"]}.toc', 'w') as f:
        f.writelines([
            f'{line}\r\n'
            for line in [
                *[f'## {k}: {v}' for k, v in config['toc'].items()],
                *filelist(config)]])

def zip_(config):
    addon = config['addon']
    with zipfile.ZipFile(f'{addon}.zip', 'w') as zf:
        for f in filelist(config) + [f'{addon}.toc']:
            zf.write(f, f'{addon}/{f}')

commands = {
    'toc': toc,
    'zip': zip_,
}

def args():
    parser = argparse.ArgumentParser()
    parser.add_argument('cmd', choices=commands.keys())
    return parser.parse_args()

args = args()
commands[args.cmd](yaml.load(Path('build.yaml').read_text(), Loader=yaml.Loader))
