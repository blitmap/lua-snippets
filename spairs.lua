local tsort   = table.sort
local setmeta = setmetatable

require('helpers')

local tkeys = table.keys

local iter =
    function (tbl, sort_func)
		local keys = tkeys(tbl)
        
        tsort(keys, sort_func)

		local x = 0

        -- Our iterator function.
        -- Upvalues: tbl, keys, and x
        local spairs_iterator =
            function ()
				x = x + 1
                return keys[x], tbl[keys[x]]
            end 
            
        return spairs_iterator
    end 

return iter

--[[

Example usage:

-- Simple example with only number & string keys.
for k, v in spairs({ 1, 2, [99] = '99', [23] = '23' }) do
    print(k, v)
end 

print(srep('-', 40))

local whatever =
{
    [1]               = 'one',
    [5]               = 'two',
    [6]               = 'three',
    ['99']            = 'four',
    [{}]              = 'five',
    [function () end] = 'six'
}   

-- Second example.
for k, v in spairs(whatever, function (a, b) return tos(a) < tos(b) end) do
    print(k, v)
end

]]
