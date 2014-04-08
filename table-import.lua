#!/usr/bin/env lua

local is_empty =
	function (self)
		return not next(self)
	end

table.import =
	function (self, from, pref, keys)
		if type(keys) == 'string' then
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

assert(string.reverse == table.import({}, string     ).reverse )
assert(string.reverse == table.import({}, string, 's').sreverse)

local f =
	function ()
		table.import(_ENV, io)
		table.import(_ENV, io, 'io_')

		write('hello thar!\r\n')
		io_write('blah. ~\r\n')
	end

f()

table.import(_ENV, string, 's', { 'reverse', 'rep', 'sub' })

print(sreverse('cat'), srep('donut', 5), ssub('abcdefg', 3, 6))

