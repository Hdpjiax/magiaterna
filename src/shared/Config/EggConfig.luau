--!strict
--[[
    EggConfig.luau
    All 6 Regional Egg Families, coin costs, and transparent weighted drop probabilities for MAGIA ETERNA.
]]

export type EggDrop = {
	PetId: string,
	Rarity: string,
	Weight: number,
	Percentage: number,
}

export type EggDefinition = {
	Id: string,
	Name: string,
	Region: string,
	CostCoins: number,
	Drops: { EggDrop },
	TotalWeight: number,
}

local EggConfig = {}

local eggs: { [string]: EggDefinition } = {
	["Egg_Bosque"] = {
		Id = "Egg_Bosque",
		Name = "Huevo del Bosque",
		Region = "Bosque",
		CostCoins = 1000,
		TotalWeight = 1000,
		Drops = {
			{ PetId = "Pet_R1_SlimeVerde", Rarity = "Común", Weight = 500, Percentage = 50.0 },
			{ PetId = "Pet_R1_ZorroHoja", Rarity = "Poco común", Weight = 270, Percentage = 27.0 },
			{ PetId = "Pet_R1_BuhoMagico", Rarity = "Raro", Weight = 140, Percentage = 14.0 },
			{ PetId = "Pet_R1_HadaBosque", Rarity = "Épico", Weight = 60, Percentage = 6.0 },
			{ PetId = "Pet_R1_CiervoAncestral", Rarity = "Legendario", Weight = 25, Percentage = 2.5 },
			{ PetId = "Pet_R1_DragonEspiritual", Rarity = "Mítico", Weight = 5, Percentage = 0.5 },
		},
	},
	["Egg_Volcanico"] = {
		Id = "Egg_Volcanico",
		Name = "Huevo Volcánico",
		Region = "Minas",
		CostCoins = 15000,
		TotalWeight = 1000,
		Drops = {
			{ PetId = "Pet_R2_Salamandra", Rarity = "Común", Weight = 500, Percentage = 50.0 },
			{ PetId = "Pet_R2_MurcielagoIgneo", Rarity = "Poco común", Weight = 270, Percentage = 27.0 },
			{ PetId = "Pet_R2_GolemBebe", Rarity = "Raro", Weight = 140, Percentage = 14.0 },
			{ PetId = "Pet_R2_LoboLava", Rarity = "Épico", Weight = 60, Percentage = 6.0 },
			{ PetId = "Pet_R2_FenixCeniza", Rarity = "Legendario", Weight = 25, Percentage = 2.5 },
			{ PetId = "Pet_R2_DragonMagma", Rarity = "Mítico", Weight = 5, Percentage = 0.5 },
		},
	},
	["Egg_Glacial"] = {
		Id = "Egg_Glacial",
		Name = "Huevo Glacial",
		Region = "Hielo",
		CostCoins = 100000,
		TotalWeight = 1000,
		Drops = {
			{ PetId = "Pet_R3_PinguinoArcano", Rarity = "Común", Weight = 500, Percentage = 50.0 },
			{ PetId = "Pet_R3_ZorroPolar", Rarity = "Poco común", Weight = 270, Percentage = 27.0 },
			{ PetId = "Pet_R3_YetiBebe", Rarity = "Raro", Weight = 140, Percentage = 14.0 },
			{ PetId = "Pet_R3_LoboGlaciar", Rarity = "Épico", Weight = 60, Percentage = 6.0 },
			{ PetId = "Pet_R3_EspirituAurora", Rarity = "Legendario", Weight = 25, Percentage = 2.5 },
			{ PetId = "Pet_R3_DragonEscarcha", Rarity = "Mítico", Weight = 5, Percentage = 0.5 },
		},
	},
	["Egg_Espectral"] = {
		Id = "Egg_Espectral",
		Name = "Huevo Espectral",
		Region = "Cripta",
		CostCoins = 750000,
		TotalWeight = 1000,
		Drops = {
			{ PetId = "Pet_R4_MurcielagoEspectral", Rarity = "Común", Weight = 500, Percentage = 50.0 },
			{ PetId = "Pet_R4_CuervoOscuro", Rarity = "Poco común", Weight = 270, Percentage = 27.0 },
			{ PetId = "Pet_R4_GatoFantasma", Rarity = "Raro", Weight = 140, Percentage = 14.0 },
			{ PetId = "Pet_R4_LoboAlmas", Rarity = "Épico", Weight = 60, Percentage = 6.0 },
			{ PetId = "Pet_R4_CaballeroEspectro", Rarity = "Legendario", Weight = 25, Percentage = 2.5 },
			{ PetId = "Pet_R4_DragonNecrotico", Rarity = "Mítico", Weight = 5, Percentage = 0.5 },
		},
	},
	["Egg_Celestial"] = {
		Id = "Egg_Celestial",
		Name = "Huevo Celestial",
		Region = "Cielos",
		CostCoins = 5000000,
		TotalWeight = 1000,
		Drops = {
			{ PetId = "Pet_R5_GrifoBebe", Rarity = "Común", Weight = 500, Percentage = 50.0 },
			{ PetId = "Pet_R5_Angel", Rarity = "Poco común", Weight = 270, Percentage = 27.0 },
			{ PetId = "Pet_R5_UnicornioSolar", Rarity = "Raro", Weight = 140, Percentage = 14.0 },
			{ PetId = "Pet_R5_Fenix", Rarity = "Épico", Weight = 60, Percentage = 6.0 },
			{ PetId = "Pet_R5_SerafinLuz", Rarity = "Legendario", Weight = 25, Percentage = 2.5 },
			{ PetId = "Pet_R5_DragonCelestial", Rarity = "Mítico", Weight = 5, Percentage = 0.5 },
		},
	},
	["Egg_Cosmico"] = {
		Id = "Egg_Cosmico",
		Name = "Huevo Cósmico",
		Region = "Abismo",
		CostCoins = 35000000,
		TotalWeight = 1000,
		Drops = {
			{ PetId = "Pet_R6_OjoVacio", Rarity = "Común", Weight = 500, Percentage = 50.0 },
			{ PetId = "Pet_R6_PulpoCosmico", Rarity = "Poco común", Weight = 270, Percentage = 27.0 },
			{ PetId = "Pet_R6_Sombra", Rarity = "Raro", Weight = 140, Percentage = 14.0 },
			{ PetId = "Pet_R6_DevoradorDimensional", Rarity = "Épico", Weight = 60, Percentage = 6.0 },
			{ PetId = "Pet_R6_HeraldoEstelar", Rarity = "Legendario", Weight = 25, Percentage = 2.5 },
			{ PetId = "Pet_R6_DragonInfinito", Rarity = "Mítico", Weight = 5, Percentage = 0.5 },
		},
	},
}

function EggConfig.GetEgg(eggId: string): EggDefinition?
	return eggs[eggId]
end

function EggConfig.Exists(eggId: string): boolean
	return eggs[eggId] ~= nil
end

function EggConfig.GetAllEggs(): { EggDefinition }
	local list = {}
	for _, egg in pairs(eggs) do
		table.insert(list, egg)
	end
	table.sort(list, function(a, b) return a.CostCoins < b.CostCoins end)
	return list
end

function EggConfig.RollPet(eggId: string): (string?, string?)
	local egg = eggs[eggId]
	if not egg then return nil, nil end

	local roll = math.random(1, egg.TotalWeight)
	local cumulative = 0
	for _, drop in ipairs(egg.Drops) do
		cumulative += drop.Weight
		if roll <= cumulative then
			return drop.PetId, drop.Rarity
		end
	end
	return egg.Drops[1].PetId, egg.Drops[1].Rarity
end

return table.freeze(EggConfig)
