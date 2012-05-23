#!/usr/bin/env lua

local helpers = require('helpers')

local println = helpers.println
local squote  = helpers.squote

assert(helpers.make_strings_interpolatable())

-- {{{ ltrim(), rtrim(), and trim() definitions

-- Each of these functions return a 2nd value letting
-- the caller know if the string was changed at all
-- (if the trim was necessary)

string.ltrim =
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

string.rtrim =
	function (str)
		local tmp = str:find('%S%s*$')
		local res = ''

		if tmp then
			res = tmp == #str and str or str:sub(1, tmp)
		end
				
		return res, res ~= str
	end

string.trim =
	function (str)
		local res1, stat1 = string.ltrim(str)
		local res2, stat2 = string.rtrim(res1)

		return res2, stat1 and stat2
	end

-- }}}

-- {{{ Testing *trim() functions :-)

local tests =
	{
		{
			func_name = 'string.ltrim',
			{ '',             ''           },
			{ '  ',           ''           },
			{ 'ltrim me',     'ltrim me'   },
			{ '  ltrim me',   'ltrim me'   },
			{ 'ltrim me  ',   'ltrim me  ' },
			{ '  ltrim me  ', 'ltrim me  ' },
		},
		{
			func_name = 'string.rtrim',
			{ '',             ''           },
			{ '  ',           ''           },
			{ 'rtrim me',     'rtrim me'   },
			{ '  rtrim me',   '  rtrim me' },
			{ 'rtrim me  ',   'rtrim me'   },
			{ '  rtrim me  ', '  rtrim me' },
		},
		{
			func_name = 'string.trim',
			{ '',            ''        },
			{ '  ',          ''        },
			{ 'trim me',     'trim me' },
			{ '  trim me  ', 'trim me' },
		}
	}

for x, testcase in ipairs(tests) do

	println('Testing function: %s()\r\n' % testcase.func_name)

	for y, test in ipairs(testcase) do
		local f = assert(loadstring('return ' .. testcase.func_name))()

		local initial = test[1]
		local expects = test[2]

		local res, modified = f(initial)

		println(
			'\tTest #%d'                                % y,
			'',
			"\t==    Expecting: %s -> %s (%schange)"    % { squote(initial), squote(expects), initial == expects and 'should not ' or 'needs to ' },
			"\t==  Test Result: %s -> %s"               % { squote(initial), squote(res) },
			"\t== Trimmed Form: %s! (string %schanged)" % { res == expects and 'Correct' or 'Incorrect', initial == res and 'un' or '' },
			''
		)

	end

	println()

end

-- }}}
