set -e
eval `luarocks path`
export LUA_PATH="../addonmaker/?.lua;$LUA_PATH"
compgen -G "*test.lua" | while read test; do
  echo "******** $test *******"
  lua $test
done
compgen -G "*_spec.lua" | while read spec; do
  busted $spec
done
luacheck --config ../addonmaker/luacheckrc.lua *.lua
