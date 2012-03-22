#!/usr/bin/env lua

-- Helper function. Usage: fprintf(io.stderr, 'Help %s!', 'me')
local fprintf = function (fd, ...) fd:write(string.format(...)) end

----

local typenames, types = {}, {}

for v_name, v in pairs(_G) do

	local v_type = type(v)

	-- Collect the type names and create
	-- their associated tables dynamically.
	if not types[v_type] then
		types[v_type] = {}
		table.insert(typenames, v_type)
	end
	
	table.insert(types[v_type], v_name)

end

table.sort(typenames)

for _, typename in ipairs(typenames) do

	-- Sort the elements of each type.
	table.sort(types[typename])

	fprintf(io.stdout, '%s:%s\r\n\r\n', typename, table.concat(types[typename], ','))

end
