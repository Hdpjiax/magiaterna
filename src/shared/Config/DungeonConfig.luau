--!strict
--[[
    DungeonConfig.luau
    Configuration for 6 Dungeon Regions, 5 Difficulty Tiers, Rooms, and Loot Drops for MAGIA ETERNA.
]]

export type DungeonDifficulty = 1 | 2 | 3 | 4 | 5

export type DifficultyStats = {
	HealthMultiplier: number,
	DamageMultiplier: number,
	RewardMultiplier: number,
	GuaranteeRebirthShard: boolean,
}

export type DungeonLootEntry = {
	ItemType: "Coin" | "Essence" | "Material",
	Id: string,
	MinAmount: number,
	MaxAmount: number,
	DropChance: number, -- 0.0 to 1.0 (1.0 = 100%)
}

export type DungeonRegionDefinition = {
	Id: string,
	Name: string,
	RecommendedLevel: string,
	BossId: string,
	MiniBossId: string,
	NormalEnemies: { string },
	RoomsCount: number,
	TargetDurationMinutes: number,
	LootTable: { DungeonLootEntry },
}

local DungeonConfig = {}

-- 5 Difficulty Multipliers (I to V)
DungeonConfig.DIFFICULTIES: { [DungeonDifficulty]: DifficultyStats } = {
	[1] = {
		HealthMultiplier = 1.00,
		DamageMultiplier = 1.00,
		RewardMultiplier = 1.00,
		GuaranteeRebirthShard = false,
	},
	[2] = {
		HealthMultiplier = 1.35,
		DamageMultiplier = 1.15,
		RewardMultiplier = 1.15,
		GuaranteeRebirthShard = false,
	},
	[3] = {
		HealthMultiplier = 1.80,
		DamageMultiplier = 1.35,
		RewardMultiplier = 1.30,
		GuaranteeRebirthShard = false,
	},
	[4] = {
		HealthMultiplier = 2.50,
		DamageMultiplier = 1.65,
		RewardMultiplier = 1.55,
		GuaranteeRebirthShard = false,
	},
	[5] = {
		HealthMultiplier = 3.50,
		DamageMultiplier = 2.10,
		RewardMultiplier = 1.90,
		GuaranteeRebirthShard = true, -- High difficulty rewards guaranteed Rebirth Shard!
	},
}

-- 6 Regions Catalog
local dungeons: { [string]: DungeonRegionDefinition } = {
	["Dungeon_Bosque"] = {
		Id = "Dungeon_Bosque",
		Name = "Bosque de los Susurros",
		RecommendedLevel = "1 - 10",
		BossId = "Boss_TreantAncestral",
		MiniBossId = "MiniBoss_GuardianRaices",
		NormalEnemies = { "Enemy_SlimeVerde", "Enemy_DuendeBosque", "Enemy_LoboMagico", "Enemy_HadaCorrupta" },
		RoomsCount = 5, -- 3 combat, 1 miniboss/exploration, 1 boss
		TargetDurationMinutes = 6,
		LootTable = {
			{ ItemType = "Coin", Id = "Coins", MinAmount = 500, MaxAmount = 1500, DropChance = 1.0 },
			{ ItemType = "Essence", Id = "EsenciaVerde", MinAmount = 3, MaxAmount = 8, DropChance = 0.9 },
			{ ItemType = "Material", Id = "MaderaAntigua", MinAmount = 8, MaxAmount = 20, DropChance = 1.0 },
			{ ItemType = "Material", Id = "HojaMagica", MinAmount = 5, MaxAmount = 12, DropChance = 0.8 },
			{ ItemType = "Material", Id = "PiedraRunica", MinAmount = 1, MaxAmount = 3, DropChance = 0.4 },
			{ ItemType = "Material", Id = "NucleoTreant", MinAmount = 1, MaxAmount = 1, DropChance = 0.25 }, -- Rare boss material
		},
	},
	["Dungeon_Minas"] = {
		Id = "Dungeon_Minas",
		Name = "Minas del Fuego Eterno",
		RecommendedLevel = "10 - 20",
		BossId = "Boss_DragonMagma",
		MiniBossId = "MiniBoss_ColosoIgneo",
		NormalEnemies = { "Enemy_MurcielagoLava", "Enemy_GolemIgneo", "Enemy_MineroMaldito" },
		RoomsCount = 5,
		TargetDurationMinutes = 7,
		LootTable = {
			{ ItemType = "Coin", Id = "Coins", MinAmount = 3000, MaxAmount = 8000, DropChance = 1.0 },
			{ ItemType = "Material", Id = "CarbonArcano", MinAmount = 10, MaxAmount = 25, DropChance = 0.9 },
			{ ItemType = "Material", Id = "HierroVolcanico", MinAmount = 5, MaxAmount = 15, DropChance = 0.7 },
			{ ItemType = "Material", Id = "CorazonMagma", MinAmount = 1, MaxAmount = 1, DropChance = 0.25 },
		},
	},
}

-- Retrieves dungeon region definition by ID
function DungeonConfig.GetDungeon(dungeonId: string): DungeonRegionDefinition?
	return dungeons[dungeonId]
end

-- Checks if dungeon exists
function DungeonConfig.Exists(dungeonId: string): boolean
	return dungeons[dungeonId] ~= nil
end

-- Calculates final difficulty-scaled enemy HP
function DungeonConfig.GetScaledHealth(baseHp: number, difficulty: DungeonDifficulty): number
	local diffStats = DungeonConfig.DIFFICULTIES[difficulty] or DungeonConfig.DIFFICULTIES[1]
	return math.floor(baseHp * diffStats.HealthMultiplier)
end

-- Calculates final difficulty-scaled enemy Damage
function DungeonConfig.GetScaledDamage(baseDmg: number, difficulty: DungeonDifficulty): number
	local diffStats = DungeonConfig.DIFFICULTIES[difficulty] or DungeonConfig.DIFFICULTIES[1]
	return math.floor(baseDmg * diffStats.DamageMultiplier)
end

return table.freeze(DungeonConfig)
