set -e
python3 /addonmaker/build.py toc
for test in *test.lua; do
  echo "******** $test *******"
  LUA_PATH=/addonmaker/?.lua lua $test
done
luacheck *.lua
python3 /addonmaker/build.py zip
