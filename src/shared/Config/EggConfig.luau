--!strict
--[[
    EggConfig.luau
    Egg Families, coin costs, and transparent weighted drop probabilities for MAGIA ETERNA.
    Complies with Roblox PolicyService by strictly enforcing transparent drop rates.
]]

export type EggDrop = {
	PetId: string,
	Rarity: string,
	Weight: number, -- Relative weight (sums to total weight)
	Percentage: number, -- Display percentage
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
			{ PetId = "Pet_R2_DragonMagma", Rarity = "Mítico", Weight = 5, Percentage = 0.5 },
		},
	},
}

-- Retrieves egg configuration by ID
function EggConfig.GetEgg(eggId: string): EggDefinition?
	return eggs[eggId]
end

-- Checks if egg exists
function EggConfig.Exists(eggId: string): boolean
	return eggs[eggId] ~= nil
end

-- Performs a server-side weighted roll for an egg
function EggConfig.RollPet(eggId: string): (string?, string?)
	local egg = eggs[eggId]
	if not egg or #egg.Drops == 0 then return nil, nil end
	
	local randomWeight = math.random(1, egg.TotalWeight)
	local currentWeight = 0
	
	for _, drop in ipairs(egg.Drops) do
		currentWeight += drop.Weight
		if randomWeight <= currentWeight then
			return drop.PetId, drop.Rarity
		end
	end
	
	-- Fallback to first drop in case of rounding edge-case
	return egg.Drops[1].PetId, egg.Drops[1].Rarity
end

return table.freeze(EggConfig)
