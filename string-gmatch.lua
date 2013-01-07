#!/usr/bin/env lua

local cwrap   = coroutine.wrap
local cyield  = coroutine.yield

local sgmatch = string.gmatch

local orig_select = select

select =
	function (first, ...)
		if first == '*' then
			return orig_select('#', ...), ...
		end

		return orig_select(first, ...)
	end


local orig_sgmatch = string.gmatch

string.gmatch =
	function (s, m, ...)
		local f       = orig_sgmatch(s, m)
		local n, i, j = select('#', ...)

		if n == 0 then
			return f
		end

		if n == 1 then
			if type(...) == 'function' then
				while true do
					local ret = { f() }

					if not next(ret) then
						break
					end

					(...)(unpack(ret))
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
