#!/usr/bin/env lua

-- pad the left side
string.lpad =
	function (str, len, char)
		return (char or ' '):rep(len - #str) .. str
	end

-- pad the right side
string.rpad =
	function (str, len, char)
		return str .. (char or ' '):rep(len - #str)
	end

-- pad on both sides (centering effect with left justification)
string.pad =
	function (str, len, char, just)
		char = char or ' '

		-- pad() prefers left-justified centering '  cat   ' -- 8 chars wide ('cat'):pad(8)
		return str:rpad(math[just and 'floor' or 'ceil']((len + #str) / 2), char):lpad(len, char)
	end

print('  cat'   == ('cat'):lpad(5))
print('cat  '   == ('cat'):rpad(5))
print('  cat  ' == ('cat'):pad(7))
print('  cat   ' == ('cat'):pad(8))
print('   cat  ' == ('cat'):pad(8, ' ', true))

print()

for i = 1, 33 do
	print([[']] .. ('cat'):pad(i) .. [[']])
end
