return {
  assertEquals = require('luassert').are.same,
  RunTests = function(tests)
    local failed = 0
    for i, test in ipairs(tests) do
      local state, env, addon = require('addonloader')(tests.before)
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
  end,
}
