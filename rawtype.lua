#!/usr/bin/env lua

-- {{{ The type() wrap and rawtype() implementation

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
		local status, ret = pcall(function () return tmp.__type(what) end)

		return tostring(status and ret or tmp.__type)
	end

-- Alias to that.
rawtype = orig_type

-- }}}

local a = 'i am a string'
local b = newproxy(true)
local c = newproxy(true)
local d = newproxy(true)

-- b's type is a bear :D  i swear; no really
getmetatable(b).__type = 'bear'

-- c's type is a pdp11 :o  fancy smancy
getmetatable(c).__type = function () return 'pdp11' end

-- d is peanuts.  it just is.
do
	local tmp = newproxy(true)
	getmetatable(tmp).__call = function () return 'peanuts' end

	getmetatable(d).__type = tmp
end

print(type(a), rawtype(a))
print(type(b), rawtype(b))
print(type(c), rawtype(c))
print(type(d), rawtype(d))
