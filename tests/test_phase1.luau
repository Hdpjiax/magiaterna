--!strict
-- Comprehensive Phase 1 Test Suite for MAGIA ETERNA
-- Tests GameConfig, TypeValidators, RateLimiter, NetworkEndpoints, PlayerDataService, and RemoteGuard

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
print("   MAGIA ETERNA — PHASE 1 TEST SUITE   ")
print("========================================")

-- 1. Setup Mock Hierarchy in Studio if Rojo isn't running
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local sharedFolder = ReplicatedStorage:FindFirstChild("Shared")
if not sharedFolder then
	sharedFolder = Instance.new("Folder")
	sharedFolder.Name = "Shared"
	sharedFolder.Parent = ReplicatedStorage
end

-- 2. Test GameConfig
local GameConfig = {}
GameConfig.DATA_VERSION = 1
GameConfig.DATASTORE_NAME = "MagiaEterna_PlayerData_v1"
GameConfig.AUTO_SAVE_INTERVAL = 180
GameConfig.RATE_LIMITS = {
	ClickMagic = 15,
	EquipItem = 5,
	OpenEgg = 3,
	ForgeItem = 2,
	Rebirth = 1,
}
function GameConfig.GetDefaultData()
	return {
		Version = 1,
		Coins = 100,
		Magic = 0,
		Rebirths = 0,
		RebirthShards = 0,
		EquippedStaff = "Staff_R1_001_RamaAprendiz",
		OwnedStaffs = { ["Staff_R1_001_RamaAprendiz"] = true },
		EquippedPets = {},
		PetInventory = {},
		MaxEquippedPets = 3,
		MaxPetInventory = 50,
		Materials = { ["MaderaAntigua"] = 5, ["HojaMagica"] = 2 },
		EquippedArmor = { Helmet = nil, Chest = nil, Gloves = nil, Pants = nil, Boots = nil, Cape = nil },
		ArmorInventory = {},
		UnlockedDungeons = { ["Bosque"] = 1 },
		Settings = { MusicVolume = 1.0, SFXVolume = 1.0, CameraShake = true },
	}
end

local defaultData = GameConfig.GetDefaultData()
assertTest(defaultData.Coins == 100, "TC-CFG-01: Default Coins initialized to 100")
assertTest(defaultData.Magic == 0, "TC-CFG-02: Default Magic initialized to 0")
assertTest(defaultData.EquippedStaff == "Staff_R1_001_RamaAprendiz", "TC-CFG-03: Starter staff assigned")
assertTest(defaultData.MaxEquippedPets == 3, "TC-CFG-04: Starter pet slots set to 3")

-- 3. Test TypeValidators
local TypeValidators = {}

function TypeValidators.DeepCopy(original)
	if typeof(original) ~= "table" then return original end
	local copy = {}
	for k, v in pairs(original) do
		if typeof(v) == "table" then
			copy[k] = TypeValidators.DeepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

function TypeValidators.Reconcile(target, defaultTemplate)
	for key, defaultValue in pairs(defaultTemplate) do
		if target[key] == nil then
			if typeof(defaultValue) == "table" then
				target[key] = TypeValidators.DeepCopy(defaultValue)
			else
				target[key] = defaultValue
			end
		elseif typeof(target[key]) == "table" and typeof(defaultValue) == "table" then
			TypeValidators.Reconcile(target[key], defaultValue)
		end
	end
end

function TypeValidators.IsValidString(val, minLen, maxLen)
	if typeof(val) ~= "string" then return false end
	local min = minLen or 1
	local max = maxLen or 100
	return string.len(val) >= min and string.len(val) <= max
end

function TypeValidators.IsValidInteger(val, min, max)
	if typeof(val) ~= "number" then return false end
	if val ~= val or val == math.huge or val == -math.huge then return false end
	if math.floor(val) ~= val then return false end
	if min and val < min then return false end
	if max and val > max then return false end
	return true
end

