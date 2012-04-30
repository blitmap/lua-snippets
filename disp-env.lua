#!/usr/bin/env lua

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

io.stdout:write('\r\n')

for _, typename in ipairs(typenames) do

	-- Sort the elements of each type.
	table.sort(types[typename])

	io.stdout:write(typename, ':\r\n\r\n\t', table.concat(types[typename], '\r\n\t'), '\r\n\r\n')

end
