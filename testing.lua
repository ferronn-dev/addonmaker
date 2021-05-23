local lfs = require('lfs')
local loader = require('addonloader')
local tocs = (function()
  local tocs = {}
  for file in lfs.dir('.') do
    if file:find('%.toc$') then
      table.insert(tocs, file)
    end
  end
  return tocs
end)()
return {
  assertEquals = require('luassert').are.same,
  RunTests = function(tests)
    for _, toc in ipairs(tocs) do
      print(toc)
      local failed = 0
      for i, test in ipairs(tests) do
        local state, env, addon = loader(tests.before, toc)
        local success, err = pcall(test, state, nil, addon, env)
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
  end,
}
