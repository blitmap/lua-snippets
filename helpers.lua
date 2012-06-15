#!/usr/bin/env lua

---- string-related
local sgsub   = string.gsub
local smatch  = string.match
local sformat = string.format
local tos     = tostring
local string  = string

---- table-related
local table    = table
local next     = next
local getmeta  = getmetatable
local setmeta  = setmetatable -- can only use on tables
local dsetmeta = debug.setmetatable
local tcat     = table.concat
local tins     = table.insert

---- debug-related
local dgetinfo = debug.getinfo

---- math-related
local mfloor = math.floor
local math   = math

---- generator-related
local pairs  = pairs
local ipairs = ipairs

---- file-related
local ioutput = io.output

---- random...-related
local type   = type
local pcall  = pcall
local assert = assert
local select = select
local unpack = unpack

module('helpers', package.seeall)

-- {{{ scriptname() --

-- get the script name
local scriptname =
	function ()
		-- 2 stack level of the function that called scriptname()
		return smatch(dgetinfo(2).short_src, '[^/]*$')
	end

-- }}}

-- just the script itself
assert(scriptname() == 'helpers.lua', 'scriptname() is incorrect')

_G.scriptname = scriptname

-- {{{ fprintf()

local fprintf =
	function (fh, ...)
		-- fh:write() does have a return value!
		return fh:write(sformat(...))
	end

-- }}}

do
    local dev_null = assert(io.open('/dev/null', 'w'))

    assert(fprintf(dev_null, 'test'), 'fprintf() is incorrect')

	-- REMEMBER TO CLOSE
    assert(dev_null:close())
end

_G.fprintf = fprintf

-- {{{ printf()

local printf =
	function (...)
		return fprintf(ioutput(), ...)
	end

-- }}}

do
	-- save the default output file
	local old  = ioutput()
	local null = assert(io.output('/dev/null'))

	assert(old ~= null)

	assert(printf('test'), 'printf() is incorrect')

	-- *CLOSE* /dev/null first
	assert(ioutput():close())

	-- revert to old default output
	assert(ioutput(old) == old)
end

_G.printf = printf

-- {{{ fprintln()

-- pass any number of strings and this will terminate them when written to the file handle
-- collects the returned values from fh:write() in a table for each arg passed, which is in another table that gets returned
-- this might be slow with lots of args
local fprintln =
	function (fh, ...)
		local ret = { true }

		-- the point of this loop is to avoid simply doing a table.concat()
		-- which would create a large string to *then* write to the file
		for _, v in ipairs({ ... }) do
			ret = { fh:write(v, '\r\n') }

			-- something went wrong writing to fh
			if ret[1] ~= true then break end
		end

		return unpack(ret)
	end

-- }}}

do
    local dev_null = assert(io.open('/dev/null', 'w'))

    assert(fprintln(dev_null, 'test', 'me', 'baby'), 'fprintln() is incorrect')

    -- REMEMBER TO CLOSE
    assert(dev_null:close())
end

_G.fprintln = fprintln

-- {{{ println()

local println =
	function (...)
		return fprintln(ioutput(), ...)
	end

-- }}}

do
    -- save the default output file
    local old  = ioutput()
    local null = assert(ioutput('/dev/null'))

    assert(old ~= null)

    assert(println('testme!', 'no test me!'), 'println() is incorrect')

    -- *CLOSE* /dev/null first
    assert(ioutput():close())

    -- revert to old default output
    assert(ioutput(old) == old)
end

_G.println = println

