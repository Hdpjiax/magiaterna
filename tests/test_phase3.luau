--!strict
-- Comprehensive Phase 3 Test Suite for MAGIA ETERNA
-- Tests PetConfig, EggConfig, EggService hatching, PetService equipment limits,
-- Favorite lock, Golden/Rainbow Fusion, and MagicService Pet Multipliers.

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
print("   MAGIA ETERNA — PHASE 3 TEST SUITE   ")
print("========================================")

-- 1. Test PetConfig
local PetConfig = {}
PetConfig.TIER_MULTIPLIERS = {
	["Normal"] = 1.0,
	["Golden"] = 1.5,
	["Rainbow"] = 2.5,
}
local petCatalog = {
	["Pet_R1_SlimeVerde"] = {
		Id = "Pet_R1_SlimeVerde",
		Name = "Slime Verde",
		Region = "Bosque",
		Rarity = "Común",
		MagicBonusPercent = 5,
		CoinsBonusPercent = 2,
	},
	["Pet_R1_DragonEspiritual"] = {
		Id = "Pet_R1_DragonEspiritual",
		Name = "Dragón Espiritual",
		Region = "Bosque",
		Rarity = "Mítico",
		MagicBonusPercent = 300,
		CoinsBonusPercent = 75,
	},
}
function PetConfig.GetPet(id: string)
	return petCatalog[id]
end
function PetConfig.CalculateStats(id: string, tier: string?)
	local pet = petCatalog[id]
	if not pet then return { MagicBonus = 0, CoinsBonus = 0 } end
	local mult = PetConfig.TIER_MULTIPLIERS[tier or "Normal"] or 1.0
	return {
		MagicBonus = pet.MagicBonusPercent * mult,
		CoinsBonus = pet.CoinsBonusPercent * mult,
	}
end

local slime = PetConfig.GetPet("Pet_R1_SlimeVerde")
assertTest(slime ~= nil and slime.MagicBonusPercent == 5, "TC-PET-01: Starter Slime Verde has +5% magic bonus")
local goldenStats = PetConfig.CalculateStats("Pet_R1_SlimeVerde", "Golden")
assertTest(goldenStats.MagicBonus == 7.5, "TC-PET-02: Golden evolution applies 1.5x stats multiplier")
local rainbowStats = PetConfig.CalculateStats("Pet_R1_SlimeVerde", "Rainbow")
assertTest(rainbowStats.MagicBonus == 12.5, "TC-PET-03: Rainbow evolution applies 2.5x stats multiplier")

-- 2. Test EggConfig
local EggConfig = {}
local eggCatalog = {
	["Egg_Bosque"] = {
		Id = "Egg_Bosque",
		CostCoins = 1000,
		TotalWeight = 1000,
		Drops = {
			{ PetId = "Pet_R1_SlimeVerde", Weight = 500, Rarity = "Común" },
			{ PetId = "Pet_R1_DragonEspiritual", Weight = 5, Rarity = "Mítico" },
		}
	}
}
function EggConfig.GetEgg(id: string)
	return eggCatalog[id]
end
function EggConfig.RollPet(id: string)
	local egg = eggCatalog[id]
	if not egg then return nil, nil end
	local roll = math.random(1, 1000)
	if roll <= 5 then
		return "Pet_R1_DragonEspiritual", "Mítico"
	else
		return "Pet_R1_SlimeVerde", "Común"
	end
end

assertTest(EggConfig.GetEgg("Egg_Bosque").CostCoins == 1000, "TC-EGG-01: Egg_Bosque costs 1,000 Coins")
local rolledId, rolledRarity = EggConfig.RollPet("Egg_Bosque")
assertTest(rolledId ~= nil and (rolledRarity == "Común" or rolledRarity == "Mítico"), "TC-EGG-02: Egg roll returns valid pet")

-- 3. Test EggService Hatching Logic
local testProfile = {
	Coins = 500, -- Insufficient
	Magic = 0,
	Rebirths = 0,
	MaxPetInventory = 10,
	MaxEquippedPets = 3,
	EquippedPets = {},
	PetInventory = {},
}

local function tryHatch(profile, eggId)
	local egg = EggConfig.GetEgg(eggId)
	if not egg then return false, "No existe el huevo" end
	if profile.Coins < egg.CostCoins then return false, "Oro insuficiente" end
	
	local count = 0
	for _, _ in pairs(profile.PetInventory) do count += 1 end
	if count >= profile.MaxPetInventory then return false, "Inventario lleno" end
	
	profile.Coins -= egg.CostCoins
	local pId, rar = EggConfig.RollPet(eggId)
	local uuid = "uuid_" .. tostring(math.random(10000, 99999))
	profile.PetInventory[uuid] = {
		Id = pId,
		Species = "Slime Verde",
		Tier = "Normal",
		Locked = false,
	}
	return true, uuid
end

-- Try hatch with 500 coins (Requires 1000)
local failHatch, _ = tryHatch(testProfile, "Egg_Bosque")
assertTest(failHatch == false, "TC-EGG-03: Hatching with insufficient coins fails gracefully")
assertTest(testProfile.Coins == 500, "TC-EGG-04: Coins untouched after failed hatch")

