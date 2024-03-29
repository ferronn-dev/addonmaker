"""Converts python datatypes into Lua strings."""
from collections import abc
import numbers

def luaquote(string):
    """Quotes a python string as a Lua string literal."""
    replacements = [
        ('\\', '\\\\'),
        ('\'', '\\\''),
        ('\n', '\\n'),
    ]
    for old, new in replacements:
        string = string.replace(old, new)
    return '\'' + string + '\''

def py2lua(value, indent=''):
    """Converts a python datatype into a string containing a Lua literal."""
    def recurse(val):
        return py2lua(val, indent + '  ')
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

def addon_file(dbdict, stublib=None):
    """Converts a name-value dictionary into a WoW addon file with a literal dictionary."""
    if stublib:
        return '\n'.join([
            '-- luacheck: max_line_length 1000',
            *[f'Mixin(LibStub:NewLibrary({luaquote(stublib + "-" + k)}, 1), ' +
                f'({py2lua(v)})[WOW_PROJECT_ID])'
              for k, v in dbdict.items()],
            ''
        ])
    return '\n'.join([
        '-- luacheck: max_line_length 1000',
        'local _, G = ...',
        *[f'G.{k} = ({py2lua(v)})[WOW_PROJECT_ID]' for k, v in dbdict.items()],
        ''
    ])
