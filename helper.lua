local busted = require('busted')
local loader = require('addonloader')
busted.subscribe({'test', 'start'}, function()
  local state, env, addon = loader()
  _G.wow = {
    state = state,
    addon = addon,
    env = env,
  }
end)
