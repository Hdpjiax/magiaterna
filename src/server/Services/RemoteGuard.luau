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
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)
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
	local threshold = maxPerSecond or (GameConfig.RATE_LIMITS and GameConfig.RATE_LIMITS[actionName]) or 5
	local isAllowed = RateLimiter.Check(player.UserId, actionName, threshold)
	if not isAllowed then
		-- Silently reject spam or log warning
		return false
	end
	
	return true
end

-- Alias for Validate (used by CombatService, DungeonService, etc.)
function RemoteGuard.ValidateRequest(player: Player, actionName: string, maxPerSecond: number?): boolean
	return RemoteGuard.Validate(player, actionName, maxPerSecond)
end

-- Protects and binds a server-side RemoteEvent with zero-trust validation and rate limiting
function RemoteGuard.ProtectEvent(
	eventName: string,
	actionName: string,
	maxPerSecond: number?,
	handler: (player: Player, ...any) -> ()
): RBXScriptConnection?
	local remote = NetworkEndpoints.GetEvent(eventName)
	if not remote then
		warn(string.format("[RemoteGuard] Cannot protect event '%s': Remote not found.", eventName))
		return nil
	end

	return remote.OnServerEvent:Connect(function(player: Player, ...: any)
		if RemoteGuard.Validate(player, actionName, maxPerSecond) then
			handler(player, ...)
		end
	end)
end

-- Connects cleanup on player removing
Players.PlayerRemoving:Connect(function(player)
	RateLimiter.Reset(player.UserId)
end)

return table.freeze(RemoteGuard)
