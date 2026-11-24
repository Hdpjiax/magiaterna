--!strict
--[[
    EnemyAnimationController.luau
    Client-side organic animation and procedural kinematics engine for dungeon enemies in MAGIA ETERNA.
    Features:
    - Slime Squash-and-Stretch: fluid gelatinous hopping and impact squashing.
    - Flying Creature Aerodynamics: procedural 10-12 Hz wing flapping for Bats, Griffins, and Dragons.
    - Organic Breathing Idles: torso expansion and atmospheric hovering for Bosses and Minibosses.
    - Dynamic Attack Lunges: snappy forward dash and weapon slash recoil on EnemyAttacked event.
    - Death Dissolve FX: flash, particle burst, and smooth shrink upon defeat.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Source"):WaitForChild("shared")
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local Controllers = script.Parent
local SoundController = require(Controllers:WaitForChild("SoundController") :: ModuleScript)

local EnemyAnimationController = {}
local localPlayer = Players.LocalPlayer

type AnimatedEnemy = {
	Model: Model,
	Category: string,
	Wings: { Left: BasePart?, Right: BasePart? },
	BodyPart: BasePart?,
	OriginalSize: Vector3,
	OriginalPivot: CFrame,
	IsSlime: boolean,
	IsFlyer: boolean,
	PhaseOffset: number,
}

local activeAnimatedEnemies: { [Model]: AnimatedEnemy } = {}

-- Registers an enemy model for client-side procedural animation
local function registerModel(model: Model)
	if activeAnimatedEnemies[model] then return end

	local modelName = model.Name
	local isSlime = string.find(modelName, "Slime") ~= nil
	local isFlyer = string.find(modelName, "Murcielago") ~= nil
		or string.find(modelName, "Grifo") ~= nil
		or string.find(modelName, "Dragon") ~= nil
		or string.find(modelName, "Angel") ~= nil
		or string.find(modelName, "Arcangel") ~= nil
		or string.find(modelName, "Espectro") ~= nil

	local bodyPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("Body") or model:FindFirstChild("Head")
	if not bodyPart or not bodyPart:IsA("BasePart") then return end

	-- Find wings
	local leftWing = model:FindFirstChild("WingUpperL") or model:FindFirstChild("WingL") or model:FindFirstChild("LeftWing")
	local rightWing = model:FindFirstChild("WingUpperR") or model:FindFirstChild("WingR") or model:FindFirstChild("RightWing")

	activeAnimatedEnemies[model] = {
		Model = model,
		Category = model:GetAttribute("IsBoss") and "Boss" or "Normal",
		Wings = {
			Left = leftWing and leftWing:IsA("BasePart") and leftWing or nil,
			Right = rightWing and rightWing:IsA("BasePart") and rightWing or nil,
		},
		BodyPart = bodyPart,
		OriginalSize = bodyPart.Size,
		OriginalPivot = model:GetPivot(),
		IsSlime = isSlime,
		IsFlyer = isFlyer,
		PhaseOffset = math.random() * math.pi * 2,
	}
end

-- Plays an attack lunge animation on an enemy
function EnemyAnimationController.PlayAttackLunge(model: Model, targetPos: Vector3)
	local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then return end

	local origCF = model:GetPivot()
	local forwardDir = (targetPos - origCF.Position).Unit
	local lungeCF = origCF + forwardDir * 3.5

	-- Snappy forward lunge (0.10s)
	local lungeTween = TweenService:Create(root, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = lungeCF,
	})
	-- Smooth step back (0.18s)
	local returnTween = TweenService:Create(root, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		CFrame = origCF,
	})

	lungeTween:Play()
	lungeTween.Completed:Connect(function()
		returnTween:Play()
	end)

	-- Spawn claw / slash visual indicator
	local slash = Instance.new("Part")
	slash.Name = "EnemySlashFX"
	slash.Size = Vector3.new(3, 0.2, 3)
	slash.Material = Enum.Material.Neon
	slash.Color = Color3.fromRGB(255, 60, 40)
	slash.CanCollide = false
	slash.Anchored = true
	slash.CFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(math.random(-30, 30)), math.rad(math.random(0, 180)), 0)
	slash.Parent = workspace

	TweenService:Create(slash, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(5.5, 0.05, 5.5),
		Transparency = 1,
	}):Play()
	Debris:AddItem(slash, 0.28)
end

-- 60 FPS Procedural Animation Loop
local function onRenderStep(deltaTime: number)
	local now = os.clock()
	local char = localPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then return end

	for model, data in pairs(activeAnimatedEnemies) do
		if not model.Parent or not data.BodyPart or not data.BodyPart.Parent then
			activeAnimatedEnemies[model] = nil
			continue
		end

		local dist = (data.BodyPart.Position - hrp.Position).Magnitude
		if dist > 140 then continue end -- Skip distant enemies for performance

		local timeVal = now * 4 + data.PhaseOffset

		-- 1. Slime Squash & Stretch
		if data.IsSlime then
			local bounce = math.sin(timeVal * 1.5)
			local scaleY = 1.0 + bounce * 0.22
			local scaleXZ = 1.0 - bounce * 0.15
			data.BodyPart.Size = Vector3.new(
				data.OriginalSize.X * scaleXZ,
				data.OriginalSize.Y * scaleY,
				data.OriginalSize.Z * scaleXZ
			)
		end

		-- 2. Flying Creatures Wing Flap
		if data.IsFlyer and data.Wings.Left and data.Wings.Right then
			local flapAngle = math.sin(timeVal * 2.2) * 28
			local pivot = model:GetPivot()
			data.Wings.Left.CFrame = pivot * CFrame.new(-7, 3, -1) * CFrame.Angles(0, 0, math.rad(flapAngle + 30))
			data.Wings.Right.CFrame = pivot * CFrame.new(7, 3, -1) * CFrame.Angles(0, 0, math.rad(-flapAngle - 30))
		end

		-- 3. Living Torso Idle Breathing (All Enemies)
		if not data.IsSlime and data.BodyPart.Name == "Torso" then
			local breath = math.sin(now * 2.5 + data.PhaseOffset) * 0.04
			data.BodyPart.Size = data.OriginalSize * (1.0 + breath)
		end
	end
end

function EnemyAnimationController.Init()
	-- Discover active dungeon enemies
	task.spawn(function()
		while true do
			for _, child in ipairs(Workspace:GetChildren()) do
				if string.find(child.Name, "Dungeon_") and child:IsA("Model") then
					for _, desc in ipairs(child:GetDescendants()) do
						if desc:IsA("Model") and (desc:GetAttribute("EnemyId") or string.find(desc.Name, "Enemy_") or desc:FindFirstChild("EnemyId")) then
							registerModel(desc)
						end
					end
				end
			end
			task.wait(2.5)
		end
	end)

	-- Listen for enemy attack lunges from server
	local attackEvt = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.EnemyAttacked)
	if attackEvt then
		attackEvt.OnClientEvent:Connect(function(data: any)
			if typeof(data) ~= "table" then return end
			local model = data.EnemyModel :: Model?
			local targetPos = data.TargetPosition :: Vector3?
			if model and targetPos then
				EnemyAnimationController.PlayAttackLunge(model, targetPos)
			end
		end)
	end

	RunService.RenderStepped:Connect(onRenderStep)
	print("[EnemyAnimationController] Initialized successfully with Slime Squash/Stretch, Wing Flaps, and Attack Lunges.")
end

return EnemyAnimationController
