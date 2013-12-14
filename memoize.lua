local guids   = setmetatable({}, { __mode = 'k' })
local counter = 0 -- note: this could eventually overflow...

-- the functions are the weak-keys
local funcs = setmetatable({}, { __mode = 'k' })

-- (1, nil, 'cat', '', function() end) -> '3||7|38|27'
local call_to_str =
	function (...)
		local uids = {}

		for i = 1, select('#', ...) do
			local v = select(i, ...)

			if v ~= nil and not guids[v] then
				counter  = counter + 1
				guids[v] = counter
			end

			v = guids[v] or ''

			uids[i] = v
		end

		return table.concat(uids, '|')
	end

local call =
	function (f, ...)
		if not funcs[f] then
			-- weakly-link keys, as the keys are the objects we track
			funcs[f] = {}
		end

		local call = call_to_str(...)

		if not funcs[f][call] then
			-- table.pack() is magic
			-- constructs a table that preserves nil in the sequence
			funcs[f][call] = table.pack(f(...))
			print('-- called: ' .. tostring(f))
		else
			print('-- not called: ' .. tostring(f))
		end

		return table.unpack(funcs[f][call])
	end

local memoize =
	function (f)
		return function (...) return call(f, ...) end
	end

local unmemoize =
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

return { call = call, func = memoize, drop_cache = unmemoize }
