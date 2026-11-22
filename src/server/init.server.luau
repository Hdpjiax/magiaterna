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
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local Services = script:WaitForChild("Services")
local PlayerDataService = require(Services:WaitForChild("PlayerDataService") :: ModuleScript)
local MagicService = require(Services:WaitForChild("MagicService") :: ModuleScript)
local RebirthService = require(Services:WaitForChild("RebirthService") :: ModuleScript)
local PetService = require(Services:WaitForChild("PetService") :: ModuleScript)
local EggService = require(Services:WaitForChild("EggService") :: ModuleScript)
local ForgeService = require(Services:WaitForChild("ForgeService") :: ModuleScript)
local EquipmentService = require(Services:WaitForChild("EquipmentService") :: ModuleScript)
local EnemyService = require(Services:WaitForChild("EnemyService") :: ModuleScript)
local CombatService = require(Services:WaitForChild("CombatService") :: ModuleScript)
local DungeonService = require(Services:WaitForChild("DungeonService") :: ModuleScript)

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
CombatService.Init()
DungeonService.Init()

print("[MAGIA ETERNA] Phases 1 through 5 Server Services are active.")
