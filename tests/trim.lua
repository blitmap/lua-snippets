-- add the enclosing directory as a search path for
-- require(); concatenation order is specific here
package.path = '../?.lua;' .. package.path

local helpers = require('helpers')
local trim    = require('trim')

string.rtrim = trim.rtrim
string.ltrim = trim.ltrim
string.trim  = trim.trim

local tests =
    {   
        {   
            func_name = 'string.ltrim',
            { '',             ''           },  
            { '  ',           ''           },  
            { 'ltrim me',     'ltrim me'   },  
            { '  ltrim me',   'ltrim me'   },  
            { 'ltrim me  ',   'ltrim me  ' },
            { '  ltrim me  ', 'ltrim me  ' },
        },  
        {   
            func_name = 'string.rtrim',
            { '',             ''           },  
            { '  ',           ''           },  
            { 'rtrim me',     'rtrim me'   },  
            { '  rtrim me',   '  rtrim me' },
            { 'rtrim me  ',   'rtrim me'   },  
            { '  rtrim me  ', '  rtrim me' },
        },  
        {   
            func_name = 'string.trim',
            { '',            ''        },  
            { '  ',          ''        },  
            { 'trim me',     'trim me' },
            { '  trim me  ', 'trim me' },
        }   
    }   

for x, testcase in ipairs(tests) do

    println('Testing function: %s()\r\n' % testcase.func_name)

    for y, test in ipairs(testcase) do
        local f = assert(loadstring('return ' .. testcase.func_name))()

        local initial = test[1]
        local expects = test[2]

        local res, modified = f(initial)

        println(
            '\tTest #%d'                                % y,
            '', 
            "\t==    Expecting: %s -> %s (%schange)"    % { initial:squote(), expects:squote(), initial == expects and 'should not ' or 'needs to ' },
            "\t==  Test Result: %s -> %s"               % { initial:squote(),     res:squote() },
            "\t== Trimmed Form: %s! (string %schanged)" % { res == expects and 'Correct' or 'Incorrect', initial == res and 'un' or '' },
            ''  
        )   

    end 

    println()
end

