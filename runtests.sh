set -e
eval `luarocks path`
export LUA_PATH="/addonmaker/?.lua;$LUA_PATH"
function luas { find -name "$1" -not -path './libs/*' -not -path './addonmaker/*' ; }
luas '*.lua' | xargs luacheck -q --config /addonmaker/luacheckrc.lua
luas '*test.lua' | while read test; do
  echo "******** $test *******"
  lua $test
done
luas '*_spec.lua' | xargs -r busted -v
