"""Generates an addon .zip file from a list of toc files."""
import pathlib
import sys
import zipfile

def genzip():
    """Writes an addon zip file."""
    addon = sys.argv[1]
    tocs = [pathlib.Path(f) for f in sys.argv[2:]]
    tocfiles = [
        line
        for toc in tocs
        for line in toc.read_text().splitlines() if not line.startswith('#')
    ]
    others = [
        file
        for file in ['bindings.xml']
        if pathlib.Path(file).exists()
    ]

    files = sorted(set([str(f) for f in tocs] + tocfiles + others))
    with zipfile.ZipFile(f'{addon}.zip', 'w') as zfile:
        for file in files:
            zfile.write(file, f'{addon}/{file}')

if __name__ == "__main__":
    genzip()
