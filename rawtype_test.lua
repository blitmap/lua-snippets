-- Testing four scenarios:
-- 1) An object with no metatable, should respond like original type()
-- 2) An object with a metatable and string .__type, should return the value of .__type
-- 3) An object with a metatable and function .__type, should return the result of .__type(object)
-- 4) An object with a metatable and callable .__type, should return the result of .__type(object) -- __type can be anything with a __call metamethod defined

require('rawtype')

local a = 'i am a string' -- I'm just a simple string. :'(
local b = newproxy(true)
local c = newproxy(true)
local d = newproxy(true)

-- b's type is a bear :D  i swear; no really
getmetatable(b).__type = 'bear'

-- c's type is a pdp11 :o  fancy smancy
getmetatable(c).__type = function () return 'pdp11' end

-- d is peanuts.  it just is.
do
    local tmp = newproxy(true)
    getmetatable(tmp).__call = function () return 'peanuts' end

    getmetatable(d).__type = tmp
end

print(type(a), rawtype(a))
print(type(b), rawtype(b))
print(type(c), rawtype(c))
print(type(d), rawtype(d))
