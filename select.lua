#!/usr/bin/env lua

--[[

This is meant to be a very slight modification to
select() where if called with '*' as the first arg,
select() will prepend the vararg with the number of args.

Basically just to avoid this:

local n, a, b, c = select('#', ...), ...

]]

local orig_select = select

select =
    function (first, ...)
        if first == '*' then
            return orig_select('#', ...), ...
        end

        return orig_select(first, ...)
    end

print(select(2,   'a', 'b', 'c', 'd'))
print(select('#', 'a', 'b', 'c', 'd'))
print(select('*', 'a', 'b', 'c', 'd'))
