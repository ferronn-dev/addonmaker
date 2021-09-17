"""Generates a Ninja build file from an addonmaker specification."""
import sys
from pathlib import Path
import yaml

buildyaml = Path('build.yaml')
pkgmeta = Path('.pkgmeta')

if pkgmeta.exists() and not buildyaml.exists():
    cfg = yaml.load(pkgmeta.read_text(encoding='utf8').replace('\t', ' '), Loader=yaml.Loader)
    libs = cfg['externals'] if 'externals' in cfg else {}
    print('\n'.join([
        'rule lib',
        '  command = sh /addonmaker/getlib.sh $repo $out',
        '',
        *[f'build {lib} : lib\n  repo = {repo["url"]}' for lib, repo in libs.items()],
    ]))
    sys.exit(0)

if not buildyaml.exists():
    raise Exception('missing build.yaml or .pkgmeta')

cfg = yaml.load(buildyaml.read_text(encoding='utf8'), Loader=yaml.Loader)
versions = cfg['versions'] if 'versions' in cfg else {}
libs = cfg['libs'] if 'libs' in cfg else {}
sqls = cfg['sql'] if 'sql' in cfg else {}
addon = cfg['addon']
stublib = addon if 'libstub' in cfg else ''
sqlluas = [str(Path(f).with_suffix('.lua')) for f in sqls]

if not versions:
    raise Exception('missing versions')
tocs = [f'{addon}-{version}.toc' for version in versions]

print('\n'.join([
    'rule lib',
    '  command = sh /addonmaker/getlib.sh $repo $out',
    '',
    'rule sql',
    '  command = env GOOGLE_APPLICATION_CREDENTIALS=/addonmaker/creds.json ' +
        f'python3 /addonmaker/db.py $in "{stublib}" $tables',
    '',
    'rule toc',
    '  command = python3 /addonmaker/gentoc.py',
    '',
    'rule zip',
    f'  command = bash /addonmaker/runtests.sh && python3 /addonmaker/genzip.py {addon} $in',
    '',
    *[f'build libs/{lib} : lib\n  repo = {repo}' for lib, repo in libs.items()],
    *[
        line
        for sql, tables in sqls.items()
        for line in [
            f'build {Path(sql).with_suffix(".lua")} : sql {sql}',
            f'  tables = {" ".join(tables)}',
            '',
        ]
    ],
    (f'build {" ".join(tocs)} | /tmp/build.dd : toc | ' +
        ' '.join([f'libs/{lib}' for lib in libs.keys()])),
    '',
    f'build {addon}.zip: ' +
        f'zip {" ".join(tocs)} | ' + ' '.join(sqlluas) + ' || /tmp/build.dd',
    '  dyndep = /tmp/build.dd',
    '',
]))
