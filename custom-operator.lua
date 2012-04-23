#!/usr/bin/env lua

local infix =
	function (f)
		local infix_object = newproxy(false)

		debug.setmetatable(
			infix_object,
			{
				__sub =
					function (lhs)
						local mt = { lhs, __sub = function (self, b) return f(self[1 --[[lhs]]], b) end }

						return setmetatable(mt, mt)
					end
			}
		)

		return infix_object
	end

local eq   = infix(function (a, b) return a == b end)
local comp = infix(function (a, b) return a == b and 0 or a < b and -1 or 1 end)

print(1  -eq-  1)
print(1 -comp- 0)
