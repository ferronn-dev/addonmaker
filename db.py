"""Runs SQL queries from build.yaml specs and outputs Lua."""
import itertools
from pathlib import Path
import sys
import pygtrie
from google.cloud import bigquery
import py2lua

versions = [
  (2, '1_13_7_38631', 'petopia'),
  (5, '2_5_1_38644', 'petopia_bc'),
]

def run_bigqueries(query, dbc, petopia):
    """Runs the given SQL on BigQuery and outputs all SELECTs performed."""
    query = query.replace('petopia.', petopia + '.')
    client = bigquery.Client('wow-ferronn-dev')
    script = client.query(
        job_config=bigquery.job.QueryJobConfig(
            default_dataset=f'wow-ferronn-dev.wow_tools_dbc_{dbc}_enUS',
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

def main():
    """Runs bigqueries and writes results."""
    sql, stublib, tables = sys.argv[1], sys.argv[2], sys.argv[3:]

    sqlpath = Path(sql)
    sqltext = sqlpath.read_text()

    def make_fields(dbc, petopia):
        trie = pygtrie.StringTrie(separator='.')
        for path, data in zip(tables, parse(list(run_bigqueries(sqltext, dbc, petopia)))):
            trie[path] = data
        return trie.traverse(
            lambda _, path, kids, value=None:
            (lambda merged=value if value else { k: v for kid in kids for k, v in kid.items() }:
            { path[-1]: merged } if path else merged)())  # pylint: disable=undefined-loop-variable

    tuples = [
        (key, (project, value))
        for project, dbc, petopia in versions
        for key, value in make_fields(dbc, petopia).items()
    ]
    out = {
        key : dict(v[1] for v in values)
        for key, values in itertools.groupby(sorted(tuples), lambda x: x[0])
    }

    with open(sqlpath.with_suffix('.lua'), 'w') as outfile:
        outfile.write(py2lua.addon_file(out, stublib))

main()
