from collections import abc
from pathlib import Path
import pygtrie
import yaml
from google.cloud import bigquery
import py2lua

def bq(query):
    client = bigquery.Client('wow-ferronn-dev')
    script = client.query(
        job_config=bigquery.job.QueryJobConfig(
            default_dataset='wow-ferronn-dev.wow_tools_dbc_1_13_6_36935_enUS',
            use_legacy_sql=False),
        query=query)
    result = script.result()
    kids = [
        job for job in sorted(
            client.list_jobs(parent_job=script.job_id),
            key=lambda j: int(j.job_id.split('_')[-1]))
        if job.statement_type == 'SELECT']
    return kids if kids else [result]

def is_scalar(x):
    return isinstance(x, str) or isinstance(x, int)

def maybe_dict(xs):
    if xs and isinstance(xs[0], list) and len(xs[0]) == 2 and not is_scalar(xs[0][1]):
        return {
            k: (v[0] if len(v) == 1 and is_scalar(v[0]) else v)
            for k, v in xs
        }
    else:
        return xs

def dunno(data):
    raise Exception('no idea what to do with a value of type ' + str(type(data)))

def parse(data):
    return (
        None
        if data is None
        else data
        if is_scalar(data)
        else parse(data.values())
        if hasattr(data, 'values')
        else maybe_dict([parse(d) for d in data])
        if hasattr(data, '__getitem__') or hasattr(data, '__iter__')
        else dunno(data))

for sql, ts in yaml.load(Path('build.yaml').read_text(), Loader=yaml.Loader)['sql'].items():
    sqlpath = Path(sql)
    trie = pygtrie.StringTrie(separator='.')
    for path, job in zip(ts, bq(sqlpath.read_text())):
        trie[path] = parse(list(job))
    data = trie.traverse(
        lambda _, path, kids, value=None:
        (lambda merged=value if value else { k: v for kid in kids for k, v in kid.items() }:
        { path[-1]: merged } if path else merged)()
    )
    with open(sqlpath.with_suffix('.lua'), 'w') as f:
        f.write(py2lua.addon_file(data))
