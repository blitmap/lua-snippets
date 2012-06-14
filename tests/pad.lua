#!/usr/bin/env lua

-- add the enclosing directory as a search path for
-- require(); concatenation order is specific here
package.path = '../?.lua;' .. package.path

local pad = require('pad')

string.lpad = pad.lpad
string.rpad = pad.rpad
string.pad  = pad.pad

print('  #'   == ('#'):lpad(3))
print('#  '   == ('#'):rpad(3))
print(' # ' == ('#'):pad(3))
print(' #  ' == ('#'):pad(4))

print()

for i = 1, 33 do 
    print([[']] .. ('cat'):pad(i) .. [[']])
end
