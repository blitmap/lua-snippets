#!/usr/bin/env lua

local cwrap   = coroutine.wrap
local cyield  = coroutine.yield

local orig_sgmatch = string.gmatch

string.gmatch =
	function (s, m, i, j)
		local f = orig_sgmatch(s, m)

		if i == nil then
			return f
		end

		if j == nil then
			-- we assume not-a-number means `i' is callable
			if type(i) ~= 'number' then
				while true do
					local ret = { f() }

					if not next(ret) then
						break
					end

					i(unpack(ret))
				end

				return -- Ash used an Escape Rope!
			end

			j = math.huge
		end

		for _ = 1, i - 1 do
			f()
		end

		return
			cwrap(
				function ()
					for x = 1, j - i do
						cyield(f())
					end
				end
			)
	end

string.gmatch('blahness', '.', print)

print(string.rep('-', 20))

for m in string.gmatch('abcdefghijklmnopqrstuvwxyz', '.', 1) do print(m) end

print(string.rep('-', 20))

for m in string.gmatch('abcdefghijklmnopqrstuvwxyz', '.', 10, 20) do print(m:upper()) end
