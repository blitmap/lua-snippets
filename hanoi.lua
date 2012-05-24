#!/usr/bin/env lua

local debug_getinfo = debug.getinfo
local string_match  = string.match

require('helpers')

local move_counter = 0

-- Declared before for recursion.
local move
move =
	function (src, dst, tmp, num)
		if num ~= 1 then
			move(src, tmp, dst, num - 1)
			move(src, dst, tmp,       1)
			move(tmp, dst, src, num - 1)
		end

		print('Move from ' .. src .. ' peg to ' .. dst .. ' peg...')

		move_counter = move_counter + 1
	end

print(scriptname())

if #arg ~= 1 then
	io.stdout:write(
		'\r\n'                                                                      ..
		'A simple implementation of the well-known \'Towers of Hanoi\' puzzle.\r\n' ..
		'\r\n'                                                                      ..
		'\tUsage: ' .. scriptname() .. ' <size>\r\n'                                ..
		'\r\n'
	)
else
	local complexity = tonumber(arg[1])

	fprintf(io.stdout, '\r\n>>> Procedure:\r\n\r\n')

	move('left', 'right', 'middle', complexity)

	fprintf(io.stdout, '\r\n>>> Tower of Hanoi, %d disks high in complexity, solved in %d moves.\r\n\r\n', complexity, move_counter)
end
