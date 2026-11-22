--!strict
--[[
    CameraController.luau
    Client-side camera controller for MAGIA ETERNA.
    Handles Forge/Egg focus transitions and accessibility-safe CameraShake.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local DataController = require(script.Parent.DataController)

local CameraController = {}
local shakeIntensity = 0
local isFocused = false

function CameraController.Shake(intensity: number, duration: number?)
	local profile = DataController.GetProfile()
	if profile and profile.Settings and profile.Settings.CameraShake == false then
		return
	end
	shakeIntensity = math.max(shakeIntensity, math.clamp(intensity, 0, 3))
	local dur = duration or 0.25
	task.delay(dur, function()
		shakeIntensity = 0
	end)
end

-- Smoothly focuses camera on a world position (e.g. Forge anvil) and restores afterwards
function CameraController.FocusOnTarget(targetCFrame: CFrame, duration: number?)
	local camera = workspace.CurrentCamera
	if not camera or isFocused then return end
	isFocused = true

	camera.CameraType = Enum.CameraType.Scriptable
	local goalCFrame = targetCFrame * CFrame.new(0, 3.5, 7) * CFrame.Angles(math.rad(-18), 0, 0)
	TweenService:Create(camera, TweenInfo.new(duration or 0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = goalCFrame,
	}):Play()
end

function CameraController.RestoreDefault()
	local camera = workspace.CurrentCamera
	if not camera then return end
	isFocused = false
	camera.CameraType = Enum.CameraType.Custom
	local player = Players.LocalPlayer
	if player and player.Character then
		local hum = player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			camera.CameraSubject = hum
		end
	end
end

function CameraController.Init()
	RunService.RenderStepped:Connect(function()
		if shakeIntensity <= 0.01 then return end
		local camera = workspace.CurrentCamera
		if not camera then return end
		local dx = (math.random() - 0.5) * 0.25 * shakeIntensity
		local dy = (math.random() - 0.5) * 0.25 * shakeIntensity
		camera.CFrame = camera.CFrame * CFrame.new(dx, dy, 0)
		shakeIntensity *= 0.88
	end)
	print("[CameraController] Initialized successfully.")
end

return table.freeze(CameraController)
