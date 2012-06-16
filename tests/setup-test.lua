#!/usr/bin/env lua

-- add the enclosing directory as a search path for
-- require(); concatenation order is specific here
package.path = '../?.lua;' .. package.path

require('lunit')
