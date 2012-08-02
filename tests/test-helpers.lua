module('helpers-testcase', lunit.testcase, package.seeall)

setup =
	function ()
		require('setup-test')
		require('helpers')
	end

test_scriptname =
	function ()
		assert_equal('test-helpers.lua', scriptname())
	end

test_fprintf =
	function ()
		local dev_null = assert(io.open('/dev/null', 'w'))

		assert_true(fprintf(dev_null, 'test'))

		-- REMEMBER TO CLOSE
		assert(dev_null:close())
	end

test_printf =
	function ()
		-- save the default output file
		local old  = io.output()
		local null = assert(io.output('/dev/null'))

		assert(old ~= null)

		assert_true(printf('test'))

		-- *CLOSE* /dev/null first
		assert(io.output():close())

		-- revert to old default output
		assert(io.output(old) == old)
	end

test_fprintln =
	function ()
		local dev_null = assert(io.open('/dev/null', 'w'))

		assert_true(fprintln(dev_null, 'test', 'me', 'baby'))

		-- REMEMBER TO CLOSE
		assert(dev_null:close())
	end

test_println =
	function ()
		-- save the default output file
		local old  = io.output()
		local null = assert(io.output('/dev/null'))

		assert(old ~= null)

		assert_true(println('testme!', 'no test me!'))

		-- *CLOSE* /dev/null first
		assert(io.output():close())

		-- revert to old default output
		assert(io.output(old) == old)
	end

