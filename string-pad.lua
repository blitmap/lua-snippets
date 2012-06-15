#!/usr/bin/env lua

local srep = string.rep

module('pad')

-- pad the left side
lpad =
	function (s, len, c)
		return srep(c or ' ', len - #s) .. s
	end

-- pad the right side
rpad =
	function (s, len, c)
		return s .. srep(c or ' ', len - #s)
	end

-- pad on both sides (centering with left justification)
pad =
	function (s, len, c)
		c = c or ' '

		return lpad(rpad(s, (len / 2) + #s, c), len, c)
	end

return _M
