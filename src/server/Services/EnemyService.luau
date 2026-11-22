--!strict
--[[
    EnemyService.luau
    Manages enemy spawning, state machines, Boss 3-phase transitions, and damage handling for MAGIA ETERNA.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local EnemyConfig = require(ReplicatedStorage.Source.shared.Config.EnemyConfig)
local DungeonConfig = require(ReplicatedStorage.Source.shared.Config.DungeonConfig)
local QuestService = require(script.Parent.QuestService)

export type EnemyInstance = {
	InstanceId: string,
	DungeonSessionId: string,
	EnemyDef: EnemyConfig.EnemyDefinition,
	MaxHealth: number,
	CurrentHealth: number,
	Position: Vector3,
	CurrentPhase: number?,
	IsDead: boolean,
}

local EnemyService = {}
local activeEnemies: { [string]: EnemyInstance } = {}
local sessionEnemyMap: { [string]: { [string]: boolean } } = {}

-- Spawns an enemy into a dungeon session
function EnemyService.SpawnEnemy(sessionId: string, enemyId: string, difficulty: number, spawnPos: Vector3): EnemyInstance?
	local enemyDef = EnemyConfig.GetEnemy(enemyId)
	if not enemyDef then
		warn("[EnemyService] Unknown enemy ID: " .. tostring(enemyId))
		return nil
	end

	local validDiff = (difficulty >= 1 and difficulty <= 5) and difficulty or 1
	local maxHealth = DungeonConfig.GetScaledHealth(enemyDef.BaseHealth, validDiff :: any)
	local instanceId = HttpService:GenerateGUID(false)

	local instance: EnemyInstance = {
		InstanceId = instanceId,
		DungeonSessionId = sessionId,
		EnemyDef = enemyDef,
		MaxHealth = maxHealth,
		CurrentHealth = maxHealth,
		Position = spawnPos,
		CurrentPhase = (enemyDef.Category == "Boss") and 1 or nil,
		IsDead = false,
	}

	activeEnemies[instanceId] = instance

	if not sessionEnemyMap[sessionId] then
		sessionEnemyMap[sessionId] = {}
	end
	sessionEnemyMap[sessionId][instanceId] = true

	return instance
end

-- Retrieves an enemy instance by its GUID
function EnemyService.GetEnemy(instanceId: string): EnemyInstance?
	return activeEnemies[instanceId]
end

-- Retrieves all enemies associated with a dungeon session
function EnemyService.GetEnemiesInSession(sessionId: string): { EnemyInstance }
	local list = {}
	local sessionSet = sessionEnemyMap[sessionId]
	if sessionSet then
		for id in pairs(sessionSet) do
			local enemy = activeEnemies[id]
			if enemy and not enemy.IsDead then
				table.insert(list, enemy)
			end
		end
	end
	return list
end

-- Checks and handles Boss 3-phase transitions based on HP percentages
function EnemyService.CheckBossPhaseTransition(enemy: EnemyInstance): (boolean, number)
	if enemy.EnemyDef.Category ~= "Boss" or not enemy.CurrentPhase then
		return false, 0
	end

	local hpPercent = enemy.CurrentHealth / enemy.MaxHealth
	local previousPhase = enemy.CurrentPhase
	local targetPhase = 1

	if hpPercent <= 0.25 then
		targetPhase = 3
	elseif hpPercent <= 0.60 then
		targetPhase = 2
	else
		targetPhase = 1
	end

	if targetPhase > previousPhase then
		enemy.CurrentPhase = targetPhase
		return true, targetPhase
	end

	return false, previousPhase
end

-- Applies damage to an enemy and checks for phase shift or death
function EnemyService.DamageEnemy(instanceId: string, damageAmount: number, attacker: Player?): (boolean, number, boolean)
	local enemy = activeEnemies[instanceId]
	if not enemy or enemy.IsDead then
		return false, 0, false
	end

	local actualDamage = math.min(enemy.CurrentHealth, math.max(1, damageAmount))
	enemy.CurrentHealth -= actualDamage

	local phaseShifted = false
	if enemy.EnemyDef.Category == "Boss" and enemy.CurrentHealth > 0 then
		local changed, newPhase = EnemyService.CheckBossPhaseTransition(enemy)
		if changed then
			phaseShifted = true
		end
	end

	local isDead = false
	if enemy.CurrentHealth <= 0 then
		enemy.CurrentHealth = 0
		enemy.IsDead = true
		isDead = true

		if attacker then
			if enemy.EnemyDef.Category == "Boss" then
				QuestService.RecordProgress(attacker, "DefeatBoss", 1)
			end
			QuestService.RecordProgress(attacker, "DefeatEnemy", 1)
		end
	end

	return isDead, actualDamage, phaseShifted
end

-- Cleans up all enemies belonging to a session
function EnemyService.ClearSession(sessionId: string)
	local sessionSet = sessionEnemyMap[sessionId]
	if sessionSet then
		for id in pairs(sessionSet) do
			activeEnemies[id] = nil
		end
		sessionEnemyMap[sessionId] = nil
	end
end

function EnemyService.Init()
	print("[EnemyService] Initialized successfully.")
end

return EnemyService
