--!strict
--[[
    QuestService.luau
    Daily, Weekly, and Achievement quest tracking and server-authoritative reward claims.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Config"):WaitForChild("GameConfig") :: ModuleScript)
local QuestConfig = require(Shared:WaitForChild("Config"):WaitForChild("QuestConfig") :: ModuleScript)
local TypeValidators = require(Shared:WaitForChild("Modules"):WaitForChild("TypeValidators") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local Services = script.Parent
local PlayerDataService = require(Services:WaitForChild("PlayerDataService") :: ModuleScript)
local RemoteGuard = require(Services:WaitForChild("RemoteGuard") :: ModuleScript)

local QuestService = {}

-- Increments progress for all quests matching the given objectiveType
function QuestService.RecordProgress(player: Player, objectiveType: QuestConfig.QuestObjectiveType, amount: number?)
	local delta = math.max(1, math.floor(amount or 1))
	local allQuests = QuestConfig.GetAllQuests()
	local anyUpdated = false

	PlayerDataService.UpdateProfile(player, function(data)
		if not data.Quests then
			data.Quests = {}
		end
		for _, q in ipairs(allQuests) do
			if q.ObjectiveType == objectiveType then
				local rec = data.Quests[q.Id]
				if not rec then
					rec = { Progress = 0, Claimed = false }
					data.Quests[q.Id] = rec
				end
				if not rec.Claimed and rec.Progress < q.TargetAmount then
					rec.Progress = math.min(q.TargetAmount, rec.Progress + delta)
					anyUpdated = true
				end
			end
		end
	end)

	if anyUpdated then
		local ev = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.QuestProgressUpdated)
		ev:FireClient(player, { ObjectiveType = objectiveType })
	end
end

-- Claims a completed quest reward atomically
function QuestService.ClaimQuest(player: Player, questId: string): (boolean, string)
	if not TypeValidators.IsValidString(questId, 2, 60) then
		return false, "Misión inválida."
	end

	local questDef = QuestConfig.GetQuest(questId)
	if not questDef then
		return false, "Misión no encontrada."
	end

	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return false, "Perfil no cargado."
	end

	local rec = profile.Quests and profile.Quests[questId]
	if not rec or rec.Progress < questDef.TargetAmount then
		return false, "Aún no has completado el objetivo de esta misión."
	end
	if rec.Claimed then
		return false, "Ya reclamaste esta recompensa."
	end

	local ok = PlayerDataService.UpdateProfile(player, function(data)
		if not data.Quests[questId] then return end
		data.Quests[questId].Claimed = true
		data.Coins += questDef.RewardCoins
		data.Essences = (data.Essences or 0) + questDef.RewardEssences
		data.RebirthShards += questDef.RewardShards
	end)

	if ok then
		return true, string.format("¡Recompensa reclamada: +%d Oro, +%d Esencias!", questDef.RewardCoins, questDef.RewardEssences)
	end
	return false, "No se pudo reclamar la misión."
end

function QuestService.Init()
	RemoteGuard.ProtectEvent(
		NetworkEndpoints.Events.RequestClaimQuest,
		"QuestClaim",
		GameConfig.RATE_LIMITS.QuestClaim,
		function(player: Player, questId: any)
			if typeof(questId) ~= "string" then return end
			local ok, msg = QuestService.ClaimQuest(player, questId)
			local notify = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.NotificationPrompt)
			notify:FireClient(player, { Type = if ok then "Success" else "Error", Message = msg })
		end
	)

	print("[QuestService] Initialized successfully.")
end

return table.freeze(QuestService)
