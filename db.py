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

for sql, ts in yaml.load(Path('build.yaml').read_text(), Loader=yaml.Loader)['sql'].items():
    sqlpath = Path(sql)
    trie = pygtrie.StringTrie(separator='.')
    for path, job in zip(ts, bq(sqlpath.read_text())):
        trie[path] = {
            key: val if isinstance(val, str) else [v.values() for v in val]
            for key, val in job
        }
    data = trie.traverse(
        lambda _, path, kids, value=None:
        (lambda merged=value if value else { k: v for kid in kids for k, v in kid.items() }:
        { path[-1]: merged } if path else merged)()
    )
    with open(sqlpath.with_suffix('.lua'), 'w') as f:
        f.write(py2lua.addon_file(data))
