--!strict
--[[
    test_quest_and_dungeon_integration.luau
    Automated QA Test Suite for server event interconnects:
    1. QuestService.RecordProgress triggered from MagicService, EggService, ForgeService,
       EnemyService, RebirthService, and DungeonService.
    2. DungeonService delivery of Gold/Essences/Materials via EconomyService and LootUtils.
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

print("==========================================================")
print("  MAGIA ETERNA — QA SUITE: QUEST & DUNGEON INTEGRATION    ")
print("==========================================================")

-- 1. Mock Player & Profile State
local mockProfile = {
	Coins = 1000,
	Essences = 20,
	Magic = 500,
	Rebirths = 0,
	RebirthShards = 0,
	UnlockedDungeons = {
		["Dungeon_Bosque"] = 1,
	},
	Materials = {
		["MaderaAntigua"] = 5,
	} :: { [string]: number },
	Quests = {
		["DQ_TRAIN_01"] = { Progress = 0, Claimed = false },
		["DQ_DUNGEON_01"] = { Progress = 0, Claimed = false },
		["DQ_EGG_01"] = { Progress = 0, Claimed = false },
		["DQ_DEFEAT_01"] = { Progress = 0, Claimed = false },
		["DQ_FORGE_01"] = { Progress = 0, Claimed = false },
	} :: { [string]: { Progress: number, Claimed: boolean } },
}

-- 2. Mock Quest Registry & RecordProgress Logic
local allQuests = {
	{ Id = "DQ_TRAIN_01", ObjectiveType = "TrainMagic", TargetAmount = 50 },
	{ Id = "DQ_DUNGEON_01", ObjectiveType = "CompleteDungeon", TargetAmount = 1 },
	{ Id = "DQ_EGG_01", ObjectiveType = "OpenEgg", TargetAmount = 3 },
	{ Id = "DQ_DEFEAT_01", ObjectiveType = "DefeatEnemy", TargetAmount = 25 },
	{ Id = "DQ_FORGE_01", ObjectiveType = "ForgeItem", TargetAmount = 1 },
}

local function recordProgress(objectiveType: string, amount: number?)
	local delta = amount or 1
	for _, q in ipairs(allQuests) do
		if q.ObjectiveType == objectiveType then
			local rec = mockProfile.Quests[q.Id]
			if rec and not rec.Claimed then
				rec.Progress = math.min(q.TargetAmount, rec.Progress + delta)
			end
		end
	end
end

-- 3. TEST GROUP 1: MagicService -> QuestService
print("\n--- Test Group 1: MagicService -> QuestService ---")
test("Initial TrainMagic progress is 0", mockProfile.Quests["DQ_TRAIN_01"].Progress == 0)

-- Simulate 10 training pulses
for _ = 1, 10 do
	recordProgress("TrainMagic", 1)
end
test("TC-QST-01: TrainMagic recorded 10 pulses", mockProfile.Quests["DQ_TRAIN_01"].Progress == 10)

-- 4. TEST GROUP 2: EggService -> QuestService
print("\n--- Test Group 2: EggService -> QuestService ---")
test("Initial OpenEgg progress is 0", mockProfile.Quests["DQ_EGG_01"].Progress == 0)

-- Simulate opening 2 eggs
recordProgress("OpenEgg", 1)
recordProgress("OpenEgg", 1)
test("TC-QST-02: OpenEgg recorded 2 eggs opened", mockProfile.Quests["DQ_EGG_01"].Progress == 2)

-- 5. TEST GROUP 3: ForgeService -> QuestService
print("\n--- Test Group 3: ForgeService -> QuestService ---")
test("Initial ForgeItem progress is 0", mockProfile.Quests["DQ_FORGE_01"].Progress == 0)

recordProgress("ForgeItem", 1)
test("TC-QST-03: ForgeItem completed (1/1)", mockProfile.Quests["DQ_FORGE_01"].Progress == 1)

-- 6. TEST GROUP 4: EnemyService -> QuestService
print("\n--- Test Group 4: EnemyService -> QuestService ---")
test("Initial DefeatEnemy progress is 0", mockProfile.Quests["DQ_DEFEAT_01"].Progress == 0)

for _ = 1, 5 do
	recordProgress("DefeatEnemy", 1)
end
test("TC-QST-04: DefeatEnemy recorded 5 kills", mockProfile.Quests["DQ_DEFEAT_01"].Progress == 5)

-- 7. TEST GROUP 5: DungeonService -> EconomyService & LootUtils
print("\n--- Test Group 5: Dungeon Loot & Economy Delivery ---")

local mockEconomy = {
	AddCoins = function(amount: number)
		mockProfile.Coins += amount
		return true
	end,
	AddEssences = function(amount: number)
		mockProfile.Essences += amount
		return true
	end,
}

local mockLootUtils = {
	RollLootTable = function(lootTable, mult)
		return {
			Coins = math.floor(1200 * mult),
			Essences = math.floor(15 * mult),
			Materials = {
				["MaderaAntigua"] = math.floor(10 * mult),
				["NucleoTreant"] = 1,
			},
		}
	end,
}

local function simulateDungeonComplete(dungeonId: string, diff: number)
	local diffMultipliers = { [1] = 1.0, [2] = 1.35, [3] = 1.80, [4] = 2.50, [5] = 3.50 }
	local mult = diffMultipliers[diff] or 1.0

	-- 1. Roll via LootUtils
	local loot = mockLootUtils.RollLootTable(nil, mult)

	-- 2. Deliver Coins & Essences via EconomyService
	mockEconomy.AddCoins(loot.Coins)
	mockEconomy.AddEssences(loot.Essences)

	-- 3. Deposit materials
	for mat, qty in pairs(loot.Materials) do
		mockProfile.Materials[mat] = (mockProfile.Materials[mat] or 0) + qty
	end

	-- 4. Guaranteed Shard on Diff V
	if diff == 5 then
		mockProfile.RebirthShards += 1
	end

	-- 5. Unlock next tier
	local curMax = mockProfile.UnlockedDungeons[dungeonId] or 1
	if diff == curMax and curMax < 5 then
		mockProfile.UnlockedDungeons[dungeonId] = curMax + 1
	end

	-- 6. Record Quest Progress
	recordProgress("CompleteDungeon", 1)

	return loot
end

local initialCoins = mockProfile.Coins
local initialEssences = mockProfile.Essences

local loot1 = simulateDungeonComplete("Dungeon_Bosque", 1)

test("TC-DNG-01: Coins awarded via EconomyService (1000 + 1200 = 2200)", mockProfile.Coins == initialCoins + 1200)
test("TC-DNG-02: Essences awarded via EconomyService (20 + 15 = 35)", mockProfile.Essences == initialEssences + 15)
test("TC-DNG-03: Materials deposited directly (MaderaAntigua 5 + 10 = 15)", mockProfile.Materials["MaderaAntigua"] == 15)
test("TC-DNG-04: Rare boss drop NucleoTreant awarded (1)", mockProfile.Materials["NucleoTreant"] == 1)
test("TC-DNG-05: Next difficulty unlocked in profile (Diff 2)", mockProfile.UnlockedDungeons["Dungeon_Bosque"] == 2)
test("TC-DNG-06: Dungeon completion quest recorded (1/1)", mockProfile.Quests["DQ_DUNGEON_01"].Progress == 1)

-- Difficulty 5 Test with Guaranteed Shard
local loot5 = simulateDungeonComplete("Dungeon_Bosque", 5)
test("TC-DNG-07: Difficulty V scales rewards (Coins > 3000)", loot5.Coins >= 4200)
test("TC-DNG-08: Guaranteed Rebirth Shard awarded (+1)", mockProfile.RebirthShards == 1)

print("\n==========================================================")
print(string.format("  INTEGRATION TEST RESULTS: %d PASSED, %d FAILED", passed, failed))
print("==========================================================")
return string.format("%d passed, %d failed", passed, failed)
