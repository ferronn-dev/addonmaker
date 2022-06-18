"""Generates an addon .zip file from a list of toc files."""
import pathlib
import sys
import zipfile

addon = sys.argv[1]
tocs = [pathlib.Path(f) for f in sys.argv[2:]]
tocfiles = [
    line
    for toc in tocs
    for line in toc.read_text().splitlines() if not line.startswith('#')
]
others = [
    f
    for f in ['bindings.xml']
    if pathlib.Path(f).exists()
]

files = sorted(set([str(f) for f in tocs] + tocfiles + others))
with zipfile.ZipFile(f'{addon}.zip', 'w') as zf:
    for f in files:
        zf.write(f, f'{addon}/{f}')
