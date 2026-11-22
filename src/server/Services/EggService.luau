--!strict
--[[
    EggService.luau
    Server-authoritative Egg Hatching and Roll System for MAGIA ETERNA.
    Validates coins, inventory limits, and executes secure weighted rolls.
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local EggConfig = require(Shared:WaitForChild("Config"):WaitForChild("EggConfig") :: ModuleScript)
local PetConfig = require(Shared:WaitForChild("Config"):WaitForChild("PetConfig") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local Services = script.Parent
local PlayerDataService = require(Services:WaitForChild("PlayerDataService") :: ModuleScript)
local RemoteGuard = require(Services:WaitForChild("RemoteGuard") :: ModuleScript)
local QuestService = require(Services:WaitForChild("QuestService") :: ModuleScript)

local EggService = {}

-- Opens an egg for a player with atomic transaction
function EggService.OpenEgg(player: Player, eggId: string): (boolean, string?, string?)
	if not RemoteGuard.Validate(player, "OpenEgg") then
		return false, nil, "Demasiadas solicitudes. Espera un momento."
	end
	
	local egg = EggConfig.GetEgg(eggId)
	if not egg then
		return false, nil, "El huevo especificado no existe."
	end
	
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return false, nil, "Error cargando perfil del jugador."
	end
	
	-- 1. Check Inventory Space
	local petCount = 0
	for _, _ in pairs(profile.PetInventory) do
		petCount += 1
	end
	if petCount >= profile.MaxPetInventory then
		return false, nil, "Inventario de mascotas lleno. Fusiona o libera mascotas."
	end
	
	-- 2. Check Coins
	if profile.Coins < egg.CostCoins then
		return false, nil, string.format("Oro insuficiente. Necesitas %d monedas.", egg.CostCoins)
	end
	
	-- 3. Execute Roll
	local rolledPetId, rarity = EggConfig.RollPet(eggId)
	if not rolledPetId then
		return false, nil, "Error al generar resultado de mascota."
	end
	
	local petDef = PetConfig.GetPet(rolledPetId)
	if not petDef then
		return false, nil, "Definición de mascota no encontrada."
	end
	
	local newUuid = HttpService:GenerateGUID(false)
	
	-- 4. Atomic Transaction: Deduct coins, add pet
	local updateSuccess = PlayerDataService.UpdateProfile(player, function(data)
		data.Coins -= egg.CostCoins
		data.PetInventory[newUuid] = {
			Id = rolledPetId,
			Species = petDef.Name,
			Tier = "Normal",
			Level = 1,
			Locked = false,
		}
	end)
	
	if updateSuccess then
		QuestService.RecordProgress(player, "OpenEgg", 1)
		
		-- Notify client
		local notifEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.NotificationPrompt)
		if notifEvent then
			local msg = string.format("¡Has obtenido un %s (%s)!", petDef.Name, rarity or "Común")
			notifEvent:FireClient(player, "¡Huevo Eclosionado!", msg, "Success")
		end
		print(string.format("[EggService] %s hatched %s (%s) from %s.", player.Name, petDef.Name, rarity or "Común", eggId))
		return true, newUuid, rolledPetId
	else
		return false, nil, "Error interno en la transacción de eclosión."
	end
end

-- Initializes EggService and connects RemoteEvent
function EggService.Init()
	local openEggEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestOpenEgg)
	openEggEvent.OnServerEvent:Connect(function(player: Player, eggId: any)
		if typeof(eggId) == "string" then
			EggService.OpenEgg(player, eggId)
		end
	end)
	
	print("[EggService] Initialized and connected to RequestOpenEgg.")
end

return table.freeze(EggService)
