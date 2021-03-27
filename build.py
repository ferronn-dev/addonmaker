"""Generates a Ninja build file from an addonmaker specification."""
from pathlib import Path
import yaml

cfg = yaml.load(Path('build.yaml').read_text(), Loader=yaml.Loader)

libs = cfg['libs']
sqls = cfg['sql']
addon = cfg['addon']

sqlluas = [str(Path(f).with_suffix('.lua')) for f in sqls]

Path('/tmp/build.ninja').write_text('\n'.join([
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
    *[
        line
        for lib, repo in libs.items()
        for line in [
            f'build libs/{lib} : lib',
            f'  repo = {repo}',
            '',
        ]
    ],
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