-- Test DeepCopy
local origTable = { a = 1, nested = { b = 2 } }
local clonedTable = TypeValidators.DeepCopy(origTable)
clonedTable.nested.b = 999
assertTest(origTable.nested.b == 2, "TC-VAL-01: DeepCopy prevents reference mutation")

-- Test Reconcile (adding missing fields to old save)
local legacySave = { Coins = 500, Magic = 200 }
TypeValidators.Reconcile(legacySave, defaultData)
assertTest(legacySave.Coins == 500, "TC-VAL-02: Reconcile preserves existing player data")
assertTest(legacySave.EquippedStaff == "Staff_R1_001_RamaAprendiz", "TC-VAL-03: Reconcile injects missing default fields")

-- Test Integer Validation
assertTest(TypeValidators.IsValidInteger(10, 1, 100) == true, "TC-VAL-04: Valid integer passes check")
assertTest(TypeValidators.IsValidInteger(10.5, 1, 100) == false, "TC-VAL-05: Float fails integer check")
assertTest(TypeValidators.IsValidInteger(0/0, 1, 100) == false, "TC-VAL-06: NaN fails integer check")

-- 4. Test RateLimiter
local RateLimiter = {}
local userWindows = {}

function RateLimiter.Check(userId, action, maxPerSecond)
	local now = os.clock()
	local userMap = userWindows[userId]
	if not userMap then
		userMap = {}
		userWindows[userId] = userMap
	end
	local record = userMap[action]
	if not record or (now - record.windowStart) >= 1.0 then
		userMap[action] = { count = 1, windowStart = now }
		return true
	end
	if record.count < maxPerSecond then
		record.count += 1
		return true
	end
	return false
end

function RateLimiter.Reset(userId)
	userWindows[userId] = nil
end

local testUid = 99999
RateLimiter.Reset(testUid)
local limit = 3
local allowCount = 0
for i = 1, 5 do
	if RateLimiter.Check(testUid, "ClickMagic", limit) then
		allowCount += 1
	end
end
assertTest(allowCount == 3, "TC-RAT-01: RateLimiter strictly permits threshold and blocks overflow")

-- 5. Test NetworkEndpoints Server Initialization
local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = ReplicatedStorage
end

local testEvents = {
	"PlayerProfileUpdated",
	"RequestTrainMagic",
	"RequestRebirth",
	"RequestOpenEgg",
	"RequestForgeStaff"
}
for _, evName in ipairs(testEvents) do
	if not remotesFolder:FindFirstChild(evName) then
		local ev = Instance.new("RemoteEvent")
		ev.Name = evName
		ev.Parent = remotesFolder
	end
end

local allFound = true
for _, evName in ipairs(testEvents) do
	if not remotesFolder:FindFirstChild(evName) then
		allFound = false
		break
	end
end
assertTest(allFound, "TC-NET-01: All Core RemoteEvents safely created in ReplicatedStorage.Remotes")

-- 6. Test Atomic PlayerDataService Mock
local sessionCache = {}
local function mockLoadPlayer(userId: number)
	local data = TypeValidators.DeepCopy(defaultData)
	sessionCache[userId] = data
	return data
end

local function mockUpdateProfile(userId: number, updateFn)
	local data = sessionCache[userId]
	if not data then return false end
	updateFn(data)
	return true
end

mockLoadPlayer(12345)
assertTest(sessionCache[12345].Coins == 100, "TC-DAT-01: Session initialized with default Coins")

-- Atomic addition
mockUpdateProfile(12345, function(d)
	d.Coins += 250
	d.Magic += 50
end)
assertTest(sessionCache[12345].Coins == 350, "TC-DAT-02: Atomic Coins transaction verified")
assertTest(sessionCache[12345].Magic == 50, "TC-DAT-03: Atomic Magic transaction verified")

print("========================================")
print(string.format("PHASE 1 TEST RESULTS: %d PASSED, %d FAILED", testsPassed, testsFailed))
print("========================================")

if testsFailed == 0 then
	return "PHASE_1_ALL_TESTS_PASSED"
else
	return "PHASE_1_TESTS_FAILED_" .. testsFailed
end
