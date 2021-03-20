"""Generates a Ninja build file from an addonmaker specification."""
from pathlib import Path
import yaml

cfg = yaml.load(Path('build.yaml').read_text(), Loader=yaml.Loader)
sqlluas = [str(Path(f).with_suffix('.lua')) for f in cfg['sql']]

Path('/tmp/build.ninja').write_text('\n'.join([
    'rule git',
    '  command = git clone --recurse-submodules $repo $out',
    '',
    'rule svn',
    '  command = svn checkout $repo $out',
    '',
    'rule sql',
    '  command = env GOOGLE_APPLICATION_CREDENTIALS=/addonmaker/creds.json ' +
        'python3 /addonmaker/db.py $sql $tables',
    '',
    'rule toc',
    '  command = python3 /addonmaker/gentoc.py',
    '',
    'rule zip',
    '  command = bash /addonmaker/runtests.sh && python3 /addonmaker/genzip.py $in',
    '',
    *[
        line
        for lib, repo in cfg['libs'].items()
        for line in [
            f'build libs/{lib} : ' + ('svn' if '/trunk' in repo else 'git'),
            f'  repo = {repo}',
            '',
        ]
    ],
    *[
        line
        for sql, tables in cfg['sql'].items()
        for line in [
            f'build {Path(sql).with_suffix(".lua")} : sql',
            f'  sql = {sql}',
            f'  tables = {" ".join(tables)}',
            '',
        ]
    ],
    (f'build | {cfg["addon"]}.toc /tmp/build.dd : toc | ' +
        ' '.join([f'libs/{lib}' for lib in cfg['libs'].keys()])),
    '',
    f'build | {cfg["addon"]}.zip: ' +
        f'zip {cfg["addon"]}.toc | ' + ' '.join(sqlluas) + ' || /tmp/build.dd',
    '  dyndep = /tmp/build.dd',
    '',
]))
