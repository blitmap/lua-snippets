#!/usr/bin/env lua

local helpers = require('helpers')

local println = helpers.println
local squote  = helpers.squote

assert(helpers.make_strings_interpolatable())

-- {{{ ltrim(), rtrim(), and trim() definitions

-- Each of these functions return a 2nd value letting
-- the caller know if the string was changed at all
-- (if the trim was necessary)

local trim = {}

trim.ltrim =
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
	end

trim.rtrim =
	function (str)
		local tmp = str:find('%S%s*$')
		local res = ''

		if tmp then
			res = tmp == #str and str or str:sub(1, tmp)
		end
				
		return res, res ~= str
	end

trim.trim =
	function (str)
		local res1, stat1 = trim.ltrim(str)
		local res2, stat2 = trim.rtrim(res1)

		return res2, stat1 and stat2
	end

setmetatable(trim, { __call = function (_, str) return trim.trim(str) end })

-- }}}

-- {{{ Testing *trim() functions :-)

local tests =
	{
		{
			func = trim.rtrim,
			func_name = 'trim.rtrim',
			{ str = '',             expected = ''           },
			{ str = '  ',           expected = ''           },
			{ str =   'ltrim me',   expected = 'ltrim me'   },
			{ str = '  ltrim me',   expected = 'ltrim me'   },
			{ str =   'ltrim me  ', expected = 'ltrim me  ' },
			{ str = '  ltrim me  ', expected = 'ltrim me  ' },
		},
		{
			func = trim.rtrim,
			func_name = 'trim.rtrim',
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
