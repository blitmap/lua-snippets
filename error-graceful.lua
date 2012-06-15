#!/usr/bin/env lua

abort =
	function (msg, was_error)
		io.stderr:write(msg, '\n')

		-- I know this looks odd but there is no implicit
		-- conversion from bool to a number in Lua.
		os.exit(type(was_error) == 'number' and was_error or (was_error and 1 or 0))
	end

abort('Something went horribly, horribly wrong :-(', 13)
