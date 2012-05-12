#!/usr/bin/env lua

-- Get the name of the running script.
-- (I'm sure this has issues, but it simply works and hasn't failed yet...)
local scriptname =
	function ()
		-- 2 stack level of the function that called scriptname()
		return string.match(debug.getinfo(2).short_src, '[^/]*$')
	end

module(scriptname(), package.seeall)

_M.fprintf =
	function (fd, ...)
		-- fh:write() does have a return value!
		return fd:write(string.format(...))
	end

_M.printf =
	function (...)
		return _M.fprintf(io.stdout, ...)
	end

-- pass any number of strings and this will terminate them when written to the file handle
-- collects the returned values from fh:write() in a table for each arg passed, which is in another table that gets returned
-- this might be slow with lots of args
_M.fprintln =
	function (fh, ...)
		local arg = { ... }
		local ret, x = {}, 0

		for _, v in ipairs(arg) do
			x = x + 1
			ret[x] = { fh:write(v, '\r\n') }
		end

		return ret
	end

_M.println =
	function (...)
		return _M.fprintln(io.stdout, ...)
	end

-- single-quote a string and escape single-quotes in that string
_M.squote =
	function (s)
		return [[']] .. tostring(s):gsub([[']], [[\']]) .. [[']]
	end

-- is interpolatable english?
_M.make_strings_interpolatable =
	function ()
		getmetatable('').__mod =
			function (fmt, args)
				return type(args) == 'table' and fmt:format(unpack(args)) or fmt:format(args)
			end

		return ('%s' % 'test') == 'test' and ('%dnd %s' % { 2, 'test' }) == '2nd test'
	end

-- merge a 2nd table into the 1st
-- accepts only array-like tables
-- oriented for:
--	table.merge = table_merge
--	local some_table = setmetatable({ 1, 2, 3 }, { __index = table })
--	some_table:merge({ 4, 5, 6 }))
_M.table_merge =
    function (self, merge_me)
        assert(type(self)     == 'table') -- assert() is more helpful if you
        assert(type(merge_me) == 'table') -- only test one condition at a time

        local self_len = #self

		for i, v in ipairs(merge_me) do
			self[self_len + i] = v
		end

        return self
    end

-- Use gsub() for match counting (example: helpers.count_matches('aaaa', 'a') -> 4
_M.count_matches =
	function (str, expression)
		return string.gsub(str, expression, '%0')
	end

_M.scriptname = scriptname

return _M
