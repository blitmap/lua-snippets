module('trim-testcase', lunit.testcase, package.seeall)

setup =
	function ()
		require('setup-test')
		require('string-trim')
	end

test_trim_require =
	function ()
		assert_table(trim)
	end

test_ltrim =
	function ()
		local ltrim = trim.ltrim

		assert_function(ltrim)

		local res, stat = nil, nil

		-- '' -> ''
		res, stat = ltrim('')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('', res)
		assert_false(stat)

		-- ' ' -> ''
		res, stat = ltrim(' ')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('', res)
		assert_true(stat)

		-- '#' -> '#'
		res, stat = ltrim('#')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('#', res)
		assert_false(stat)

		-- ' #' -> ' #'
		res, stat = ltrim(' #')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('#', res)
		assert_true(stat)

		-- '# ' -> '# '
		res, stat = ltrim('# ')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('# ', res)
		assert_false(stat)

		-- ' # ' -> '# '
		res, stat = ltrim(' # ')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('# ', res)
		assert_true(stat)
	end

test_rtrim =
	function ()
		local rtrim = trim.rtrim

		assert_function(rtrim)

		local res, stat = nil, nil

		-- '' -> ''
		res, stat = rtrim('')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('', res)
		assert_false(stat)

		-- ' ' -> ''
		res, stat = rtrim(' ')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('', res)
		assert_true(stat)

		-- '#' -> '#'
		res, stat = rtrim('#')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('#', res)
		assert_false(stat)

		-- ' #' -> ' #'
		res, stat = rtrim(' #')
		assert_string(res)
		assert_boolean(stat)
		assert_equal(' #', res)
		assert_false(stat)

		-- '# ' -> '#'
		res, stat = rtrim('# ')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('#', res)
		assert_true(stat)

		-- ' # ' -> ' #'
		res, stat = rtrim(' # ')
		assert_string(res)
		assert_boolean(stat)
		assert_equal(' #', res)
		assert_true(stat)
	end

test_trim =
	function ()
		local trim = trim.trim

		assert_function(trim)

		local res, stat = nil, nil

		-- '' -> ''
		res, stat = trim('')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('', res)
		assert_false(stat)

		-- ' ' -> ''
		res, stat = trim(' ')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('', res)
		assert_true(stat)

		-- '#' -> '#'
		res, stat = trim('#')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('#', res)
		assert_false(stat)

		-- ' #' -> '#'
		res, stat = trim(' #')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('#', res)
		assert_true(stat)

		-- '# ' -> '#'
		res, stat = trim('# ')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('#', res)
		assert_true(stat)

		-- ' # ' -> '#'
		res, stat = trim(' # ')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('#', res)
		assert_true(stat)
	end

test_all_functions_have_tests =
	function ()
	    local funcs, x = {}, 0

		for k, v in pairs(trim) do
			if type(v) == 'function' and type(_M['test_' .. k]) ~= 'function' then
				x = x + 1 
				funcs[x] = k 
			end 
		end 

		if next(funcs) ~= nil then
			table.sort(funcs)

			fail(('these functions do not have associated tests: %s()'):format(table.concat(funcs, '(), ')))
		end 
	end
