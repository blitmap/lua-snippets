#!/usr/bin/env lua

local printf =
	function (...)
		io.stdout:write(string.format(...))
	end

local round_to_nearest =
	function (n, mul)
		return math.floor(n / mul + 0.5) * mul
	end

printf(
	'Rounding to nearest 15.\r\n' ..
	'Under: %d -> %d\r\n' ..
	' Over: %d -> %d\r\n',
	7, round_to_nearest(7, 15),
	8, round_to_nearest(8, 15)
)
