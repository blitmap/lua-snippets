#!/usr/bin/env lua

---- string-related
local sgsub   = string.gsub
local smatch  = string.match
local sformat = string.format
local tos     = tostring

---- table-related
local next     = next
local getmeta  = getmetatable
local setmeta  = setmetatable -- can only use on tables
local dsetmeta = debug.setmetatable
local tcat     = table.concat
local tins     = table.insert
local trem     = table.remove

---- debug-related
local dgetinfo = debug.getinfo

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

-- {{{ scriptname() --

-- get the script name
scriptname =
	function ()
		-- 2 stack level of the function that called scriptname()
		return smatch(dgetinfo(2).short_src, '[^/]*$')
	end

-- }}}

-- {{{ fprintf()

fprintf =
	function (fh, ...)
		-- fh:write() does have a return value!
		return fh:write(sformat(...))
	end

-- }}}

-- {{{ printf()

printf =
	function (...)
		return fprintf(ioutput(), ...)
	end

-- }}}

-- {{{ fprintln()

-- pass any number of strings and this will terminate them when written to the file handle
-- collects the returned values from fh:write() in a table for each arg passed, which is in another table that gets returned
-- this might be slow with lots of args
fprintln =
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

-- {{{ println()

println =
	function (...)
		return fprintln(ioutput(), ...)
	end

-- }}}

-- {{{ range()

-- range(start)             returns an iterator from 1 to a (step = 1)
-- range(start, stop)       returns an iterator from a to b (step = 1)
-- range(start, stop, step) returns an iterator from a to b, counting by step.
range =
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

-- {{{ string.squote()

-- single-quote a string and escape single-quotes in that string
local squote =
	function (s)
		return [[']] .. sgsub(tos(s), [[']], [[\']]) .. [[']]
	end

string.squote = squote

-- }}}

-- {{{ string.count_matches()

-- Use string.gsub() for match counting (example: helpers.count_matches('aaaa', 'a') -> 4
local count_matches =
	function (self, pattern)
		return select(2, sgsub(self, pattern, '%0'))
	end

string.count_matches = count_matches

-- }}}

-- {{{ getmetatable('').__mod() (str_mod())

local str_mod =
	function (fmt, args)
		return sformat(fmt, unpack(type(args) == 'table' and args or { args }))
	end

getmeta('').__mod = str_mod

-- }}}

-- {{{ getmetatable(0).each() (num_each())

-- make numbers a little more interesting:
-- (5):each(print)
local num_each =
	function (self, f, ...)
		for i = 1, self do f(i, ...) end
	end

-- }}}

-- {{{ getmetatable(0).times() (times())

-- like :each() but doesn't provide the current
-- number as the first arg on each iteration
local num_times =
	function (self, f, ...)
		-- arg shaving :D
		num_each(self, function (_, ...) return f(...) end, ...)
--		for i = 1, self do f(...) end
	end

-- }}}

do
	local tmp = {}

	tmp.__index = tmp
	tmp.each    = num_each
	tmp.times   = num_times

	dsetmeta(0, tmp)
end

-- {{{ getmetatable(function () end).chain() (func_chain())

local func_chain =
	function (self)
		-- note the arg shaving
		-- everything from self(...) SHOULD be discarded
		return function (...) self(...) return (...) end
	end

-- }}}

-- {{{ getmetatable(function () end).wrap() (func_wrap())

local func_wrap =
	function (self, outer)
		return
			function (...)
				return outer(self(...))
			end
	end
		
-- }}}

do
	local tmp   = {}

	tmp.__index     = tmp
	tmp.chain       = func_chain
	tmp.wrap        = func_wrap

	dsetmeta(function () end, tmp)
end

-- {{{ table.merge()

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

table.merge = tmerge

-- }}}

-- {{{ table.is_empty()

-- Use this instead of #(some_table) ~= 0
-- fetching the length is much more expensive than
-- seeing if it has an initial index to iterate with
local tis_empty =
	function (self)
		return next(self) == nil
	end

table.is_empty = tis_empty

-- }}}

-- {{{ to_table() -- returns a table of the collected values from the args returned by a generator

-- example: to_table(ipairs({ 'a', 'b', 'c' }))
-- this is not redundant, believe me ^

to_table =
	function (...)
		local ret = {}

		for k, v in ... do
			ret[k] = v
		end

		return ret
	end

-- }}}

-- {{{ table.sort() (tsort())

-- I feel sexy.
local tsort = table.sort:chain()

table.sort = tsort

-- }}}

-- {{{ table.copy() (tcopy())

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

table.copy = tcopy

-- }}}

-- {{{ table.deep_copy() (tdeep_copy())

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

table.deep_copy = tdeep_copy

-- }}}

-- {{{ table.reverse() (treverse())

-- works with the sequence part of the table only
local treverse =
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

table.reverse = treverse

-- }}}

-- {{{ table.map() (tmap())

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

table.map = tmap

-- }}}

-- {{{ table.imap() (timap())

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

table.imap = timap

-- }}}

-- {{{ table.inject() (tinject())

local tinject =
    function (self, f, ...)
        local args = { ... }

        for i = 1, #self do
            args = { f(self[i], unpack(args)) }
        end

        return unpack(args)
    end

table.inject = tinject

-- }}}

-- {{{ table.reduce() (treduce())

-- accepts a table, a binary function, and (optionally) 1 initial argument
local treduce =
	function (self, f, ...)
		-- arg number restriction, c wut i did thar?
		-- tinject() actually allows for more flexibility
		return tinject(self, function (x, y) return f(x, y) end, (...))
	end

table.reduce = treduce

-- }}}

-- {{{ table.brigade (tbrigade())

-- table.brigade() is really just a reverse table.map() where each element of the table
-- passed is being called, instead of a function being provided to the table.map() directly
-- table.brigade({ print,         print,         print         }, 'hello world') -- the difference
--     table.map({ 'hello world', 'hello world', 'hello world' }, print        ) -- these do the same thing though

local tbrigade =
	function (self, ...)
		-- use the value itself as the function to call in table.map()
		tmap(self, function (func, ...) func(...) end, ...)
	end

local txmap = tbrigade

table.brigade = tbrigade
table.xmap    = txmap

-- }}}

-- {{{ table.join() (tjoin())

-- A table.join() that respects __tostring metamethods on the table elements it's joining.
local tjoin =
	function (self, ...)
		return tcat(timap(tcopy(self), tos), ...)
	end

table.join = tjoin

-- }}}

-- {{{ table.clear() (tclear())

-- Clear an existing table. (DO NOT CREATE A NEW TABLE)
local tclear =
	function (self)
		for k in pairs(self) do
			rawset(self, k, nil)
		end

		return self
	end

table.clear = tclear

-- }}}

-- {{{ table.keys() (tkeys())

local tkeys =
	function (self)
		local ret, x = {}, 0

		for k in pairs(self) do
			x = x + 1
			ret[x] = k
		end

		return ret
	end

table.keys = tkeys

-- }}}

-- {{{ table.vals() (tvals())

local tvals =
	function (self)
		local ret, x = {}, 0

		for _, v in pairs(self) do
			x = x + 1
			ret[x] = v
		end

		return ret
	end

table.vals = tvals

-- }}}

-- {{{ table.maxn() (tmaxn()) -- get highest numeric key, not the same as the length operator

local tmaxn =
	function (self)
		local tmp = nil

		for k in pairs(self) do
			if type(k) == 'number' and (tmp == nil or k > tmp) then
				tmp = k
			end
		end

		return tmp
	end

table.maxn = tmaxn
		
-- }}}

-- {{{ table.remove_if() (tremove_if()) -- in-place removal of elements if they fail the predicate

local tremove_if =
	function (self, f, ...)
		-- iterate backward for removals
		for i = #self, 1, -1 do
			if f(self[i], ...) then
				trem(self, i) -- implicit table.compact()
			end
		end

		return self
	end

table.remove_if = tremove_if

-- }}}

-- {{{ table.filter() (tfilter()) -- create a new table from those that succeed the predicate

local tfilter =
	function (self, f, ...)
		local ret, x = {}, 0

		for _, v in ipairs(self) do
			if f(v, ...) then
				x = x + 1
				ret[x] = v
			end
		end

		return ret
	end

table.filter = tfilter

-- }}}

-- {{{ table.compact() (tcompact())

-- create a new table with the numeric keys and associated values 'compacted' down into a constiguous sequence

local tcompact =
	function (self)
		local keys   = tfilter(tkeys(self), function (x) return type(x) == 'number' end)
		local ret, x = {}, 0

		for _, k in ipairs(keys) do
			x = x + 1
			ret[x] = self[k]
		end

		return ret
	end

table.compact = tcompact

-- }}}

-- {{{ table.stripe() (tstripe())

local tstripe =
	function (self, stripe)
		-- start after the last element
		-- table.insert() pushes existing values to the end
		for i = #self + 1, 2, -1 do
			tins(self, i, stripe)
		end

		return self
	end

table.stripe = tstripe

-- }}}

-- {{{ is_callable()

-- lua doesn't allow for:
-- (setmetatable({}, { __call = setmetatable({}, { __call = function () return 4 end }) }))() -- no chaining __call()'s :'(
-- as a result, is_callable() is much simpler, but used to be incredibly clever. :'(
is_callable =
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

-- {{{ valof()

-- call `what' if it is callable until it is not
-- great for chained functions
valof =
	function (what)
		while is_callable(what) do
			what = what()
		end

		return what
	end

-- }}}

-- {{{ lit() & identity() (same function)

-- lit(something) returns something exactly as it was passed
-- lit() -> literal, you wouldn't imagine how useful this is

lit =
	function (what)
		return what
	end

identity = lit

-- }}}
