print([[-- luacheck: globals files globals read_globals std
files['*_spec.lua'] = {
  std = '+busted',
}
std = 'min'
read_globals = {]])

local symbols = {
  'ChatThrottleLib',
  'LibStub',
  'setfenv',
}
for k in pairs(require('wow')({})) do
  if k ~= 'StaticPopupDialogs' then
    table.insert(symbols, k)
  end
end
table.sort(symbols)
for _, k in ipairs(symbols) do
  print("  '" .. k .. "',")
end

print([[}
globals = {
  'SlashCmdList',
  'StaticPopupDialogs',
}]])
