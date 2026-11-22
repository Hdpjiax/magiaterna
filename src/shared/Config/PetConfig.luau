--!strict
--[[
    PetConfig.luau
    Pet Catalog, evolution tiers, and statistical multipliers for MAGIA ETERNA.
    Structured to scale up to 60-90+ distinct pets across 6 regions.
]]

export type PetTier = "Normal" | "Golden" | "Rainbow"

export type PetRarity = "Común" | "Poco común" | "Raro" | "Épico" | "Legendario" | "Mítico"

export type PetDefinition = {
	Id: string,
	Name: string,
	Region: string,
	Rarity: PetRarity,
	MagicBonusPercent: number,    -- e.g. 5 = +5% magic power
	CoinsBonusPercent: number,    -- e.g. 2 = +2% coins
	LuckBonusPercent: number,     -- e.g. 1 = +1% luck
	MaterialsBonusPercent: number,-- e.g. 2 = +2% extra materials
	Description: string,
}

local PetConfig = {}

-- Evolution Tier Multipliers
PetConfig.TIER_MULTIPLIERS = {
	["Normal"] = 1.0,
	["Golden"] = 1.5,
	["Rainbow"] = 2.5,
}

-- Catalog of Initial Pets
local pets: { [string]: PetDefinition } = {
	-- Region 1: Bosque de los Susurros
	["Pet_R1_SlimeVerde"] = {
		Id = "Pet_R1_SlimeVerde",
		Name = "Slime Verde",
		Region = "Bosque",
		Rarity = "Común",
		MagicBonusPercent = 5,
		CoinsBonusPercent = 2,
		LuckBonusPercent = 0,
		MaterialsBonusPercent = 0,
		Description = "Una pequeña gota gelatinosa que resuena con la magia del bosque.",
	},
	["Pet_R1_ZorroHoja"] = {
		Id = "Pet_R1_ZorroHoja",
		Name = "Zorro Hoja",
		Region = "Bosque",
		Rarity = "Poco común",
		MagicBonusPercent = 12,
		CoinsBonusPercent = 5,
		LuckBonusPercent = 1,
		MaterialsBonusPercent = 2,
		Description = "Ágil y curioso, ayuda a recolectar esencias del entorno.",
	},
	["Pet_R1_BuhoMagico"] = {
		Id = "Pet_R1_BuhoMagico",
		Name = "Búho Mágico",
		Region = "Bosque",
		Rarity = "Raro",
		MagicBonusPercent = 25,
		CoinsBonusPercent = 8,
		LuckBonusPercent = 3,
		MaterialsBonusPercent = 4,
		Description = "Ojos sabios que revelan secretos arcanos.",
	},
	["Pet_R1_HadaBosque"] = {
		Id = "Pet_R1_HadaBosque",
		Name = "Hada del Bosque",
		Region = "Bosque",
		Rarity = "Épico",
		MagicBonusPercent = 50,
		CoinsBonusPercent = 15,
		LuckBonusPercent = 5,
		MaterialsBonusPercent = 8,
		Description = "Esparce polvo de hadas que multiplica el flujo de maná.",
	},
	["Pet_R1_CiervoAncestral"] = {
		Id = "Pet_R1_CiervoAncestral",
		Name = "Ciervo Ancestral",
		Region = "Bosque",
		Rarity = "Legendario",
		MagicBonusPercent = 120,
		CoinsBonusPercent = 30,
		LuckBonusPercent = 10,
		MaterialsBonusPercent = 15,
		Description = "Portador de astas que brillan con luz celestial.",
	},
	["Pet_R1_DragonEspiritual"] = {
		Id = "Pet_R1_DragonEspiritual",
		Name = "Dragón Espiritual",
		Region = "Bosque",
		Rarity = "Mítico",
		MagicBonusPercent = 300,
		CoinsBonusPercent = 75,
		LuckBonusPercent = 25,
		MaterialsBonusPercent = 30,
		Description = "La deidad protectora del Bosque de los Susurros.",
	},
	
	-- Region 2 Sample Pets (Minas del Fuego)
	["Pet_R2_Salamandra"] = {
		Id = "Pet_R2_Salamandra",
		Name = "Salamandra de Magma",
		Region = "Minas",
		Rarity = "Común",
		MagicBonusPercent = 350,
		CoinsBonusPercent = 80,
		LuckBonusPercent = 20,
		MaterialsBonusPercent = 25,
		Description = "Capaz de nadar en lava y potenciar el fuego interior.",
	},
	["Pet_R2_DragonMagma"] = {
		Id = "Pet_R2_DragonMagma",
		Name = "Dragón de Magma",
		Region = "Minas",
		Rarity = "Mítico",
		MagicBonusPercent = 2500,
		CoinsBonusPercent = 500,
		LuckBonusPercent = 100,
		MaterialsBonusPercent = 100,
		Description = "Una criatura titánica forjada en el núcleo ardiente.",
	},
}

-- Retrieves pet definition by ID
function PetConfig.GetPet(id: string): PetDefinition?
	return pets[id]
end

-- Calculates final stats considering pet tier (Normal, Golden, Rainbow)
function PetConfig.CalculateStats(id: string, tier: PetTier?): {
	MagicBonus: number,
	CoinsBonus: number,
	LuckBonus: number,
	MaterialsBonus: number,
}
	local pet = pets[id]
	if not pet then
		return { MagicBonus = 0, CoinsBonus = 0, LuckBonus = 0, MaterialsBonus = 0 }
	end
	
	local tierMult = PetConfig.TIER_MULTIPLIERS[tier or "Normal"] or 1.0
	return {
		MagicBonus = pet.MagicBonusPercent * tierMult,
		CoinsBonus = pet.CoinsBonusPercent * tierMult,
		LuckBonus = pet.LuckBonusPercent * tierMult,
		MaterialsBonus = pet.MaterialsBonusPercent * tierMult,
	}
end

-- Checks if pet exists
function PetConfig.Exists(id: string): boolean
	return pets[id] ~= nil
end

return table.freeze(PetConfig)
