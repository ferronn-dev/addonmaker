local toc = unpack(arg)
print(toc)
local busted = require('busted')
local loader = require('addonloader')
busted.subscribe({'test', 'start'}, function()
  local state, env, addon = loader(nil, toc)
  _G.wow = {
    state = state,
    addon = addon,
    env = env,
  }
end)
