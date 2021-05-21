local lfs = require('lfs')
local wowapi = require('wow')
local function justClassicToc()
  local tocs = {}
  for file in lfs.dir('.') do
    if file:find('%-Classic.toc$') then
      table.insert(tocs, file)
    end
  end
  assert(#tocs == 1, 'expecting exactly one toc file')
  return tocs[1]
end
local function files(toc)
  local result = {}
  for line in io.lines(toc) do
    line = line:match('^%s*(.-)%s*$'):gsub('\\', '/')
    if line ~= '' and line:sub(1, 2) ~= '##' then
      local f = assert(io.open(line, "rb"))
      local content = f:read('*all')
      f:close()
      if content:sub(1, 3) == '\239\187\191' then
        content = content:sub(4)
      end
      table.insert(result, assert(loadstring(content)))
    end
  end
  return result
end
return function(before, tocarg)
  local toc = tocarg or justClassicToc()
  local env, state = wowapi()
  if before then
    before(state)
  end
  for k, v in pairs(_G) do
    env[k] = v
  end
  env.table.unpack = nil
  env['_G'] = env
  env['print'] = function(str) state.printed = state.printed .. str .. '\n' end
  env['WOW_PROJECT_ID'] = (function()
    if toc:find('%-Classic.toc$') then
      return 2
    elseif toc:find('%-BCC.toc$') then
      return 5
    elseif toc:find('%-Mainline.toc$') then
      return 1
    else
      error('invalid toc name found')
    end
  end)
  local addon = {}
  for _, file in ipairs(files(toc)) do
    setfenv(file, env)('moo', addon)
  end
  return state, env, addon
end
