-- Helpers.

local sgsub   = string.gsub
local sformat = string.format
local smatch  = string.match

local setmeta = setmetatable

local tins = nil -- forward declaration
do
	local orig_tins = table.insert

	tins =
		function (...)
			orig_tins(...)

			return (...)
		end
end

local printf =
	function (...)
		return io.output():write(sformat(...))
	end

local squote =
	function (s)
		return [[']] .. sgsub(s, [[']], [[\']]) .. [[']]
	end

local map =
	function (t, f, ...)
		local ret = {}

		for k, v in pairs(t) do
			ret[k] = f(v, ...)
		end

		return ret
	end

local tos =
	function (o) 
		-- typename, representation
		local t = type(o)

		o = tostring(o)

		if t == 'string' then
			o = sgsub(o, '[\r\n\t]', { ['\r'] = [[\r]], ['\n'] = [[\n]], ['\t'] = [[\t]] })
			o = sgsub(o, '%c', function (c) return string.format('<0x%02X>', string.byte(c)) end)
			o = squote(o)
		elseif
			-- in order of commonality
			t == 'table'	or  
			t == 'function' or
			t == 'userdata' or
			t == 'thread'
		then
			-- subtype, value
			local s, v = smatch(o, '^([^: ]*).-(0x%x*)')

			if s == 'file' then
				t = t .. ':' .. s
			end 

--			o = '-> ' .. v
			o = v .. ':' .. t
		end 

--		return sformat('(%s) %s', t, o)
		return o
	end

local tracked   = setmetatable({}, { __mode = 'k' })
local name_info = setmetatable({}, { __mode = 'k' })

-- create metatable
local index_mt = {}

-- all the magic
local track = nil -- forward declaration
track =
	function (self, name_table)
		name_table = name_table or { '<unknown>' }

		local tmp = {}

		printf('\tadding: [%s]\r\n', table.concat(map(name_table, tos), ']['))

		tracked[tmp] = self
		name_info[tmp] = name_table

		-- descendantly add tables to track
		for k, v in pairs(self) do
			if type(v) == 'table' then
				local names = { unpack(name_table) }

				tins(names, k)

				self[k] = track(v, names)
			end
		end

		setmeta(tmp, index_mt)

		return tmp
	end

local untrack = nil -- forward declaration
untrack =
	function (t)
		local self = tracked[t]

		for k, v in pairs(self) do
			if tracked[v] ~= nil then
				-- retrieve our real table-elements
				self[k] = untrack(v)
			end
		end

		printf('\tremove: [%s]\r\n', table.concat(map(name_info[t], tos), ']['))

		tracked[t] = nil

		return self
	end

index_mt.__index =
	function (t, k)
		local self = t

		-- find our real table with the t userdata
		t = assert(tracked[t], 'attempt to index a nil value')

		local v = t[k]

		-- don't trigger if the element
		-- we're accessing is also tracked
		if tracked[v] ~= nil then
			printf('\taccess: [%s]\r\n', table.concat(tins(map(name_info[self], tos), tos(k)), ']['))
		end

		return v -- this can be nil
	end

index_mt.__newindex =
	function (t, k, v)
		local self = t

		t = assert(tracked[t], 'attempt to index a nil value')

		-- track inner tables as well
		if type(v) == 'table' then
			local tmp = { unpack(name_info[self]) }

			tins(tmp, k)

			if tracked[t[k]] then
				untrack(t[k])
			end

			t[k] = track(v, tmp)
		else
			t[k] = v
		end

		printf('\tupdate: [%s] = %s\r\n', table.concat(tins(map(name_info[self], tos), tos(k)), ']['), tos(v))
	end

-- for lua 5.2
index_mt.__pairs =
	function (s)
		return pairs(tracked[s])
	end

local blah = { a = { b = { c = {}, d = {}, e = {} } } }

--blah = track(blah, '[' .. tos('blah') .. ']')
blah = track(blah, { 'blah' })

-- table to track, parent, name of table
--blah = track(blah, _G, 'blah')

print(blah.a)

for k, v in pairs(blah) do
	print(k, v)
end