-- {{{ range()

-- range(start)             returns an iterator from 1 to a (step = 1)
-- range(start, stop)       returns an iterator from a to b (step = 1)
-- range(start, stop, step) returns an iterator from a to b, counting by step.
local range =
	function (i, to, inc)
		do
			local i_type = type(i)

			if i_type ~= 'number' then
				-- behave like a call to ipairs() with no arguments
				error(sformat([[bad argument #1 to 'range' (number expected, got %s)]], i_type == 'nil' and 'no value' or i_type))
			end
		end

		if not to then
			to = i
			i  = to == 0 and 0 or (to > 0 and 1 or -1)
		end

		-- we don't have to do the to == 0 check
		-- 0 -> 0 with any inc would never iterate
		inc = inc or (i < to and 1 or -1)

		-- step back (once) before we start
		i = i - inc

		return function () if i == to then return nil end i = i + inc return i, i end
	end

-- }}}

do
	local tmp = {}

	for i in range(10) do tmp[i] = i end

	assert(#tmp == 10, 'range() is incorrect')
end

_G.range = range

-- {{{ squote()

-- single-quote a string and escape single-quotes in that string
local squote =
	function (s)
		return [[']] .. sgsub(tos(s), [[']], [[\']]) .. [[']]
	end

-- }}}

assert(squote([[derp'test]]) == [['derp\'test']], 'squote() is incorrect')

_G.string.squote = squote

-- {{{ count_matches()

-- Use string.gsub() for match counting (example: helpers.count_matches('aaaa', 'a') -> 4
local count_matches = nil -- forward-declaration

do
	count_matches =
		function (self, pattern)
			return select(2, sgsub(self, pattern, '%0'))
		end
end

-- }}}

assert(count_matches('aaaa', 'a') == 4)

_G.string.count_matches = count_matches

-- {{{ str_mod()
local str_mod =
	function (fmt, args)
		return sformat(fmt, unpack(type(args) == 'table' and args or { args }))
	end

-- }}}

do
	local err_msg = 'str_mod() is incorrect'

	assert(str_mod('1st %s',  'test')        == '1st test', err_msg)
	assert(str_mod('%dnd %s', { 2, 'test' }) == '2nd test', err_msg)
end

getmeta('').__mod = str_mod

-- {{{ num_each()

-- make numbers a little more interesting:
-- (5):times(print)
local num_each =
	function (self, f, ...)
		for i = 1, self do f(i, ...) end
	end

-- }}}

do
	local x = 0

	num_each(3, function (y) x = x + y end)

	assert(x == 6, 'num_each() is incorrect')
end

-- {{{ num_times()

-- like :each() but doesn't provide the current
-- number as the first arg on each iteration
local num_times =
	function (self, f, ...)
		for i = 1, self do f(...) end
	end

-- }}}

do
	local x = 0

	num_times(6, function () x = x + 1 end)

	assert(x == 6, 'num_times() is incorrect')
end

do
	local tmp = {}

	tmp.__index = tmp
	tmp.each    = num_each
	tmp.times   = num_times

	dsetmeta(0, tmp)
end

-- {{{ func_chain()

local func_chain =
	function (self)
		-- note the arg shaving
		-- everything from self(...) SHOULD be discarded
		return function (...) self(...) return (...) end
	end

-- }}}

do
	local tmp = { 1, 2, 3 }

	assert(func_chain(function () end)(tmp) == tmp, 'func_chain() is incorrect')
end

-- {{{ func_wrap()

local func_wrap =
	function (self, outer)
		return
			function (...)
				return outer(self(...))
			end
	end
		
-- }}}

do
	local tmp = function (x) return x + 1 end

	assert(func_wrap(tmp, tmp)(4) == 6, 'func_wrap() is incorrect')
end

-- {{{ tmerge()

-- sequence portion of the 2nd table is inserted
-- after the sequence portion of the 1st table
-- hash values are "overlaid" from the 2nd table to the 1st
-- oriented for:
--	local some_table = setmetatable({ 1, 2, 3 }, { __index = table })
--	some_table:merge({ 4, 5, 6 }))
local tmerge =
    function (self, merge_me)
        assert(type(self)     == 'table') -- assert() is more helpful if you
        assert(type(merge_me) == 'table') -- only test one condition at a time

		local len = #self

		for k, v in pairs(merge_me) do
			self[type(k) == 'number' and len + k or k] = v
		end

        return self
    end

-- }}}

do
	local tmp = { 1, 2, 3 }
	local err_msg = 'tmerge() is incorrect'

	tmp = tmerge(tmp, { 4, 5, 6 })

	for i = 1, #tmp do
		assert(tmp[i] == i, err_msg)
	end
end

_G.table.merge = tmerge

-- {{{ tis_empty()

-- Use this instead of #(some_table) ~= 0
-- fetching the length is much more expensive than
-- seeing if it has an initial index to iterate with
local tis_empty =
	function (self)
		return next(self) == nil
	end

-- }}}

assert(tis_empty({}))
assert(not tis_empty({ 'something' }))

_G.table.is_empty = tis_empty

-- {{{ func_to_sequence() -- accepts an iterator, returns a sequence of collected values

local func_to_sequence =
	function (i, i_self, ...)
		local seq, ret = {}, { ... }

		while true do
			-- debug: print(i, i_self, unpack(ret))

			ret = { i(i_self, unpack(ret)) }

			-- iterators signify their
			-- end with the first return
			if ret[1] == nil then
				break
			end

			seq[ret[1]] = ret[2]
		end

		return seq
	end

-- }}}

do
	local err_msg = 'func_to_sequence() is incorrect'

	assert(func_to_sequence(ipairs({ 1, 2, 3, 4, 5 }))[5] == 5, err_msg)
	assert(func_to_sequence(range(5))[5]                  == 5, err_msg)
end

do
	local tmp   = {}

	tmp.__index     = tmp
	tmp.chain       = func_chain
	tmp.wrap        = func_wrap
	tmp.to_sequence = func_to_sequence

	dsetmeta(function () end, tmp)
end

-- {{{ tsort()

local tsort = nil -- forward declaration

do
	local orig_tsort = table.sort

	tsort = func_chain(orig_tsort)
end

-- }}}

assert(tsort({ 'c', 'a', 'b' })[2] == 'b')

_G.table.sort = tsort

-- {{{ tcopy()

-- makes a copy of the table (a shallow copy)
-- also makes a shallow copy if the original table's metatable (if available)
local tcopy = nil -- forward declaration

tcopy =
	function (self)
		local ret = {}

		-- Even though we copy a potential metatable after this, we're using
		-- rawset() on ret (just in case) the ordering of this changes later
		for k in pairs(self) do rawset(ret, k, rawget(self, k)) end

		do
			local tmp = getmeta(self)

			if tmp ~= nil then
				tmp = tcopy(tmp)
			end

			-- sets a metatable if it's available
			setmeta(ret, tmp)
		end

		return ret
	end

-- }}}

do
	local tmp_mt = { 1, 2, 3 }
	local tmp    = setmeta({ 1, 2, 3 }, tmp_mt)

	assert(tcopy(tmp) ~= tmp)
	assert(tcopy(tmp)[2] == 2)

	assert(getmeta(tcopy(tmp)) ~= tmp_mt)
	assert(getmeta(tcopy(tmp))[2] == 2)
end

_G.table.copy = tcopy

--  {{{ tdeep_copy()

-- deep copy a table: copy the nested tables
-- this probably shouldn't be recursive. :x
local tdeep_copy = nil -- forward declaration

tdeep_copy =
	function (self)
		local ret = {}

		-- Even though we copy a potential metatable after this, we're using
		-- rawset() on ret (just in case) the ordering of this changes later
		for k in pairs(self) do
			local v = rawget(self, k)
			rawset(ret, k, type(v) == 'table' and tdeep_copy(v) or v)
		end

		do
			local tmp = getmeta(self)

			if tmp ~= nil then
				tmp = tdeep_copy(tmp)
			end

			-- sets a metatable if it's available
			setmeta(ret, tmp)
		end

		return ret
	end

-- }}}

do
	local a = setmeta({ test = 'test' }, { test2 = { test3 = 'test' } })
	local b = tdeep_copy(a)

	local err_msg = 'tdeep_copy() is incorrect'
	
	assert(a ~= b, err_msg) assert(a.test == b.test, err_msg)

	do
		local a_mt, b_mt = getmeta(a), getmeta(b)

		assert(a_mt ~= b_mt,                         err_msg)
		assert(a_mt.test2       ~= b_mt.test2,       err_msg)
		assert(a_mt.test2.test3 == b_mt.test2.test3, err_msg)
	end
end

_G.table.deep_copy = tdeep_copy

-- {{{ treverse()

-- works with the sequence part of the table only
local treverse = nil -- forward declaration

do
	local mfloor = math.floor

	treverse =
		function (self)
			local len = #self

			-- we don't actually need math.floor(len / 2)
			-- since we step by 1
			for i = 1, len / 2 do
				self[i], self[len] = self[len], self[i]
				len = len - 1
			end

			return self
		end
end

-- }}}

do
	local tmp = { 1, 2, 3 }
	
	treverse(tmp)

	assert(tmp[1] == 3 and tmp[3] == 1, 'treverse() is incorrect')
end

_G.table.reverse = treverse

-- {{{ tmap()

-- works on the sequence part of the table
-- IT IS NOT MAP()'S JOB TO COLLECT RETURN VALUES
-- you can provide a list of arguments to supply to the function (after) the value
local tmap =
	function (self, f, ...)
		for i = 1, #self do
			f(self[i], ...)
		end

		return self
	end

-- }}}

do
	local sum = 0

	tmap({ 1, 2, 3 }, function (x) sum = sum + x end)

	assert(sum == 6, 'tmap() is incorrect')
end

_G.table.map = tmap

-- {{{ timap()

-- operates on the sequence part of the table only
-- inplace map(), return values of f take the place of their elements
-- elements are shifted down, nil returns are discarded
local timap =
	function (self, f, ...)
		local x = 0

		for i = 1, #self do
			local tmp = f(self[i], ...)

			if tmp ~= nil then
				x = x + 1
				self[x] = tmp
			end
		end

		return self
	end

-- }}}

assert(timap({ 1, 2, 3 }, function (x) return x ~= 2 and x or nil end)[2] == 3)
assert(timap({ 1, 2, 3 }, tos)[2] == '2')

_G.table.imap = timap

-- {{{ tinject()

local tinject =
    function (self, f, ...)
        local args = { ... }

        for i = 1, #self do
            args = { f(self[i], unpack(args)) }
        end

        return unpack(args)
    end

-- }}}

assert(tinject({ 1, 2, 3 }, function (x, y) return x + y        end, 0) == 6)
assert(tinject({ 1, 2, 3 }, function (x, y) return x + (y or 0) end)    == 6)

_G.table.inject = tinject

-- {{{ treduce()

-- accepts a table, a binary function, and (optionally) 1 initial argument
local treduce =
	function (self, f, ...)
		-- arg number restriction, c wut i did thar?
		-- tinject() actually allows for more flexibility
		return tinject(self, function (x, y) return f(x, y) end, (...))
	end

-- }}}

assert(treduce({ 1, 2, 3 }, function (x, y) return x + (y or 0) end) == 6)

_G.table.reduce = treduce

-- {{{ tbrigade()

-- takes a list of functions and the args to provide to them
local tbrigade =
	function (self, ...)
		-- use the value itself as the function to call in table.map()
		tmap(self, function (func, ...) func(...) end, ...)
	end

local txmap = tbrigade

-- }}}

do
	local x = 0
	local tmp = function (y) x = x + y end

	tbrigade({ tmp, tmp, tmp, tmp }, 1)

	assert(x == 4, 'tbrigade() is incorrect')
end

_G.table.brigade = tbrigade
_G.table.xmap    = txmap

-- {{{ tjoin()

-- A table.join() that respects __tostring metamethods on the table elements it's joining.
local tjoin =
	function (self, ...)
		return tcat(timap(tcopy(self), tos), ...)
	end

-- }}}

assert(tjoin({ 1, 2, 3 }, ',') == '1,2,3')
assert(pcall(tjoin, {}, '', -1, 1) == false) -- this should fail, invalid range

_G.table.join = tjoin

-- {{{ tclear()

-- Clear an existing table.
local tclear =
	function (self)
		for k in pairs(self) do
			rawset(self, k, nil)
		end

		return self
	end

-- }}}

assert(tis_empty(tclear({ 1, 2, 3 })))

_G.table.clear = tclear

-- {{{ tkeys()

local tkeys =
	function (self)
		local tmp, x = tcopy(self), 0

		tclear(self)

		for k in pairs(tmp) do
			x = x + 1
			rawset(self, x, k)
		end

		return self
	end

-- }}}

assert(tkeys({ a = 1 })[1] == 'a')

_G.table.keys = tkeys

-- {{{ tvalues()

local tvalues =
	function (self)
		local tmp, x = tcopy(self), 0

		tclear(self)

		for k in pairs(tmp) do
			x = x + 1
			rawset(self, x, rawget(tmp, k))
		end

		return self
	end

-- }}}

assert(tvalues({ 'a' })[1] == 'a')

_G.table.values = tvalues

-- {{{ tcompress()

-- squish down the numeric-key parts of the table
local tcompress =
	function (self)
		local keys, x = {}, 0
		local vals = {}
		
		for k in pairs(self) do
			if type(k) == 'number' then
				x = x + 1
				keys[x]  = k
				vals[k] = rawget(self, k)
				rawset(self, k, nil)
			end
		end

		tsort(keys)

		x = 0

		for i, k in ipairs(keys) do
			rawset(self, i, vals[k])
		end

		return self
	end
				
-- }}}

assert(#(tcompress({ [1] = 'cat', [3] = 'dog', [5] = 'horse' }))   == 3)
assert(  tcompress({ [1] = 'cat', [3] = 'dog', [5] = 'horse' })[2] == 'dog')

_G.table.compress = tcompress

-- {{{ tremove_if()

-- Pass a table (doesn't have to be an array), with a function, the function is
-- called on each value (pairs()) and the pair is removed if f(value) returns true
-- if the f(value) returns true and is in the sequence part, table.remove() is used to shift remaining elements down
local tremove_if =
	function (self, f, ...)
		local tmp = tkeys(tcopy(self))

		for k in pairs(self) do
			if f(rawget(self, k)) then
				rawset(self, k, nil)
			end
		end

		tcompress(self)

		return self
	end

-- }}}

-- 2 gets removed as it proves true for being an even value, 3 should be shifted down
assert(tremove_if({ 1, 2, 3 }, function (x) return x % 2 == 0 end)[2] == 3)
assert(tremove_if({ derp = '' }, function (x) return type(x) == 'string' end)['derp'] == nil)

_G.table.remove_if = tremove_if

-- {{{ ttranspose()

local ttranspose =
	function (self)
		local tmp = tcopy(self)

		tclear(self)

		for k in pairs(tmp) do
			-- key, value = value, key
			rawset(self, rawget(tmp, k), k)
		end

		return self
	end

-- }}}

assert(ttranspose({ 'cat' })['cat'] == 1)

_G.table.transpose = ttranspose

-- {{{ is_callable()

-- lua doesn't allow for:
-- (setmetatable({}, { __call = setmetatable({}, { __call = function () return 4 end }) }))() -- no chaining __call()'s :'(
-- as a result, is_callable() is much simpler, but used to be incredibly clever. :'(
local is_callable =
	function (what)
		if type(what) == 'function' then
			return true
		end

		local what_mt = getmeta(what)

		if what_mt ~= nil and type(what_mt.__call) == 'function' then
			return true
		end

		return false
	end

-- }}}

do
	local err_msg = 'is_callable() is incorrect'

	assert(function () end, err_msg)
	assert(is_callable(setmeta({}, { __call = function () end }), err_msg))
	assert(not is_callable(setmeta({}, { __call = 4 })), err_msg)
	assert(not is_callable(4), err_msg)

	do
		local a, b = {}, {}

		-- circularity -- maybe circuhilarity? :o)
		setmeta(a, { __call = b })
		setmeta(b, { __call = a })

		assert(not is_callable(a), err_msg)
	end
end

_G.is_callable = is_callable

-- {{{ valof()

-- call `what' if it is callable until it is not
-- great for chained functions
local valof =
	function (what)
		while is_callable(what) do
			what = what()
		end

		return what
	end

-- }}}

assert(valof(4)                                               == 4)
assert(valof(function () return 4 end)                        == 4)
assert(valof(function () return function () return 4 end end) == 4)

_G.valof = valof

-- {{{ lit() & identity() (same function)

-- lit(something) returns something exactly as it was passed
-- lit() -> literal, you wouldn't imagine how useful this is

local lit =
	function (what)
		return what
	end

local identity = lit

-- }}}

-- hahaha
assert(rawequal(lit(4), 4))

_G.lit      = lit
_G.identity = identity

return _M
