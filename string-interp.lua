#!/usr/bin/env lua

getmetatable('').__mod =
	function(a, b)
		return type(b) == 'table' and a:format(unpack(b)) or a:format(b)
--		Swell to write by not as efficient as ^
--		return a:format(unpack(type(b) == 'table' and b or { b }))
	end

println =
	function (...)
		return io.stdout:write(table.concat(arg, '\r\n') .. '\r\n')
	end

-- Example usage :-)
println(
	'%.2f'          % math.pi,
	'%-10.10s %04d' % { 'test', 123 },
	'%s'            % 'hello world! :-)',
	'This is a %s!' % (type(true) == type(false) and 'boolean' or 'mess') -- These parenthesis are important.
)
