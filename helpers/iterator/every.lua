local pairs  = pairs
local select = select
local cwrap  = coroutine.wrap
local cyield = coroutine.yield

local _G = _G

module(... or string.match(debug.getinfo(1).short_src, '^(.*)%.'))

local _every =
	function (t, f, ...)
		for k, v in pairs(t) do
			f(v, k, ...)
		end
	end

every =
	function (...)
		if select('#', ...) == 1 then
			return cwrap(_every), ..., cyield
		end

		_every(...)

		return (...)
	end

_G.every = every

return _M
