--!strict
--[[
    EnemyConfig.luau
    Enemy attributes, Bosses with 3-phase behavior, and telegraphed attack parameters for MAGIA ETERNA.
]]

export type BossPhase = 1 | 2 | 3

export type AttackTelegraph = {
	Name: string,
	Shape: "Circle" | "Cone" | "Line",
	Radius: number,
	TelegraphDuration: number, -- Time player has to dodge before damage triggers
	DamagePercentOfBase: number,
}

export type EnemyDefinition = {
	Id: string,
	Name: string,
	Category: "Normal" | "MiniBoss" | "Boss",
	BaseHealth: number,
	BaseDamage: number,
	MoveSpeed: number,
	AttackRange: number,
	AttackCooldown: number,
	Telegraphs: { AttackTelegraph }?,
	Phases: {
		[BossPhase]: {
			HpThreshold: number, -- % HP required to enter phase (e.g. 1.0, 0.60, 0.25)
			PhaseName: string,
			SpeedBonus: number,
			DamageBonus: number,
		}
	}?,
}

local EnemyConfig = {}

local enemies: { [string]: EnemyDefinition } = {
	-- Normal Enemies
	["Enemy_SlimeVerde"] = {
		Id = "Enemy_SlimeVerde",
		Name = "Slime Verde",
		Category = "Normal",
		BaseHealth = 60,
		BaseDamage = 6,
		MoveSpeed = 10,
		AttackRange = 5,
		AttackCooldown = 1.8,
	},
	["Enemy_DuendeBosque"] = {
		Id = "Enemy_DuendeBosque",
		Name = "Duende del Bosque",
		Category = "Normal",
		BaseHealth = 95,
		BaseDamage = 12,
		MoveSpeed = 13,
		AttackRange = 6,
		AttackCooldown = 1.5,
	},
	
	-- Mini-Boss
	["MiniBoss_GuardianRaices"] = {
		Id = "MiniBoss_GuardianRaices",
		Name = "Guardián de Raíces",
		Category = "MiniBoss",
		BaseHealth = 450,
		BaseDamage = 22,
		MoveSpeed = 12,
		AttackRange = 8,
		AttackCooldown = 2.2,
		Telegraphs = {
			{ Name = "GolpeDeRaices", Shape = "Circle", Radius = 12, TelegraphDuration = 1.3, DamagePercentOfBase = 150 },
		},
	},
	
	-- Final Boss: Treant Ancestral (3 Phases)
	["Boss_TreantAncestral"] = {
		Id = "Boss_TreantAncestral",
		Name = "Treant Ancestral",
		Category = "Boss",
		BaseHealth = 2200,
		BaseDamage = 40,
		MoveSpeed = 11,
		AttackRange = 10,
		AttackCooldown = 2.5,
		Telegraphs = {
			{ Name = "PisotónTitánico", Shape = "Circle", Radius = 16, TelegraphDuration = 1.5, DamagePercentOfBase = 140 },
			{ Name = "FuriaDeRamas", Shape = "Cone", Radius = 22, TelegraphDuration = 1.2, DamagePercentOfBase = 120 },
			{ Name = "IraDelBosque", Shape = "Circle", Radius = 28, TelegraphDuration = 1.8, DamagePercentOfBase = 200 },
		},
		Phases = {
			[1] = {
				HpThreshold = 1.0, -- 100% to 60%
				PhaseName = "Fase 1: Reconocimiento",
				SpeedBonus = 0,
				DamageBonus = 0,
			},
			[2] = {
				HpThreshold = 0.60, -- 60% to 25%
				PhaseName = "Fase 2: Furia Ancestral",
				SpeedBonus = 3,
				DamageBonus = 15,
			},
			[3] = {
				HpThreshold = 0.25, -- 25% to 0%
				PhaseName = "Fase 3: Ira Desatada",
				SpeedBonus = 6,
				DamageBonus = 35,
			},
		},
	},
}

-- Retrieves enemy definition by ID
function EnemyConfig.GetEnemy(enemyId: string): EnemyDefinition?
	return enemies[enemyId]
end

-- Determines current boss phase based on current health and max health
function EnemyConfig.GetBossPhase(currentHp: number, maxHp: number): BossPhase
	local ratio = currentHp / math.max(1, maxHp)
	if ratio <= 0.25 then
		return 3 -- Ultimate
	elseif ratio <= 0.60 then
		return 2 -- Fury
	else
		return 1 -- Normal
	end
end

return table.freeze(EnemyConfig)
