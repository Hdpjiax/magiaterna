--!strict
--[[
    EffectsController.luau
    Client-side VFX controller for MAGIA ETERNA.
    Handles spell impact particles, boss attack ground telegraphs, and the 5-7s Forge sequence.
    Respects Settings.ReducedEffects for mobile performance and accessibility.
]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local DataController = require(script.Parent.DataController)
local SoundController = require(script.Parent.SoundController)
local CameraController = require(script.Parent.CameraController)

local EffectsController = {}
local activeForgeSkipped = false

local function isReducedEffects(): boolean
	local profile = DataController.GetProfile()
	return profile ~= nil and profile.Settings ~= nil and profile.Settings.ReducedEffects == true
end

-- Spawns a readable ground telegraph indicator for Boss/MiniBoss attacks
function EffectsController.SpawnTelegraph(position: Vector3, radius: number, duration: number, shape: string?)
	local part = Instance.new("Part")
	part.Name = "TelegraphIndicator"
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(239, 68, 68)
	part.Transparency = 0.65
	part.Shape = if shape == "Circle" or not shape then Enum.PartType.Cylinder else Enum.PartType.Block

	if part.Shape == Enum.PartType.Cylinder then
		part.Size = Vector3.new(0.25, radius * 2, radius * 2)
		part.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	else
		part.Size = Vector3.new(radius, 0.25, radius * 1.5)
		part.CFrame = CFrame.new(position)
	end
	part.Parent = workspace

	TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Transparency = 0.2,
	}):Play()

	Debris:AddItem(part, duration + 0.15)
end

-- Spawns a quick magic burst at a world position
function EffectsController.SpawnMagicBurst(position: Vector3, color: Color3?)
	if isReducedEffects() then return end

	local orb = Instance.new("Part")
	orb.Name = "MagicBurst"
	orb.Shape = Enum.PartType.Ball
	orb.Anchored = true
	orb.CanCollide = false
	orb.Material = Enum.Material.Neon
	orb.Color = color or Color3.fromRGB(168, 85, 247)
	orb.Size = Vector3.new(1, 1, 1)
	orb.CFrame = CFrame.new(position)
	orb.Transparency = 0.2
	orb.Parent = workspace

	TweenService:Create(orb, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(5, 5, 5),
		Transparency = 1,
	}):Play()

	Debris:AddItem(orb, 0.4)
end

-- Runs the 5-7s Forge Animation Sequence (can be skipped by user)
function EffectsController.PlayForgeSequence(itemName: string, rarityColor: Color3, onStep: ((string) -> ())?, onFinished: (() -> ())?)
	activeForgeSkipped = false
	local steps = {
		{ Duration = 1.0, Label = "Colocando materiales en el yunque..." },
		{ Duration = 1.5, Label = "Martillando metal arcano..." },
		{ Duration = 1.8, Label = "Infusionando runas y cristales..." },
		{ Duration = 1.5, Label = "¡Liberando energía mágica!" },
		{ Duration = 0.7, Label = "¡Forjado completo: " .. itemName .. "!" },
	}

	task.spawn(function()
		for idx, step in ipairs(steps) do
			if activeForgeSkipped then break end
			if onStep then onStep(step.Label) end
			if idx == 2 then
				CameraController.Shake(0.6, 0.25)
			elseif idx == 4 then
				CameraController.Shake(1.2, 0.35)
				SoundController.PlaySFX("SFX_ForgeSuccess")
			end
			task.wait(step.Duration)
		end
		if onFinished then onFinished() end
	end)
end

function EffectsController.SkipForgeSequence()
	activeForgeSkipped = true
end

function EffectsController.Init()
	local telegraphEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.EnemyTelegraphStarted)
	telegraphEvent.OnClientEvent:Connect(function(payload: any)
		if typeof(payload) ~= "table" then return end
		local pos = if typeof(payload.Position) == "Vector3" then payload.Position else Vector3.new(0, 1, 0)
		local radius = if typeof(payload.Radius) == "number" then payload.Radius else 10
		local dur = if typeof(payload.Duration) == "number" then payload.Duration else 1.5
		EffectsController.SpawnTelegraph(pos, radius, dur, payload.Shape)
	end)

	print("[EffectsController] Initialized successfully.")
end

return table.freeze(EffectsController)
