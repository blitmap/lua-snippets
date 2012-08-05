local ipairs = ipairs
local select = select
local cwrap  = coroutine.wrap
local cyield = coroutine.yield

local _G = _G

module(... or string.match(debug.getinfo(1).short_src, '^(.*)%.'))

local _each =
	function (t, f, ...)
		for i, v in ipairs(t) do
			f(v, i, ...)
		end
	end

each =
	function (...)
		if select('#', ...) == 1 then
			return cwrap(_each), ..., cyield
		end

		_each(...)

		return (...)
	end

_G.each = each

return _M
