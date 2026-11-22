--!strict
--[[
    ForgeController.luau
    Client-side controller for crafting gear and equipping staves/armor in MAGIA ETERNA.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local ForgeController = {}
local lastRequestTime = 0
local REQUEST_COOLDOWN = 0.25 -- 250ms debounce

-- Requests to forge an item on the server
function ForgeController.Forge(targetId: string)
	local now = os.clock()
	if now - lastRequestTime < REQUEST_COOLDOWN then return end
	lastRequestTime = now
	
	local forgeEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestForgeStaff)
	if forgeEvent then
		forgeEvent:FireServer(targetId)
	end
end

-- Requests to equip an owned staff
function ForgeController.EquipStaff(staffId: string)
	local now = os.clock()
	if now - lastRequestTime < REQUEST_COOLDOWN then return end
	lastRequestTime = now
	
	local equipStaffEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestEquipStaff)
	if equipStaffEvent then
		equipStaffEvent:FireServer(staffId)
	end
end

-- Initializes ForgeController
function ForgeController.Init()
	print("[ForgeController] Initialized successfully.")
end

return table.freeze(ForgeController)
