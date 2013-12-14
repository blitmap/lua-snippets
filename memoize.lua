-- a table to track all objects passed to any memoized functions
local guids = setmetatable({}, { __mode = 'k' })

-- note: this could *eventually* overflow -- unlikely for practical use
local counter = 0

-- the memoized functions are the weak-keys
local funcs = setmetatable({}, { __mode = 'k' })

-- example: (1, nil, 'cat', '', function() end) -> '3||7|38|27'
local args_to_str =
	function (...)
		local ids = {}

		-- use of select() is important here
		for i = 1, select('#', ...) do
			local v = select(i, ...)

			if v ~= nil and not guids[v] then
				counter  = counter + 1
				guids[v] = counter
			end

			-- nil becomes empty-string
			ids[i] = guids[v] or ''
		end

		-- the separator is important, but can be anything
		return table.concat(ids, '|')
	end

local call =
	function (f, ...)
		if not funcs[f] then funcs[f] = {} end

		local call    = args_to_str(...)
		local returns = funcs[f]

		if not returns[call] then
			funcs[f][call] = table.pack(f(...))
			print(('call signature: %q \t calling: %s'):format(call, f))
		else
			print(('call signature: %q \t not calling: %s'):format(call, f))
		end

		return table.unpack(funcs[f][call])
	end

local clear =
	function (f)
		-- no function specified, reset memoize module (essentially)
		if not f then
			-- replace/clear guid table, guid counter, drop function call caches
			guids   = setmetatable({}, { __mode = 'k' })
			counter = 0
			funcs   = {}
		else
			funcs[f] = nil
		end
	end

return setmetatable({ call = call, forget = clear }, { __call = function (_, ...) return call(...) end })
