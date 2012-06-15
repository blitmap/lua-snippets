#!/usr/bin/env lua

local setmeta = setmetatable
local cyield  = coroutine.yield
local cresume = coroutine.resume
local ccreate = coroutine.create
local select  = select

module('range')

local count =
    function (i, to, inc)
        while i ~= to do 
            i = i + inc
            -- should return two values for
            -- some_table[i] = i usage
            cyield(i, i) 
        end
    end

-- our range() example separates the arg handling of
-- the function from the yielding coroutine body (count())
iter =
    function (i, to, inc)
        if not to then
            to = i
            i  = to == 0 or (to > 0 and 1 or -1)
        end

        inc = inc or (i < to and 1 or -1)

        local co = ccreate(count)

        return
            function () -- iterator
                return select(2, cresume(co, i - 1, to, inc)) -- select past the status
            end

        -- The above lines up to ccreate() could instead be written like so:
        -- return cwrap(function () count(i - 1, to, inc) end)
        -- coroutine.wrap() turns yielding functions into iterators (roughly)
    end

-- require('range') range() -> iter()
return setmeta(_M, { __call = function (_, ...) return iter(...) end }) 

--[[

-- Usage:

require('range')

for i in range(10) do
    print(i)
end

debug.setmetatable(
	function () end,
	{
		__index =
			{
				collect =
					function (...)
						local tmp = {}

						for k, v in ... do
							tmp[k] = v
						end

						return tmp
					end
			}
	}
)

-- it's that easy. :p
local some_table = range(3, 243, 9):collect()

]]
