local lfs = require('lfs')
local wowapi = require('wow')
return function(before)
  local tocs = {}
  for file in lfs.dir('.') do
    if file:find('%.toc$') then
      table.insert(tocs, file)
    end
  end
  assert(#tocs == 1, 'expecting exactly one toc file')
  local files = {}
  for line in io.lines(tocs[1]) do
    line = line:sub(1, -2)
    if line:sub(1, 2) ~= '##' then
      local f = assert(io.open(line, "rb"))
      local content = f:read('*all')
      f:close()
      if content:sub(1, 3) == '\239\187\191' then
        content = content:sub(4)
      end
      table.insert(files, { name = line, content = content })
    end
  end
  local env = {}
  local api, state = wowapi(env)
  if before then
    before(state)
  end
  for k, v in pairs(_G) do
    env[k] = v
  end
  for k, v in pairs(api) do
    env[k] = v
  end
  env['_G'] = env
  env['print'] = function(str) state.printed = state.printed .. str .. '\n' end
  local addon = {}
  for _, file in ipairs(files) do
    assert(load(file.content, file.name, 't', env))('moo', addon)
  end
  return state, env, addon
end
