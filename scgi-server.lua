--[[

	Implementaton Notes:

	-- header.REQUEST_URI or header.SCRIPT_FILENAME etc aren't validated to be within
	-- the DOCUMENT_ROOT, we make nginx check this for us with try_files $uri = 404;

	-- validate_headers() is largely unnecessary since nginx also will send the
	-- correct headers as per the SCGI spec every time

	-- The only real checking we do is make sure that no duplicate headers are sent,
	-- in that: We can either error or only accept the first value defined per the
	-- duplicate header. (like the first CONTENT_LENGTH value)

]]

-- this is because of the 5.1 to 5.2 migration on Arch :(
package.path =
	package.path ..
	';/usr/lib/lua/?.lua;'

package.cpath =
	package.cpath ..
	';/usr/lib/lua/?.so;'

local posix  = require('posix')
local socket = require('socket')

-- {{{ some helpers

table.shift =
	function (self)
		return table.remove(self, 1)
	end

table.pusht =
	function (self, t2)
		local n = #self

		for _, v in ipairs(t2) do
			n = n + 1
			self[n] = v
		end

		return self
	end

table.map =
	function (self, f, ...)
		for k, v in pairs(self) do
			f(v, k, self, ...)
		end
	end

local empty  =
	function (self)
		return next(self) == nil
	end

local indexOf =
	function (t, v, gen)
		for idx, val in (gen or pairs)(t) do
			if val == v then
				return idx
			end
		end
	end

-- }}}

local host = 'localhost'
local port = 8888

local r       = {} -- the read "set"
local w       = {} -- the write "set"
local threads = setmetatable({}, { __mode = 'k' }) -- threads vanish as sockets "drop out"

-- ['/script/path/from/document/root.lua'] = { attrs = lfs.attributes(...), source = ..., bytecode = ... }
local cache = {}

scgi = { cache = cache, conns = 0, failed = 0, succeeded = 0 }

local validate_scgi =
	function (headers)
		if headers[1] ~= 'CONTENT_LENGTH' then
			error('SCGI spec mandates CONTENT_LENGTH be the first header')
		end

		if headers.CONTENT_LENGTH == '' then
			error('SCGI requires CONTENT_LENGTH have a value, even if "0"')
		end

		if headers.SCGI ~= '1' then
			error('request from webserver must have "SCGI" header with value of "1"')
		end

		-- enforce base 10, we should never have CONTENT_LENGTH: 0xFF (lol)
		if not tonumber(headers.CONTENT_LENGTH, 10) then
			error('CONTENT_LENGTH\'s value is not a number')
		end
	end

local recvall =
	function (c)
		local tmp = {}

		while true do
			local err, partial = select(2, c:receive('*a'))

			-- timeout is EAGAIN (in a sense)
			if err ~= 'timeout' then
				error(err)
			end

			if partial == '' then
				-- nothing read, we're done
				break
			end

			table.insert(tmp, partial)
		end

		return table.concat(tmp)
	end


local croutine =
	function (c)
		local netstring = recvall(c) or error('connection established but nothing received')

		table.remove(r, indexOf(r, c)) -- we don't immediately need write so I'm a bit unhappy about this
		table.insert(w, c)
		coroutine.yield()

		local netsize, scgistart = string.match(netstring, '^(%d+):()')

		if not netsize then
			error('netstring size not found in SCGI request')
		end

		local head = string.sub(netstring, scgistart, scgistart + netsize)

		local headers = {}

		for k, v in string.gmatch(head, '(%Z+)%z(%Z*)%z') do
			if headers[k] then
				error('duplicate SCGI header encountered')
			end

			table.insert(headers, k) -- track ordering
			headers[k] = v
		end

		coroutine.yield() -- we've been at this long enough

		validate_scgi(headers)

		headers[0] = head

		local body = string.sub(netstring, scgistart + netsize + 1, headers.CONTENT_LENGTH) -- 1 for ';' at the end of the header section

		local path     = headers.PATH_TRANSLATED
		local attrs    = posix.stat(path)
--		local attrs    = lfs.attributes(path)
		local cached   = cache[path]

--[[
		if
			not cached or
			attrs.modification ~= cached.attrs.modification or
			attrs.change       ~= cached.attrs.change
		then
]]
		if
			not cached or
			attrs.mtime ~= cached.attrs.mtime or
			attrs.ctime ~= cached.attrs.ctime
		then
			local tmp = assert(io.open(path, 'rb'))

			local source = tmp:read('*a')

			assert(tmp:close())

			if string.sub(source, 1, 2) == '#!' then
				source = string.sub(source, (string.find(source, '\n', 1, true)))
			end

			local bytecode = assert(loadstring(source, path))

			cached = { path = path, attrs = attrs, source = source, bytecode = bytecode }

			cache[path] = cached
		end

		coroutine.yield() -- take a break

		scgi.self    = cached
		scgi.request = netstring
		scgi.headers = headers
		scgi.body    = body

		local response = {}

		local tmp = coroutine.create(cached.bytecode)

		while true do
			local stat = { coroutine.resume(tmp) }
			local ok   = table.shift(stat)

			if not ok then
				error(stat[1])
			end

			table.pusht(response, stat)

			if coroutine.status(tmp) == 'dead' then
				break
			end
		end

		coroutine.yield()

		-- bring it all together
		response = table.concat(response)

		if response == '' then
			response = 'Content-Type: text/plain\r\nStatus: 204 No Content\r\n\r\nSCGI request successful; no output'
		end

		local i   = 1
		local len = #response

		while i <= len do
			local sent, err = c:send(response, i)

			if not sent and err ~= 'timeout' then
				error(err)
			end

			i = sent + 1

			coroutine.yield()
		end

		assert(c:shutdown())
		table.remove(w, indexOf(w, c))
	end

local sroutine =
	function (s)
		while true do
			local c = assert(s:accept())

			assert(c:settimeout(0))

			threads[c] = assert(coroutine.create(croutine))

			table.insert(r, c) -- insert the new client in the read set

			coroutine.yield()
		end
	end

local serv = assert(socket.tcp())

assert(serv:bind(host, port))

assert(serv:listen())

print(('Listening on %s:%s ...'):format(serv:getsockname()))

assert(serv:settimeout(0)) -- so we can non-blockingly :accept()

threads[serv] = assert(coroutine.create(sroutine))

table.insert(r, serv)

while true do
	local read, write = socket.select(r, w)

	for _, set in ipairs({ read, write }) do
		for _, s in ipairs(set) do
			local ok, err = coroutine.resume(threads[s], s)

			if ok then
				scgi.succeeded = scgi.succeeded + 1
			else
				print(err)
				pcall(function () s:send('Content-Type: text/plain\r\nStatus: 500 Internal Server Error\r\n\r\n' .. err) end)

				if s == serv then
					serv:shutdown()
					os.exit(false)
				end

				for _, set in pairs({ r, w }) do -- it may be in either of these
					local idx = indexOf(set, s)

					if idx then
						table.remove(set, idx)
					end
				end

				ok, err = pcall(function () s:close() end)

				if not ok then
					print(err)
				end

				scgi.failed = scgi.failed + 1
			end

			scgi.conns = scgi.conns + 1
		end
	end
end
