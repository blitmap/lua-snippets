--[[

The numeric for loop repeats a block of code while a control variable
runs through an arithmetic progression. It has the following syntax: 

-- e1, e2, and e3 are evaluated only once before the loop.

]]

for v = e1, e2, e3 do
	--[[ block ]]
end

-- Equivalent to:

do
	local var, limit, step = tonumber(e1), tonumber(e2), tonumber(e3)

	if not (var and limit and step) then error() end

	while
		(step  > 0 and var <= limit) or
		(step <= 0 and var >= limit)
	do
		local v = var
		--[[ block ]]
		var = var + step
	end
end

--[[

The generic for statement works over functions, called iterators. On each
iteration,the iterator function is called to produce a new value, stopping
when this new value is nil. The generic for loop has the following syntax: 

-- explist is evaluated only once (e.g. for i, v in ipairs(table) do ... end)
-- ipairs() is called and returns an iterator only once (ipairs() is a generator)

]]

for var_1, ···, var_n in explist do
	--[[ block ]]
end

-- Equivalent to:

do
	local f, s, var = explist

	while true do
		local var_1, ···, var_n = f(s, var)
		var = var_1
		if var == nil then
			break
		end
		--[[ block ]]
	end
end
