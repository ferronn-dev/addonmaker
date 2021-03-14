"""Converts python datatypes into Lua strings."""
from collections import abc
import numbers

def luaquote(string):
    replacements = [
        ('\\', '\\\\'),
        ('\'', '\\\''),
        ('\n', '\\n'),
    ]
    for old, new in replacements:
        string = string.replace(old, new)
    return '\'' + string + '\''

def py2lua(value, indent=''):
    recurse = lambda x: py2lua(x, indent + '  ')
    return (
        luaquote(value) if isinstance(value, str) else
        ('true' if value else 'false') if isinstance(value, bool) else
        str(value) if isinstance(value, numbers.Number) else
        py2lua(value._asdict(), indent) if hasattr(value, '_asdict') else
        ('{\n' + ''.join([
            f'{indent}  [{recurse(k)}] = {recurse(v)},\n'
            for k, v in value.items() if v is not None
        ]) + f'{indent}}}') if isinstance(value, abc.Mapping) else
        ('{\n' + ''.join([
            f'{indent}  {recurse(v)},\n' for v in value
        ]) + f'{indent}}}') if isinstance(value, abc.Iterable) or hasattr(value, '__getitem__') else
        'nil')

def addon_file(dbdict):
    return '\n'.join([
        '-- luacheck: max_line_length 1000',
        'local _, G = ...',
        *[f'G.{k} = {py2lua(v)}' for k, v in dbdict.items()],
        ''
    ])
