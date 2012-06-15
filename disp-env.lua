#!/usr/bin/env lua

local typenames, types = {}, {}

for k, v in pairs(_G) do
	local v_type = type(v)

	-- Collect the type names and create
	-- their associated tables dynamically.
	if not types[v_type] then
		types[v_type] = {}
		table.insert(typenames, v_type)
	end
	
	table.insert(types[v_type], k)
end

table.sort(typenames)

io.output():write('\r\n')

for _, typename in ipairs(typenames) do
	-- Sort the elements of each type.
	table.sort(types[typename])

	io.output():write(typename, ':\r\n\r\n')

	for _, v in ipairs(types[typename]) do
		io.output():write('\t', tostring(v), '\r\n')
	end

	io.output():write('\r\n')
end
