--!strict
--[[
    DungeonConfig.luau
    All 6 Dungeon Regions, 5 Difficulty Tiers, Rooms, and Loot Drops for MAGIA ETERNA.
]]

export type DungeonDifficulty = number

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
	DropChance: number,
}

export type DungeonRegionDefinition = {
	Id: string,
	Name: string,
	RegionKey: string,
	RecommendedLevel: string,
	BossId: string,
	MiniBossId: string,
	NormalEnemies: { string },
	RoomsCount: number,
	TargetDurationMinutes: number,
	LootTable: { DungeonLootEntry },
}

local DungeonConfig = {}

local DIFFICULTIES: { [number]: DifficultyStats } = {
	[1] = { HealthMultiplier = 1.00, DamageMultiplier = 1.00, RewardMultiplier = 1.00, GuaranteeRebirthShard = false },
	[2] = { HealthMultiplier = 1.35, DamageMultiplier = 1.15, RewardMultiplier = 1.15, GuaranteeRebirthShard = false },
	[3] = { HealthMultiplier = 1.80, DamageMultiplier = 1.35, RewardMultiplier = 1.30, GuaranteeRebirthShard = false },
	[4] = { HealthMultiplier = 2.50, DamageMultiplier = 1.65, RewardMultiplier = 1.55, GuaranteeRebirthShard = false },
	[5] = { HealthMultiplier = 3.50, DamageMultiplier = 2.10, RewardMultiplier = 1.90, GuaranteeRebirthShard = true },
}
DungeonConfig.DIFFICULTIES = DIFFICULTIES