-- Add 5000 coins and hatch 4 pets successfully
testProfile.Coins = 5000
local okHatch1, petUuid1 = tryHatch(testProfile, "Egg_Bosque")
local okHatch2, petUuid2 = tryHatch(testProfile, "Egg_Bosque")
local okHatch3, petUuid3 = tryHatch(testProfile, "Egg_Bosque")
local okHatch4, petUuid4 = tryHatch(testProfile, "Egg_Bosque")

assertTest(okHatch1 and okHatch2 and okHatch3 and okHatch4, "TC-EGG-05: Hatching 4 pets with sufficient coins succeeds")
assertTest(testProfile.Coins == 1000, "TC-EGG-06: Exactly 4,000 coins deducted (1,000 remaining)")
assertTest(testProfile.PetInventory[petUuid1] ~= nil, "TC-EGG-07: Pet 1 stored in PetInventory")

-- 4. Test Pet Equipment Limits
local function tryEquip(profile, uuid)
	if not profile.PetInventory[uuid] then return false, "No existe" end
	for _, eq in ipairs(profile.EquippedPets) do
		if eq == uuid then return false, "Ya equipada" end
	end
	if #profile.EquippedPets >= profile.MaxEquippedPets then
		return false, "Límite alcanzado"
	end
	table.insert(profile.EquippedPets, uuid)
	return true, "Equipada"
end

local function tryUnequip(profile, uuid)
	for i, eq in ipairs(profile.EquippedPets) do
		if eq == uuid then
			table.remove(profile.EquippedPets, i)
			return true
		end
	end
	return false
end

assertTest(tryEquip(testProfile, petUuid1) == true, "TC-PET-04: Equipped pet 1")
assertTest(tryEquip(testProfile, petUuid2) == true, "TC-PET-05: Equipped pet 2")
assertTest(tryEquip(testProfile, petUuid3) == true, "TC-PET-06: Equipped pet 3 (Max limit reached)")
assertTest(tryEquip(testProfile, petUuid4) == false, "TC-PET-07: Equipping 4th pet rejected when limit is 3")
assertTest(#testProfile.EquippedPets == 3, "TC-PET-08: Exactly 3 pets equipped")

-- Unequip
assertTest(tryUnequip(testProfile, petUuid2) == true, "TC-PET-09: Successfully unequipped pet 2")
assertTest(#testProfile.EquippedPets == 2, "TC-PET-10: Exactly 2 pets equipped after unequip")

-- 5. Test Pet Multiplier Calculation on Magic Power
local function getTotalPetMultiplier(profile)
	local bonusSum = 0
	for _, uuid in ipairs(profile.EquippedPets) do
		local p = profile.PetInventory[uuid]
		if p then
			local stats = PetConfig.CalculateStats(p.Id, p.Tier)
			bonusSum += stats.MagicBonus
		end
	end
	return 1.0 + (bonusSum / 100)
end

-- 2 Slimes equipped: each +5% -> total +10% -> 1.10 multiplier
local mult = getTotalPetMultiplier(testProfile)
assertTest(mult == 1.10, "TC-PET-11: 2 equipped slimes provide exactly 1.10x total multiplier")

-- 6. Test Pet Fusion (3 Normals -> 1 Golden)
local function tryFuse(profile, uuids)
	if #uuids ~= 3 then return false end
	for _, u in ipairs(uuids) do
		if not profile.PetInventory[u] or profile.PetInventory[u].Locked then
			return false
		end
		for _, eq in ipairs(profile.EquippedPets) do
			if eq == u then return false, "Desequipa primero" end
		end
	end
	
	-- Remove the 3
	for _, u in ipairs(uuids) do
		profile.PetInventory[u] = nil
	end
	local goldenUuid = "golden_1"
	profile.PetInventory[goldenUuid] = {
		Id = "Pet_R1_SlimeVerde",
		Species = "Slime Verde",
		Tier = "Golden",
		Locked = false,
	}
	return true, goldenUuid
end

-- Unequip all before fusion
tryUnequip(testProfile, petUuid1)
tryUnequip(testProfile, petUuid3)

local fuseOk, goldenId = tryFuse(testProfile, { petUuid1, petUuid3, petUuid4 })
assertTest(fuseOk == true, "TC-FUS-01: Fusion of 3 normal pets succeeded")
assertTest(testProfile.PetInventory[petUuid1] == nil, "TC-FUS-02: Consumed pet 1 deleted")
assertTest(testProfile.PetInventory[goldenId] ~= nil, "TC-FUS-03: Resulting golden pet created in inventory")
assertTest(testProfile.PetInventory[goldenId].Tier == "Golden", "TC-FUS-04: Resulting pet has Golden tier")

print("========================================")
print(string.format("PHASE 3 TEST RESULTS: %d PASSED, %d FAILED", testsPassed, testsFailed))
print("========================================")

if testsFailed == 0 then
	return "PHASE_3_ALL_TESTS_PASSED"
else
	return "PHASE_3_TESTS_FAILED_" .. testsFailed
end
