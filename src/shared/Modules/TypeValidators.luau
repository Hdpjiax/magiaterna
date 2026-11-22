--!strict
--[[
    TypeValidators.luau
    Safe deep-cloning and payload validation utilities for network requests and data integrity.
]]

local TypeValidators = {}

-- Performs a deep copy of a dictionary or array, preventing reference pollution
function TypeValidators.DeepCopy<T>(original: T): T
	if typeof(original) ~= "table" then
		return original
	end
	
	local copy = {}
	for k, v in pairs(original :: any) do
		if typeof(v) == "table" then
			copy[k] = TypeValidators.DeepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy :: any
end

-- Reconciles a target table against a default schema, adding missing keys without overriding existing values
function TypeValidators.Reconcile(target: { [string]: any }, defaultTemplate: { [string]: any })
	for key, defaultValue in pairs(defaultTemplate) do
		if target[key] == nil then
			if typeof(defaultValue) == "table" then
				target[key] = TypeValidators.DeepCopy(defaultValue)
			else
				target[key] = defaultValue
			end
		elseif typeof(target[key]) == "table" and typeof(defaultValue) == "table" then
			TypeValidators.Reconcile(target[key], defaultValue)
		end
	end
end

-- Validates that a value is a non-empty string within max length
function TypeValidators.IsValidString(val: any, minLen: number?, maxLen: number?): boolean
	if typeof(val) ~= "string" then return false end
	local min = minLen or 1
	local max = maxLen or 100
	return string.len(val) >= min and string.len(val) <= max
end

-- Validates that a value is a valid finite integer within range
function TypeValidators.IsValidInteger(val: any, min: number?, max: number?): boolean
	if typeof(val) ~= "number" then return false end
	if val ~= val or val == math.huge or val == -math.huge then return false end -- NaN / Inf
	if math.floor(val) ~= val then return false end -- Not an integer
	if min and val < min then return false end
	if max and val > max then return false end
	return true
end

-- Validates that a value is a valid positive number
function TypeValidators.IsPositiveNumber(val: any): boolean
	if typeof(val) ~= "number" then return false end
	if val ~= val or val == math.huge or val == -math.huge then return false end
	return val >= 0
end

return table.freeze(TypeValidators)
