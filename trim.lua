#!/usr/bin/env lua

-- {{{ ltrim(), rtrim(), and trim() definitions

-- Each of these functions return a 2nd value letting
-- the caller know if the string was changed at all
-- (if the trim was necessary)

local trim =
	{
		left =
			function (str)
				local tmp = str:find('%S')
				local res = tmp and str:sub(tmp) or ''

				return res, res ~= str
			end,
		right =
			function (str)
				local tmp = str:find('%S%s*$')
				local res = tmp and str:sub(1, tmp) or ''

				return res, res ~= str
			end
	}

setmetatable(
	trim,
	{
		-- Our trim()
		__call =
			function (_, str)
				local res1, stat1 = trim.left(str)
				local res2, stat2 = trim.right(res1)

				return res2, stat1 and stat2
			end
	}
)

-- Buwhahahaha.
-- string.trim = trim
-- `('  derp  '):trim()`
-- `('  derp  '):trim.left()`
-- `('  derp  '):trim.right()`

-- }}}

-- {{{ Helpers

getmetatable('').__mod =
	function (fmt, args)
		return type(args) == 'table' and fmt:format(unpack(args)) or fmt:format(args)
	end

local println =
	function (...)
		for _, v in ipairs(arg) do
			io.stdout:write(v, '\r\n')
		end
	end

local squote =
	function (str)
		return [[']] .. tostring(str):gsub([[']], [[\']]) .. [[']]
	end

-- }}}

-- {{{ Testing *trim() functions :-)

local tests =
	{
		{
			func = trim.left,
			func_name = 'trim.left',
			{ str = '',             expected = '',           needs_trim = false },
			{ str = '  ',           expected = '',           needs_trim = true  },
			{ str =   'ltrim me',   expected = 'ltrim me',   needs_trim = false },
			{ str = '  ltrim me',   expected = 'ltrim me',   needs_trim = true  },
			{ str =   'ltrim me  ', expected = 'ltrim me  ', needs_trim = false },
			{ str = '  ltrim me  ', expected = 'ltrim me  ', needs_trim = true  }
		},
		{
			func = trim.right,
			func_name = 'trim.right',
			{ str = '',             expected = '',           needs_trim = false },
			{ str = '  ',           expected = '',           needs_trim = true  },
			{ str =   'rtrim me',   expected =   'rtrim me', needs_trim = false },
			{ str = '  rtrim me',   expected = '  rtrim me', needs_trim = false },
			{ str =   'rtrim me  ', expected =   'rtrim me', needs_trim = true  },
			{ str = '  rtrim me  ', expected = '  rtrim me', needs_trim = true  }
		},
		{
			func = trim,
			func_name = 'trim',
			{ str = '',             expected = '',           needs_trim = false },
			{ str = '  ',           expected = '',           needs_trim = true  },
			{ str =   'trim me',    expected = 'trim me',    needs_trim = false },
			{ str = '  trim me  ',  expected = 'trim me',    needs_trim = true  }
		}
	}

for x, testcase in ipairs(tests) do

	println('Testing function: %s()\r\n' % testcase.func_name)

	for y, test in ipairs(testcase) do

		local res, modified = testcase.func(test.str)

		println(
			"\t==    Expecting: %s -> %s (%schange)"    % { squote(test.str), squote(test.expected), test.needs_trim and 'needs to ' or 'should not ' },
			"\t==  Test Result: %s -> %s"               % { squote(test.str), squote(res) },
			"\t== Trimmed Form: %s! (string %schanged)" % { res == test.expected and 'Correct' or 'Incorrect', modified and '' or 'un' },
			''
		)

	end

	println()

end

-- }}}
