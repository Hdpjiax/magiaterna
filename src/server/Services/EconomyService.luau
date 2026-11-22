--!strict
--[[
    EconomyService.luau
    Server-authoritative economy manager for MAGIA ETERNA.
    Handles Gold/Essence transactions, safe quick-sell of materials & unlocked/unequipped pets.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Config"):WaitForChild("GameConfig") :: ModuleScript)
local PetConfig = require(Shared:WaitForChild("Config"):WaitForChild("PetConfig") :: ModuleScript)
local RarityUtils = require(Shared:WaitForChild("Modules"):WaitForChild("RarityUtils") :: ModuleScript)
local TypeValidators = require(Shared:WaitForChild("Modules"):WaitForChild("TypeValidators") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local Services = script.Parent
local PlayerDataService = require(Services:WaitForChild("PlayerDataService") :: ModuleScript)
local RemoteGuard = require(Services:WaitForChild("RemoteGuard") :: ModuleScript)

local EconomyService = {}

-- Server-side material sell values (Gold per unit)
local MATERIAL_VALUES: { [string]: number } = {
	-- Bosque
	MaderaAntigua = 5, HojaMagica = 8, EsenciaVerde = 15, PiedraRunica = 35, NucleoTreant = 120,
	-- Minas
	CarbonArcano = 18, HierroVolcanico = 28, CristalIgneo = 55, AzufreMagico = 110, CorazonMagma = 350,
	-- Hielo
	HieloEterno = 50, ZafiroGlacial = 80, PielYeti = 150, EscarchaPura = 280, AlmaCongelada = 900,
	-- Cripta
	HuesoEspectral = 140, PolvoAlma = 220, PlataMaldita = 400, EsenciaSombria = 750, CorazonNecrotico = 2400,
	-- Cielos
	PlumaCelestial = 380, OroSagrado = 600, FragmentoSolar = 1100, PolvoEstelar = 2000, NucleoArcangel = 6500,
	-- Abismo
	FragmentoVacio = 1000, MateriaOscura = 1600, CristalDimensional = 3000, EsenciaInfinita = 5500, CorazonInfinito = 18000,
}

function EconomyService.GetMaterialValue(materialId: string): number
	return MATERIAL_VALUES[materialId] or 5
end

function EconomyService.AddCoins(player: Player, amount: number): boolean
	if not TypeValidators.IsPositiveNumber(amount) or amount <= 0 then
		return false
	end
	local addAmount = math.floor(amount)
	return PlayerDataService.UpdateProfile(player, function(data)
		data.Coins += addAmount
	end)
end

function EconomyService.SpendCoins(player: Player, amount: number): boolean
	if not TypeValidators.IsPositiveNumber(amount) or amount <= 0 then
		return false
	end
	local profile = PlayerDataService.GetProfile(player)
	if not profile or profile.Coins < amount then
		return false
	end
	return PlayerDataService.UpdateProfile(player, function(data)
		data.Coins = math.max(0, data.Coins - math.floor(amount))
	end)
end

function EconomyService.AddEssences(player: Player, amount: number): boolean
	if not TypeValidators.IsPositiveNumber(amount) or amount <= 0 then
		return false
	end
	local addAmount = math.floor(amount)
	return PlayerDataService.UpdateProfile(player, function(data)
		data.Essences = (data.Essences or 0) + addAmount
	end)
end

function EconomyService.SpendEssences(player: Player, amount: number): boolean
	if not TypeValidators.IsPositiveNumber(amount) or amount <= 0 then
		return false
	end
	local profile = PlayerDataService.GetProfile(player)
	if not profile or (profile.Essences or 0) < amount then
		return false
	end
	return PlayerDataService.UpdateProfile(player, function(data)
		data.Essences = math.max(0, (data.Essences or 0) - math.floor(amount))
	end)
end

-- Sells material quantity for server-calculated Gold
function EconomyService.SellMaterial(player: Player, materialId: string, quantity: number): (boolean, string)
	if not TypeValidators.IsValidString(materialId, 2, 60) then
		return false, "Material inválido."
	end
	if not TypeValidators.IsValidInteger(quantity, 1, 100000) then
		return false, "Cantidad inválida."
	end

	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return false, "Perfil no cargado."
	end

	local owned = profile.Materials[materialId] or 0
	if owned < quantity then
		return false, "No tienes suficientes materiales."
	end

	local unitPrice = EconomyService.GetMaterialValue(materialId)
	local totalGold = unitPrice * quantity

	local ok = PlayerDataService.UpdateProfile(player, function(data)
		local current = data.Materials[materialId] or 0
		local remaining = current - quantity
		if remaining <= 0 then
			data.Materials[materialId] = nil
		else
			data.Materials[materialId] = remaining
		end
		data.Coins += totalGold
	end)

	if ok then
		return true, string.format("Vendiste %dx %s por %d Oro.", quantity, materialId, totalGold)
	end
	return false, "Error al procesar la venta."
end

-- Safely sells an unlocked & unequipped pet for Gold
function EconomyService.SellPet(player: Player, petUuid: string): (boolean, string)
	if not TypeValidators.IsValidString(petUuid, 4, 80) then
		return false, "Mascota inválida."
	end

	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return false, "Perfil no cargado."
	end

	local pet = profile.PetInventory[petUuid]
	if not pet then
		return false, "No posees esta mascota."
	end

	if pet.Locked then
		return false, "No puedes vender una mascota bloqueada o favorita."
	end

	for _, equippedUuid in ipairs(profile.EquippedPets) do
		if equippedUuid == petUuid then
			return false, "Desequipa la mascota antes de venderla."
		end
	end

	local def = PetConfig.GetPet(pet.Species)
	local rarityMult = def and RarityUtils.GetSellMultiplier(def.Rarity) or 1.0
	local tierMult = PetConfig.TIER_MULTIPLIERS[pet.Tier] or 1.0
	local goldValue = math.max(50, math.floor(150 * rarityMult * tierMult))

	local ok = PlayerDataService.UpdateProfile(player, function(data)
		data.PetInventory[petUuid] = nil
		data.Coins += goldValue
	end)

	if ok then
		return true, string.format("Mascota vendida por %d Oro.", goldValue)
	end
	return false, "Error al vender mascota."
end

function EconomyService.Init()
	RemoteGuard.ProtectEvent(
		NetworkEndpoints.Events.RequestSellMaterial,
		"EconomySell",
		GameConfig.RATE_LIMITS.EconomySell,
		function(player: Player, materialId: any, quantity: any)
			if typeof(materialId) ~= "string" or typeof(quantity) ~= "number" then return end
			local ok, msg = EconomyService.SellMaterial(player, materialId, quantity)
			local notify = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.NotificationPrompt)
			notify:FireClient(player, { Type = if ok then "Success" else "Error", Message = msg })
		end
	)

	RemoteGuard.ProtectEvent(
		NetworkEndpoints.Events.RequestSellPet,
		"EconomySell",
		GameConfig.RATE_LIMITS.EconomySell,
		function(player: Player, petUuid: any)
			if typeof(petUuid) ~= "string" then return end
			local ok, msg = EconomyService.SellPet(player, petUuid)
			local notify = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.NotificationPrompt)
			notify:FireClient(player, { Type = if ok then "Success" else "Error", Message = msg })
		end
	)

	print("[EconomyService] Initialized successfully.")
end

return table.freeze(EconomyService)
