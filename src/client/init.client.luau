--!strict
--[[
    Main Client Entry Point
    MAGIA ETERNA
    Initializes core client controllers: DataController, SoundController, CameraController,
    AnimationController, EffectsController, MagicController, PetFollowController,
    ForgeController, CombatController, NotificationController, UIController.
]]

local Controllers = script:WaitForChild("Controllers")
local DataController = require(Controllers:WaitForChild("DataController") :: ModuleScript)
local SoundController = require(Controllers:WaitForChild("SoundController") :: ModuleScript)
local CameraController = require(Controllers:WaitForChild("CameraController") :: ModuleScript)
local AnimationController = require(Controllers:WaitForChild("AnimationController") :: ModuleScript)
local EffectsController = require(Controllers:WaitForChild("EffectsController") :: ModuleScript)
local MagicController = require(Controllers:WaitForChild("MagicController") :: ModuleScript)
local PetFollowController = require(Controllers:WaitForChild("PetFollowController") :: ModuleScript)
local ForgeController = require(Controllers:WaitForChild("ForgeController") :: ModuleScript)
local CombatController = require(Controllers:WaitForChild("CombatController") :: ModuleScript)
local NotificationController = require(Controllers:WaitForChild("NotificationController") :: ModuleScript)
local UIController = require(Controllers:WaitForChild("UIController") :: ModuleScript)
local InteractionController = require(Controllers:WaitForChild("InteractionController") :: ModuleScript)
local TutorialController = require(Controllers:WaitForChild("TutorialController") :: ModuleScript)
local BossHealthBar = require(script:WaitForChild("UI"):WaitForChild("BossHealthBar") :: ModuleScript)

print("[MAGIA ETERNA] Client Initializing...")

-- Core State, Audio & Visuals
DataController.Init()
SoundController.Init()
CameraController.Init()
AnimationController.Init()
EffectsController.Init()

-- Gameplay & World Interactions
MagicController.Init()
PetFollowController.Init()
ForgeController.Init()
CombatController.Init()
InteractionController.Init()

-- UI, Feedback & Onboarding
NotificationController.Init()
UIController.Init()
TutorialController.Init()
BossHealthBar.Init()

print("[MAGIA ETERNA] Client Core Ready (All Phases & World Interactions Active).")
