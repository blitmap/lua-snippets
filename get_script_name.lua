#!/usr/bin/env lua

local scriptname =
	function ()
		return debug.getinfo(1).short_src
	end

print(scriptname())
