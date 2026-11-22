--!strict
--[[
    UIFormatters.luau
    Client UI formatter facade delegating to shared NumberFormatter.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NumberFormatter = require(Shared:WaitForChild("Modules"):WaitForChild("NumberFormatter") :: ModuleScript)

local UIFormatters = {}

function UIFormatters.FormatNumber(value: number): string
	return NumberFormatter.FormatNumber(value)
end

function UIFormatters.FormatTime(seconds: number): string
	return NumberFormatter.FormatTime(seconds)
end

function UIFormatters.ToRoman(num: number): string
	return NumberFormatter.ToRoman(num)
end

function UIFormatters.FormatPercent(value: number): string
	return NumberFormatter.FormatPercent(value)
end

return UIFormatters
