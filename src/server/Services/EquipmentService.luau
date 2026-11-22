--!strict
--[[
    EquipmentService.luau
    Player Equipment Manager for Staves and Armor Sets in MAGIA ETERNA.
    Applies health and defensive statistics to avatars and syncs equipped gear safely.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local StaffConfig = require(Shared:WaitForChild("Config"):WaitForChild("StaffConfig") :: ModuleScript)
local ArmorConfig = require(Shared:WaitForChild("Config"):WaitForChild("ArmorConfig") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local Services = script.Parent
local PlayerDataService = require(Services:WaitForChild("PlayerDataService") :: ModuleScript)
local RemoteGuard = require(Services:WaitForChild("RemoteGuard") :: ModuleScript)

local EquipmentService = {}

-- Applies armor defensive and health bonuses to the player's character
local function applyArmorToCharacter(player: Player)
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	local profile = PlayerDataService.GetProfile(player)
	if not profile then return end
	
	local stats = ArmorConfig.CalculateTotalStats(profile.EquippedArmor)
	local baseHp = 100
	local healthBonus = (stats and (stats.TotalHealth or (stats :: any).TotalHealthBonus)) or 0
	local targetMaxHp = baseHp + healthBonus
	
	humanoid.MaxHealth = targetMaxHp
	if humanoid.Health > targetMaxHp then
		humanoid.Health = targetMaxHp
	end
end

-- Equips a staff for the player
function EquipmentService.EquipStaff(player: Player, staffId: string): (boolean, string)
	if not RemoteGuard.Validate(player, "EquipItem") then
		return false, "Demasiadas solicitudes de equipamiento."
	end
	
	if not StaffConfig.Exists(staffId) then
		return false, "El bastón especificado no existe."
	end
	
	local profile = PlayerDataService.GetProfile(player)
	if not profile then return false, "Perfil no disponible." end
	
	-- Verify ownership
	if not profile.OwnedStaffs[staffId] then
		return false, "No posees este bastón. Forja o encuéntralo primero."
	end
	
	local success = PlayerDataService.UpdateProfile(player, function(data)
		data.EquippedStaff = staffId
	end)
	
	return success, success and "Bastón equipado con éxito." or "Error interno al equipar bastón."
end

-- Equips an armor piece for the player
function EquipmentService.EquipArmor(player: Player, armorPieceId: string): (boolean, string)
	if not RemoteGuard.Validate(player, "EquipItem") then
		return false, "Demasiadas solicitudes."
	end
	
	local pieceDef = ArmorConfig.GetPiece(armorPieceId)
	if not pieceDef then
		return false, "La pieza de armadura especificada no existe."
	end
	
	local profile = PlayerDataService.GetProfile(player)
	if not profile then return false, "Perfil no disponible." end
	
	-- Verify ownership in ArmorInventory
	if (profile.ArmorInventory[armorPieceId] or 0) <= 0 then
		return false, "No posees esta pieza de armadura en tu inventario."
	end
	
	local success = PlayerDataService.UpdateProfile(player, function(data)
		data.EquippedArmor[pieceDef.Slot] = armorPieceId
	end)
	
	if success then
		applyArmorToCharacter(player)
	end
	
	return success, success and "Pieza de armadura equipada." or "Error al equipar armadura."
end

-- Unequips an armor slot
function EquipmentService.UnequipArmor(player: Player, slot: string): (boolean, string)
	if not RemoteGuard.Validate(player, "EquipItem") then
		return false, "Demasiadas solicitudes."
	end
	
	local success = PlayerDataService.UpdateProfile(player, function(data)
		data.EquippedArmor[slot] = nil
	end)
	
	if success then
		applyArmorToCharacter(player)
	end
	
	return success, success and "Pieza desequipada." or "Error al desequipar."
end

-- Initializes EquipmentService and hooks events
function EquipmentService.Init()
	local equipStaffEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestEquipStaff)
	equipStaffEvent.OnServerEvent:Connect(function(player: Player, staffId: any)
		if typeof(staffId) == "string" then
			EquipmentService.EquipStaff(player, staffId)
		end
	end)
	
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			task.wait(0.5)
			applyArmorToCharacter(player)
		end)
	end)
	
	print("[EquipmentService] Initialized and connected to Equipment Remotes.")
end

return table.freeze(EquipmentService)
