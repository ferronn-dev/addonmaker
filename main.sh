set -e
BUILD=/tmp/build.ninja.$$
python3 /addonmaker/build.py > $BUILD
if [ "$1" = "clean" ]; then
  rm -rf libs
  ninja -f $BUILD -t clean
else
  ninja -f $BUILD
  if [ "$1" = "release" ]; then
    env GITHUB_TOKEN="$2" sh /addonmaker/release.sh
  fi
fi
