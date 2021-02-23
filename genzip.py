"""Generates an addon .zip file from its .toc."""
import pathlib
import sys
import zipfile

toc = pathlib.Path(sys.argv[1])
files = [toc] + [
    line
    for line in toc.read_text().splitlines()
    if not line.startswith('#')
]
with zipfile.ZipFile(toc.with_suffix('.zip'), 'w') as zf:
    for f in files:
        zf.write(f, f'{toc.stem}/{f}')
