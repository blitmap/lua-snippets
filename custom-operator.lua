#!/usr/bin/env lua

local infix = nil

do
	local infix_object = {}

	infix =
		function (f)
			local mt = { __sub = function (self, b) return f(self[1], b) end }
			return
				setmetatable(
					infix_object,
					{
						__sub =
							function (a)
								return setmetatable({ a }, mt)
							end
					}
				)
		end
end

local eq = infix(function (a, b) return a == b end)

print(1 -eq- 1)
