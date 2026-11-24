--!strict
--[[
    Main Server Entry Point
    MAGIA ETERNA
    Initializes core services:
    - Phase 1: Network Endpoints, Data Persistence, Security Guards
    - Phase 2: Magic Simulator, Rebirth Service
    - Phase 3: Pet Service, Egg Hatching Service
    - Phase 4: Blacksmith Forge Service, Equipment Service
    - Phase 5: Dungeon Service, Enemy Service, Combat Service
    - Phase 6: Economy Service, Quest Service, Monetization Service, Settings
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Config"):WaitForChild("GameConfig") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local Services = script:WaitForChild("Services")
local PlayerDataService = require(Services:WaitForChild("PlayerDataService") :: ModuleScript)
local RemoteGuard = require(Services:WaitForChild("RemoteGuard") :: ModuleScript)
local MagicService = require(Services:WaitForChild("MagicService") :: ModuleScript)
local RebirthService = require(Services:WaitForChild("RebirthService") :: ModuleScript)
local PetService = require(Services:WaitForChild("PetService") :: ModuleScript)
local EggService = require(Services:WaitForChild("EggService") :: ModuleScript)
local ForgeService = require(Services:WaitForChild("ForgeService") :: ModuleScript)
local EquipmentService = require(Services:WaitForChild("EquipmentService") :: ModuleScript)
local EnemyService = require(Services:WaitForChild("EnemyService") :: ModuleScript)
local EnemyAIService = require(Services:WaitForChild("EnemyAIService") :: ModuleScript)
local CombatService = require(Services:WaitForChild("CombatService") :: ModuleScript)
local DungeonService = require(Services:WaitForChild("DungeonService") :: ModuleScript)
local EconomyService = require(Services:WaitForChild("EconomyService") :: ModuleScript)
local QuestService = require(Services:WaitForChild("QuestService") :: ModuleScript)
local MonetizationService = require(Services:WaitForChild("MonetizationService") :: ModuleScript)
local TutorialService = require(Services:WaitForChild("TutorialService") :: ModuleScript)

print("========================================")
print("     MAGIA ETERNA — SERVER STARTING    ")
print("========================================")

-- 1. Initialize Network Remotes
NetworkEndpoints.InitServer()

-- 2. Initialize Data Persistence & Session Services (Phase 1)
PlayerDataService.Init()

-- 3. Initialize Magic Simulator & Rebirth Services (Phase 2)
MagicService.Init()
RebirthService.Init()

-- 4. Initialize Pet & Egg Services (Phase 3)
PetService.Init()
EggService.Init()

-- 5. Initialize Forge & Equipment Services (Phase 4)
ForgeService.Init()
EquipmentService.Init()

-- 6. Initialize Combat & Dungeon Services (Phase 5)
EnemyService.Init()
EnemyAIService.Init()
CombatService.Init()
DungeonService.Init()

-- 7. Initialize Economy, Quests, Monetization & Settings (Phase 6)
EconomyService.Init()
QuestService.Init()
MonetizationService.Init()
TutorialService.Init()

RemoteGuard.ProtectEvent(
	NetworkEndpoints.Events.RequestUpdateSettings,
	"SettingsUpdate",
	GameConfig.RATE_LIMITS.SettingsUpdate,
	function(player: Player, settingsPayload: any)
		if typeof(settingsPayload) ~= "table" then return end
		PlayerDataService.UpdateProfile(player, function(data)
			if typeof(settingsPayload.MusicVolume) == "number" then
				data.Settings.MusicVolume = math.clamp(settingsPayload.MusicVolume, 0, 1)
			end
			if typeof(settingsPayload.SFXVolume) == "number" then
				data.Settings.SFXVolume = math.clamp(settingsPayload.SFXVolume, 0, 1)
			end
			if typeof(settingsPayload.CameraShake) == "boolean" then
				data.Settings.CameraShake = settingsPayload.CameraShake
			end
			if typeof(settingsPayload.ReducedEffects) == "boolean" then
				data.Settings.ReducedEffects = settingsPayload.ReducedEffects
			end
		end)
	end
)

print("[MAGIA ETERNA] All Server Services (Phases 1-6) are active.")
