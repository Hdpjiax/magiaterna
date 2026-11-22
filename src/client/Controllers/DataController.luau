--!strict
--[[
    DataController.luau
    Client-side data controller for MAGIA ETERNA.
    Receives and caches safe replicated state updates from the server without exposing write access.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Config"):WaitForChild("GameConfig") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

type PlayerData = GameConfig.PlayerData

local DataController = {}
local cachedData: PlayerData? = nil
local dataChangedBindable = Instance.new("BindableEvent")

DataController.OnDataChanged = dataChangedBindable.Event

-- Returns current cached player data
function DataController.GetData(): PlayerData?
	return cachedData
end

-- Initializes listener for server data updates
function DataController.Init()
	local updateEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.PlayerProfileUpdated)
	updateEvent.OnClientEvent:Connect(function(updatedData: PlayerData)
		cachedData = updatedData
		dataChangedBindable:Fire(cachedData)
	end)
	
	print("[DataController] Client data replication listener initialized.")
end

return table.freeze(DataController)
