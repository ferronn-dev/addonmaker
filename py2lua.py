from collections import abc
import numbers

def luaquote(s):
    replacements = [
        ('\\', '\\\\'),
        ('\'', '\\\''),
        ('\n', '\\n'),
    ]
    for old, new in replacements:
        s = s.replace(old, new)
    return '\'' + s + '\''

def py2lua(x, n=0):
    return (
        luaquote(x) if isinstance(x, str) else
        ('true' if x else 'false') if isinstance(x, bool) else
        str(x) if isinstance(x, numbers.Number) else
        py2lua(x._asdict(), n) if hasattr(x, '_asdict') else
        ('{\n' + ''.join([
            f'{" "*(n+2)}[{py2lua(k, n+2)}] = {py2lua(v, n+2)},\n'
            for k, v in x.items() if v is not None
        ]) + f'{" "*n}}}') if isinstance(x, abc.Mapping) else
        ('{\n' + ''.join([
            f'{" "*(n+2)}{py2lua(v, n+2)},\n' for v in x
        ]) + f'{" "*n}}}') if isinstance(x, abc.Iterable) else
        'nil')

def addon_file(vs):
    return '\n'.join([
        '-- luacheck: max_line_length 1000',
        'local _, G = ...',
        *[f'G.{k} = {py2lua(v)}' for k, v in vs.items()],
        ''
    ])
