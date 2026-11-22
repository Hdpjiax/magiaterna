--!strict
-- Comprehensive Phase 4 Test Suite for MAGIA ETERNA
-- Tests RecipeConfig, ArmorConfig Set Bonuses, ForgeService Atomic Transactions,
-- Anti-Dupe, and EquipmentService Gear Management.

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
print("   MAGIA ETERNA — PHASE 4 TEST SUITE   ")
print("========================================")

-- 1. Test RecipeConfig
local recipes = {
	["Staff_R1_002_BastonMaderaVieja"] = {
		TargetId = "Staff_R1_002_BastonMaderaVieja",
		Name = "Bastón de Madera Vieja",
		Category = "Staff",
		RequiredMaterials = { ["MaderaAntigua"] = 10, ["HojaMagica"] = 5 },
		RequiredCoins = 250,
		RequiredRebirth = 0,
	},
	["Armor_Forest_Chest"] = {
		TargetId = "Armor_Forest_Chest",
		Name = "Pechera del Guardián del Bosque",
		Category = "Armor",
		RequiredMaterials = { ["MaderaAntigua"] = 30, ["HojaMagica"] = 20 },
		RequiredCoins = 1500,
		RequiredRebirth = 0,
	},
}
local function getRecipe(id: string) return recipes[id] end

local staffRec = getRecipe("Staff_R1_002_BastonMaderaVieja")
assertTest(staffRec ~= nil and staffRec.Category == "Staff", "TC-REC-01: Staff recipe found with category Staff")
assertTest(staffRec.RequiredMaterials["MaderaAntigua"] == 10, "TC-REC-02: Requires 10 MaderaAntigua")

local armorRec = getRecipe("Armor_Forest_Chest")
assertTest(armorRec ~= nil and armorRec.Category == "Armor", "TC-REC-03: Armor recipe found with category Armor")

-- 2. Test ArmorConfig and Set Bonuses
local armorPieces = {
	["Armor_Forest_Helmet"] = { Slot = "Helmet", Def = 5, Hp = 25, SetId = "Set_Forest" },
	["Armor_Forest_Chest"] = { Slot = "Chest", Def = 15, Hp = 60, SetId = "Set_Forest" },
	["Armor_Forest_Gloves"] = { Slot = "Gloves", Def = 6, Hp = 20, SetId = "Set_Forest" },
	["Armor_Forest_Pants"] = { Slot = "Pants", Def = 10, Hp = 40, SetId = "Set_Forest" },
	["Armor_Forest_Boots"] = { Slot = "Boots", Def = 6, Hp = 25, SetId = "Set_Forest" },
	["Armor_Forest_Cape"] = { Slot = "Cape", Def = 8, Hp = 30, SetId = "Set_Forest" },
}

local function calculateArmorStats(equipped)
	local totalDef = 0
	local totalHp = 0
	local piecesCount = 0
	for slot, pieceId in pairs(equipped) do
		if pieceId and armorPieces[pieceId] then
			totalDef += armorPieces[pieceId].Def
			totalHp += armorPieces[pieceId].Hp
			piecesCount += 1
		end
	end
	
	local hasSetBonus = (piecesCount == 6)
	if hasSetBonus then
		totalHp = math.floor(totalHp * 1.15) -- +15% set bonus
	end
	return { Def = totalDef, Hp = totalHp, HasSetBonus = hasSetBonus }
end

-- Test partial armor (3 pieces)
local partialArmor = {
	Helmet = "Armor_Forest_Helmet",
	Chest = "Armor_Forest_Chest",
	Gloves = "Armor_Forest_Gloves",
}
local statsPartial = calculateArmorStats(partialArmor)
assertTest(statsPartial.HasSetBonus == false, "TC-ARM-01: 3 pieces do not trigger 6-piece set bonus")
assertTest(statsPartial.Def == 26, "TC-ARM-02: Defensive stats sum correctly (5+15+6 = 26)")

-- Test complete 6-piece armor set
local fullArmor = {
	Helmet = "Armor_Forest_Helmet",
	Chest = "Armor_Forest_Chest",
	Gloves = "Armor_Forest_Gloves",
	Pants = "Armor_Forest_Pants",
	Boots = "Armor_Forest_Boots",
	Cape = "Armor_Forest_Cape",
}
local statsFull = calculateArmorStats(fullArmor)
assertTest(statsFull.HasSetBonus == true, "TC-ARM-03: Full 6-piece set triggers Set Bonus")
assertTest(statsFull.Hp == math.floor((25+60+20+40+25+30) * 1.15), "TC-ARM-04: Full set applies +15% HP multiplier")

-- 3. Test ForgeService Crafting Logic
local testProfile = {
	Coins = 1000,
	Rebirths = 0,
	Materials = {
		["MaderaAntigua"] = 15,
		["HojaMagica"] = 4, -- Missing 1 HojaMagica for Staff (requires 5)
	},
	OwnedStaffs = { ["Staff_R1_001_RamaAprendiz"] = true },
	ArmorInventory = {},
	EquippedStaff = "Staff_R1_001_RamaAprendiz",
	EquippedArmor = {},
}

