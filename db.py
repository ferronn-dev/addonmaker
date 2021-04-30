"""Runs SQL queries from build.yaml specs and outputs Lua."""
from pathlib import Path
import sys
import pygtrie
from google.cloud import bigquery
import py2lua

def run_bigqueries(query):
    """Runs the given SQL on BigQuery and outputs all SELECTs performed."""
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

def is_scalar(value):
    """Returns whether the given value is a scalar."""
    return isinstance(value, (str, int))

def maybe_dict(value):
    """Returns a dictionary if the given SELECT output looks dict-like."""
    if (value
            and isinstance(value[0], list)
            and len(value[0]) == 2
            and not is_scalar(value[0][1])):
        return {
            k: (v[0] if len(v) == 1 and is_scalar(v[0]) else v)
            for k, v in value
        }
    if len(value) == 1 and is_scalar(value[0]):
        return value[0]
    return value

def dunno(data):
    """Raises an exception. Used when parse() cannot deal with the given data."""
    raise Exception('no idea what to do with a value of type ' + str(type(data)))

def parse(data):
    """Converts SELECT output into a python data structure, or throws dunno()."""
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

sql = sys.argv[1]
ts = sys.argv[2:]
sqlpath = Path(sql)
trie = pygtrie.StringTrie(separator='.')
for path, job in zip(ts, run_bigqueries(sqlpath.read_text())):
    trie[path] = parse(list(job))
out = trie.traverse(
    lambda _, path, kids, value=None:
    (lambda merged=value if value else { k: v for kid in kids for k, v in kid.items() }:
    { path[-1]: merged } if path else merged)()  # pylint: disable=undefined-loop-variable
)
with open(sqlpath.with_suffix('.lua'), 'w') as f:
    f.write(py2lua.addon_file(out))
