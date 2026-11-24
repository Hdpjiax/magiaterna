--!strict
--[[
    MagicController.luau
    Client-side controller for training magic and executing rebirths in MAGIA ETERNA.
    Features client-side debounce to optimize network traffic, procedural cast animations,
    staff crystal flashes, ground aura ripples, and floating mana indicators.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Source"):WaitForChild("shared")
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local Controllers = script.Parent
local AnimationController = require(Controllers:WaitForChild("AnimationController") :: ModuleScript)
local EffectsController = require(Controllers:WaitForChild("EffectsController") :: ModuleScript)
local SoundController = require(Controllers:WaitForChild("SoundController") :: ModuleScript)
local StaffVisualController = require(Controllers:WaitForChild("StaffVisualController") :: ModuleScript)

local MagicController = {}
local localPlayer = Players.LocalPlayer
local lastClickTime = 0
local CLICK_COOLDOWN = 0.08 -- Max 12 clicks/sec from client

-- Triggers a training pulse from client
function MagicController.Train()
	local now = os.clock()
	if now - lastClickTime < CLICK_COOLDOWN then
		return
	end
	lastClickTime = now

	-- 1. Client-Side Instant Animation & VFX Feedback
	AnimationController.PlayStaffSwing()
	StaffVisualController.PulseStaffTip()

	local char = localPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if hrp then
		EffectsController.SpawnCastAura(hrp.CFrame)
		EffectsController.SpawnTrainingPulse(hrp.Position, 1)
	end

	SoundController.PlaySFX("SFX_MagicClick")

	-- 2. Server Event
	local trainEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestTrainMagic)
	if trainEvent then
		trainEvent:FireServer()
	end
end

-- Requests a rebirth from client
function MagicController.RequestRebirth()
	AnimationController.PlayCelebrate()
	SoundController.PlaySFX("SFX_RebirthFanfare")

	local rebirthEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestRebirth)
	if rebirthEvent then
		rebirthEvent:FireServer()
	end
end

-- Initializes notification listener
function MagicController.Init()
	local notifEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.NotificationPrompt)
	if notifEvent then
		notifEvent.OnClientEvent:Connect(function(title: string, message: string, alertType: string)
			print(string.format("[NOTIFICACIÓN - %s]: %s (%s)", title, message, alertType))
		end)
	end

	print("[MagicController] Initialized successfully with responsive casting feedback.")
end

return table.freeze(MagicController)
