local wowapi = require('wow')
local function files(toc)
  local result = {}
  for line in io.lines(toc) do
    line = line:match('^%s*(.-)%s*$'):gsub('\\', '/')
    if line ~= '' and line:sub(1, 2) ~= '##' and line:sub(-4) == '.lua' then
      local f = assert(io.open(line, 'rb'))
      local content = f:read('*all')
      f:close()
      if content:sub(1, 3) == '\239\187\191' then
        content = content:sub(4)
      end
      table.insert(result, assert(loadstring(content, line)))
    end
  end
  return result
end
return function(before, toc)
  local env, state = wowapi()
  if before then
    before(state)
  end
  for k, v in pairs(_G) do
    env[k] = v
  end
  env.table.unpack = nil
  env.table.wipe = env.wipe
  env['_G'] = env
  env['print'] = function(str)
    state.printed = state.printed .. str .. '\n'
  end
  env['WOW_PROJECT_ID'] = (function()
    if toc:find('[%-_]Classic.toc$') or toc:find('[%-_]Vanilla.toc$') then
      return env.WOW_PROJECT_CLASSIC
    elseif toc:find('[%-_]BCC.toc$') or toc:find('[%-_]TBC.toc$') then
      return env.WOW_PROJECT_BURNING_CRUSADE_CLASSIC
    elseif toc:find('[%-_]WOTLKC.toc$') or toc:find('[%-_]Wrath.toc$') then
      return env.WOW_PROJECT_BURNING_CRUSADE_CLASSIC
    elseif toc:find('[%-_]Mainline.toc$') then
      return env.WOW_PROJECT_MAINLINE
    else
      error('invalid toc name found')
    end
  end)()
  local addon = {}
  for _, file in ipairs(files(toc)) do
    setfenv(file, env)('moo', addon)
  end
  return state, env, addon
end
