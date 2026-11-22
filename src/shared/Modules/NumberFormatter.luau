--!strict
--[[
    NumberFormatter.luau
    Shared string and number formatters for MAGIA ETERNA (Client & Server).
    Handles K/M/B/T/Q metric suffixes, time countdowns, percentages, and Roman numerals.
]]

local NumberFormatter = {}

local METRIC_SUFFIXES = {
	{ Threshold = 1e18, Suffix = "Qi" },
	{ Threshold = 1e15, Suffix = "Q" },
	{ Threshold = 1e12, Suffix = "T" },
	{ Threshold = 1e9,  Suffix = "B" },
	{ Threshold = 1e6,  Suffix = "M" },
	{ Threshold = 1e3,  Suffix = "K" },
}

function NumberFormatter.FormatNumber(value: number): string
	if value ~= value or value == math.huge or value == -math.huge then
		return "0"
	end
	if value < 0 then
		return "-" .. NumberFormatter.FormatNumber(-value)
	end
	if value < 1000 then
		return string.format("%d", math.floor(value))
	end

	for _, entry in ipairs(METRIC_SUFFIXES) do
		if value >= entry.Threshold then
			local formatted = value / entry.Threshold
			if formatted >= 100 then
				return string.format("%.0f%s", formatted, entry.Suffix)
			elseif formatted >= 10 then
				return string.format("%.1f%s", formatted, entry.Suffix)
			else
				return string.format("%.2f%s", formatted, entry.Suffix)
			end
		end
	end

	return tostring(math.floor(value))
end

function NumberFormatter.FormatTime(seconds: number): string
	local s = math.max(0, math.floor(seconds))
	local mins = math.floor(s / 60)
	local remSecs = s % 60
	return string.format("%02d:%02d", mins, remSecs)
end

function NumberFormatter.ToRoman(num: number): string
	local romans = { [1] = "I", [2] = "II", [3] = "III", [4] = "IV", [5] = "V" }
	return romans[num] or tostring(num)
end

function NumberFormatter.FormatPercent(value: number): string
	if value == math.floor(value) then
		return string.format("%d%%", value)
	end
	return string.format("%.1f%%", value)
end

return table.freeze(NumberFormatter)
