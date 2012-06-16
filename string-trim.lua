#!/usr/bin/env lua

local ssub  = string.sub
local sfind = string.find

module('trim')

-- Each of these functions return a 2nd value letting
-- the caller know if the string was changed at all

ltrim =
	function (s)
		local res = s
		local tmp = sfind(res, '%S')

		-- string.sub() will create a duplicate if
		-- called with the first and last index
		-- (str_sub() in lstrlib.c)

		if not tmp then
			res = ''
		elseif tmp ~= 1 then
			res = ssub(res, tmp)
		end

		return res, res ~= s
	end

rtrim =
	function (s)
		local res = s
		local tmp = sfind(res, '%S%s*$')

		if not tmp then
			res = ''
		elseif tmp ~= #res then
			res = ssub(res, 1, tmp)
		end
				
		return res, res ~= s
	end

trim =
	function (s)
		local res1, stat1 = ltrim(s)
		local res2, stat2 = rtrim(res1)

		return res2, stat1 or stat2
	end

return _M

