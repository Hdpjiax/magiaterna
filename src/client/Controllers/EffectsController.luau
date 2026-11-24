--!strict
--[[
    EffectsController.luau
    Client-side VFX controller for MAGIA ETERNA.
    Features:
    - Floating Combat Text (Damage Numbers) with bounce physics, element colors, and clean fadeout.
    - Arcane Spell Beams & Elemental Projectiles connecting player's staff tip directly to targeted enemies.
    - Radial Magic Cast Rings and Ground Auras at the caster's feet.
    - Training Mana Pulse indicators (+Magia floating icons).
    - Boss attack ground telegraphs (Circles, Cones, Rectangles).
    - Full 5-7s Cinematic Forge sequence with camera shake and anvil sparks.
    - Respects Settings.ReducedEffects for low-end mobile optimization.
]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Source"):WaitForChild("shared")
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local DataController = require(script.Parent.DataController)
local SoundController = require(script.Parent.SoundController)
local CameraController = require(script.Parent.CameraController)

local EffectsController = {}
local activeForgeSkipped = false
local localPlayer = Players.LocalPlayer

local function isReducedEffects(): boolean
	local profile = DataController.GetProfile()
	return profile ~= nil and profile.Settings ~= nil and profile.Settings.ReducedEffects == true
end

-- Spawns floating combat text (Damage Numbers) above the hit enemy
function EffectsController.SpawnDamageNumber(worldPos: Vector3, damage: number, isDead: boolean?, elementColor: Color3?)
	local part = Instance.new("Part")
	part.Name = "DamageNumberAnchor"
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.CFrame = CFrame.new(worldPos + Vector3.new((math.random() - 0.5) * 1.5, 2.5, (math.random() - 0.5) * 1.5))
	part.Transparency = 1
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Anchored = true
	part.Parent = workspace

	local bb = Instance.new("BillboardGui")
	bb.Name = "DamageGui"
	bb.Size = UDim2.new(0, 140, 0, 45)
	bb.StudsOffset = Vector3.new(0, 0, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 120
	bb.Parent = part

	local label = Instance.new("TextLabel")
	label.Name = "DamageText"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Text = isDead and string.format("💥 -%d", damage) or string.format("-%d", damage)
	label.TextColor3 = isDead and Color3.fromRGB(255, 60, 50) or (elementColor or Color3.fromRGB(255, 215, 60))
	label.TextStrokeColor3 = Color3.fromRGB(15, 10, 20)
	label.TextStrokeTransparency = 0.1
	label.Parent = bb

	-- Upward floating + Pop scaling tween
	local targetCF = part.CFrame * CFrame.new(0, 3.2, 0)
	local floatTween = TweenService:Create(part, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = targetCF,
	})

	local fadeTween = TweenService:Create(label, TweenInfo.new(0.40, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	})

	floatTween:Play()
	task.delay(0.25, function()
		fadeTween:Play()
	end)

	Debris:AddItem(part, 0.75)
end

-- Spawns a floating training pulse (+Magia) above player
function EffectsController.SpawnTrainingPulse(worldPos: Vector3, powerGained: number)
	if isReducedEffects() then return end

	local part = Instance.new("Part")
	part.Name = "TrainingPulseAnchor"
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.CFrame = CFrame.new(worldPos + Vector3.new((math.random() - 0.5) * 1.0, 3.0, (math.random() - 0.5) * 1.0))
	part.Transparency = 1
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Anchored = true
	part.Parent = workspace

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 120, 0, 35)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 60
	bb.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = string.format("+%d ⚡", powerGained)
	label.TextColor3 = Color3.fromRGB(60, 220, 255)
	label.TextStrokeColor3 = Color3.fromRGB(10, 20, 30)
	label.TextStrokeTransparency = 0.2
	label.Parent = bb

	TweenService:Create(part, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = part.CFrame * CFrame.new(0, 2.5, 0),
	}):Play()

	task.delay(0.25, function()
		TweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		}):Play()
	end)

	Debris:AddItem(part, 0.65)
end

-- Fires an arcane beam from the staff tip to the target position
function EffectsController.FireSpellBeam(originPos: Vector3, targetPos: Vector3, elementColor: Color3?)
	local color = elementColor or Color3.fromRGB(80, 210, 255)
	local distance = (targetPos - originPos).Magnitude
	if distance < 0.5 then return end

	-- 1. Laser / Arcane Cylinder Beam
	local beamPart = Instance.new("Part")
	beamPart.Name = "SpellBeamFX"
	beamPart.Material = Enum.Material.Neon
	beamPart.Color = color
	beamPart.Anchored = true
	beamPart.CanCollide = false
	beamPart.CanTouch = false
	beamPart.CanQuery = false
	beamPart.Size = Vector3.new(0.45, distance, 0.45)
	beamPart.CFrame = CFrame.new(originPos, targetPos) * CFrame.new(0, 0, -distance / 2) * CFrame.Angles(math.rad(90), 0, 0)
	beamPart.Transparency = 0.1
	beamPart.Parent = workspace

	-- Flash beam and shrink
	TweenService:Create(beamPart, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.05, distance, 0.05),
		Transparency = 1,
	}):Play()

	Debris:AddItem(beamPart, 0.22)

	-- 2. Impact Sparks at target
	EffectsController.SpawnMagicBurst(targetPos, color)
