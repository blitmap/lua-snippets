local select = select
local cwrap  = coroutine.wrap
local cyield = coroutine.yield

local _G = _G

module(... or string.match(debug.getinfo(1).short_src, '^(.*)%.'))

local _reach =
	function (t, f, ...)
		for i = #t, 1, -1 do
			f(t[i], i, ...)
		end
	end 

reach =
	function (...)
		if select('#', ...) == 1 then
			return cwrap(_reach), ..., cyield
		end

		_reach(...)

		return (...)
	end

_G.reach = reach

return _M
