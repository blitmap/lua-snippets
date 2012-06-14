-- Testing four scenarios:
-- 1) An object with no metatable, should respond like original type()
-- 2) An object with a metatable and string .__type, should return the value of .__type
-- 3) An object with a metatable and function .__type, should return the result of .__type(object)
-- 4) An object with a metatable and callable .__type, should fail and return rawtype(object)
		-- metamethods *must* be functions, not callable objects, but __type may be a string like __index may be a table

-- add the enclosing directory as a search path for
-- require(); concatenation order is specific here
package.path = '../?.lua;' .. package.path

require('rawtype')

local a = 'i am a string' -- I'm just a simple string. :'(
local b = setmetatable({}, { __type = 'bear' })
local c = setmetatable({}, { __type = function () return 'pdp11' end })
local d = setmetatable({}, { __type = setmetatable({}, { __call = function () return 'peanuts' end }) })

print(type(a), rawtype(a))
print(type(b), rawtype(b))
print(type(c), rawtype(c))
print(type(d), rawtype(d)) -- this should print 'table' twice, its __type is not rawly a function
