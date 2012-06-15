#!/usr/bin/env lua

-- add the enclosing directory as a search path for
-- require(); concatenation order is specific here
package.path = '../../?.lua;' .. package.path

require('string.strinterp')

print('%s'    % 'test')
print('%s %s' % { 'hello', 'world' })
print('%s'    % (true and 'this is important' or 'the parenthesis are a must'))
