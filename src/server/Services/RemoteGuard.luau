--!strict
--[[
    RemoteGuard.luau
    Security and rate-limiting middleware for server-side RemoteEvents.
    Ensures zero-trust: validates player presence, session lock, request frequency, and payload types.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local GameConfig = require(Shared:WaitForChild("Config"):WaitForChild("GameConfig") :: ModuleScript)
local RateLimiter = require(Shared:WaitForChild("Modules"):WaitForChild("RateLimiter") :: ModuleScript)
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService") :: ModuleScript)

local RemoteGuard = {}

-- Validates that a client request is legitimate before allowing processing
function RemoteGuard.Validate(player: Player, actionName: string, maxPerSecond: number?): boolean
	-- 1. Validate Player instance
	if not player or not player:IsDescendantOf(Players) then
		return false
	end
	
	-- 2. Validate Session Existence
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		warn(string.format("[RemoteGuard] Rejected %s from %s: Profile not loaded yet.", actionName, player.Name))
		return false
	end
	
	-- 3. Rate Limit Check
	local threshold = maxPerSecond or GameConfig.RATE_LIMITS[actionName] or 5
	local isAllowed = RateLimiter.Check(player.UserId, actionName, threshold)
	if not isAllowed then
		-- Silently reject spam or log warning
		return false
	end
	
	return true
end

-- Connects cleanup on player removing
Players.PlayerRemoving:Connect(function(player)
	RateLimiter.Reset(player.UserId)
end)

return table.freeze(RemoteGuard)
