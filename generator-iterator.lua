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
local   _each = function (t, f, ...) for i, v in ipairs(t) do f(v,    i, ...) end end -- all 3 are value-first, key 2nd
local  _every = function (t, f, ...) for k, v in  pairs(t) do f(v,    k, ...) end end 
local  _reach = function (t, f, ...) for i = #t,  1, -1    do f(t[i], i, ...) end end 

local itergen =
	function (iter)
		return
			function (t, ...)
				if ... then
					iter(t, ...)

					return t
				end

				return cwrap(iter), t, cyield
			end
	end

-- these public-facing functions either generate an iterator or iterate if a function and args are passed
each  = itergen( _each)
reach = itergen(_reach)
every = itergen(_every)

-- strictly for k, v-returning generators
local geniter =
	function (gen)
		return
			function (t, f, ...)
				if f then
					for k, v in gen(t) do
						f(k, v, ...)
					end

					return t
				end

				return gen(t)
			end
	end

-- make ipairs/pairs also act as iterators
ipairs = geniter(ipairs)
pairs  = geniter( pairs)

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
