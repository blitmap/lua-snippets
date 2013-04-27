--[[

	Implementaton Notes:

	header.REQUEST_URI or header.SCRIPT_FILENAME etc aren't validated to be within
	the DOCUMENT_ROOT, we make nginx check this for us with try_files $uri = 404;

	validate_headers() is largely unnecessary since nginx also will send the
	correct headers as per the SCGI spec every time

	The only real checking we do is make sure that no duplicate headers are sent,
	in that: We can either error or only accept the first value defined per the
	duplicate header. (like the first CONTENT_LENGTH value)

	THIS SCGI SERVER WILL READ THE ENTIRE REQUEST BODY,
	it can be DoS'd if you do not limit this in your webserver:

	Example for nginx (in http section):

	client_body_buffer_size     16k;
	client_header_buffer_size   1k; 
	client_max_body_size        1m; 
	large_client_header_buffers 4 8k; 

]]

-- this is because of the 5.1 to 5.2 migration on Arch :(
package.path =
	package.path ..
	';/usr/lib/lua/?.lua;'

package.cpath =
	package.cpath ..
	';/usr/lib/lua/?.so;'

local posix    = require('posix')

local socket   = require('socket')
local sselect  = socket.select

local ssub     = string.sub
local sgsub    = string.gsub
local sfind    = string.find
local sgmatch  = string.gmatch
local smatch   = string.match
local sformat  = string.format
local dtrace   = debug.traceback

local cstatus = coroutine.status
local ccreate = coroutine.create
local cresume = coroutine.resume
local cyield  = coroutine.yield

local tcat = table.concat
local tins = table.insert
local trem = table.remove

local log = print

local host = 'localhost'
local port = 8888

local r, w = {}, {}

local threads = setmetatable({}, { __mode = 'k' }) -- threads vanish as sockets "drop out"

-- ['/script/path/from/document/root.lua'] = { attrs = lfs.attributes(...), source = ..., bytecode = ... }
local cache = {}

scgi = { cache = cache, conns = 0, failed = 0, succeeded = 0 }

local validate_scgi =
	function (headers)
		if headers[1] ~= 'CONTENT_LENGTH' then
			error('SCGI requires CONTENT_LENGTH be the first header')
		end

		if headers.CONTENT_LENGTH == '' then
			error('SCGI requires CONTENT_LENGTH have a value, even if "0"')
		end

		if headers.SCGI ~= '1' then
			error('"SCGI\\01\\0" must be present in the SCGI request head')
		end

		if not not tonumber(headers.CONTENT_LENTH) then
			error('CONTENT_LENGTH\'s value is not a number')
		end
	end

local recvall =
	function (c)
		local tmp = nil

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

			tmp = tmp ~= nil and (tmp .. partial) or partial
		end

		return tmp
	end

local indexOf =
	function (t, v, gen)
		for idx, val in (gen or pairs)(t) do
			if val == v then
				return idx
			end
		end
	end

local croutine =
	function (c)
		local netstring = recvall(c) or error('connection established but nothing received')

		trem(r, indexOf(r, c)) -- we don't immediately need write so I'm a bit unhappy about this
		tins(w, c)
		cyield()

		local netsize, scgistart = smatch(netstring, '^(%d+):()')

		if not netsize then
			error('netstring size not found in SCGI request')
		end

		local head = ssub(netstring, scgistart, scgistart + netsize)

		local headers = {}

		for k, v in sgmatch(head, '(%Z+)%z(%Z*)%z') do
			if headers[k] then
				error('duplicate SCGI header encountered')
			end

			tins(headers, k) -- track ordering
			headers[k] = v
		end

		cyield() -- we've been at this long enough

		validate_scgi(headers)

		headers[0] = head

		local body = ssub(netstring, scgistart + netsize + 1, headers.CONTENT_LENGTH) -- 1 for ';' at the end of the header section

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

			if ssub(source, 1, 2) == '#!' then
				source = ssub(source, (sfind(source, '\n', 1, true)))
			end

			local bytecode = assert(loadstring(source, path))

			cached = { path = path, attrs = attrs, source = source, bytecode = bytecode }

			cache[path] = cached
		end

		cyield() -- take a break

		scgi.current = cached
		scgi.request = netstring
		scgi.headers = headers
		scgi.body    = body

		local response = {}

		local tmp = coroutine.wrap(cached.bytecode)

		local collect =
			function (...)
				if not ... then
					return
				end

				for i = 1, select('#', ...) do
					tins(response, tostring(select(i, ...)))
				end

				return true
			end

		-- FINALLY RUNNING IT
		while collect(tmp()) do end

		cyield()

		-- bring it all together
		response = tcat(response)

		local i   = 1
		local len = #response

		while i <= len do
			local sent, err = c:send(response, i)

			if not sent and err ~= 'timeout' then
				error(err)
			end

			i = sent + 1

			cyield()
		end

		trem(w, indexOf(w, c))

		assert(c:shutdown())

		scgi.conns     = scgi.conns     + 1
		scgi.succeeded = scgi.succeeded + 1
	end

local sroutine =
	function (s)
		while true do
			local c = assert(s:accept())

			assert(c:settimeout(0))

			threads[c] = ccreate(croutine)

			tins(r, c) -- insert the new client in the read set

			cyield()
		end
	end

local serv = assert(socket.tcp())

assert(serv:bind(host, port))

assert(serv:listen())

print(('Listening on %s:%s ...'):format(serv:getsockname()))

assert(serv:settimeout(0)) -- so we can non-blockingly :accept()

threads[serv] = assert(ccreate(sroutine))

tins(r, serv)

local x = 0

while true do
	local read, write = sselect(r, w)

	for _, set in ipairs({ read, write }) do
		for _, s in ipairs(set) do
			local ok, err = cresume(threads[s], s)

			if not ok then
				log(err)
				pcall(function () c:send('Content-Type: text/html\r\nStatus: 500\r\n\r\n' .. err) end )

				if s == serv then
					break
					break
				end

				for _, set in pairs({ r, w }) do -- it may be in either of these
					local idx = indexOf(set, s)

					if idx then
						trem(set, idx)
					end
				end

				ok, err = pcall(function () s:close() end)

				if not ok then
					log(err)
				end

				scgi.failed = scgi.failed + 1
				scgi.conns  = scgi.conns  + 1
			end
		end
	end
end

serv:shutdown()
