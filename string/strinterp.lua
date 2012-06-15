#!/usr/bin/env lua

local type    = type
local sformat = string.format

module('strinterp')

strinterp =
	function(a, b)
		return type(b) == 'table' and sformat(a, unpack(b)) or sformat(a, b)
--		Swell to write by not as efficient as ^
--		return a:format(unpack(type(b) == 'table' and b or { b }))
	end

-- add it to the global string table
make_global =
	function ()
		_G.string.__mod = strinterp
	end

return _M
