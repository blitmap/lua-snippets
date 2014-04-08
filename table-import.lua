#!/usr/bin/env lua

-- table.import(_ENV, string)
-- table.import(_ENV, string, 's')
-- table.import(_ENV, string, { 'reverse', 'byte' })
-- table.import(_ENV, string, 's', { 'reverse', 'byte' })

local is_empty =
	function (self)
		return not next(self)
	end

table.import =
	function (self, from, pref, keys)
		if type(pref) == 'table' then
			pref, keys = keys, pref
		end

		pref = pref or ''
		keys = keys or {}

		-- do we import everything?
		if is_empty(keys) then
			for k, v in pairs(from) do
				self[pref .. k] = v
			end
		else
			for _, k in pairs(keys) do
				self[pref .. k] = from[k]
			end
		end

		return self
	end

assert(string.reverse == table.import({}, string     ).reverse                )
assert(string.reverse == table.import({}, string, 's').sreverse               )
assert(nil            == table.import({}, string, { 'reverse' }).byte         )
assert(string.reverse == table.import({}, string, 's', { 'reverse' }).sreverse)

table.import(_ENV, string, 's', { 'reverse', 'rep', 'sub' })

print(sreverse('cat'), srep('donut', 5), ssub('abcdefg', 3, 6))
