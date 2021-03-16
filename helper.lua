local busted = require('busted')
busted.subscribe({'test', 'start'}, function()
  local state, env, addon = require('addonloader')()
  _G.wow = {
    state = state,
    addon = addon,
    env = env,
  }
end)
