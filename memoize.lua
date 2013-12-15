local counter, guids, funcs

local init =
	function ()
		counter = 0
		funcs   = nil
		guids   = setmetatable({}, { __mode = 'k' })
	end

init()

local memoize = {}

-- turns a call into a list of object ids (NOT SERIALIZING)
-- example: (1, nil, 'cat', '', function() end) -> '3||7|38|27'
local args_to_str =
	function (...)
		local ids = {}

		-- select() is important here
		for i = 1, select('#', ...) do
			local v = select(i, ...)

			if v ~= nil and not guids[v] then
				counter  = counter + 1
				guids[v] = counter
			end

			-- nil is tracked as a vacancy between ||
			ids[i] = guids[v] or ''
		end

		-- the separator is important, should be a non-number
		return table.concat(ids, '|')
	end

memoize.call =
	function (f, ...)
		if not funcs    then funcs = setmetatable({}, { __mode = 'k' }) end
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

memoize.forget_call =
	function (f, ...)
		if not funcs[f] then return end

		-- forget this specific call
		funcs[f][args_to_str(...)] = nil
	end

memoize.forget =
	function (f)
		if f then
			funcs[f] = nil
		else
			init()
		end
	end

memoize.forget_everything = init

return setmetatable(memoize, { __call = function (_, ...) return memoize.call(...) end })
