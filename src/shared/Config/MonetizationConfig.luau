--!strict
--[[
    MonetizationConfig.luau
    Catálogo oficial de Monetización Responsable para MAGIA ETERNA.
    Cumple con las políticas oficiales de Roblox:
    - Sin mecánicas Pay-to-Win que rompan el balance.
    - Probabilidades transparentes y descripciones claras.
    - IDs estables y listos para vincular a IDs reales del Creator Hub.
]]

export type ProductType = "GamePass" | "DevProduct"

export type MonetizationProduct = {
	Id: string,
	AssetId: number, -- Reemplazar con ID de Roblox Creator Hub al publicar
	Type: ProductType,
	Name: string,
	RobuxPrice: number,
	Description: string,
	BenefitText: string,
	Icon: string,
}

local MonetizationConfig = {}

local products: { [string]: MonetizationProduct } = {
	-- ==========================================
	-- GAME PASSES OFICIALES (Beneficios Permanentes)
	-- ==========================================
	["GP_VIP"] = {
		Id = "GP_VIP",
		AssetId = 0,
		Type = "GamePass",
		Name = "Pase VIP",
		RobuxPrice = 399,
		Description = "Acceso exclusivo VIP: Tag dorado en chat y multiplicador de Oro x1.2 en todas las fuentes.",
		BenefitText = "Tag Dorado + Oro x1.2 Permanente",
		Icon = "rbxassetid://6034287517",
	},
	["GP_AUTO_TRAIN"] = {
		Id = "GP_AUTO_TRAIN",
		AssetId = 0,
		Type = "GamePass",
		Name = "Auto-Train Acelerado",
		RobuxPrice = 199,
		Description = "Entrena magia automáticamente a velocidad x2 sin necesidad de clics manuales.",
		BenefitText = "Auto-Entrenamiento x2 Vel.",
		Icon = "rbxassetid://6034287525",
	},
	["GP_PET_SLOTS"] = {
		Id = "GP_PET_SLOTS",
		AssetId = 0,
		Type = "GamePass",
		Name = "+2 Mascotas Equipadas",
		RobuxPrice = 249,
		Description = "Permite equipar 2 mascotas adicionales de forma permanente (pasa de 3 a 5 activas).",
		BenefitText = "Capacidad de 3 a 5 Mascotas",
		Icon = "rbxassetid://6034287530",
	},
	["GP_INVENTORY_50"] = {
		Id = "GP_INVENTORY_50",
		AssetId = 0,
		Type = "GamePass",
		Name = "+50 Ranuras de Inventario",
		RobuxPrice = 149,
		Description = "Expande permanentemente la capacidad del inventario de bastones y armaduras en +50 espacios.",
		BenefitText = "+50 Espacios de Equipo",
		Icon = "rbxassetid://6034287535",
	},

	-- ==========================================
	-- DEVELOPER PRODUCTS (Consumibles Recomprables)
	-- ==========================================
	["DP_COINS_1000"] = {
		Id = "DP_COINS_1000",
		AssetId = 0,
		Type = "DevProduct",
		Name = "Bolsa de 1,000 Monedas",
		RobuxPrice = 25,
		Description = "Bolsa repleta de 1,000 Monedas de Oro para forja y compras inmediatas.",
		BenefitText = "+1,000 Oro Instantáneo",
		Icon = "rbxassetid://6034287540",
	},
	["DP_COINS_10000"] = {
		Id = "DP_COINS_10000",
		AssetId = 0,
		Type = "DevProduct",
		Name = "Cofre de 10,000 Monedas",
		RobuxPrice = 149,
		Description = "Gran cofre del tesoro con 10,000 Monedas de Oro (¡Mejor valor!).",
		BenefitText = "+10,000 Oro Instantáneo",
		Icon = "rbxassetid://6034287545",
	},
	["DP_ESSENCES_500"] = {
		Id = "DP_ESSENCES_500",
		AssetId = 0,
		Type = "DevProduct",
		Name = "Frasco de 500 Esencias",
		RobuxPrice = 45,
		Description = "500 Esencias mágicas puras para mejorar bastones y transmutaciones.",
		BenefitText = "+500 Esencias Mágicas",
		Icon = "rbxassetid://6034287550",
	},
	["DP_ESSENCES_5000"] = {
		Id = "DP_ESSENCES_5000",
		AssetId = 0,
		Type = "DevProduct",
		Name = "Garrafa de 5,000 Esencias",
		RobuxPrice = 299,
		Description = "Gran depósito alquímico con 5,000 Esencias mágicas.",
		BenefitText = "+5,000 Esencias Mágicas",
		Icon = "rbxassetid://6034287555",
	},
	["DP_REBIRTH_SHARDS"] = {
		Id = "DP_REBIRTH_SHARDS",
		AssetId = 0,
		Type = "DevProduct",
		Name = "Fardo de 1 Esquirla de Rebirth",
		RobuxPrice = 99,
		Description = "1 Esquirla de Rebirth sagrada para acelerar tus ascensiones.",
		BenefitText = "+1 Esquirla de Rebirth",
		Icon = "rbxassetid://6034287560",
	},
}

function MonetizationConfig.GetProduct(id: string): MonetizationProduct?
	return products[id]
end

function MonetizationConfig.GetByAssetId(assetId: number): MonetizationProduct?
	if assetId == 0 then return nil end
	for _, p in pairs(products) do
		if p.AssetId == assetId then
			return p
		end
	end
	return nil
end

function MonetizationConfig.GetAllProducts(): { MonetizationProduct }
	local list = {}
	for _, p in pairs(products) do
		table.insert(list, p)
	end
	table.sort(list, function(a, b) 
		if a.Type ~= b.Type then
			return a.Type == "GamePass" -- GamePasses primero
		end
		return a.RobuxPrice < b.RobuxPrice 
	end)
	return list
end

return table.freeze(MonetizationConfig)
