#!/usr/bin/env lua

do
	local str_mt    = getmetatable('')
	local str_index = str_mt.__index

	if type(str_index) == 'table' then
		local tmp = str_index
		str_index = function (_, i) return tmp[i] end
	end

	str_mt.__index =
		function (s, i)
			-- because we like to be clever.
			-- return type(i) == 'number' and s:sub(i, i) or str_index(s, i)
			return (type(i) == 'number' and string.sub or str_index)(s, i, i)
		end
end

-- Can only index a single character at a time
print(('cat')[2])
print(('cat')[3])

string.slice =
	function (self, start, finish)
		return self:sub(start, finish or start)
	end

-- Can slice out a single character or multiple
print(('cat'):slice(2))
print(('cat'):slice(1, 2))
