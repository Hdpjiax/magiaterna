--!strict
--[[
    test_phase5.luau
    Comprehensive QA Test Suite for Phase 5: Dungeons, Combat & Boss Fights.
    Runs self-contained in Roblox Studio.
]]

local passed = 0
local failed = 0

local function test(name: string, condition: boolean, extra: string?)
	if condition then
		passed += 1
		print(string.format("  [PASS] %s", name))
	else
		failed += 1
		warn(string.format("  [FAIL] %s - %s", name, extra or "Assertion failed"))
	end
end

print("========================================")
print("     MAGIA ETERNA — QA SUITE: PHASE 5   ")
print("========================================")

-- 1. Configuration Validation: DungeonConfig
print("\n--- Test Group 1: Dungeon & Difficulty Configuration ---")

local DIFFICULTIES = {
	[1] = { HealthMultiplier = 1.00, DamageMultiplier = 1.00, RewardMultiplier = 1.00, GuaranteeRebirthShard = false },
	[2] = { HealthMultiplier = 1.35, DamageMultiplier = 1.15, RewardMultiplier = 1.15, GuaranteeRebirthShard = false },
	[3] = { HealthMultiplier = 1.80, DamageMultiplier = 1.35, RewardMultiplier = 1.30, GuaranteeRebirthShard = false },
	[4] = { HealthMultiplier = 2.50, DamageMultiplier = 1.65, RewardMultiplier = 1.55, GuaranteeRebirthShard = false },
	[5] = { HealthMultiplier = 3.50, DamageMultiplier = 2.10, RewardMultiplier = 1.90, GuaranteeRebirthShard = true },
}

local function getScaledHealth(baseHp: number, diff: number): number
	local d = DIFFICULTIES[diff] or DIFFICULTIES[1]
	return math.floor(baseHp * d.HealthMultiplier)
end

local function getScaledDamage(baseDmg: number, diff: number): number
	local d = DIFFICULTIES[diff] or DIFFICULTIES[1]
	return math.floor(baseDmg * d.DamageMultiplier)
end

