module('rawtype-testcase', lunit.testcase, package.seeall)

setup =
	function ()
		require('setup-test')
		require('rawtype')

		-- Testing four scenarios:
		-- 1) An object with no metatable, should respond like original type()
		-- 2) An object with a metatable and string .__type, should return the value of .__type
		-- 3) An object with a metatable and function .__type, should return the result of .__type(object)
		-- 4) An object with a metatable and callable .__type, should fail and return rawtype(object)
			-- metamethods *must* be functions, not callable objects, but __type may be a string like __index may be a table

		a = 'i am a string' -- I'm just a simple string. :'(
		b = setmetatable({}, { __type = 'bear' }) 
		c = setmetatable({}, { __type = function () return 'pdp11' end }) 
		d = setmetatable({}, { __type = setmetatable({}, { __call = function () return 'peanuts' end }) })
	end

test_type =
	function ()
		local tmp = nil

		tmp = type(a)
		assert_string(tmp)
		assert_equal('string', tmp)
		tmp = nil

		tmp = type(b)
		assert_string(tmp)
		assert_equal('bear',   tmp)
		tmp = nil

		tmp = type(c)
		assert_string(tmp)
		assert_equal('pdp11',  tmp)
		tmp = nil

		tmp = type(d)
		assert_string(tmp)
		assert_equal('table',  tmp)
	end

test_rawtype =
	function ()
		local tmp = nil

		tmp = rawtype(a)
		assert_string(tmp)
		assert_equal('string', tmp)
		tmp = nil

		tmp = rawtype(b)
		assert_string(tmp)
		assert_equal('table',  tmp)
		tmp = nil

		tmp = rawtype(c)
		assert_string(tmp)
		assert_equal('table',  tmp)
		tmp = nil

		tmp = rawtype(d)
		assert_string(tmp)
		assert_equal('table',  tmp)
	end
