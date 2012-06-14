#!/usr/bin/env lua

-- The type() wrap and rawtype() implementation

-- Save this under a new name
rawtype = type

-- Wrap orig_type() to respect a __type metamethod
type =
	function (what)
		do
			local tmp = getmetatable(what)

			if tmp ~= nil then
				local tmp2 = rawtype(tmp.__type)

				-- metamethods must be functions, not callable objects (table/userdata with __call())
				-- exceptions: __index and __newindex can be tables
				-- the exception here is __type() may be a string
				if     tmp2 == 'string'   then return tostring(tmp.__type)
				elseif tmp2 == 'function' then return tostring(tmp.__type(what))
				end

				-- if we're at this point, __type is -----.
				-- unacceptable, fall back to rawtype() v
			end
		end

		-- fallback
		return rawtype(what)
	end

