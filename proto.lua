local type_err = [[%s to '%s' (%s expected, got %s)]]
local ferror   = function (e, l) error(string.format(table.unpack(e)), l) end

local proto =
    function (types, ...)
		-- procedure: check callers, then arg limits, then types

		-- the function calling proto()
        local fname = debug.getinfo(2, 'n').name or '?'

        local nargs = select('#', ...)
        
        if types.min and nargs < types.min then
            ferror({ type_err, 'too few arguments', fname, 'at least ' .. types.min, nargs }, 2)
        end
            
        if types.max and nargs > types.max then
            ferror({ type_err, 'too many arguments', fname, 'at most ' .. types.max, nargs }, 2)
        end
            
        if types.expects and nargs ~= types.expects then
            if nargs < types.expects then
                ferror({ type_err, 'too few arguments', fname, types.expects, nargs }, 2)
            end
                
            if nargs > types.expects then
                ferror({ type_err, 'too many arguments', fname, types.expects, nargs }, 2)
            end
        end     

		----

        for i = 1, #types do
            local v = select(i, ...)
            local t = types[i]
            local vt = type(v)
            
            if t == '*' then
                goto continue
            end
                
            -- any value that equates to true
            if t == '!' then
                if v then
                    goto continue
                end
                    
                ferror({ type_err, 'bad arrgument #' .. i, fname, 'truth', vt }, 2)
            end 
                
            -- '!string' == anything but string
            if t:sub(1, 1) == '!' then
                t = t:sub(2, #t)
            
                if t == vt then
                    ferror({ type_err, 'bad argument #' .. i, fname, 'not-' .. t, t }, 2)
                end
                    
                goto continue
            end 
                
            -- special case for strings that can be numbers
            if t == 'number' then
                if not tonumber(v) then
                    ferror({ type_err, 'bad argument #' .. i, fname, t, vt }, 2)
                end
            elseif t ~= vt then
                ferror({ type_err, 'bad argument #' .. i, fname, t, vt }, 2)
            end

            ::continue::
        end 
    end

-- NOTE:
--
-- Because f() is called anonymously through pcall(), the caller name for each of these should be '?'

local f = nil

f = function (...) proto({ 'string' }, ...) end
print('#1', pcall(f, 'hi there!')) -- matches the prototype

f = function (...) proto({ 'string' }, ...) end
print('#2', pcall(f, nil)) -- should fail

f = function (...) proto({ 'number', 'number', 'table' }, ...) end
print('#3', pcall(f, 1, 3, {})) -- matches the prototype

f = function (...) proto({ 'number', '*', 'table' }, ...) end -- we don't care what type the 2nd arg is
print('#4', pcall(f, 1, false, {})) -- this should be good, too

f = function (...) proto({ '!' }, ...) end
print('#5', pcall(f, 'truth value')) -- in this example we want something that evaluates to true

f = function (...) proto({ '!string' }, ...) end -- now we're looking for something not a string
print('#6', pcall(f, 1)) -- this should succeed
print('#7', pcall(f, 'whoops!')) -- this should fail

f = function (...) proto({ 'number', 'number', min = 3 }, ...) end -- looking for a minimum of 3 args
print('#8', pcall(f, 1, 2)) -- this should fail
print('#9', pcall(f, 1, 2, 3)) -- this should succeed
print('#10', pcall(f, 1, 2, 3, 4)) -- this should also succeed

f = function (...) proto({ 'number', 'number', max = 3 }, ...) end -- looking for a maximum of 3 args
print('#11', pcall(f, 1, 2)) -- should succeed
print('#12', pcall(f, 1, 2, 3)) -- should succeed
print('#13', pcall(f, 1, 2, 3, 4)) -- should fail

f = function (...) proto({ 'number', 'number', expects = 2 }, ...) end -- looking for exactly 2 args, no less, no more
print('#15', pcall(f, 1)) -- should fail
print('#14', pcall(f, 1, 2)) -- should succeed
print('#16', pcall(f, 1, 2, 3)) -- should succeed
