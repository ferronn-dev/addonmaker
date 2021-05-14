"""Generates an addon .zip file from a list of toc files."""
import pathlib
import sys
import zipfile

addon = sys.argv[1]
tocs = [pathlib.Path(f) for f in sys.argv[2:]]

files = sorted(set([str(f) for f in tocs] + [
    line
    for toc in tocs
    for line in toc.read_text().splitlines() if not line.startswith('#')
]))
with zipfile.ZipFile(f'{addon}.zip', 'w') as zf:
    for f in files:
        zf.write(f, f'{addon}/{f}')
