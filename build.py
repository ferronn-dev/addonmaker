"""Generates a Ninja build file from an addonmaker specification."""
import sys
from pathlib import Path
import yaml

buildyaml = Path('build.yaml')
pkgmeta = Path('.pkgmeta')

if pkgmeta.exists() and not buildyaml.exists():
    cfg = yaml.load(pkgmeta.read_text(), Loader=yaml.Loader)
    libs = cfg['externals'] if 'externals' in cfg else {}
    print('\n'.join([
        'rule lib',
        '  command = sh /addonmaker/getlib.sh $repo $out',
        '',
        *[f'build {lib} : lib\n  repo = {repo}' for lib, repo in libs.items()],
    ]))
    sys.exit(0)

if not buildyaml.exists():
    raise Exception('missing build.yaml or .pkgmeta')

cfg = yaml.load(buildyaml.read_text(), Loader=yaml.Loader)
libs = cfg['libs'] if 'libs' in cfg else {}
sqls = cfg['sql'] if 'sql' in cfg else {}
addon = cfg['addon']
sqlluas = [str(Path(f).with_suffix('.lua')) for f in sqls]

print('\n'.join([
    'rule lib',
    '  command = sh /addonmaker/getlib.sh $repo $out',
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
    *[f'build libs/{lib} : lib\n  repo = {repo}' for lib, repo in libs.items()],
    *[
        line
        for sql, tables in sqls.items()
        for line in [
            f'build {Path(sql).with_suffix(".lua")} : sql',
            f'  sql = {sql}',
            f'  tables = {" ".join(tables)}',
            '',
        ]
    ],
    (f'build | {addon}.toc /tmp/build.dd : toc | ' +
        ' '.join([f'libs/{lib}' for lib in libs.keys()])),
    '',
    f'build | {addon}.zip: ' +
        f'zip {addon}.toc | ' + ' '.join(sqlluas) + ' || /tmp/build.dd',
    '  dyndep = /tmp/build.dd',
    '',
]))
