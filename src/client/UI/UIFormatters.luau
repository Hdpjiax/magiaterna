--!strict
--[[
    UIFormatters.luau
    Central string and number formatters for MAGIA ETERNA's HUD.
    Handles K/M/B/T metric suffixes, currency formatting, time countdowns, and Roman numerals.
]]

local UIFormatters = {}

local METRIC_SUFFIXES = {
	{ Threshold = 1e15, Suffix = "Q" },
	{ Threshold = 1e12, Suffix = "T" },
	{ Threshold = 1e9,  Suffix = "B" },
	{ Threshold = 1e6,  Suffix = "M" },
	{ Threshold = 1e3,  Suffix = "K" },
}

-- Formats a large number into abbreviated format (e.g. 1500 -> "1.50K", 2300000 -> "2.30M")
function UIFormatters.FormatNumber(value: number): string
	if value < 0 then
		return "-" .. UIFormatters.FormatNumber(-value)
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

-- Formats seconds into MM:SS format (e.g. 125 -> "02:05")
function UIFormatters.FormatTime(seconds: number): string
	local s = math.max(0, math.floor(seconds))
	local mins = math.floor(s / 60)
	local remSecs = s % 60
	return string.format("%02d:%02d", mins, remSecs)
end

-- Converts an integer to Roman Numerals (1 to 5)
function UIFormatters.ToRoman(num: number): string
	local romans = { [1] = "I", [2] = "II", [3] = "III", [4] = "IV", [5] = "V" }
	return romans[num] or tostring(num)
end

return UIFormatters
