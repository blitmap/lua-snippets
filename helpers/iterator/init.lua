local require = require
local assert  = assert
local pairs   = pairs

module(... or string.match(debug.getinfo(1).short_src, '^(.*)%.'))

for _, v in pairs({ 'each', 'reach', 'every', 'range', 'pairs', 'ipairs' }) do
	-- each = require('each').each
	_M[v] = assert(require(... .. '.' .. v)[v])
end

return _M
