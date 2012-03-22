-- To be pedantic and snobbish,
-- this is technically a generator.
-- It "generates" an iterator.
local spairs =
    function (tbl, sort_func)
        local keys, x = {}, 0
        
		-- Make our potentially unconstiguous index of
		-- keys into a constiguous array of keys.
        for index in pairs(tbl) do
            x = x + 1
            keys[x] = index
        end 
        
        -- All the simple magic.
        table.sort(keys, sort_func)
        
		-- Reset this so we can use it to
		-- keep track of our "last key"
		x = 0
        
        -- Our iterator function.
        -- Upvalues: keys and x
        local spairs_iterator =
            function (t)
				x = x + 1
                return keys[x], t[keys[x]]
            end 
            
        -- Return the iterator, the table,
        -- and the starting index for the iterator
        return spairs_iterator, tbl
    end 
    
local whatever =
{
    [1]               = 'one',
    [5]               = 'two',
    [6]               = 'three',
    ['99']            = 'four',
    [{}]              = 'five',
    [function () end] = 'six'
}   

-- Simple example with only number & string keys.
for k, v in spairs({ 1, 2, [99] = '99', [23] = '23' }) do
    print(k, v)
end 

print(string.rep('-', 40))

-- Second example.
for k, v in spairs(whatever, function (a, b) return tostring(a) < tostring(b) end) do
    print(k, v)
end