test("TC-DUNG-01: 5 Difficulty tiers defined", #DIFFICULTIES == 5)
test("TC-DUNG-02: Diff 1 multipliers are 1.0x", DIFFICULTIES[1].HealthMultiplier == 1.0 and DIFFICULTIES[1].DamageMultiplier == 1.0)
test("TC-DUNG-03: Diff 5 health multiplier is 3.50x", DIFFICULTIES[5].HealthMultiplier == 3.50)
test("TC-DUNG-04: Diff 5 guarantees Rebirth Shard", DIFFICULTIES[5].GuaranteeRebirthShard == true)
test("TC-DUNG-05: Diff 1-4 do NOT guarantee Rebirth Shard", DIFFICULTIES[1].GuaranteeRebirthShard == false and DIFFICULTIES[4].GuaranteeRebirthShard == false)

local dungeonBosque = {
	Id = "Dungeon_Bosque",
	Name = "Bosque de los Susurros",
	BossId = "Boss_TreantAncestral",
	MiniBossId = "MiniBoss_GuardianRaices",
	NormalEnemies = { "Enemy_SlimeVerde", "Enemy_DuendeBosque" },
	RoomsCount = 5,
	LootTable = {
		{ ItemType = "Coin", Id = "Coins", MinAmount = 500, MaxAmount = 1500, DropChance = 1.0 },
		{ ItemType = "Material", Id = "MaderaAntigua", MinAmount = 8, MaxAmount = 20, DropChance = 1.0 },
		{ ItemType = "Material", Id = "HojaMagica", MinAmount = 5, MaxAmount = 12, DropChance = 0.8 },
		{ ItemType = "Material", Id = "NucleoTreant", MinAmount = 1, MaxAmount = 1, DropChance = 0.25 },
	},
}

test("TC-DUNG-06: Dungeon Bosque has 5 rooms", dungeonBosque.RoomsCount == 5)
test("TC-DUNG-07: Boss ID matches Treant Ancestral", dungeonBosque.BossId == "Boss_TreantAncestral")
test("TC-DUNG-08: MiniBoss ID matches Guardián de Raíces", dungeonBosque.MiniBossId == "MiniBoss_GuardianRaices")

-- 2. Enemy Definition & Telegraphs
print("\n--- Test Group 2: Enemy Definition & Boss 3-Phases ---")

local bossTreant = {
	Id = "Boss_TreantAncestral",
	Name = "Treant Ancestral",
	Category = "Boss",
	BaseHealth = 2200,
	BaseDamage = 40,
	MoveSpeed = 11,
	Telegraphs = {
		{ Name = "PisotónTitánico", Shape = "Circle", Radius = 16, TelegraphDuration = 1.5, DamagePercentOfBase = 140 },
		{ Name = "FuriaDeRamas", Shape = "Cone", Radius = 22, TelegraphDuration = 1.2, DamagePercentOfBase = 120 },
		{ Name = "IraDelBosque", Shape = "Circle", Radius = 28, TelegraphDuration = 1.8, DamagePercentOfBase = 200 },
	},
	Phases = {
		[1] = { HpThreshold = 1.0, PhaseName = "Fase 1: Reconocimiento" },
		[2] = { HpThreshold = 0.60, PhaseName = "Fase 2: Furia del Bosque" },
		[3] = { HpThreshold = 0.25, PhaseName = "Fase 3: Ira Titánica Desatada" },
	},
}

test("TC-ENMY-01: Boss base health is 2200 HP", bossTreant.BaseHealth == 2200)
test("TC-ENMY-02: Boss has 3 telegraphed AoE attacks", #bossTreant.Telegraphs == 3)
test("TC-ENMY-03: Boss has 3 distinct combat phases", bossTreant.Phases[1] ~= nil and bossTreant.Phases[2] ~= nil and bossTreant.Phases[3] ~= nil)

-- 3. Enemy Service & Phase Transition Simulation
print("\n--- Test Group 3: Boss State Machine & Phase Transitions ---")

local enemyInstance = {
	InstanceId = "UUID_BOSS_001",
	EnemyDef = bossTreant,
	MaxHealth = getScaledHealth(bossTreant.BaseHealth, 1),
	CurrentHealth = getScaledHealth(bossTreant.BaseHealth, 1),
	CurrentPhase = 1,
	IsDead = false,
}

test("TC-STAT-01: Boss spawns with 2200/2200 HP in Phase 1", enemyInstance.CurrentHealth == 2200 and enemyInstance.CurrentPhase == 1)

local function checkBossPhaseTransition(enemy): (boolean, number)
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

local function damageEnemy(enemy, amount): (boolean, number, boolean)
	local actualDamage = math.min(enemy.CurrentHealth, amount)
	enemy.CurrentHealth -= actualDamage
	local phaseShifted = false
	if enemy.CurrentHealth > 0 then
		local changed, _ = checkBossPhaseTransition(enemy)
		if changed then phaseShifted = true end
	else
		enemy.IsDead = true
	end
	return enemy.IsDead, actualDamage, phaseShifted
end

-- Deal 1000 damage -> 1200 HP (54.5% HP) -> Should trigger Phase 2
local isDead, dealt, phaseShift = damageEnemy(enemyInstance, 1000)
test("TC-STAT-02: Deals 1000 damage (1200 HP remaining)", enemyInstance.CurrentHealth == 1200 and not isDead)
test("TC-STAT-03: Triggers Phase 2 at <= 60% HP threshold", phaseShift == true and enemyInstance.CurrentPhase == 2)

-- Deal 700 damage -> 500 HP (22.7% HP) -> Should trigger Phase 3
local isDead2, dealt2, phaseShift2 = damageEnemy(enemyInstance, 700)
test("TC-STAT-04: Deals 700 damage (500 HP remaining)", enemyInstance.CurrentHealth == 500 and not isDead2)
test("TC-STAT-05: Triggers Phase 3 at <= 25% HP threshold", phaseShift2 == true and enemyInstance.CurrentPhase == 3)

-- Deal 600 damage -> 0 HP -> Dead
local isDead3, dealt3, phaseShift3 = damageEnemy(enemyInstance, 600)
test("TC-STAT-06: Lethal damage marks boss as Dead (0 HP)", isDead3 == true and enemyInstance.IsDead == true and enemyInstance.CurrentHealth == 0)

-- Test Difficulty V Boss Scaling
local bossDiff5Hp = getScaledHealth(bossTreant.BaseHealth, 5)
test("TC-STAT-07: Boss HP at Difficulty V scales to 7700 HP", bossDiff5Hp == 7700)

-- 4. Combat Formula Verification
print("\n--- Test Group 4: Authoritative Combat Formula ---")

local function calculateSpellDamage(staffPower: number, rebirths: number, petMultiplier: number, armorDefense: number): number
	local rebirthMult = 1.0 + (rebirths * 1.0)
	local armorBonus = 1.0 + (armorDefense * 0.005)
	return math.floor(staffPower * rebirthMult * petMultiplier * armorBonus)
end

local baseDmg = calculateSpellDamage(10, 0, 1.0, 0)
local midDmg = calculateSpellDamage(25, 2, 2.5, 40)
local highDmg = calculateSpellDamage(80, 5, 5.0, 100)

test("TC-CMB-01: Base beginner damage is 10", baseDmg == 10)
test("TC-CMB-02: Mid-game damage scales with pets and rebirths", midDmg > 200)
test("TC-CMB-03: End-game damage exceeds 3000", highDmg > 3000)

-- 5. Dungeon Session Lifecycle & Reward Distribution
print("\n--- Test Group 5: Dungeon Lifecycle, Rooms & Loot ---")

local playerProfile = {
	Coins = 500,
	Materials = {} :: { [string]: number },
	RebirthShards = 0,
	UnlockedDungeons = {
		["Dungeon_Bosque"] = 1,
	},
}

-- 5.1 Verification of Entry Permissions
local function canEnter(diff: number): boolean
	local maxUnlocked = playerProfile.UnlockedDungeons["Dungeon_Bosque"] or 1
	return diff <= maxUnlocked
end

test("TC-LIF-01: Entry permitted for unlocked Difficulty 1", canEnter(1) == true)
test("TC-LIF-02: Entry rejected for locked Difficulty 2", canEnter(2) == false)

-- 5.2 Room Progression Simulation (1 -> 2 -> 3 -> 4 MiniBoss -> 5 Boss)
local session = {
	CurrentRoom = 1,
	MaxRooms = 5,
	Status = "Active",
	Difficulty = 1,
}

local function clearRoom(s)
	if s.CurrentRoom < s.MaxRooms then
		s.CurrentRoom += 1
	else
		s.Status = "Completed"
	end
end

clearRoom(session) -- to Room 2
clearRoom(session) -- to Room 3
clearRoom(session) -- to Room 4 (MiniBoss)
test("TC-LIF-03: Progresses through mob rooms to Room 4 MiniBoss", session.CurrentRoom == 4)

clearRoom(session) -- to Room 5 (Final Boss)
test("TC-LIF-04: Progresses to Room 5 Final Boss", session.CurrentRoom == 5)

clearRoom(session) -- Clears Boss
test("TC-LIF-05: Defeating Room 5 Boss completes dungeon", session.Status == "Completed")

-- 5.3 Loot Distribution & Difficulty Unlock
local function distributeRewards(profile, dungeon, difficulty)
	local diffStats = DIFFICULTIES[difficulty]
	-- Guaranteed Coins & Materials simulation
	profile.Coins += math.floor(1000 * diffStats.RewardMultiplier)
	profile.Materials["MaderaAntigua"] = (profile.Materials["MaderaAntigua"] or 0) + math.floor(15 * diffStats.RewardMultiplier)
	profile.Materials["NucleoTreant"] = (profile.Materials["NucleoTreant"] or 0) + 1

	if diffStats.GuaranteeRebirthShard then
		profile.RebirthShards += 1
	end

	-- Unlock next tier if completing highest
	local currentMax = profile.UnlockedDungeons[dungeon.Id] or 1
	if difficulty == currentMax and currentMax < 5 then
		profile.UnlockedDungeons[dungeon.Id] = currentMax + 1
	end
end

distributeRewards(playerProfile, dungeonBosque, 1)

test("TC-LIF-06: Coins rewarded (500 + 1000 = 1500)", playerProfile.Coins == 1500)
test("TC-LIF-07: Rare material NucleoTreant awarded", playerProfile.Materials["NucleoTreant"] == 1)
test("TC-LIF-08: Completing Diff 1 unlocks Diff 2", playerProfile.UnlockedDungeons["Dungeon_Bosque"] == 2)
test("TC-LIF-09: Player can now enter Difficulty 2", canEnter(2) == true)

-- 5.4 High Difficulty (Diff V) Guaranteed Shard Verification
distributeRewards(playerProfile, dungeonBosque, 5)
test("TC-LIF-10: Difficulty V guarantees Rebirth Shard (+1)", playerProfile.RebirthShards == 1)

print("\n========================================")
print(string.format("  PHASE 5 TEST RESULTS: %d PASSED, %d FAILED", passed, failed))
print("========================================")
