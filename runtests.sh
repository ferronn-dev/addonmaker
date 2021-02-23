set -e
for test in *test.lua; do
  echo "******** $test *******"
  LUA_PATH=../addonmaker/?.lua lua $test
done
luacheck --config ../addonmaker/luacheckrc.lua *.lua
