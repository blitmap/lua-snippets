local deque = {}

local construct =
	function (_, ...)
		local o = {}

		-- piggyback this to 'init' our deque
		deque.clear(o)

		for _, v in ipairs({ ... }) do
			deque.push_back(o, v)
		end

		return setmetatable(o, deque)
	end

deque.empty =
	function (self)
		local empty = self._back < self._front

		if empty then
			deque.clear(self)
		end

		return empty
	end

deque.pop_front =
	function (self)
		if deque.empty(self) then return end

		local i = self._items[self._front]

		self._items[self._front] = nil -- GC this

		-- push this back
		self._front = self._front + 1

		return i
	end

deque.pop_back =
	function (self)
		if deque.empty(self) then return end

		local i = self._items[self._back]

		self._items[self._back] = nil -- GC this

		-- bring this in
		self._back = self._back - 1

		return i
	end

deque.push_front =
	function (self, i)
		self._front = self._front - 1

		self._items[self._front] = i
	end

deque.push_back =
	function (self, i)
		self._back = self._back + 1

		self._items[self._back] = i
	end

deque.clear =
	function (self)
		self._front = 1
		self._back  = 0
		self._items = {}
	end

-- not sure anybody will use this...
deque.swap =
	function (self, other)
		-- swappy swappy!
		self._front, other._front = other._front, self._front
		self._back,  other._back  = other._back,  self._back
		self._items, other._items = other._items, self._items
	end

-- expensive: avoid inserting things in the middle of queues
deque.insert =
	function (self, ...)
		if select('#', ...) == 1 then
			deque.push_back(self, ...)
		else
			local i, v = ...
			local idx = self._front + i - 1

			self._back = self._back + 1

			for x = self._back, idx, -1 do
				self._items[x] = self._items[x - 1] -- move this "up"
			end

			self._items[idx] = v
		end
	end

-- expensive: avoid deleting things in the middle of queues
deque.erase =
	function (self, ...)
		local i, n = ...

		if select('#', ...) == 1 then
			n = 1
		end

		self._back = self._back - n

		for x = self._front + i - 1, self._back do
			self._items[x    ] = self._items[x + n]
			self._items[x + n] = nil -- GC teim! \o/
		end
	end

deque.length = function (self)    return self._back - self._front + 1     end
deque.front  = function (self)    return self._items[self._front        ] end
deque.back   = function (self)    return self._items[self._back         ] end
deque.at     = function (self, i) return self._items[self._front + i - 1] end

-- metamethods
deque.__call  = construct    -- local d = deque('a', 'b', 'c')
deque.__index = deque        -- d:empty() -> false
deque.__len   = deque.length -- #d -> 3

deque.__pairs =
	function (self)
		local k, v

		return
			function ()
				k, v = next(self._items, k)

				if k ~= nil then
					return k - self._front + 1, v
				end
			end
	end

deque.__ipairs =
	function (self)
		local i = self._front - 1

		return
			function ()
				i = i + 1

				local v = self._items[i]

				if v ~= nil then
					return i, v
				end
			end
	end

return setmetatable(deque, deque)
