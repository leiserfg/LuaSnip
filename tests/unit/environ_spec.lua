local helpers = require("test.functional.helpers")(after_each)
local exec_lua = helpers.exec_lua

describe("luasnip.utils.environ", function()
	local function check_not_empty(test_name, namespace_setup, var_name)
		it(test_name, function()
			assert.is_true(
				exec_lua(
					([=[
					local Environ = require("luasnip.utils.environ")
                                        %s
                                        local env = Environ:new()
                                        return env.%s > 0
                                        ]=]):format(namespace_setup, var_name)
				)
			)
		end)
	end

	local function check_empty(test_name, namespace_setup, var_name)
		it(test_name, function()
			assert.is_false(
				exec_lua(
					[=[
					local Environ = require("luasnip.utils.environ")
                                        %s
                                        local env = Environ:new()
                                        return env.%s > 0
                                        ]=],
                                        namespace_setup,
				        var_name
				)
			)
		end)
	end

	helpers.exec("set rtp+=" .. os.getenv("LUASNIP_SOURCE"))

	check_not_empty("Has builtin namespace var", [[]], "CURRENT_YEAR")
end)
