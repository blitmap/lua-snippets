#!/usr/bin/env lua

local table_contains =
	function (t, what, mode)
		if not mode then
			for _, v in pairs(t) do
				if v == what then
					return true
				end
			end
		else
			assert(type(mode) == 'string')

			if mode:find('v') then
				for _, v in pairs(t) do
					if v == what then
						return true
					end
				end
			end

			if mode:find('k') and t[what] ~= nil then
				return true
			end
		end

		return false
	end

print(table_contains({ 1, 2, 3, 4, 5 }, 3))
print(table_contains({ ['one'] = 1, ['two'] = 2, ['three'] = 3 }, 'one', 'k'))
print(table_contains({ ['one'] = 1, ['two'] = 2, ['three'] = 3 }, 3, 'kv'))

table.contains = table_contains

setmetatable(table, { __call = function (self, newtable) assert(type(newtable) == 'table') return setmetatable(newtable, { __index = self }) end })

local b = table({ 'a', 'b', 'c', 'd', 'e' })

print(b:contains('c') and 'Yay!' or 'No :(')
