#!/usr/bin/env lua

local srep   = string.rep

local cwrap  = coroutine.wrap
local cyield = coroutine.yield

local println =
	function (...)
		for i = 1, select('#', ...) do
			io.output():write(select(i, ...), '\r\n')
		end
	end

-- iterators
local   _each = function (t, f, ...) for i =  1, #t        do f(t[i], i, ...) end end -- all 3 are value-first, key 2nd
local  _reach = function (t, f, ...) for i = #t,  1, -1    do f(t[i], i, ...) end end 
local  _every = function (t, f, ...) for k, v in  pairs(t) do f(v,    k, ...) end end 

-- these public-facing functions either generate an iterator or iterate if a function and args are passed
each  = function (t, ...) if ... ~= nil then  _each(t, ...) return t end return cwrap( _each), t, cyield end
reach = function (t, ...) if ... ~= nil then _reach(t, ...) return t end return cwrap(_reach), t, cyield end
every = function (t, ...) if ... ~= nil then _every(t, ...) return t end return cwrap(_every), t, cyield end

-- make pairs/ipairs generators also act as directly started iterators if a function and args are passed
do
	local orig_pairs  = pairs
	local orig_ipairs = ipairs

	pairs  = function (t, f, ...) if f ~= nil then for k, v in orig_pairs(t)  do f(k, v, ...) end return t end return orig_pairs(t)  end
	ipairs = function (t, f, ...) if f ~= nil then for k, v in orig_ipairs(t) do f(k, v, ...) end return t end return orig_ipairs(t) end
end

--------------------------
--       examples       --
--------------------------

local tmp = { 'a', 'b', 'c', 'd', 'e', 'f', 'g' }
local sep = srep('-', 70)

--------------------------
--    iterator calls    --
--------------------------

for _, v in ipairs({ 'each', 'reach', 'every', 'ipairs', 'pairs' }) do
	local iter = _G[v]

	println
	(
		sep,
		('%s(tmp, print) -- iterator call'):format(v),
		sep
	)

	-- Special note: The iterator form returns its `self'. assert(tmp == ...)
	assert(tmp == iter(tmp, print))
end

--------------------------
--    generator calls   --
--------------------------

for _, v in ipairs({ 'each', 'reach', 'every', 'ipairs', 'pairs' }) do
	local gener = _G[v]

	println
	(
		sep,
		('for x, y in %s(tmp) do print(x, y) end -- generator call'):format(v),
		sep
	)

	for x, y in gener(tmp) do
		print(x, y)
	end
end
