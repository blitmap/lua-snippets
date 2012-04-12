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
				local res = ''

				-- We found something to "trim to".
				if tmp then
					-- Avoid string.sub()'ing the whole string from 1 to #str.
					-- str_sub() in lstrlib.c does not avoid creating a new
					-- string that is an exact copy of the string passed to it
					res = tmp == 1 and str or str:sub(tmp)
				end

				return res, res ~= str
			end,
		right =
			function (str)
				local tmp = str:find('%S%s*$')
				local res = ''

				if tmp then
					res = tmp == #str and str or str:sub(1, tmp)
				end
				
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
			{ str = '',             expected = ''           },
			{ str = '  ',           expected = ''           },
			{ str =   'ltrim me',   expected = 'ltrim me'   },
			{ str = '  ltrim me',   expected = 'ltrim me'   },
			{ str =   'ltrim me  ', expected = 'ltrim me  ' },
			{ str = '  ltrim me  ', expected = 'ltrim me  ' },
		},
		{
			func = trim.right,
			func_name = 'trim.right',
			{ str = '',             expected = ''           },
			{ str = '  ',           expected = ''           },
			{ str =   'rtrim me',   expected =   'rtrim me' },
			{ str = '  rtrim me',   expected = '  rtrim me' },
			{ str =   'rtrim me  ', expected =   'rtrim me' },
			{ str = '  rtrim me  ', expected = '  rtrim me' },
		},
		{
			func = trim,
			func_name = 'trim',
			{ str = '',             expected = ''           },
			{ str = '  ',           expected = ''           },
			{ str =   'trim me',    expected = 'trim me'    },
			{ str = '  trim me  ',  expected = 'trim me'    },
		}
	}

for x, testcase in ipairs(tests) do

	println('Testing function: %s()\r\n' % testcase.func_name)

	for y, test in ipairs(testcase) do

		local res, modified = testcase.func(test.str)

		println(
			'\tTest #%d'                                % y,
			'',
			"\t==    Expecting: %s -> %s (%schange)"    % { squote(test.str), squote(test.expected), test.str == test.expected and 'should not ' or 'needs to ' },
			"\t==  Test Result: %s -> %s"               % { squote(test.str), squote(res) },
			"\t== Trimmed Form: %s! (string %schanged)" % { res == test.expected and 'Correct' or 'Incorrect', test.str == res and 'un' or '' },
			''
		)

	end

	println()

end

-- }}}
