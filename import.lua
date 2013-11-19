#!/usr/bin/env lua

--- import() -- creates global references to functions in a table,
--- by creating a new _ENV that "passes through" to the original _ENV

-- import(some_module)                                             -- import all functions as globals from some_module
-- import(some_module, 'prefix_')                                  -- import all functions as globals from some_module (whatever in some_module becomes prefix_whatever)
-- import(some_module, { 'only', 'these', 'functions' }             -- import some_module.only, some_module.these, and some_module.functions (selective import)
-- import(some_module, { 'only', 'these', 'functions' }, 'prefix_') -- ^ but with a prefix used when creating the global identifier

-- so we don't wind up creating "chained" _ENV's with import()
-- (creating multiple "inheriting" _ENV's with several calls to import())
local envs = setmetatable({}, { __mode = 'kv' })

local import =
	function (t, ...)
		require('debug')

		local pref, keys

		if select('#', ...) > 1 or (... ~= nil and type(...) == 'table') then
			keys, pref = ...
		else
			pref, keys = ...
		end

		keys = keys or {}
		pref = pref or ''

		-- table-empty check
		if not next(keys) then
			for k in pairs(t) do
				table.insert(keys, k)
			end
		end

		local new_env = envs[_ENV] or setmetatable({}, { __index = _ENV, __newindex = _ENV })

		-- if envs[_ENV], we wind up adding to _ENV
		for _, k in pairs(keys) do
			rawset(new_env, pref .. k, t[k])
		end

		if not envs[new_env] then
			envs[new_env] = new_env
			debug.setupvalue(debug.getinfo(1, 'f').func, 1, new_env)
			-- debug
			print('env replaced')
		else
			-- debug
			print('env not replaced')
		end
	end

import(string, { 'reverse', 'rep', 'sub' }, 's')

local f =
	function ()
		import(io)
		import(io, 'io_')

		write('hello thar!\r\n')
		io_write('blah. ~\r\n')
	end

print(sreverse('cat'), srep('donut', 5), ssub('abcdefg', 3, 6))


f()
