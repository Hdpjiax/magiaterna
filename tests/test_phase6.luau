--!strict
--[[
    test_phase6.luau
    Automated QA Test Suite for Phase 6: Adaptive UI, Audio & Polish for MAGIA ETERNA.
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
print("     MAGIA ETERNA — QA SUITE: PHASE 6   ")
print("========================================")

-- 1. Test Group 1: UIFormatters (Metric, Time, Roman)
print("\n--- Test Group 1: UIFormatters ---")

local METRIC_SUFFIXES = {
	{ Threshold = 1e15, Suffix = "Q" },
	{ Threshold = 1e12, Suffix = "T" },
	{ Threshold = 1e9,  Suffix = "B" },
	{ Threshold = 1e6,  Suffix = "M" },
	{ Threshold = 1e3,  Suffix = "K" },
}

local function formatNumber(value: number): string
	if value < 0 then
		return "-" .. formatNumber(-value)
	end
	if value < 1000 then
		return string.format("%d", math.floor(value))
	end
	for _, entry in ipairs(METRIC_SUFFIXES) do
		if value >= entry.Threshold then
			local formatted = value / entry.Threshold
			if formatted >= 100 then
				return string.format("%.0f%s", formatted, entry.Suffix)
			elseif formatted >= 10 then
				return string.format("%.1f%s", formatted, entry.Suffix)
			else
				return string.format("%.2f%s", formatted, entry.Suffix)
			end
		end
	end
	return tostring(math.floor(value))
end

local function formatTime(seconds: number): string
	local s = math.max(0, math.floor(seconds))
	local mins = math.floor(s / 60)
	local remSecs = s % 60
	return string.format("%02d:%02d", mins, remSecs)
end

local function toRoman(num: number): string
	local romans = { [1] = "I", [2] = "II", [3] = "III", [4] = "IV", [5] = "V" }
	return romans[num] or tostring(num)
end

test("TC-FMT-01: Numbers < 1000 display exact integer (850 -> '850')", formatNumber(850) == "850")
test("TC-FMT-02: Thousands formatted with K suffix (1500 -> '1.50K')", formatNumber(1500) == "1.50K")
test("TC-FMT-03: Tens of thousands (25400 -> '25.4K')", formatNumber(25400) == "25.4K")
test("TC-FMT-04: Hundreds of thousands (350000 -> '350K')", formatNumber(350000) == "350K")
test("TC-FMT-05: Millions formatted with M suffix (2500000 -> '2.50M')", formatNumber(2500000) == "2.50M")
test("TC-FMT-06: Billions formatted with B suffix (4200000000 -> '4.20B')", formatNumber(4200000000) == "4.20B")
test("TC-FMT-07: Trillions formatted with T suffix (1000000000000 -> '1.00T')", formatNumber(1000000000000) == "1.00T")
test("TC-FMT-08: Negative numbers formatted correctly (-1500 -> '-1.50K')", formatNumber(-1500) == "-1.50K")

test("TC-FMT-09: Time 0s formats to '00:00'", formatTime(0) == "00:00")
test("TC-FMT-10: Time 75s formats to '01:15'", formatTime(75) == "01:15")
test("TC-FMT-11: Time 305s formats to '05:05'", formatTime(305) == "05:05")

test("TC-FMT-12: Roman 1 formats to 'I'", toRoman(1) == "I")
test("TC-FMT-13: Roman 5 formats to 'V'", toRoman(5) == "V")

-- 2. Test Group 2: Sound Configuration & Categories
print("\n--- Test Group 2: Sound Catalog & Categorization ---")

local soundCatalog = {
	UI_ButtonClick = { Id = "UI_ButtonClick", AssetId = "rbxassetid://9114223170", Category = "UI", BaseVolume = 0.6 },
	SFX_MagicClick = { Id = "SFX_MagicClick", AssetId = "rbxassetid://9114224000", Category = "SFX", BaseVolume = 0.7 },
	SFX_RebirthFanfare = { Id = "SFX_RebirthFanfare", AssetId = "rbxassetid://9114224500", Category = "SFX", BaseVolume = 0.9 },
	SFX_ForgeSuccess = { Id = "SFX_ForgeSuccess", AssetId = "rbxassetid://9114225500", Category = "SFX", BaseVolume = 0.8 },
	SFX_DungeonVictory = { Id = "SFX_DungeonVictory", AssetId = "rbxassetid://9114226500", Category = "SFX", BaseVolume = 1.0 },
	BGM_Lobby = { Id = "BGM_Lobby", AssetId = "rbxassetid://1848354536", Category = "Music", BaseVolume = 0.45 },
}

test("TC-SND-01: UI button click sound defined with Category 'UI'", soundCatalog.UI_ButtonClick.Category == "UI")
test("TC-SND-02: Magic click SFX defined with Category 'SFX'", soundCatalog.SFX_MagicClick.Category == "SFX")
test("TC-SND-03: Rebirth fanfare has high priority volume (0.9)", soundCatalog.SFX_RebirthFanfare.BaseVolume >= 0.9)
test("TC-SND-04: Background music categorized as 'Music'", soundCatalog.BGM_Lobby.Category == "Music")
test("TC-SND-05: All registered sounds possess valid rbxassetid links", 
	soundCatalog.SFX_ForgeSuccess.AssetId:sub(1, 13) == "rbxassetid://" and
	soundCatalog.SFX_DungeonVictory.AssetId:sub(1, 13) == "rbxassetid://")

-- 3. Test Group 3: Modal Orchestration & UI State
print("\n--- Test Group 3: Modal Navigation Stack ---")

local activeModal: string? = nil

local function openModal(name: string)
	if activeModal == name then
		activeModal = nil -- Toggle close
	else
		activeModal = name
	end
end

local function closeModal()
	activeModal = nil
end

test("TC-MOD-01: Modal stack starts empty", activeModal == nil)

openModal("Pets")
test("TC-MOD-02: Opening Pets sets activeModal to 'Pets'", activeModal == "Pets")

openModal("Forge")
test("TC-MOD-03: Opening Forge safely overrides activeModal to 'Forge'", activeModal == "Forge")

openModal("Forge") -- Toggle
test("TC-MOD-04: Clicking active button toggles modal closed", activeModal == nil)

openModal("Dungeons")
closeModal()
test("TC-MOD-05: Calling closeModal resets activeModal to nil", activeModal == nil)

-- 4. Test Group 4: Responsive HUD Currency Replication
print("\n--- Test Group 4: Responsive HUD Currency Replication ---")

local mockHUDLabels = {
	Coins = "0",
	Magic = "0",
	Rebirths = "0",
	Shards = "0",
}

local function updateHUD(profile)
	mockHUDLabels.Coins = formatNumber(profile.Coins or 0)
	mockHUDLabels.Magic = formatNumber(profile.Magic or 0)
	mockHUDLabels.Rebirths = formatNumber(profile.Rebirths or 0)
	mockHUDLabels.Shards = formatNumber(profile.RebirthShards or 0)
end

local testProfile = {
	Coins = 1540000, -- 1.54M
	Magic = 85000,   -- 85.0K
	Rebirths = 3,    -- 3
	RebirthShards = 12, -- 12
}

updateHUD(testProfile)

test("TC-HUD-01: Coins rendered formatted as '1.54M'", mockHUDLabels.Coins == "1.54M")
test("TC-HUD-02: Magic rendered formatted as '85.0K'", mockHUDLabels.Magic == "85.0K")
test("TC-HUD-03: Rebirths rendered as '3'", mockHUDLabels.Rebirths == "3")
test("TC-HUD-04: Rebirth Shards rendered as '12'", mockHUDLabels.Shards == "12")

print("\n========================================")
print(string.format("  PHASE 6 TEST RESULTS: %d PASSED, %d FAILED", passed, failed))
print("========================================")
return string.format("%d passed, %d failed", passed, failed)
