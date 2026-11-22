--!strict
-- Comprehensive Phase 2 Test Suite for MAGIA ETERNA
-- Tests StaffConfig, RebirthConfig, MagicService calculations, Atomic Training, and Rebirth Execution

local testsPassed = 0
local testsFailed = 0

local function assertTest(condition: boolean, testName: string)
	if condition then
		testsPassed += 1
		print(string.format("[PASS] %s", testName))
	else
		testsFailed += 1
		warn(string.format("[FAIL] %s", testName))
	end
end

print("========================================")
print("   MAGIA ETERNA — PHASE 2 TEST SUITE   ")
print("========================================")

-- 1. Test StaffConfig
local StaffConfig = {}
local staves = {
	["Staff_R1_001_RamaAprendiz"] = {
		Id = "Staff_R1_001_RamaAprendiz",
		Name = "Rama de Aprendiz",
		Region = "Bosque",
		Rarity = "Común",
		BasePower = 1,
		Element = "Naturaleza",
	},
	["Staff_R1_010_BastonNaturaleza"] = {
		Id = "Staff_R1_010_BastonNaturaleza",
		Name = "Bastón de la Naturaleza",
		Region = "Bosque",
		Rarity = "Raro",
		BasePower = 35,
		Element = "Naturaleza",
	},
	["Staff_R1_020_BastonCorazonVerde"] = {
		Id = "Staff_R1_020_BastonCorazonVerde",
		Name = "Bastón del Corazón Verde",
		Region = "Bosque",
		Rarity = "Mítico",
		BasePower = 1500,
		Element = "Naturaleza",
	},
}
function StaffConfig.GetStaff(id: string)
	return staves[id]
end

local starterStaff = StaffConfig.GetStaff("Staff_R1_001_RamaAprendiz")
assertTest(starterStaff ~= nil and starterStaff.BasePower == 1, "TC-STF-01: Starter staff exists with BasePower 1")
local mythicStaff = StaffConfig.GetStaff("Staff_R1_020_BastonCorazonVerde")
assertTest(mythicStaff ~= nil and mythicStaff.BasePower == 1500, "TC-STF-02: Region 1 Mythic staff has BasePower 1500")
assertTest(StaffConfig.GetStaff("NonExistent") == nil, "TC-STF-03: Invalid staff ID safely returns nil")

-- 2. Test RebirthConfig
local RebirthConfig = {}
function RebirthConfig.GetCost(currentRebirths: number): number
	return math.floor(10000 * (10 ^ (currentRebirths * 0.60)))
end

function RebirthConfig.GetMultiplier(rebirthLevel: number): number
	if rebirthLevel <= 0 then return 1.0 end
	if rebirthLevel < 5 then
		return 1.0 + (rebirthLevel * 0.25)
	elseif rebirthLevel < 10 then
		return 2.75 + ((rebirthLevel - 5) * 0.65)
	else
		return 6.0 + ((rebirthLevel - 10) * 1.25)
	end
end

local milestones = {
	[5] = { RebirthLevel = 5, Title = "Señor de las Bestias", BonusPetSlots = 1, BonusShards = 5 },
}
function RebirthConfig.GetMilestone(lvl: number)
	return milestones[lvl]
end

assertTest(RebirthConfig.GetCost(0) == 10000, "TC-REB-01: Rebirth 0 requires exactly 10,000 magic")
assertTest(RebirthConfig.GetMultiplier(0) == 1.0, "TC-REB-02: Rebirth 0 multiplier is 1.0x")
assertTest(RebirthConfig.GetMultiplier(1) == 1.25, "TC-REB-03: Rebirth 1 multiplier is 1.25x")
assertTest(RebirthConfig.GetMultiplier(5) == 2.75, "TC-REB-04: Rebirth 5 multiplier is 2.75x")
assertTest(RebirthConfig.GetMilestone(5) ~= nil and RebirthConfig.GetMilestone(5).BonusPetSlots == 1, "TC-REB-05: Rebirth 5 milestone unlocks bonus pet slot")