test_range =
	function ()
		local tmp = {}

		for i in range(10) do tmp[i] = i end

		assert_equal(10, #tmp)
	end

test_string_squote =
	function ()
		assert_equal([['derp\'test']], string.squote([[derp'test]]))
	end

test_string_count_matches =
	function ()
		assert_equal(4, string.count_matches('aaaa', 'a'))
	end

test_string_interpolation =
	function ()
		assert_equal('1st test',  '1st %s' %      'test'  )
		assert_equal('2nd test', '%dnd %s' % { 2, 'test' })
	end

test_number_each =
	function ()
		local x = 0

		(3):each(function (y) x = x + y end)

		assert_equal(6, x)
	end

test_number_times =
	function ()
		local x = 0

		(6):times(function () x = x + 1 end)

		assert_equal(6, x)
	end

test_function_chain =
	function ()
		assert_equal(4, (function () end):chain()(4))
	end

test_function_wrap =
	function ()
		local tmp = function (x) return x + 1 end

		assert_equal(6, tmp:wrap(tmp)(4))
	end

test_table_append =
	function ()
		local tmp     = table.append({ 1, 2, 3 }, { 4, 5, 6 })
		local tmp_len = #tmp

		assert_table(tmp)
		assert_equal(6, tmp_len)

		for i = 1, #tmp do
			assert_equal(i, tmp[i])
		end
	end

test_table_prepend =
	function ()
		local tmp     = table.prepend({ 4, 5, 6 }, { 1, 2, 3 })
		local tmp_len = #tmp

		assert_table(tmp)
		assert_equal(6, tmp_len)

		for i = 1, #tmp do
			assert_equal(i, tmp[i])
		end
	end

test_table_is_empty =
	function ()
		 assert_true(table.is_empty({             }))
		assert_false(table.is_empty({ 'something' }))
	end

test_table_to_table =
	function ()
		local tmp = to_table(ipairs({ 1, 2, 3, 4, 5 }))

		assert_table(tmp)
		assert_equal(5, #tmp)
		assert_equal(5, tmp[5])
	end

test_table_sort =
	function ()
		local tmp = { 'c', 'a', 'b' }

		-- make sure it returns the same table passed to it
		assert_equal(tmp, table.sort(tmp))
		assert_equal('b', tmp[2])
	end

test_table_copy =
	function ()
		local tmp_mt  = { 1, 2, 3 }
		local tmp     = setmetatable({ 1, 2, 3 }, tmp_mt)

		local copy    = table.copy(tmp, 'rm')
		local copy_mt = getmetatable(copy)

		assert_table(copy)
		assert_not_equal(tmp, copy)
		assert_equal(2, copy[2])

		assert_table(copy_mt)
		assert_not_equal(tmp, copy_mt)
		assert_equal(2, copy_mt[2])
	end

test_table_reverse =
	function ()
		local tmp = { 1, 2, 3 }

		table.reverse(tmp)

		assert_equal(3, tmp[1])
		assert_equal(1, tmp[3])
	end

test_table_map =
	function ()
		local sum = 0

		table.map({ 1, 2, 3 }, function (x) sum = sum + x end)

		assert_equal(6, sum)
	end

test_table_inject =
	function ()
		assert_equal(6, table.inject({ 1, 2, 3 }, function (x, y) return x + (y or 0) end))
		assert_equal(6, table.inject({ 1, 2, 3 }, function (x, y) return x + y        end, 0)) -- with initial arg
	end

test_table_reduce =
	function ()
		assert_equal(6, table.reduce({ 1, 2, 3 }, function (x, y) return x + (y or 0) end))
	end

test_table_join =
	function ()
		assert_equal('1,2,3', table.join({ 1, 2, 3 }, ','))

		-- this should fail like table.concat() with an invalid i, j does
		assert_false(pcall(table.join, {}, '', -1, 1))
	end

test_table_clear =
	function ()
		local orig    = { 1, 2, 3 }
		local cleared = table.clear(orig)

		assert_equal(orig, cleared)
		assert_equal(0,    #orig)
	end

test_table_keys =
	function ()
		local tmp = table.keys({ a = 1 })

		assert_table(tmp)
		assert_nil(tmp[a])
		assert_equal('a', tmp[1])
	end

test_table_vals =
	function ()
		-- intended for unsequenced tables (otherwise you could unpack())
		local tmp = table.vals({ a = 'b' })

		assert_table(tmp)
		assert_nil(tmp.a)
		assert_equal('b', tmp[1])
	end

test_table_compact =
	function ()
		local tmp = table.compact({ [1] = 'cat', [33] = 'dog', [509] = 'horse' })
		
		assert_equal(3, #tmp)
		assert_equal('dog', tmp[2])
	end

test_table_remove_if =
	function ()
		-- 2 gets removed as it proves true for being an even value, 3 should be shifted down
		assert_equal(3, table.remove_if({ 1, 2, 3 }, function (x) return x % 2 == 0 end)[2])
		assert_nil(table.remove_if({ 'derp' }, function (x) return type(x) == 'string' end)[1])
	end

test_table_stripe =
	function ()
		local tmp = table.stripe({ 1, 2, 3 }, 'nyan')

		assert_table(tmp)
		assert_equal(1,      tmp[1])
		assert_equal('nyan', tmp[2])
		assert_equal(2,      tmp[3])
		assert_equal('nyan', tmp[4])
		assert_equal(3,      tmp[5])
		assert_equal('nyan', tmp[6])
		assert_equal(6,      #tmp)

		-- nothing to stripe
		assert_equal(0, #table.stripe({}, 'nyan'))
	end

test_is_callable =
	function ()
		-- is
		assert_true(is_callable(function () end))
		assert_true(is_callable(setmetatable({}, { __call = function () end })))

		-- not
		assert_false(is_callable(4))
		assert_false(is_callable(setmetatable({}, { __call = 4 })))
	end

test_valof =
	function ()
		assert_equal(4, valof(4))
		assert_equal(4, valof(function () return 4 end))
		assert_equal(4, valof(function () return function () return 4 end end))

		do
			local tmp = newproxy(true)

			getmetatable(tmp).__call = function () return 4 end

			assert_equal(4, valof(tmp))
		end
	end

test_lit =
	function ()
		-- hahahahaha
		assert_equal(4, lit(4))

		do
			local tmp = function () end
			assert_equal(tmp, lit(tmp))
		end
	end

