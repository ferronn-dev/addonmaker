"""Generates a Ninja build file from an addonmaker specification."""
from pathlib import Path
import yaml

cfg = yaml.load(Path('build.yaml').read_text(), Loader=yaml.Loader)

Path('/tmp/build.ninja').write_text('\n'.join([
    'rule git',
    '  command = git clone --recurse-submodules $repo $out',
    '',
    'rule svn',
    '  command = svn checkout $repo $out',
    '',
    'rule sql',
    '  command = env GOOGLE_APPLICATION_CREDENTIALS=/addonmaker/creds.json ' +
        'python3 /addonmaker/db.py',
    '',
    'rule toc',
    '  command = python3 /addonmaker/gentoc.py',
    '',
    'rule zip',
    '  command = sh /addonmaker/runtests.sh && python3 /addonmaker/genzip.py $in',
    '',
    *[
        line
        for lib, repo in cfg['libs'].items()
        for line in [
            f'build libs/{lib}: ' + 'svn' if '/trunk' in repo else 'git',
            f'  repo = {repo}',
            '',
        ]
    ],
    (''.join([
        'build | ',
        ' '.join([str(Path(f).with_suffix('.lua')) for f in cfg['sql']]),
        ': sql | ',
        ' '.join(cfg['sql'].keys()),
    ])),
    '',
    (f'build | {cfg["addon"]}.toc /tmp/build.dd: toc | ' +
        ' '.join([f'libs/{lib}' for lib in cfg['libs'].keys()])),
    '',
    f'build | {cfg["addon"]}.zip: zip {cfg["addon"]}.toc || /tmp/build.dd',
    '  dyndep = /tmp/build.dd',
    '',
]))
