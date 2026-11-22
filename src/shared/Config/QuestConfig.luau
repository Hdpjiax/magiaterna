--!strict
--[[
    QuestConfig.luau
    Daily Quests, Weekly Quests, and Permanent Achievements for MAGIA ETERNA.
]]

export type QuestCategory = "Daily" | "Weekly" | "Achievement"

export type QuestObjectiveType =
	| "TrainMagic"
	| "CompleteDungeon"
	| "OpenEgg"
	| "DefeatEnemy"
	| "DefeatBoss"
	| "ForgeItem"
	| "ReachRebirth"
	| "CollectStaff"

export type QuestDefinition = {
	Id: string,
	Name: string,
	Category: QuestCategory,
	ObjectiveType: QuestObjectiveType,
	TargetAmount: number,
	RewardCoins: number,
	RewardEssences: number,
	RewardShards: number,
	Description: string,
}

local QuestConfig = {}

local quests: { [string]: QuestDefinition } = {
	-- Daily Quests
	["DQ_TRAIN_01"] = {
		Id = "DQ_TRAIN_01",
		Name = "Entrenamiento Diario",
		Category = "Daily",
		ObjectiveType = "TrainMagic",
		TargetAmount = 50,
		RewardCoins = 500,
		RewardEssences = 10,
		RewardShards = 0,
		Description = "Entrena tu poder mágico 50 veces.",
	},
	["DQ_DUNGEON_01"] = {
		Id = "DQ_DUNGEON_01",
		Name = "Explorador del Bosque",
		Category = "Daily",
		ObjectiveType = "CompleteDungeon",
		TargetAmount = 1,
		RewardCoins = 1500,
		RewardEssences = 15,
		RewardShards = 0,
		Description = "Supera 1 mazmorra en cualquier dificultad.",
	},
	["DQ_EGG_01"] = {
		Id = "DQ_EGG_01",
		Name = "Coleccionista Novato",
		Category = "Daily",
		ObjectiveType = "OpenEgg",
		TargetAmount = 3,
		RewardCoins = 800,
		RewardEssences = 10,
		RewardShards = 0,
		Description = "Abre 3 huevos de mascota.",
	},
	["DQ_DEFEAT_01"] = {
		Id = "DQ_DEFEAT_01",
		Name = "Cacería de Esbirros",
		Category = "Daily",
		ObjectiveType = "DefeatEnemy",
		TargetAmount = 25,
		RewardCoins = 1200,
		RewardEssences = 15,
		RewardShards = 0,
		Description = "Derrota a 25 enemigos en mazmorras.",
	},
	["DQ_FORGE_01"] = {
		Id = "DQ_FORGE_01",
		Name = "Forjador Mágico",
		Category = "Daily",
		ObjectiveType = "ForgeItem",
		TargetAmount = 1,
		RewardCoins = 1000,
		RewardEssences = 12,
		RewardShards = 0,
		Description = "Fabrica 1 bastón o pieza de armadura en el yunque.",
	},

	-- Weekly Quests
	["WQ_DUNGEONS_10"] = {
		Id = "WQ_DUNGEONS_10",
		Name = "Conquistador de Mazmorras",
		Category = "Weekly",
		ObjectiveType = "CompleteDungeon",
		TargetAmount = 10,
		RewardCoins = 25000,
		RewardEssences = 100,
		RewardShards = 5,
		Description = "Completa 10 mazmorras con éxito.",
	},
	["WQ_BOSSES_05"] = {
		Id = "WQ_BOSSES_05",
		Name = "Azote de Titanes",
		Category = "Weekly",
		ObjectiveType = "DefeatBoss",
		TargetAmount = 5,
		RewardCoins = 40000,
		RewardEssences = 150,
		RewardShards = 10,
		Description = "Derrota a 5 jefes finales de región.",
	},

	-- Achievements
	["ACH_REBIRTH_1"] = {
		Id = "ACH_REBIRTH_1",
		Name = "Primer Renacimiento",
		Category = "Achievement",
		ObjectiveType = "ReachRebirth",
		TargetAmount = 1,
		RewardCoins = 5000,
		RewardEssences = 25,
		RewardShards = 3,
		Description = "Alcanza tu primer Rebirth.",
	},
	["ACH_STAFF_10"] = {
		Id = "ACH_STAFF_10",
		Name = "Coleccionista de Bastones I",
		Category = "Achievement",
		ObjectiveType = "CollectStaff",
		TargetAmount = 10,
		RewardCoins = 10000,
		RewardEssences = 50,
		RewardShards = 5,
		Description = "Desbloquea 10 bastones distintos en tu armería.",
	},
}

function QuestConfig.GetQuest(questId: string): QuestDefinition?
	return quests[questId]
end

function QuestConfig.GetAllQuests(): { QuestDefinition }
	local list = {}
	for _, q in pairs(quests) do
		table.insert(list, q)
	end
	table.sort(list, function(a, b) return a.Id < b.Id end)
	return list
end

return table.freeze(QuestConfig)
