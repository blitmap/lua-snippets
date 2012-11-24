#!/usr/bin/env lua

-- I thought it would be fun to hide calls in the form of member access.

local num_mt = {}

num_mt.__index =
	function (s, k)
		return num_mt[k](s)
	end

num_mt.int = math.floor

debug.setmetatable(0, num_mt)

----

t = 4.8572848

print(t.int)