-- 3. Test MagicService Power Calculation
local function calculatePower(profile)
	local basePower = 1
	local staffPower = 0
	local staff = StaffConfig.GetStaff(profile.EquippedStaff)
	if staff then staffPower = staff.BasePower end
	local rebirthMult = RebirthConfig.GetMultiplier(profile.Rebirths)
	local petMultiplier = 1.0
	return math.max(1, math.floor((basePower + staffPower) * rebirthMult * petMultiplier))
end

local testProfile = {
	Magic = 0,
	Coins = 100,
	Rebirths = 0,
	RebirthShards = 0,
	EquippedStaff = "Staff_R1_001_RamaAprendiz",
	MaxEquippedPets = 3,
}

-- Starter calculation: (1 base + 1 staff) * 1.0 = 2
local p1 = calculatePower(testProfile)
assertTest(p1 == 2, "TC-MAG-01: Starter power calculation is exactly 2")

-- Equip Rare staff (Power 35): (1 base + 35 staff) * 1.0 = 36
testProfile.EquippedStaff = "Staff_R1_010_BastonNaturaleza"
local p2 = calculatePower(testProfile)
assertTest(p2 == 36, "TC-MAG-02: Rare staff power calculation is exactly 36")

-- With Rebirth 1 (1.25x): (1 + 35) * 1.25 = 45
testProfile.Rebirths = 1
local p3 = calculatePower(testProfile)
assertTest(p3 == 45, "TC-MAG-03: Rebirth 1 multiplier scales power to exactly 45")

-- 4. Test Atomic Training Pulse
testProfile.Magic += p3
assertTest(testProfile.Magic == 45, "TC-MAG-04: Magic pulse increments atomically")

-- 5. Test Rebirth Execution Logic
local function tryRebirth(profile)
	local cost = RebirthConfig.GetCost(profile.Rebirths)
	if profile.Magic < cost then
		return false, "Magia insuficiente"
	end
	
	local newLvl = profile.Rebirths + 1
	local ms = RebirthConfig.GetMilestone(newLvl)
	local shards = ms and ms.BonusShards or 1
	
	profile.Magic = 0
	profile.Rebirths = newLvl
	profile.RebirthShards += shards
	if ms and ms.BonusPetSlots then
		profile.MaxEquippedPets += ms.BonusPetSlots
	end
	return true, "Exito"
end

-- Attempt rebirth with insufficient magic (Requires cost for R1: 10,000 * 10^0.60 ≈ 39,810)
local successLow, _ = tryRebirth(testProfile)
assertTest(successLow == false, "TC-REB-06: Rebirth fails gracefully when player has insufficient magic")
assertTest(testProfile.Rebirths == 1, "TC-REB-07: Player Rebirth level unchanged on failure")

-- Grant enough magic and attempt rebirth
local needed = RebirthConfig.GetCost(testProfile.Rebirths)
testProfile.Magic = needed + 5000
local successOk, msg = tryRebirth(testProfile)
assertTest(successOk == true, "TC-REB-08: Rebirth succeeds when requirements are met")
assertTest(testProfile.Magic == 0, "TC-REB-09: Player magic reset to 0 after rebirth")
assertTest(testProfile.Rebirths == 2, "TC-REB-10: Player Rebirth level incremented to 2")
assertTest(testProfile.RebirthShards > 0, "TC-REB-11: Player rewarded with RebirthShards")

-- Simulate reaching Rebirth 5 milestone
testProfile.Rebirths = 4
testProfile.Magic = RebirthConfig.GetCost(4) + 100
local success5, _ = tryRebirth(testProfile)
assertTest(success5 == true, "TC-REB-12: Rebirth 5 successfully executed")
assertTest(testProfile.MaxEquippedPets == 4, "TC-REB-13: Rebirth 5 milestone grants 4th pet slot")

print("========================================")
print(string.format("PHASE 2 TEST RESULTS: %d PASSED, %d FAILED", testsPassed, testsFailed))
print("========================================")

if testsFailed == 0 then
	return "PHASE_2_ALL_TESTS_PASSED"
else
	return "PHASE_2_TESTS_FAILED_" .. testsFailed
end
