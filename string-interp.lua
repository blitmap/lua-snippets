#!/usr/bin/env lua

local t       = type
local fmt     = string.format
local unpack  = unpack
local getmeta = getmetatable

module('strinterp')

getmeta('').__mod =
	function(a, b)
		return t(b) == 'table' and fmt(a, unpack(b)) or fmt(a, b)
--		return fmt(a, unpack(t(b) == 'table' and b or { b })) -- not as efficient
	end

-- nothing in here...
return _M