local dungeons: { [string]: DungeonRegionDefinition } = {
	["Dungeon_Bosque"] = {
		Id = "Dungeon_Bosque",
		Name = "Bosque de los Susurros",
		RegionKey = "Bosque",
		RecommendedLevel = "1-5",
		BossId = "Enemy_TreantAncestral",
		MiniBossId = "Enemy_GuardianRaices",
		NormalEnemies = { "Enemy_SlimeVerde", "Enemy_DuendeBosque", "Enemy_LoboMagico", "Enemy_HadaCorrupta" },
		RoomsCount = 5,
		TargetDurationMinutes = 5,
		LootTable = {
			{ ItemType = "Coin", Id = "Gold", MinAmount = 100, MaxAmount = 200, DropChance = 1.0 },
			{ ItemType = "Essence", Id = "Essence", MinAmount = 5, MaxAmount = 10, DropChance = 1.0 },
			{ ItemType = "Material", Id = "MaderaAntigua", MinAmount = 4, MaxAmount = 8, DropChance = 0.95 },
			{ ItemType = "Material", Id = "HojaMagica", MinAmount = 3, MaxAmount = 6, DropChance = 0.85 },
			{ ItemType = "Material", Id = "EsenciaVerde", MinAmount = 2, MaxAmount = 4, DropChance = 0.65 },
			{ ItemType = "Material", Id = "PiedraRunica", MinAmount = 1, MaxAmount = 3, DropChance = 0.40 },
			{ ItemType = "Material", Id = "NucleoTreant", MinAmount = 1, MaxAmount = 1, DropChance = 0.20 },
		},
	},
	["Dungeon_Minas"] = {
		Id = "Dungeon_Minas",
		Name = "Minas del Fuego Eterno",
		RegionKey = "Minas",
		RecommendedLevel = "5-15",
		BossId = "Enemy_DragonMagma",
		MiniBossId = "Enemy_ColosoIgneo",
		NormalEnemies = { "Enemy_MurcielagoLava", "Enemy_GolemIgneo", "Enemy_MineroMaldito", "Enemy_SalamandraFuego" },
		RoomsCount = 5,
		TargetDurationMinutes = 6,
		LootTable = {
			{ ItemType = "Coin", Id = "Gold", MinAmount = 450, MaxAmount = 900, DropChance = 1.0 },
			{ ItemType = "Essence", Id = "Essence", MinAmount = 12, MaxAmount = 24, DropChance = 1.0 },
			{ ItemType = "Material", Id = "CarbonArcano", MinAmount = 4, MaxAmount = 8, DropChance = 0.95 },
			{ ItemType = "Material", Id = "HierroVolcanico", MinAmount = 3, MaxAmount = 6, DropChance = 0.85 },
			{ ItemType = "Material", Id = "CristalIgneo", MinAmount = 2, MaxAmount = 4, DropChance = 0.65 },
			{ ItemType = "Material", Id = "AzufreMagico", MinAmount = 1, MaxAmount = 3, DropChance = 0.40 },
			{ ItemType = "Material", Id = "CorazonMagma", MinAmount = 1, MaxAmount = 1, DropChance = 0.20 },
		},
	},
	["Dungeon_Hielo"] = {
		Id = "Dungeon_Hielo",
		Name = "Reino del Hielo",
		RegionKey = "Hielo",
		RecommendedLevel = "15-30",
		BossId = "Enemy_TitanGlacial",
		MiniBossId = "Enemy_ReinaEscarcha",
		NormalEnemies = { "Enemy_LoboArtico", "Enemy_EspectroHielo", "Enemy_CaballeroCongelado", "Enemy_YetiHielo" },
		RoomsCount = 5,
		TargetDurationMinutes = 6,
		LootTable = {
			{ ItemType = "Coin", Id = "Gold", MinAmount = 2000, MaxAmount = 4000, DropChance = 1.0 },
			{ ItemType = "Essence", Id = "Essence", MinAmount = 25, MaxAmount = 50, DropChance = 1.0 },
			{ ItemType = "Material", Id = "HieloEterno", MinAmount = 4, MaxAmount = 8, DropChance = 0.95 },
			{ ItemType = "Material", Id = "ZafiroGlacial", MinAmount = 3, MaxAmount = 6, DropChance = 0.85 },
			{ ItemType = "Material", Id = "PielYeti", MinAmount = 2, MaxAmount = 4, DropChance = 0.65 },
			{ ItemType = "Material", Id = "EscarchaPura", MinAmount = 1, MaxAmount = 3, DropChance = 0.40 },
			{ ItemType = "Material", Id = "AlmaCongelada", MinAmount = 1, MaxAmount = 1, DropChance = 0.20 },
		},
	},
	["Dungeon_Cripta"] = {
		Id = "Dungeon_Cripta",
		Name = "Cripta de las Almas",
		RegionKey = "Cripta",
		RecommendedLevel = "30-50",
		BossId = "Enemy_ReyAlmas",
		MiniBossId = "Enemy_CaballeroSinAlma",
		NormalEnemies = { "Enemy_EsqueletoCripta", "Enemy_EspectroCripta", "Enemy_VampiroCripta", "Enemy_NigromanteCripta" },
		RoomsCount = 5,
		TargetDurationMinutes = 7,
		LootTable = {
			{ ItemType = "Coin", Id = "Gold", MinAmount = 9000, MaxAmount = 18000, DropChance = 1.0 },
			{ ItemType = "Essence", Id = "Essence", MinAmount = 55, MaxAmount = 110, DropChance = 1.0 },
			{ ItemType = "Material", Id = "HuesoEspectral", MinAmount = 4, MaxAmount = 8, DropChance = 0.95 },
			{ ItemType = "Material", Id = "PolvoAlma", MinAmount = 3, MaxAmount = 6, DropChance = 0.85 },
			{ ItemType = "Material", Id = "PlataMaldita", MinAmount = 2, MaxAmount = 4, DropChance = 0.65 },
			{ ItemType = "Material", Id = "EsenciaSombria", MinAmount = 1, MaxAmount = 3, DropChance = 0.40 },
			{ ItemType = "Material", Id = "CorazonNecrotico", MinAmount = 1, MaxAmount = 1, DropChance = 0.20 },
		},
	},
	["Dungeon_Cielos"] = {
		Id = "Dungeon_Cielos",
		Name = "Templo de los Cielos",
		RegionKey = "Cielos",
		RecommendedLevel = "50-70",
		BossId = "Enemy_ArcangelCaos",
		MiniBossId = "Enemy_GuardianSolar",
		NormalEnemies = { "Enemy_CentinelaCielos", "Enemy_GrifoCielos", "Enemy_AngelCaido", "Enemy_ElementalLuz" },
		RoomsCount = 5,
		TargetDurationMinutes = 7,
		LootTable = {
			{ ItemType = "Coin", Id = "Gold", MinAmount = 40000, MaxAmount = 80000, DropChance = 1.0 },
			{ ItemType = "Essence", Id = "Essence", MinAmount = 120, MaxAmount = 240, DropChance = 1.0 },
			{ ItemType = "Material", Id = "PlumaCelestial", MinAmount = 4, MaxAmount = 8, DropChance = 0.95 },
			{ ItemType = "Material", Id = "OroSagrado", MinAmount = 3, MaxAmount = 6, DropChance = 0.85 },
			{ ItemType = "Material", Id = "FragmentoSolar", MinAmount = 2, MaxAmount = 4, DropChance = 0.65 },
			{ ItemType = "Material", Id = "PolvoEstelar", MinAmount = 1, MaxAmount = 3, DropChance = 0.40 },
			{ ItemType = "Material", Id = "NucleoArcangel", MinAmount = 1, MaxAmount = 1, DropChance = 0.20 },
		},
	},
	["Dungeon_Abismo"] = {
		Id = "Dungeon_Abismo",
		Name = "Abismo del Infinito",
		RegionKey = "Abismo",
		RecommendedLevel = "70-100",
		BossId = "Enemy_DiosVacio",
		MiniBossId = "Enemy_DestructorDimensional",
		NormalEnemies = { "Enemy_DevoradorAbismo", "Enemy_SombraAbismo", "Enemy_AberracionAbismo", "Enemy_MagoVacio" },
		RoomsCount = 5,
		TargetDurationMinutes = 8,
		LootTable = {
			{ ItemType = "Coin", Id = "Gold", MinAmount = 180000, MaxAmount = 360000, DropChance = 1.0 },
			{ ItemType = "Essence", Id = "Essence", MinAmount = 250, MaxAmount = 500, DropChance = 1.0 },
			{ ItemType = "Material", Id = "FragmentoVacio", MinAmount = 4, MaxAmount = 8, DropChance = 0.95 },
			{ ItemType = "Material", Id = "MateriaOscura", MinAmount = 3, MaxAmount = 6, DropChance = 0.85 },
			{ ItemType = "Material", Id = "CristalDimensional", MinAmount = 2, MaxAmount = 4, DropChance = 0.65 },
			{ ItemType = "Material", Id = "EsenciaInfinita", MinAmount = 1, MaxAmount = 3, DropChance = 0.40 },
			{ ItemType = "Material", Id = "CorazonInfinito", MinAmount = 1, MaxAmount = 1, DropChance = 0.20 },
		},
	},
}

