#!/usr/bin/env lua

-- All we're doing here is looking for <number> <number> <not-number/operator>
-- and rearranging it so the operator is in the middle, then evaluating the
-- string as a whole like an expression written in Lua.

-- Note: An operator is anything that does not have a number as its first
-- character. (log10 could be an operator but would fail the eval)
-- This is done in the off chance more operators are added to Lua in the future. :-]

require('helpers')

----

local operand = '[+-]?[%de%.]+'
local operator = '[^%d%s]%S*'

for expr in io.lines() do

	local original_expr = expr

	-- Simple check to enforce RPN notation and
	-- not anything Lua-expression-legal.
	if
		string.find(expr, '^' .. operator) or
		string.find(expr, operand  .. '%s+' .. operator .. '%s+' .. operand)
	then
		printf(
			'ordering error detected in invalid RPN expression: %q\r\n' ..
			'>> please see: http://en.wikipedia.org/wiki/Reverse_Polish_notation\r\n',
			original_expr
		)
	else
		if string.match(expr, '^%s*$') then
			print('result: 0')
		else
			local new_expr = ''

			repeat
				expr, matches =
					string.gsub(
						expr,                              -- RPN ordering
						string.format('(%s)%%s+(%s)%%s+(%s)', operand, operand, operator),
						function (lhs, rhs, oper)
							new_expr = string.format('%s %s %s', lhs, oper, rhs) .. new_expr
							return '' -- replace what we found with nothing.
						end
					)
			until matches == 0

			-- If there is anything left, like a single element
			-- or two, prepend it to our new expression to evaluate.
			if not string.match(expr, '^%s*$') then
				new_expr = expr .. new_expr
			end

			do
				-- Search for matches, don't modify the string at all.
				-- Pretty much exploit gsub() for match count
				local operands  = string.count_matches(original_expr, operand)
				local operators = string.count_matches(original_expr, operator)

				-- We have a problem if this isn't true.
				-- RPN expressions always have an odd number of
				-- elements, with 1 more operand than operator.
				-- "2 3 4 * ^", "2 3 /", "9 83 2 + %", ...
				if operators > operands then
					printf(
						'invalid RPN expression, too many %s: %q\r\n',
						operators >= operands and 'operators to operands' or 'operands to operators',
						original_expr
					)
				elseif 
					operands <= operators
				then
					printf('invalid RPN expression, too few operands to operators: %q\r\n', original_expr)
				else
					success, result = pcall(loadstring('return ' .. new_expr))

					-- AFTER we have evaluated the expression, *then* we check to
					-- see if we originally had the right number of operators and operands.
					if success then
						printf('result: %d\r\n', result)
					else
						printf('invalid operator in valid RPN expression: %q\r\n', original_expr)
					end
				end
			end
		end
	end
end

-- PS: I love polish notation over reverse polish notation.
--     Operatorsr-first makes more sense to me :-(
--
--     (You could easily tweak this for PN or
--     delete a lot of it for infix notation.)
