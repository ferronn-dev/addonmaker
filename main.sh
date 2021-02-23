set -e
python3 ../addonmaker/build.py
ninja -f /tmp/build.ninja "$@"