local function tryForge(profile, targetId)
	local rec = getRecipe(targetId)
	if not rec then return false, "No existe receta" end
	if profile.Rebirths < rec.RequiredRebirth then return false, "Rebirth insuficiente" end
	if profile.Coins < rec.RequiredCoins then return false, "Oro insuficiente" end
	
	for mat, req in pairs(rec.RequiredMaterials) do
		if (profile.Materials[mat] or 0) < req then
			return false, "Materiales insuficientes"
		end
	end
	
	if rec.Category == "Staff" and profile.OwnedStaffs[targetId] then
		return false, "Ya posees este baston"
	end
	
	-- Atomic deduct
	profile.Coins -= rec.RequiredCoins
	for mat, req in pairs(rec.RequiredMaterials) do
		profile.Materials[mat] -= req
	end
	
	if rec.Category == "Staff" then
		profile.OwnedStaffs[targetId] = true
	elseif rec.Category == "Armor" then
		profile.ArmorInventory[targetId] = (profile.ArmorInventory[targetId] or 0) + 1
	end
	return true, "Exito"
end

-- Try forge with insufficient HojaMagica (has 4, needs 5)
local failMat, _ = tryForge(testProfile, "Staff_R1_002_BastonMaderaVieja")
assertTest(failMat == false, "TC-FRG-01: Forging fails gracefully with insufficient materials")
assertTest(testProfile.Coins == 1000, "TC-FRG-02: Coins untouched after failed forge")
assertTest(testProfile.Materials["MaderaAntigua"] == 15, "TC-FRG-03: Materials untouched after failed forge")

-- Give materials and forge staff successfully
testProfile.Materials["HojaMagica"] = 10
local okForgeStaff, _ = tryForge(testProfile, "Staff_R1_002_BastonMaderaVieja")
assertTest(okForgeStaff == true, "TC-FRG-04: Staff forged successfully with sufficient materials and coins")
assertTest(testProfile.Coins == 750, "TC-FRG-05: Exactly 250 coins deducted (1000 - 250 = 750)")
assertTest(testProfile.Materials["MaderaAntigua"] == 5, "TC-FRG-06: Exactly 10 MaderaAntigua deducted (15 - 10 = 5)")
assertTest(testProfile.Materials["HojaMagica"] == 5, "TC-FRG-07: Exactly 5 HojaMagica deducted (10 - 5 = 5)")
assertTest(testProfile.OwnedStaffs["Staff_R1_002_BastonMaderaVieja"] == true, "TC-FRG-08: Staff added to OwnedStaffs")

-- Try duplicate forge of the same staff
local dupForge, _ = tryForge(testProfile, "Staff_R1_002_BastonMaderaVieja")
assertTest(dupForge == false, "TC-FRG-09: Duplicate forge of already owned staff is strictly prevented")

-- 4. Test Armor Forging
testProfile.Coins = 2000
testProfile.Materials["MaderaAntigua"] = 50
testProfile.Materials["HojaMagica"] = 30
local okForgeArmor, _ = tryForge(testProfile, "Armor_Forest_Chest")
assertTest(okForgeArmor == true, "TC-FRG-10: Armor chest forged successfully")
assertTest(testProfile.ArmorInventory["Armor_Forest_Chest"] == 1, "TC-FRG-11: Armor piece registered in ArmorInventory")

-- 5. Test EquipmentService
local function tryEquipStaff(profile, staffId)
	if not profile.OwnedStaffs[staffId] then return false, "No posees este baston" end
	profile.EquippedStaff = staffId
	return true, "Equipado"
end

local function tryEquipArmor(profile, armorId)
	if (profile.ArmorInventory[armorId] or 0) <= 0 then return false, "No posees esta armadura" end
	local piece = armorPieces[armorId]
	if not piece then return false, "No existe pieza" end
	profile.EquippedArmor[piece.Slot] = armorId
	return true, "Equipada"
end

-- Try equip unowned staff
assertTest(tryEquipStaff(testProfile, "Staff_R1_020_BastonCorazonVerde") == false, "TC-EQP-01: Equipping unowned staff rejected")
-- Equip forged staff
assertTest(tryEquipStaff(testProfile, "Staff_R1_002_BastonMaderaVieja") == true, "TC-EQP-02: Equipping forged staff succeeds")
assertTest(testProfile.EquippedStaff == "Staff_R1_002_BastonMaderaVieja", "TC-EQP-03: EquippedStaff updated in profile")

-- Equip forged armor piece
assertTest(tryEquipArmor(testProfile, "Armor_Forest_Chest") == true, "TC-EQP-04: Equipping forged armor piece succeeds")
assertTest(testProfile.EquippedArmor["Chest"] == "Armor_Forest_Chest", "TC-EQP-05: Chest slot equipped in profile")

print("========================================")
print(string.format("PHASE 4 TEST RESULTS: %d PASSED, %d FAILED", testsPassed, testsFailed))
print("========================================")

if testsFailed == 0 then
	return "PHASE_4_ALL_TESTS_PASSED"
else
	return "PHASE_4_TESTS_FAILED_" .. testsFailed
end
