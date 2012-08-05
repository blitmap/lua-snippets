local select     = select
local orig_pairs = pairs

local _G = _G

module(... or string.match(debug.getinfo(1).short_src, '^(.*)%.'))

local _pairs =
	function (t, f, ...)
		for k, v in orig_pairs(t) do
			f(k, v, ...)
		end
	end

pairs =
	function (...)
		if select('#', ...) == 1 then
			return orig_pairs(...)
		end

		_pairs(...)

		return (...)
	end

_G.pairs = pairs

return _M
