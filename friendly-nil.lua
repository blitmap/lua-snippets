#!/usr/bin/env lua

-- make nil friendlier

-- these functions are named in the form of what they return
local none = function (    )                            end
local nnil = function (l, r) return l ~= nil and l or r end

local nil_mt =
{
	__call   = none,                                       -- call a nil value without pcall and have it do nothing!
	__index  = none,                                       -- stop writing: return some_table and some_table[idx] or ...
	__concat = nnil,                                       -- stop concatenating to an initial empty-string when iteratively building a long string!
	__add    = nnil,                                       -- stop adding nil to things...
	__unm    = function (    ) return    - 0          end, -- sign is preserved even on 0
	__mul    = function (l, r) return 0 *  nnil(l, r) end, -- again, to preserve signedness
	__sub    = function (l, r) return    - nnil(l, r) end, -- just unary-minus the rhs
	__div    = function (l, r) return 0 /  nnil(l, r) end, -- we can't make use of zero() because 0 / 0
	__pow    = function (l, r) return 0 ^  nnil(l, r) end,
}

debug.setmetatable(nil, nil_mt)

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
