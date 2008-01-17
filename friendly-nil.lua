#!/usr/bin/env lua

-- make nil friendlier

do
	-- these functions are named in the form of what they return
	local none = function (      )            end
	local rhs  = function (_, rhs) return rhs end

	local nil_mt =
	{
		__call   = none, -- call a nil value without pcall!
		__index  = none, -- stop writing: return some_table and some_table[idx] or ...
		__concat = rhs,  -- stop concatenating to an initial empty-string when iteratively building a long string!
		__add    = rhs,  -- for arithmetic nil could be treated simply as 0 for all operations 0 + 3, 0 * 3, 0 ^ 3, ...
		__unm    = function (    ) return    -0 end, -- sign is preserved even on 0
		__mul    = function (_, y) return 0 * y end, -- again, to preserve signate
		__sub    = function (_, y) return    -y end, -- just unary-minus the rhs
		__div    = function (_, y) return 0 / y end, -- we can't make use of zero() because 0 / 0
		__pow    = function (_, y) return 0 ^ y end,
	}

	debug.setmetatable(nil, nil_mt)
end

local a =  a()
local b =  b['something']
local c =  c .. 'testing'
local d =  d +  3
local e = -e
local f =  f * -3 -- signage test
local g =  g -  3
local h =  h /  0 -- nan test
local i =  i ^ -3 -- inf test

print(a, b, c, d, e, f, g, h, i)
