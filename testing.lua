local lfs = require('lfs')
local wowapi = require('wow')

local function assertEquals(want, got, ctx)
  ctx = ctx or '_'
  assert(
      type(want) == type(got),
      'in ' .. ctx .. '\nwant ' .. type(want) .. '\ngot ' .. type(got))
  if type(want) == 'table' then
    local wantKeys, gotKeys = {}, {}
    for k, _ in pairs(want) do
      table.insert(wantKeys, k)
    end
    for k, _ in pairs(got) do
      table.insert(gotKeys, k)
    end
    assertEquals(#wantKeys, #gotKeys, '#tablekeys ' .. ctx)
    table.sort(wantKeys)
    table.sort(gotKeys)
    for i = 1, #wantKeys do
      assertEquals(wantKeys[i], gotKeys[i], 'tablekeys ' .. ctx)
    end
    for i = 1, #wantKeys do
      local key = wantKeys[i]
      assertEquals(want[key], got[key], 'table[' .. key .. '] ' .. ctx)
    end
  else
    assert(want == got, 'in ' .. ctx .. '\nwant ' .. tostring(want) .. '\ngot ' .. tostring(got))
  end
end

local function RunTests(tests)
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
      local f = assert(io.open(line, "r"))
      table.insert(files, { name = line, content = f:read('*all') })
      f:close()
    end
  end
  local failed = 0
  for i, test in ipairs(tests) do
    local api, state = wowapi()
    local env = {}
    for k, v in pairs(_G) do
      env[k] = v
    end
    for k, v in pairs(api) do
      env[k] = v
    end
    env['_G'] = env
    env['print'] = function(str) state.printed = str end
    local addonEnv = {}
    for _, file in ipairs(files) do
      assert(load(file.content, file.name, 't', env))('moo', addonEnv)
    end
    local success, err = pcall(test, state, api, addonEnv, env)
    if not success then
      failed = failed + 1
      print(i .. ': ' .. err)
    end
  end
  local passed = #tests - failed
  print('passed ' .. passed .. ' of ' .. #tests .. ' tests')
  if failed > 0 then
    os.exit(1)
  end
end

return {
  assertEquals = assertEquals,
  RunTests = RunTests,
}
