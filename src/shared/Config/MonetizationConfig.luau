--!strict
--[[
    MonetizationConfig.luau
    Game Passes and Developer Products catalog for MAGIA ETERNA.
    NOTE: Replace AssetId = 0 with your real Roblox Creator Hub IDs before publishing.
]]

export type ProductType = "GamePass" | "DevProduct"

export type MonetizationProduct = {
	Id: string,
	AssetId: number, -- Roblox PassId or ProductId (0 = placeholder)
	Type: ProductType,
	Name: string,
	RobuxPrice: number,
	Description: string,
}

local MonetizationConfig = {}

local products: { [string]: MonetizationProduct } = {
	-- Game Passes
	["GP_VIP"] = {
		Id = "GP_VIP",
		AssetId = 0,
		Type = "GamePass",
		Name = "VIP Permanente",
		RobuxPrice = 399,
		Description = "+25% Magia, +25% Oro y etiqueta VIP en el chat.",
	},
	["GP_PET_SLOTS"] = {
		Id = "GP_PET_SLOTS",
		AssetId = 0,
		Type = "GamePass",
		Name = "+2 Espacios de Mascotas",
		RobuxPrice = 249,
		Description = "Equipa hasta 2 mascotas adicionales simultáneamente.",
	},
	["GP_AUTO_TRAIN"] = {
		Id = "GP_AUTO_TRAIN",
		AssetId = 0,
		Type = "GamePass",
		Name = "Autoentrenamiento Avanzado",
		RobuxPrice = 199,
		Description = "Entrena magia automáticamente más rápido sin clics manuales.",
	},
	["GP_2X_COINS"] = {
		Id = "GP_2X_COINS",
		AssetId = 0,
		Type = "GamePass",
		Name = "x2 Monedas",
		RobuxPrice = 299,
		Description = "Duplica todo el Oro obtenido en mazmorras y ventas.",
	},
	["GP_2X_MAGIC"] = {
		Id = "GP_2X_MAGIC",
		AssetId = 0,
		Type = "GamePass",
		Name = "x2 Magia",
		RobuxPrice = 299,
		Description = "Duplica toda la Magia generada al entrenar.",
	},

	-- Developer Products
	["DP_WELCOME_PACK"] = {
		Id = "DP_WELCOME_PACK",
		AssetId = 0,
		Type = "DevProduct",
		Name = "Pack de Bienvenida",
		RobuxPrice = 49,
		Description = "2,500 Oro + 25 Esencias + 1 Fragmento de Renacimiento.",
	},
	["DP_LUCK_BOOST"] = {
		Id = "DP_LUCK_BOOST",
		AssetId = 0,
		Type = "DevProduct",
		Name = "Boost de Suerte (15 min)",
		RobuxPrice = 39,
		Description = "Aumenta la suerte de botín en mazmorras por 15 minutos.",
	},
	["DP_COINS_BOOST"] = {
		Id = "DP_COINS_BOOST",
		AssetId = 0,
		Type = "DevProduct",
		Name = "Boost de Monedas (15 min)",
		RobuxPrice = 29,
		Description = "Aumenta en +50% el Oro obtenido durante 15 minutos.",
	},
	["DP_DUNGEON_REVIVE"] = {
		Id = "DP_DUNGEON_REVIVE",
		AssetId = 0,
		Type = "DevProduct",
		Name = "Revivir en Mazmorra",
		RobuxPrice = 19,
		Description = "Revive instantáneamente en la sala actual con vida completa.",
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
	table.sort(list, function(a, b) return a.RobuxPrice < b.RobuxPrice end)
	return list
end

return table.freeze(MonetizationConfig)