function DungeonConfig.GetDungeon(dungeonId: string): DungeonRegionDefinition?
	return dungeons[dungeonId]
end

function DungeonConfig.Exists(dungeonId: string): boolean
	return dungeons[dungeonId] ~= nil
end

function DungeonConfig.GetAllDungeons(): { DungeonRegionDefinition }
	local order = { "Dungeon_Bosque", "Dungeon_Minas", "Dungeon_Hielo", "Dungeon_Cripta", "Dungeon_Cielos", "Dungeon_Abismo" }
	local list = {}
	for _, id in ipairs(order) do
		if dungeons[id] then
			table.insert(list, dungeons[id])
		end
	end
	return list
end

function DungeonConfig.GetScaledHealth(baseHp: number, difficulty: DungeonDifficulty): number
	local diffStats = DungeonConfig.DIFFICULTIES[difficulty] or DungeonConfig.DIFFICULTIES[1]
	return math.floor(baseHp * diffStats.HealthMultiplier)
end

function DungeonConfig.GetScaledDamage(baseDmg: number, difficulty: DungeonDifficulty): number
	local diffStats = DungeonConfig.DIFFICULTIES[difficulty] or DungeonConfig.DIFFICULTIES[1]
	return math.floor(baseDmg * diffStats.DamageMultiplier)
end

return table.freeze(DungeonConfig)
