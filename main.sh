set -e
python3 /addonmaker/build.py > /tmp/build.ninja
if [ "$1" = "clean" ]; then
  rm -rf libs
  ninja -f /tmp/build.ninja -t clean
else
  ninja -f /tmp/build.ninja
  if [ "$1" = "release" ]; then
    env GITHUB_TOKEN="$2" sh /addonmaker/release.sh
  fi
fi
