#!/usr/bin/env lua

local cwrap  = coroutine.wrap
local cyield = coroutine.yield

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

--------------------------
--    iterator calls    --
--------------------------

for _, v in ipairs({ 'each', 'reach', 'every', 'ipairs', 'pairs' }) do
	local iter = _G[v]

	print(('-'):rep(70))
	print(('%s(tmp, print) -- iterator call'):format(v))
	print(('-'):rep(70))

	-- Special note: The iterator form returns its `self'. assert(tmp == ...)
	assert(tmp == iter(tmp, print))
end

--------------------------
--    generator calls   --
--------------------------

for _, v in ipairs({ 'each', 'reach', 'every' }) do
	local gener = _G[v]

	print(('-'):rep(70))
	print(('for v, i in %s(tmp) do print(v, i) end -- generator call'):format(v))
	print(('-'):rep(70))

	for v, i in gener(tmp) do
		print(v, i)
	end
end
	
for _, v in ipairs({ 'pairs', 'ipairs' }) do
	local gener = _G[v]

	print(('-'):rep(70))
	print(('for i, v in %s(tmp) do print(i, v) end -- generator call'):format(v))
	print(('-'):rep(70))

	for i, v in gener(tmp) do
		print(i, v)
	end
end

