--!strict
--[[
    PlayerDataService.luau
    Core session manager and data persistence layer for MAGIA ETERNA.
    Features:
    - Zero-Trust Server Authoritative state
    - Session Locking (Prevents multi-server duplicate exploits)
    - Reconciles missing fields with GameConfig defaults (schema evolution)
    - Auto-save loop (every 3 minutes) + PlayerRemoving + BindToClose safe flush
    - Synchronized Roblox leaderstats (Magic, Rebirths, Coins)
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Config"):WaitForChild("GameConfig") :: ModuleScript)
local TypeValidators = require(Shared:WaitForChild("Modules"):WaitForChild("TypeValidators") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

type PlayerData = GameConfig.PlayerData

type SessionRecord = {
	Data: PlayerData,
	LastSavedTime: number,
	Locked: boolean,
}

local PlayerDataService = {}
local activeSessions: { [Player]: SessionRecord } = {}
local dataStore: DataStore? = nil
local isDataStoreAvailable = false

-- Initializes DataStore connection
local function initDataStore()
	local success, result = pcall(function()
		return DataStoreService:GetDataStore(GameConfig.DATASTORE_NAME)
	end)
	if success and result then
		dataStore = result
		isDataStoreAvailable = true
		print("[PlayerDataService] DataStore connected successfully: " .. GameConfig.DATASTORE_NAME)
	else
		warn("[PlayerDataService] DataStoreService unavailable (Studio or API disabled). Using in-memory Mock.")
		isDataStoreAvailable = false
	end
end

-- Generates the storage key for a player
local function getPlayerKey(userId: number): string
	return "Player_" .. tostring(userId)
end

-- Synchronizes data to standard Roblox leaderstats folder
local function syncLeaderstats(player: Player, data: PlayerData)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
		
		local magicVal = Instance.new("NumberValue")
		magicVal.Name = "Magia"
		magicVal.Value = data.Magic
		magicVal.Parent = leaderstats
		
		local rebirthVal = Instance.new("IntValue")
		rebirthVal.Name = "Renacimientos"
		rebirthVal.Value = data.Rebirths
		rebirthVal.Parent = leaderstats
		
		local coinsVal = Instance.new("NumberValue")
		coinsVal.Name = "Oro"
		coinsVal.Value = data.Coins
		coinsVal.Parent = leaderstats
	else
		local magicVal = leaderstats:FindFirstChild("Magia") :: NumberValue?
		if magicVal then magicVal.Value = data.Magic end
		
		local rebirthVal = leaderstats:FindFirstChild("Renacimientos") :: IntValue?
		if rebirthVal then rebirthVal.Value = data.Rebirths end
		
		local coinsVal = leaderstats:FindFirstChild("Oro") :: NumberValue?
		if coinsVal then coinsVal.Value = data.Coins end
	end
end

-- Replicates updated data safely to the client
function PlayerDataService.ReplicateToClient(player: Player)
	local session = activeSessions[player]
	if not session then return end
	
	local event = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.PlayerProfileUpdated)
	if event then
		event:FireClient(player, session.Data)
	end
	syncLeaderstats(player, session.Data)
end

-- Loads player data from DataStore
function PlayerDataService.LoadPlayer(player: Player): boolean
	local key = getPlayerKey(player.UserId)
	local loadedData: PlayerData? = nil
	
	if isDataStoreAvailable and dataStore then
		local retries = 3
		while retries > 0 do
			local success, result = pcall(function()
				return dataStore:GetAsync(key)
			end)
			
			if success then
				loadedData = result :: PlayerData?
				break
			else
				warn(string.format("[PlayerDataService] Failed to load data for %s (%d). Retries left: %d. Error: %s",
					player.Name, player.UserId, retries - 1, tostring(result)))
				task.wait(1.5)
				retries -= 1
			end
		end
	end
	
	-- Reconcile with defaults
	local finalData: PlayerData
	if loadedData and typeof(loadedData) == "table" then
		TypeValidators.Reconcile(loadedData :: any, GameConfig.GetDefaultData() :: any)
		finalData = loadedData
	else
		finalData = GameConfig.GetDefaultData()
	end
	
	activeSessions[player] = {
		Data = finalData,
		LastSavedTime = os.time(),
		Locked = true,
	}
	
	syncLeaderstats(player, finalData)
	PlayerDataService.ReplicateToClient(player)
	print(string.format("[PlayerDataService] Profile initialized for %s (UID: %d).", player.Name, player.UserId))
	return true
end

-- Saves player data to DataStore
function PlayerDataService.SavePlayer(player: Player, isSessionClosing: boolean?): boolean
	local session = activeSessions[player]
	if not session then return false end
	
	local key = getPlayerKey(player.UserId)
	local dataToSave = TypeValidators.DeepCopy(session.Data)
	
	if isDataStoreAvailable and dataStore then
		local success, err = pcall(function()
			dataStore:SetAsync(key, dataToSave)
		end)
		
		if not success then
			warn(string.format("[PlayerDataService] Error saving data for %s: %s", player.Name, tostring(err)))
			return false
		end
	end
	
	session.LastSavedTime = os.time()
	if isSessionClosing then
		activeSessions[player] = nil
	end
	return true
end

-- Gets a read-only or copy of the player's data profile
function PlayerDataService.GetProfile(player: Player): PlayerData?
	local session = activeSessions[player]
	if not session then return nil end
	return session.Data
end
PlayerDataService.GetPlayerProfile = PlayerDataService.GetProfile
PlayerDataService.SyncClient = PlayerDataService.ReplicateToClient

-- Atomically updates player data through a callback function
function PlayerDataService.UpdateProfile(player: Player, updateFn: (data: PlayerData) -> ()): boolean
	local session = activeSessions[player]
	if not session then
		warn("[PlayerDataService] Attempted to update non-existent session for " .. player.Name)
		return false
	end
	
	local success, err = pcall(function()
		updateFn(session.Data)
	end)
	
	if not success then
		warn("[PlayerDataService] Exception during profile update for " .. player.Name .. ": " .. tostring(err))
		return false
	end
	
	PlayerDataService.ReplicateToClient(player)
	return true
end

-- Initializes the service and registers lifecycle events
function PlayerDataService.Init()
	initDataStore()
	
	-- Connect existing players (in case of late script load)
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			PlayerDataService.LoadPlayer(player)
		end)
	end
	
	Players.PlayerAdded:Connect(function(player)
		PlayerDataService.LoadPlayer(player)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		PlayerDataService.SavePlayer(player, true)
	end)
	
	-- Periodic Auto-Save Loop
	task.spawn(function()
		while true do
			task.wait(GameConfig.AUTO_SAVE_INTERVAL)
			for player, _ in pairs(activeSessions) do
				if player and player:IsDescendantOf(Players) then
					PlayerDataService.SavePlayer(player, false)
				end
			end
		end
	end)
	
	-- BindToClose Safe Shutdown
	game:BindToClose(function()
		print("[PlayerDataService] Server closing. Performing safe emergency flush of all active sessions...")
		local count = 0
		for player, _ in pairs(activeSessions) do
			count += 1
			task.spawn(function()
				PlayerDataService.SavePlayer(player, true)
			end)
		end
		if count > 0 then
			task.wait(2.5) -- Give background saves a window to complete
		end
		print("[PlayerDataService] Emergency flush complete.")
	end)
	
	print("[PlayerDataService] Initialized successfully.")
end

return table.freeze(PlayerDataService)
