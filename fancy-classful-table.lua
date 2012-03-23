#!/usr/bin/env lua

-- First lookup in list, then in table.
local list    = {}
local list_mt = { __index = function (t, key) return list[key] or table[key] end }

-- I'm not sure if this is the best way of storing private data.
-- List objects are the keys in private_data, the value tables
-- are collected as the objects used as keys are collected.
-- As long as the list object lives, the private data lives, but the private
-- data doesn't keep the objects themselves from being collected (weak reference).
local private_data = setmetatable({}, { __mode = 'k' })

-- It's all just a glorified table. >.<
local new =
	function (...)
		-- Save the initial size of what we're keeping in the table.
		--
		-- Right now it is a waste to keep the size in a table of its own but
		-- I haven't yet determined what else I might want to keep private.
		private_data[arg] = { size = #arg }

		-- Return the already-created table.
		return setmetatable(arg, list_mt)
	end

-- list(1, 2, 3) -> { 1, 2, 3 }
-- I'm avoiding a convention for what to call the
-- constructor by instead making the list table callable.
setmetatable(list, { __call = function (_, ...) return new(...) end })

-- This could be better.
-- Or it could just simply (& stupidly) be list.size = function (self) return #self end
list.size =
	function (self)
		-- This is my attempt to avoid updating
		-- the size if I don't have to.
		-- We are assuming numeric keys are constiguous
		-- (no { [1] = true, [2] = nil, [3] = true })

		local sz = private_data[self].size

		if
			-- The one after should not be occupied.
			self[sz + 1] ~= nil or
			-- The size-index has no value.
			(sz ~= 0 and self[sz] == nil)
		then
			sz = #self
		end

		-- list.size() should be the only
		-- thing that touches this private data
		-- After all, it self-updates when :size() is called.
		private_data[self].size = sz

		return sz
	end

list.is_empty =
	function (self)
		return self:size() == 0
	end

-- Not used anywhere... might be useful ~someday~.
list.clear =
	function (self)
		-- Count down from the end-index
		-- and forcibly remove the reference.
		-- (more thorough way instead of just creating a
		-- new list and losing the previous reference)
		for i = self:size(), 1, -1 do
			-- This is really table.remove()
			self:remove(i)
		end

		return self
	end

list.push =
	function (self, ...)
		local i = self:size()

		for _, v in ipairs(arg) do
			i = i + 1
			self[i] = v
		end

		return self
	end

list.pop =
	function (self, pops)
		pops = pops ~= nil and pops >= 0 and pops or 1

		-- Count back to the first index.
		for i = self:size(), 1, -1 do

			-- Pops would ~normally~ break the loop
			-- before we clear everything in self.
			if pops == 0 then
				break
			end

			-- This is really table.remove()
			self:remove(i)
			pops = pops - 1
		end

		return self
	end

list.clone =
	function (self)
		return list(unpack(self))
	end

-- Some retardation.
list.self =
	function (self)
		return self
	end

list.first =
	function (self)
		return self[1]
	end

list.last =
	function (self)
		return self[self:size()]
	end

-- Lispy :D
list.car = list.first
list.cdr =
	function (self)
		return list(unpack(self, 2, self:size()))
	end

-- More aliases :D
list.head = list.car
list.rest = list.cdr
list.tail = list.last

-- Metamethods

local list_mt_two_arith =
	function (arith_func)
		return
			function (lhs, rhs)
				local tmp = lhs:clone()

				-- We iterate with a normal for
				-- loop instead of with pairs()
				if type(rhs) == 'table' then
					for i = 1, tmp:size() do
						tmp[i] = arith_func(tmp[i], rhs[i])
					end
				else
					for i = 1, tmp:size() do
						tmp[i] = arith_func(tmp[i], rhs)
					end
				end

				return tmp
			end
	end

-- The something or something_else is to work around
-- the problem of when list2 doesn't have that index.
list_mt.__add = list_mt_two_arith(function (a, b) return not b and a or a + b end)
list_mt.__mul = list_mt_two_arith(function (a, b) return not b and a or a * b end)
list_mt.__sub = list_mt_two_arith(function (a, b) return not b and a or a - b end)
list_mt.__div = list_mt_two_arith(function (a, b) return not b and a or a / b end)
list_mt.__pow = list_mt_two_arith(function (a, b) return not b and a or a ^ b end)
list_mt.__mod = list_mt_two_arith(function (a, b) return not b and a or a % b end)
list_mt.__unm = function (self) return self * -1 end -- piggybacking __mul

-- This tostring() accepts all types if
-- they have a __tostring themselves.
list_mt.__tostring =
	function (self)
		return self:is_empty() and '{}' or '{ ' .. table.concat(self, ', ') .. ' }'
	end

list_mt.__call =
	function (self)
		-- self[1] could be a function *OR* callable object.
		-- (__call -- which could also be a callable object, not a function XD)
		return self[1](unpack(self, 2, self:size()))
--		return self[1](unpack(self:cdr()))
	end

--- Example usage:
local printf = function (...) io.stdout:write(string.format(...)) end

local my_list = list(1, 2, 3)
my_list:push(4, 5, 6, 7, 8, 9, 10)
my_list:pop(2)

printf(
	'  my_list:first() = %s\r\n' ..
    '   my_list:self() = %s\r\n' ..
	'   my_list:last() = %s\r\n' ..
	'   my_list:tail() = %s\r\n' ..
	'    my_list:car() = %s\r\n' ..
	'    my_list:cdr() = %s\r\n' ..
	'   my_list:head() = %s\r\n' ..
	'   my_list:rest() = %s\r\n' ..
	'   my_list:size() = %d\r\n' ..
    '          my_list = %s\r\n' ..
	'my_list + my_list = %s\r\n' ..
	'my_list * my_list = %s\r\n' ..
	'my_list - my_list = %s\r\n' ..
	'my_list / my_list = %s\r\n' ..
	'my_list ^ my_list = %s\r\n' ..
	'my_list %% my_list = %s\r\n' ..
	'         -my_list = %s\r\n' ..
	"list:concat(', ') = %s -- this is really table.concat()\r\n" ..
	'\r\n' ..
	"my_list:insert(1, function (...) return table.concat({ ... }, ' ~ ') end)\r\n" ..
	'\r\n' ..
	'my_list()         = %s\r\n',
	tostring(my_list:first()),
	tostring(my_list:self()),
	tostring(my_list:last()),
	tostring(my_list:tail()),
	tostring(my_list:car()),
	tostring(my_list:cdr()),
	tostring(my_list:head()),
	tostring(my_list:rest()),
	my_list:size(),
	tostring(my_list),
	tostring(my_list + my_list),
	tostring(my_list * my_list),
	tostring(my_list - my_list),
	tostring(my_list / my_list),
	tostring(my_list ^ my_list),
	tostring(my_list % my_list),
	tostring(-my_list),
	my_list:concat(', '),
	my_list:insert(1, function (...) return table.concat({ ... }, ' ~ ') end) or true and my_list()
)


--- Future considerations:
-- Type-checking and error-handling
-- Perl array-like shifting, insertions, deletions, ...
