module('pad-testcase', lunit.testcase, package.seeall)

setup =
	function ()
		require('setup-test')
		require('string-pad')
	end

test_pad_require =
	function ()
		assert_table(pad)
	end

test_lpad =
	function ()
		local lpad = pad.lpad

		assert_function(lpad)

		local res, stat = nil, nil

		-- '' -> '', with -1 left-padding
		res, stat = lpad('', -1)
		assert_string(res)
		assert_boolean(stat)
		assert_equal('', res)
		assert_false(stat)

		-- '' -> '', with 0 left-padding
		res, stat = lpad('', 0)
		assert_string(res)
		assert_boolean(stat)
		assert_equal('', res)
		assert_false(stat)

		-- '#' -> '#', with 1 left-padding
		res, stat = lpad('#', 1)
		assert_string(res)
		assert_boolean(stat)
		assert_equal('#', res)
		assert_false(stat)

		-- '#' -> ' #', with 2 left-padding
		res, stat = lpad('#', 2)
		assert_string(res)
		assert_boolean(stat)
		assert_equal(' #', res)
		assert_true(stat)

		-- '' -> '  ', with 2 left-padding
		res, stat = lpad('', 2)
		assert_string(res)
		assert_boolean(stat)
		assert_equal('  ', res)
		assert_true(stat)

		-- '#' -> '--#', with 3 left-padding, and '-' char specified
		res, stat = lpad('#', 3, '-')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('--#', res)
		assert_true(stat)
	end

test_rpad =
	function ()
		local rpad = pad.rpad

		assert_function(rpad)

		-- '' -> '', with -1 right-padding
		res, stat = rpad('', -1)
		assert_string(res)
		assert_boolean(stat)
		assert_equal('', res)
		assert_false(stat)

		-- '' -> '', with 0 right-padding
		res, stat = rpad('', 0)
		assert_string(res)
		assert_boolean(stat)
		assert_equal('', res)
		assert_false(stat)

		-- '#' -> '#', with 1 right-padding
		res, stat = rpad('#', 1)
		assert_string(res)
		assert_boolean(stat)
		assert_equal('#', res)
		assert_false(stat)

		-- '#' -> '# ', with 2 right-padding
		res, stat = rpad('#', 2)
		assert_string(res)
		assert_boolean(stat)
		assert_equal('# ', res)
		assert_true(stat)

		-- '' -> ' ', with 2 right-padding
		res, stat = rpad('', 2)
		assert_string(res)
		assert_boolean(stat)
		assert_equal('  ', res)
		assert_true(stat)

		-- '#' -> '#--', with 3 right-padding, and '-' char specified
		res, stat = rpad('#', 3, '-')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('#--', res)
		assert_true(stat)
	end

test_pad =
	function ()
		local pad = pad.pad

		assert_function(pad)

		-- '' -> '', with -1 padding
		res, stat = pad('', -1)
		assert_string(res)
		assert_boolean(stat)
		assert_equal('', res)
		assert_false(stat)

		-- '' -> '', with 0 padding
		res, stat = pad('', 0)
		assert_string(res)
		assert_boolean(stat)
		assert_equal('', res)
		assert_false(stat)

		-- '#' -> '#', with 1 padding
		res, stat = pad('#', 1)
		assert_string(res)
		assert_boolean(stat)
		assert_equal('#', res)
		assert_false(stat)

		-- '#' -> '# ', with 2 padding, centering is still left-justified
		res, stat = pad('#', 2)
		assert_string(res)
		assert_boolean(stat)
		assert_equal('# ', res)
		assert_true(stat)

		-- '#' -> ' # ', with 3 padding
		res, stat = pad('#', 3)
		assert_string(res)
		assert_boolean(stat)
		assert_equal(' # ', res)
		assert_true(stat)

		-- '#' -> ' #  ', with 2 padding, centering is still left-justified
		res, stat = pad('#', 4)
		assert_string(res)
		assert_boolean(stat)
		assert_equal(' #  ', res)
		assert_true(stat)

		-- '#' -> '--#--', with 3 padding, and '-' char specified
		res, stat = pad('#', 5, '-')
		assert_string(res)
		assert_boolean(stat)
		assert_equal('--#--', res)
		assert_true(stat)
	end

test_all_functions_have_tests =
	function ()
	    local funcs, x = {}, 0

		for k, v in pairs(pad) do
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
