--!strict
--[[
    PetFollowController.luau
    Client-side 3D pet visual follow and orbital animation controller for MAGIA ETERNA.
    Features:
    - Generates stylized 3D companion models (Body, Cute cartoon eyes, Flapping wings/ears, Sparkle aura).
    - 60 FPS smooth orbital physics using RenderStepped with buttery Lerp interpolation.
    - Procedural wing flapping (math.sin) and dynamic vertical bobbing.
    - Overhead companion nameplate with rarity color and bonus stat display.
    - Zero server physics overhead, instant client responsiveness, mobile optimized.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Source"):WaitForChild("shared")
local PetConfig = require(Shared:WaitForChild("Config"):WaitForChild("PetConfig") :: ModuleScript)
local RarityUtils = require(Shared:WaitForChild("Modules"):WaitForChild("RarityUtils") :: ModuleScript)

local Controllers = script.Parent
local DataController = require(Controllers:WaitForChild("DataController") :: ModuleScript)

local PetFollowController = {}
local localPlayer = Players.LocalPlayer
local activePetModels: { [string]: Model } = {}
local petWingParts: { [string]: { Left: BasePart, Right: BasePart } } = {}

local orbitRadius = 6.0
local orbitSpeed = 1.6

-- Color mapping based on pet region
local REGION_PET_COLORS = {
	Bosque = Color3.fromRGB(80, 220, 110),
	Minas = Color3.fromRGB(255, 90, 40),
	Hielo = Color3.fromRGB(90, 215, 255),
	Cripta = Color3.fromRGB(180, 70, 240),
	Cielos = Color3.fromRGB(255, 215, 70),
	Abismo = Color3.fromRGB(230, 40, 130),
}

-- Creates a stylized 3D pet companion model
local function createPetModel(petUuid: string, petId: string, tier: string?): Model
	local petDef = PetConfig.GetPet(petId)
	local petName = petDef and petDef.Name or "Mascota"
	local petRegion = petDef and petDef.Region or "Bosque"
	local petRarity = petDef and petDef.Rarity or "Común"
	local rarityInfo = RarityUtils.GetRarityInfo(petRarity)

	local baseColor = REGION_PET_COLORS[petRegion] or Color3.fromRGB(120, 200, 255)
	if tier == "Golden" then
		baseColor = Color3.fromRGB(255, 215, 50)
	elseif tier == "Rainbow" then
		baseColor = Color3.fromRGB(255, 120, 220)
	end

	local model = Instance.new("Model")
	model.Name = "Pet_" .. petUuid

	-- 1. Main Pet Body (Rounded smooth cube / ball)
	local body = Instance.new("Part")
	body.Name = "PetRoot"
	body.Size = Vector3.new(1.8, 1.8, 1.8)
	body.Shape = (string.find(petName, "Slime") or string.find(petName, "Pinguino")) and Enum.PartType.Ball or Enum.PartType.Block
	body.Material = (tier == "Golden" or tier == "Rainbow" or petRarity == "Legendario" or petRarity == "Mítico") and Enum.Material.Neon or Enum.Material.SmoothPlastic
	body.Color = baseColor
	body.CanCollide = false
	body.CanTouch = false
	body.CanQuery = false
	body.Anchored = true
	body.Parent = model

	-- 2. Cute cartoon eyes
	for eyeIdx, eyeX in ipairs({ -0.42, 0.42 }) do
		local eye = Instance.new("Part")
		eye.Name = "Eye_" .. eyeIdx
		eye.Size = Vector3.new(0.28, 0.45, 0.15)
		eye.Material = Enum.Material.SmoothPlastic
		eye.Color = Color3.fromRGB(15, 15, 20)
		eye.CanCollide = false
		eye.CanTouch = false
		eye.CanQuery = false
		eye.Anchored = true
		eye.Parent = model

		-- Specular white pupil highlight
		local pupil = Instance.new("Part")
		pupil.Name = "Pupil_" .. eyeIdx
		pupil.Size = Vector3.new(0.12, 0.16, 0.08)
		pupil.Material = Enum.Material.Neon
		pupil.Color = Color3.fromRGB(255, 255, 255)
		pupil.CanCollide = false
		pupil.CanTouch = false
		pupil.CanQuery = false
		pupil.Anchored = true
		pupil.Parent = model
	end

	-- 3. Wings for Flying/Mythic pets (Dragons, Angels, Birds, Fairies)
	local isFlyer = string.find(petName, "Dragon") or string.find(petName, "Hada") or string.find(petName, "Buho") or string.find(petName, "Fenix") or string.find(petName, "Angel") or string.find(petName, "Serafin") or string.find(petName, "Murcielago")
	if isFlyer then
		local leftWing = Instance.new("Part")
		leftWing.Name = "LeftWing"
		leftWing.Size = Vector3.new(0.8, 0.15, 0.9)
		leftWing.Material = Enum.Material.Neon
		leftWing.Color = (tier == "Golden") and Color3.fromRGB(255, 235, 120) or baseColor
		leftWing.CanCollide = false
		leftWing.CanTouch = false
		leftWing.Anchored = true
		leftWing.Parent = model

		local rightWing = Instance.new("Part")
		rightWing.Name = "RightWing"
		rightWing.Size = Vector3.new(0.8, 0.15, 0.9)
		rightWing.Material = Enum.Material.Neon
		rightWing.Color = leftWing.Color
		rightWing.CanCollide = false
		rightWing.CanTouch = false
		rightWing.Anchored = true
		rightWing.Parent = model

		petWingParts[petUuid] = { Left = leftWing, Right = rightWing }
	end

	-- 4. Overhead Nameplate BillboardGui
	local bb = Instance.new("BillboardGui")
	bb.Name = "PetBillboard"
	bb.Size = UDim2.new(0, 130, 0, 36)
	bb.StudsOffset = Vector3.new(0, 1.8, 0)
	bb.AlwaysOnTop = false
	bb.MaxDistance = 45
	bb.Parent = body

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.55, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Text = (tier and tier ~= "Normal" and "[" .. tier .. "] " or "") .. petName
	nameLabel.TextColor3 = rarityInfo.Color
	nameLabel.TextStrokeColor3 = Color3.fromRGB(10, 10, 15)
	nameLabel.TextStrokeTransparency = 0.15
	nameLabel.Parent = bb

	local bonusLabel = Instance.new("TextLabel")
	bonusLabel.Size = UDim2.new(1, 0, 0.45, 0)
	bonusLabel.Position = UDim2.new(0, 0, 0.55, 0)
	bonusLabel.BackgroundTransparency = 1
	bonusLabel.TextScaled = true
	bonusLabel.Font = Enum.Font.GothamMedium
	bonusLabel.Text = string.format("✨ +%d%% Magia", petDef and petDef.MagicBonusPercent or 5)
	bonusLabel.TextColor3 = Color3.fromRGB(255, 240, 180)
	bonusLabel.TextStrokeColor3 = Color3.fromRGB(10, 10, 15)
	bonusLabel.TextStrokeTransparency = 0.2
	bonusLabel.Parent = bb

	-- 5. Floating sparkles
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	pe.Color = ColorSequence.new(baseColor)
	pe.Size = NumberSequence.new(0.25, 0.05)
	pe.Rate = 5
	pe.Lifetime = NumberRange.new(0.5, 0.9)
	pe.Speed = NumberRange.new(0.3, 1.0)
	pe.SpreadAngle = Vector2.new(180, 180)
	pe.Parent = body

	model.PrimaryPart = body
	model.Parent = workspace
	return model
end

-- Refreshes visual pet models based on equipped pets in player profile
function PetFollowController.Refresh()
	local data = DataController.GetData()
	local equippedUuids = data and data.EquippedPets or {}
	local equippedSet = {}

	-- Map equipped pet UUIDs to pet data
	local petLookup = {}
	if data and data.Pets then
		for _, p in ipairs(data.Pets) do
			petLookup[p.Uuid] = p
		end
	end

	-- Create missing pet models
	for _, uuid in ipairs(equippedUuids) do
		equippedSet[uuid] = true
		if not activePetModels[uuid] then
			local petInfo = petLookup[uuid]
			local petId = petInfo and petInfo.Id or "Pet_R1_SlimeVerde"
			local tier = petInfo and petInfo.Tier or "Normal"
			activePetModels[uuid] = createPetModel(uuid, petId, tier)
		end
	end

	-- Remove unequipped pet models
	for uuid, petModel in pairs(activePetModels) do
		if not equippedSet[uuid] then
			petModel:Destroy()
			activePetModels[uuid] = nil
			petWingParts[uuid] = nil
		end
	end
end

-- Calculates target CFrame for pet index out of total equipped
local function getPetTargetCFrame(rootCFrame: CFrame, index: number, total: number): CFrame
	local now = os.clock()
	local angleStep = (math.pi * 2) / math.max(1, total)
	local angle = (index * angleStep) + (now * 0.4)

	local offsetX = math.sin(angle) * orbitRadius
	local offsetZ = math.cos(angle) * orbitRadius
	local bobbingY = math.sin(now * 3.5 + index) * 0.38

	local targetPos = rootCFrame.Position + Vector3.new(offsetX, 1.4 + bobbingY, offsetZ)
	local lookTarget = rootCFrame.Position + (rootCFrame.LookVector * 15)
	return CFrame.new(targetPos, lookTarget)
end

-- Updates pet positions and sub-parts each frame (60 FPS)
local function onRenderStep(deltaTime: number)
	local character = localPlayer.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not rootPart then return end

	local data = DataController.GetData()
	if not data then return end

	local now = os.clock()
	local totalEquipped = #data.EquippedPets

	for index, petUuid in ipairs(data.EquippedPets) do
		local petModel = activePetModels[petUuid]
		if petModel and petModel.PrimaryPart then
			local body = petModel.PrimaryPart
			local targetCF = getPetTargetCFrame(rootPart.CFrame, index, totalEquipped)
			local alpha = math.clamp(deltaTime * 10, 0, 1)
			local newCF = body.CFrame:Lerp(targetCF, alpha)
			body.CFrame = newCF

			-- Update eyes and pupils
			local eye1 = petModel:FindFirstChild("Eye_1") :: BasePart?
			local eye2 = petModel:FindFirstChild("Eye_2") :: BasePart?
			local pupil1 = petModel:FindFirstChild("Pupil_1") :: BasePart?
			local pupil2 = petModel:FindFirstChild("Pupil_2") :: BasePart?

			if eye1 then eye1.CFrame = newCF * CFrame.new(-0.42, 0.25, -0.92) end
			if eye2 then eye2.CFrame = newCF * CFrame.new(0.42, 0.25, -0.92) end
			if pupil1 then pupil1.CFrame = newCF * CFrame.new(-0.38, 0.28, -1.0) end
			if pupil2 then pupil2.CFrame = newCF * CFrame.new(0.38, 0.28, -1.0) end

			-- Flap wings procedurally if present
			local wings = petWingParts[petUuid]
			if wings then
				local flapAngle = math.sin(now * 11 + index) * 32
				wings.Left.CFrame = newCF * CFrame.new(-0.95, 0.35, 0.3) * CFrame.Angles(0, 0, math.rad(flapAngle))
				wings.Right.CFrame = newCF * CFrame.new(0.95, 0.35, 0.3) * CFrame.Angles(0, 0, math.rad(-flapAngle))
			end
		end
	end
end

function PetFollowController.Init()
	DataController.OnDataChanged:Connect(function()
		PetFollowController.Refresh()
	end)

	localPlayer.CharacterAdded:Connect(function()
		task.wait(0.3)
		PetFollowController.Refresh()
	end)

	RunService.RenderStepped:Connect(onRenderStep)
	print("[PetFollowController] Initialized successfully with 3D stylized pet models and 60 FPS orbital physics.")
end

return table.freeze(PetFollowController)
