--!strict
--[[
    Main Client Entry Point
    MAGIA ETERNA
    Initializes core client controllers: DataController, MagicController, PetFollowController,
    ForgeController, CombatController, SoundController, NotificationController, UIController.
]]

local Controllers = script:WaitForChild("Controllers")
local DataController = require(Controllers:WaitForChild("DataController") :: ModuleScript)
local MagicController = require(Controllers:WaitForChild("MagicController") :: ModuleScript)
local PetFollowController = require(Controllers:WaitForChild("PetFollowController") :: ModuleScript)
local ForgeController = require(Controllers:WaitForChild("ForgeController") :: ModuleScript)
local CombatController = require(Controllers:WaitForChild("CombatController") :: ModuleScript)
local SoundController = require(Controllers:WaitForChild("SoundController") :: ModuleScript)
local NotificationController = require(Controllers:WaitForChild("NotificationController") :: ModuleScript)
local UIController = require(Controllers:WaitForChild("UIController") :: ModuleScript)

print("[MAGIA ETERNA] Client Initializing...")

-- Core State & Sound
DataController.Init()
SoundController.Init()

-- Gameplay Controllers
MagicController.Init()
PetFollowController.Init()
ForgeController.Init()
CombatController.Init()

-- UI & Feedback
NotificationController.Init()
UIController.Init()

print("[MAGIA ETERNA] Client Core Ready (All Phases 1-6 Active).")
