#!/usr/bin/env lua

-- This way of referencing is similar to how io.output() works.

-- io.output is a function
-- io.output() with no arguments returns the default output file handle
-- io.output(file_handle) changes the file handle it's keeping track of

local ref =
	function (object)
		return
			-- io.output() is basically this function
			function (obj)
				if obj ~= nil then
					object = obj
				end

				return object
			end
	end

local b = ref('something cool')

print(b())

b('something different')

print(b())
