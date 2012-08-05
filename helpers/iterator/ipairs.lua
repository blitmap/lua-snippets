local select      = select
local orig_ipairs = ipairs

local _G = _G

module(... or string.match(debug.getinfo(1).short_src, '^(.*)%.'))

local _ipairs =
	function (t, f, ...)
		for i, v in orig_ipairs(t) do
			f(i, v, ...)
		end
	end

ipairs =
	function (...)
		local self = ...

		if select('#', ...) == 1 then
			return orig_ipairs(...)
		end

		_ipairs(...)

		return (...)
	end

_G.ipairs = ipairs

return _M
