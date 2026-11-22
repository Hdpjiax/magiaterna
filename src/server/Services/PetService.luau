--!strict
--[[
    PetService.luau
    Pet management, equipment limits, fusion, and bonus calculation service for MAGIA ETERNA.
    Computes total multipliers for MagicService and EconomyService.
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local PetConfig = require(Shared:WaitForChild("Config"):WaitForChild("PetConfig") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local Services = script.Parent
local PlayerDataService = require(Services:WaitForChild("PlayerDataService") :: ModuleScript)
local RemoteGuard = require(Services:WaitForChild("RemoteGuard") :: ModuleScript)

local PetService = {}

-- Calculates total magic multiplier from equipped pets (e.g. +25% = 1.25)
function PetService.GetTotalMagicMultiplier(player: Player): number
	local profile = PlayerDataService.GetProfile(player)
	if not profile then return 1.0 end
	
	local totalBonusPercent = 0
	for _, petUuid in ipairs(profile.EquippedPets) do
		local petItem = profile.PetInventory[petUuid]
		if petItem then
			local stats = PetConfig.CalculateStats(petItem.Id, petItem.Tier :: any)
			totalBonusPercent += stats.MagicBonus
		end
	end
	
	return 1.0 + (totalBonusPercent / 100)
end

-- Calculates total coins multiplier from equipped pets
function PetService.GetTotalCoinsMultiplier(player: Player): number
	local profile = PlayerDataService.GetProfile(player)
	if not profile then return 1.0 end
	
	local totalBonusPercent = 0
	for _, petUuid in ipairs(profile.EquippedPets) do
		local petItem = profile.PetInventory[petUuid]
		if petItem then
			local stats = PetConfig.CalculateStats(petItem.Id, petItem.Tier :: any)
			totalBonusPercent += stats.CoinsBonus
		end
	end
	
	return 1.0 + (totalBonusPercent / 100)
end

-- Equips a pet by UUID
function PetService.EquipPet(player: Player, petUuid: string): (boolean, string)
	if not RemoteGuard.Validate(player, "EquipItem") then
		return false, "Demasiadas solicitudes."
	end
	
	local profile = PlayerDataService.GetProfile(player)
	if not profile then return false, "Perfil no disponible." end
	
	local petItem = profile.PetInventory[petUuid]
	if not petItem then
		return false, "La mascota no existe en tu inventario."
	end
	
	-- Check if already equipped
	for _, eqUuid in ipairs(profile.EquippedPets) do
		if eqUuid == petUuid then
			return false, "La mascota ya está equipada."
		end
	end
	
	-- Check maximum equipped limit
	if #profile.EquippedPets >= profile.MaxEquippedPets then
		return false, string.format("Límite de mascotas equipadas alcanzado (%d/%d).", #profile.EquippedPets, profile.MaxEquippedPets)
	end
	
	local success = PlayerDataService.UpdateProfile(player, function(data)
		table.insert(data.EquippedPets, petUuid)
	end)
	
	return success, success and "Mascota equipada con éxito." or "Error interno al equipar."
end

-- Unequips a pet by UUID
function PetService.UnequipPet(player: Player, petUuid: string): (boolean, string)
	if not RemoteGuard.Validate(player, "EquipItem") then
		return false, "Demasiadas solicitudes."
	end
	
	local success = PlayerDataService.UpdateProfile(player, function(data)
		for index, eqUuid in ipairs(data.EquippedPets) do
			if eqUuid == petUuid then
				table.remove(data.EquippedPets, index)
				break
			end
		end
	end)
	
	return success, success and "Mascota desequipada." or "Error al desequipar."
end

-- Toggles lock on a pet
function PetService.ToggleLock(player: Player, petUuid: string): (boolean, boolean)
	local profile = PlayerDataService.GetProfile(player)
	if not profile then return false, false end
	
	local petItem = profile.PetInventory[petUuid]
	if not petItem then return false, false end
	
	local newLockState = not petItem.Locked
	local success = PlayerDataService.UpdateProfile(player, function(data)
		if data.PetInventory[petUuid] then
			data.PetInventory[petUuid].Locked = newLockState
		end
	end)
	
	return success, newLockState
end

-- Fuses 3 duplicate pets into a higher tier (Normal -> Golden, Golden -> Rainbow)
function PetService.FusePets(player: Player, petUuids: { string }): (boolean, string)
	if #petUuids ~= 3 then
		return false, "Se requieren exactamente 3 mascotas idénticas para fusionar."
	end
	
	local profile = PlayerDataService.GetProfile(player)
	if not profile then return false, "Perfil no disponible." end
	
	local baseSpecies: string? = nil
	local baseTier: string? = nil
	local baseId: string? = nil
	
	for _, uuid in ipairs(petUuids) do
		local item = profile.PetInventory[uuid]
		if not item then return false, "Una de las mascotas seleccionadas no existe." end
		if item.Locked then return false, "No puedes fusionar mascotas bloqueadas." end
		
		-- Ensure not equipped
		for _, eqUuid in ipairs(profile.EquippedPets) do
			if eqUuid == uuid then
				return false, "Desequipa las mascotas antes de fusionarlas."
			end
		end
		
		if not baseSpecies then
			baseSpecies = item.Species
			baseTier = item.Tier
			baseId = item.Id
		else
			if item.Species ~= baseSpecies or item.Tier ~= baseTier then
				return false, "Las 3 mascotas deben ser de la misma especie y nivel de evolución."
			end
		end
	end
	
	local nextTier: string
	if baseTier == "Normal" then
		nextTier = "Golden"
	elseif baseTier == "Golden" then
		nextTier = "Rainbow"
	else
		return false, "Esta mascota ya ha alcanzado su evolución máxima."
	end
	
	local newUuid = HttpService:GenerateGUID(false)
	local success = PlayerDataService.UpdateProfile(player, function(data)
		-- Remove the 3 consumed pets
		for _, uuid in ipairs(petUuids) do
			data.PetInventory[uuid] = nil
		end
		-- Add the fused pet
		data.PetInventory[newUuid] = {
			Id = baseId :: string,
			Species = baseSpecies :: string,
			Tier = nextTier,
			Level = 1,
			Locked = false,
		}
	end)
	
	return success, success and ("¡Fusión exitosa! Nueva mascota: " .. (baseSpecies or "") .. " (" .. nextTier .. ")") or "Error durante la fusión."
end

-- Initializes PetService and hooks remote events
function PetService.Init()
	local equipEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestEquipPet)
	equipEvent.OnServerEvent:Connect(function(player: Player, petUuid: any)
		if typeof(petUuid) == "string" then
			PetService.EquipPet(player, petUuid)
		end
	end)
	
	local unequipEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestUnequipPet)
	unequipEvent.OnServerEvent:Connect(function(player: Player, petUuid: any)
		if typeof(petUuid) == "string" then
			PetService.UnequipPet(player, petUuid)
		end
	end)
	
	local lockEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestLockPet)
	lockEvent.OnServerEvent:Connect(function(player: Player, petUuid: any)
		if typeof(petUuid) == "string" then
			PetService.ToggleLock(player, petUuid)
		end
	end)
	
	print("[PetService] Initialized and connected to Pet Remotes.")
end

return table.freeze(PetService)
