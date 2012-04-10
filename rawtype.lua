

-- {{{ The type() wrap and rawtype() implementation

-- Save this.
local orig_type = type

-- Wrap orig_type() to respect a __type metamethod
type =
	function (what)
		local tmp = getmetatable(what)

		-- Nothing special here,
		-- behave like the original type()
		if not tmp or not tmp.__type then
			return orig_type(what)
		end

		local __type_metafield = tmp.__type

		-- If a __type (metafield?) is defined,
		-- call it if it is callable, or return
		-- its member value otherwise.
		if
			orig_type(__type_metafield) == 'function' or
			getmetatable(__type_metafield).__call
		then
			return __type_metafield(what)
		else
			return __type_metafield
		end
	end

-- Alias to that.
rawtype = orig_type

-- }}}

local a = 'i am a string'
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
