set -e
python3 /addonmaker/build.py toc
GOOGLE_APPLICATION_CREDENTIALS=/addonmaker/creds.json python3 /addonmaker/db.py
for test in *test.lua; do
  echo "******** $test *******"
  LUA_PATH=/addonmaker/?.lua lua $test
done
luacheck --config /addonmaker/luacheckrc.lua *.lua
python3 /addonmaker/build.py zip
