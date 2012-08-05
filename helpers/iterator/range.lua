local cyield  = coroutine.yield
local cwrap   = coroutine.wrap

local _G = _G

module(... or string.match(debug.getinfo(1).short_src, '^(.*)%.'))

local _range =
    function (i, to, inc, f, ...)
        while i ~= to do 
            i = i + inc
            -- return twice for:
			-- for k, v in range(10) do some_table[k] = v end
            f(i, i, ...) 
        end
    end

range =
	function (i, to, inc, ...)
        if not to then
            to = i -- copy this over

			i = to == 0 and 0

			if i == to then
				to  = -1
				inc = -1
			end

            i  = to == 0 and 0 or (to > 0 and 1 or -1)
        end

        inc = inc or (i < to and 1 or -1)

--		This does not work because: for i in range_iter, i - inc, to, inc, cyield do ... end
--		return cwrap(function () count(i - inc, to, inc, cyield) end)

		if not ... then
			return cwrap(function () _range(i - inc, to, inc, cyield) end)
		end

		_range(i - inc, to, inc, ...)
    end

_G.range = range

return _M
