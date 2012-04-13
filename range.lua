#!/usr/bin/env lua

local range =
	function (num)
		local count_to =
			function (max)
				for i = 1, max do
					coroutine.yield(i)
				end
			end

--[[
		local co = coroutine.create(count_to)

		return
			function () -- iterator
				local status, res = coroutine.resume(co, num)

				return res
			end
--]]

		-- ^ About the same as.
		return coroutine.wrap(function () count_to(num) end)
	end

for i in range(10) do
	print(i)
end