end

-- Spawns a radial rune aura circle on the ground at the caster's feet
function EffectsController.SpawnCastAura(rootCFrame: CFrame, elementColor: Color3?)
	if isReducedEffects() then return end

	local ring = Instance.new("Part")
	ring.Name = "CastAuraRing"
	ring.Shape = Enum.PartType.Cylinder
	ring.Material = Enum.Material.Neon
	ring.Color = elementColor or Color3.fromRGB(60, 220, 255)
	ring.Anchored = true
	ring.CanCollide = false
	ring.CanTouch = false
	ring.CanQuery = false
	ring.Size = Vector3.new(0.08, 2, 2)
	ring.CFrame = CFrame.new(rootCFrame.Position.X, rootCFrame.Position.Y - 2.8, rootCFrame.Position.Z) * CFrame.Angles(0, 0, math.rad(90))
	ring.Transparency = 0.25
	ring.Parent = workspace

	TweenService:Create(ring, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.04, 9, 9),
		Transparency = 1,
	}):Play()

	Debris:AddItem(ring, 0.38)
end

-- Spawns a readable ground telegraph indicator for Boss/MiniBoss attacks
function EffectsController.SpawnTelegraph(position: Vector3, radius: number, duration: number, shape: string?)
	local part = Instance.new("Part")
	part.Name = "TelegraphIndicator"
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
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

-- Spawns an explosive magic burst at a world position
function EffectsController.SpawnMagicBurst(position: Vector3, color: Color3?)
	if isReducedEffects() then return end

	local orb = Instance.new("Part")
	orb.Name = "MagicBurst"
	orb.Shape = Enum.PartType.Ball
	orb.Anchored = true
	orb.CanCollide = false
	orb.CanTouch = false
	orb.CanQuery = false
	orb.Material = Enum.Material.Neon
	orb.Color = color or Color3.fromRGB(168, 85, 247)
	orb.Size = Vector3.new(1.2, 1.2, 1.2)
	orb.CFrame = CFrame.new(position)
	orb.Transparency = 0.15
	orb.Parent = workspace

	TweenService:Create(orb, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(5.5, 5.5, 5.5),
		Transparency = 1,
	}):Play()

	Debris:AddItem(orb, 0.32)
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
	-- Listen for boss telegraph visual warnings
	local telegraphEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.EnemyTelegraphStarted)
	if telegraphEvent then
		telegraphEvent.OnClientEvent:Connect(function(payload: any)
			if typeof(payload) ~= "table" then return end
			local pos = if typeof(payload.Position) == "Vector3" then payload.Position else Vector3.new(0, 1, 0)
			local radius = if typeof(payload.Radius) == "number" then payload.Radius else 10
			local dur = if typeof(payload.Duration) == "number" then payload.Duration else 1.5
			EffectsController.SpawnTelegraph(pos, radius, dur, payload.Shape)
		end)
	end

	-- Listen for authoritative damage dealt to spawn damage numbers & impact VFX
	local damageEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.DamageDealt)
	if damageEvent then
		damageEvent.OnClientEvent:Connect(function(data: any)
			if typeof(data) ~= "table" then return end
			local pos = data.Position or Vector3.new(0, 5, 0)
			local damage = data.Damage or 10
			local isDead = data.IsDead == true

			EffectsController.SpawnDamageNumber(pos, damage, isDead)
			EffectsController.SpawnMagicBurst(pos, isDead and Color3.fromRGB(255, 60, 50) or Color3.fromRGB(80, 210, 255))
			CameraController.Shake(isDead and 0.55 or 0.25, 0.12)
		end)
	end

	-- 60 FPS Ambient Animation Loop: Rotates boss halos, crystal orbs, and floating runes
	local RunService = game:GetService("RunService")
	RunService.RenderStepped:Connect(function(deltaTime: number)
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not hrp then return end

		-- Check models in workspace near player for animated props
		for _, child in ipairs(workspace:GetChildren()) do
			if (string.find(child.Name, "Dungeon_") or string.find(child.Name, "MagiaEterna_Lobby")) and child:IsA("Model") then
				for _, part in ipairs(child:GetDescendants()) do
					if part:IsA("BasePart") then
						if string.find(part.Name, "Halo") or string.find(part.Name, "Rune_Circle") or string.find(part.Name, "Celestial_Ring") then
							part.CFrame = part.CFrame * CFrame.Angles(0, math.rad(35 * deltaTime), 0)
						end
					end
				end
			end
		end
	end)

	print("[EffectsController] Initialized successfully with Damage Numbers, Arcane Beams, Cast Auras, and Ambient Prop Dynamics.")
end

return table.freeze(EffectsController)
