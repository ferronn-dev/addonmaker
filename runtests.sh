set -e
eval `luarocks path`
export LUA_PATH="../addonmaker/?.lua;$LUA_PATH"
for test in *test.lua; do
  echo "******** $test *******"
  lua $test
done
luacheck --config ../addonmaker/luacheckrc.lua *.lua
