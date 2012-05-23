#!/usr/bin/env lua

-- The type() wrap and rawtype() implementation

-- Save this.
local orig_type = type

-- Wrap orig_type() to respect a __type metamethod
type =
	function (what)
		local tmp = getmetatable(what)

		-- what has no __type metafield,
		-- behave like the original type()
		if tmp == nil or tmp.__type == nil then
			return orig_type(what)
		end

		-- If __type is callable, return that result (or return its member value).
		-- Note: __type maybe a function or an object with a __call metamethod
		local status, ret = pcall(tmp.__type, what)

		return tostring(status and ret or tmp.__type)
	end

-- Alias to that.
rawtype = orig_type
