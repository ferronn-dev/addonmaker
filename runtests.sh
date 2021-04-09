set -e
eval `luarocks path`
export LUA_PATH="/addonmaker/?.lua;$LUA_PATH"
luacheck -q --config /addonmaker/luacheckrc.lua *.lua
compgen -G "*test.lua" | while read test; do
  echo "******** $test *******"
  lua $test
done
compgen -G "*_spec.lua" | xargs -r busted --helper=/addonmaker/helper.lua
