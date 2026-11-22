--!strict
--[[
    NetworkEndpoints.luau
    Central registry of RemoteEvents and RemoteFunctions for MAGIA ETERNA.
    Ensures that Remotes are created once on the server and safely retrieved on the client.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NetworkEndpoints = {}

-- Catalog of RemoteEvents
NetworkEndpoints.Events = {
	-- Data & State Replication
	PlayerProfileUpdated = "PlayerProfileUpdated", -- Server -> Client: Replicates safe view of data
	NotificationPrompt = "NotificationPrompt",       -- Server -> Client: Pops up toast / message
	
	-- Magic Simulator & Training
	RequestTrainMagic = "RequestTrainMagic",         -- Client -> Server: Click / training pulse
	
	-- Rebirth
	RequestRebirth = "RequestRebirth",               -- Client -> Server: Execute rebirth
	
	-- Pets & Eggs
	RequestOpenEgg = "RequestOpenEgg",               -- Client -> Server: Open specific egg
	RequestEquipPet = "RequestEquipPet",             -- Client -> Server: Equip pet UUID
	RequestUnequipPet = "RequestUnequipPet",         -- Client -> Server: Unequip pet UUID
	RequestLockPet = "RequestLockPet",               -- Client -> Server: Lock/unlock pet
	
	-- Forging & Equipment
	RequestForgeStaff = "RequestForgeStaff",         -- Client -> Server: Craft staff by ID
	RequestEquipStaff = "RequestEquipStaff",         -- Client -> Server: Equip owned staff
	RequestForgeArmor = "RequestForgeArmor",         -- Client -> Server: Craft armor piece
	
	-- Dungeons & Combat
	RequestEnterDungeon = "RequestEnterDungeon",     -- Client -> Server: Queue for dungeon
	CombatCastSpell = "CombatCastSpell",             -- Client -> Server: Spell attack input
	DungeonStateUpdated = "DungeonStateUpdated",     -- Server -> Client: Room & session status
	EnemyTelegraphStarted = "EnemyTelegraphStarted", -- Server -> Client: Telegraph visual warning
	DungeonCompleted = "DungeonCompleted",           -- Server -> Client: Run rewards or defeat summary
}

-- Catalog of RemoteFunctions
NetworkEndpoints.Functions = {
	GetServerTimestamp = "GetServerTimestamp",
}

local remotesFolder: Folder? = nil

-- Gets or creates the Remotes folder under ReplicatedStorage
local function getRemotesFolder(): Folder
	if remotesFolder then return remotesFolder end
	
	if RunService:IsServer() then
		local folder = ReplicatedStorage:FindFirstChild("Remotes")
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = "Remotes"
			folder.Parent = ReplicatedStorage
		end
		remotesFolder = folder :: Folder
		return remotesFolder
	else
		remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10) :: Folder
		if not remotesFolder then
			error("[NetworkEndpoints] Timeout waiting for 'Remotes' folder in ReplicatedStorage!")
		end
		return remotesFolder
	end
end

-- Initializes all Remotes on the Server
function NetworkEndpoints.InitServer()
	assert(RunService:IsServer(), "[NetworkEndpoints] InitServer must only be called from Server!")
	local folder = getRemotesFolder()
	
	for _, eventName in pairs(NetworkEndpoints.Events) do
		if not folder:FindFirstChild(eventName) then
			local remoteEvent = Instance.new("RemoteEvent")
			remoteEvent.Name = eventName
			remoteEvent.Parent = folder
		end
	end
	
	for _, funcName in pairs(NetworkEndpoints.Functions) do
		if not folder:FindFirstChild(funcName) then
			local remoteFunc = Instance.new("RemoteFunction")
			remoteFunc.Name = funcName
			remoteFunc.Parent = folder
		end
	end
	
	print("[NetworkEndpoints] All Remotes initialized safely on Server.")
end

-- Retrieves a RemoteEvent safely
function NetworkEndpoints.GetEvent(eventName: string): RemoteEvent
	local folder = getRemotesFolder()
	local event = folder:WaitForChild(eventName, 10) :: RemoteEvent
	assert(event and event:IsA("RemoteEvent"), "[NetworkEndpoints] Invalid RemoteEvent: " .. tostring(eventName))
	return event
end

-- Retrieves a RemoteFunction safely
function NetworkEndpoints.GetFunction(funcName: string): RemoteFunction
	local folder = getRemotesFolder()
	local func = folder:WaitForChild(funcName, 10) :: RemoteFunction
	assert(func and func:IsA("RemoteFunction"), "[NetworkEndpoints] Invalid RemoteFunction: " .. tostring(funcName))
	return func
end

return table.freeze(NetworkEndpoints)
