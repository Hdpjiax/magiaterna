--!strict
--[[
    StaffVisualController.luau
    Client-side visual controller that creates, welds, and animates the player's 3D equipped Staff.
    Features:
    - Seamlessly supports both R15 and R6 character rigs.
    - Stylized staff geometry: Shaft, Grip, Ornamental Crown, and Glowing Neon Crystal Tip.
    - Element-based themes (Naturaleza, Fuego, Hielo, Oscuridad, Luz, Vacío) with matching particles and dynamic lighting.
    - Automatic refresh when equipped staff changes in player profile or character respawns.
    - Exposes GetStaffTipPosition() and PulseStaffTip() for spellcasting and beam VFX.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Source"):WaitForChild("shared")
local StaffConfig = require(Shared:WaitForChild("Config"):WaitForChild("StaffConfig") :: ModuleScript)

local Controllers = script.Parent
local DataController = require(Controllers:WaitForChild("DataController") :: ModuleScript)

local StaffVisualController = {}
local localPlayer = Players.LocalPlayer
local currentStaffModel: Model? = nil
local currentTipPart: BasePart? = nil

-- Element visual themes: Color, Material, ParticleTexture
local ELEMENT_THEMES = {
	["Naturaleza"] = {
		Color = Color3.fromRGB(60, 225, 90),
		ShaftColor = Color3.fromRGB(95, 60, 35),
		ShaftMaterial = Enum.Material.Wood,
		LightColor = Color3.fromRGB(80, 255, 110),
	},
	["Fuego"] = {
		Color = Color3.fromRGB(255, 75, 25),
		ShaftColor = Color3.fromRGB(45, 30, 35),
		ShaftMaterial = Enum.Material.Basalt,
		LightColor = Color3.fromRGB(255, 120, 40),
	},
	["Hielo"] = {
		Color = Color3.fromRGB(70, 210, 255),
		ShaftColor = Color3.fromRGB(180, 215, 235),
		ShaftMaterial = Enum.Material.Ice,
		LightColor = Color3.fromRGB(100, 230, 255),
	},
	["Oscuridad"] = {
		Color = Color3.fromRGB(185, 55, 245),
		ShaftColor = Color3.fromRGB(28, 25, 32),
		ShaftMaterial = Enum.Material.Slate,
		LightColor = Color3.fromRGB(200, 75, 255),
	},
	["Luz"] = {
		Color = Color3.fromRGB(255, 220, 60),
		ShaftColor = Color3.fromRGB(240, 235, 225),
		ShaftMaterial = Enum.Material.Marble,
		LightColor = Color3.fromRGB(255, 240, 100),
	},
	["Vacío"] = {
		Color = Color3.fromRGB(245, 45, 125),
		ShaftColor = Color3.fromRGB(20, 18, 24),
		ShaftMaterial = Enum.Material.Basalt,
		LightColor = Color3.fromRGB(255, 65, 150),
	},
	["Vacio"] = {
		Color = Color3.fromRGB(245, 45, 125),
		ShaftColor = Color3.fromRGB(20, 18, 24),
		ShaftMaterial = Enum.Material.Basalt,
		LightColor = Color3.fromRGB(255, 65, 150),
	},
}

-- Removes any currently equipped visual staff
local function clearCurrentStaff()
	if currentStaffModel then
		currentStaffModel:Destroy()
		currentStaffModel = nil
		currentTipPart = nil
	end
end

-- Builds and attaches a 3D stylized staff to the character's right hand
local function buildAndAttachStaff(staffId: string)
	clearCurrentStaff()

	local character = localPlayer.Character
	if not character then return end

	-- Find right hand part (R15 RightHand or R6 Right Arm)
	local rightGrip = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if not rightGrip or not rightGrip:IsA("BasePart") then return end

	local staffDef = StaffConfig.GetStaff(staffId)
	local element = staffDef and staffDef.Element or "Naturaleza"
	local theme = ELEMENT_THEMES[element] or ELEMENT_THEMES.Naturaleza

	local model = Instance.new("Model")
	model.Name = "EquippedStaffVisual"

	-- 1. Staff Shaft (Handle)
	local shaft = Instance.new("Part")
	shaft.Name = "Shaft"
	shaft.Size = Vector3.new(0.28, 4.2, 0.28)
	shaft.Material = theme.ShaftMaterial
	shaft.Color = theme.ShaftColor
	shaft.CanCollide = false
	shaft.Massless = true
	shaft.Parent = model

	-- 2. Golden Grip Accent
	local grip = Instance.new("Part")
	grip.Name = "GripRing"
	grip.Size = Vector3.new(0.34, 0.6, 0.34)
	grip.Material = Enum.Material.Metal
	grip.Color = Color3.fromRGB(225, 185, 50)
	grip.CanCollide = false
	grip.Massless = true
	grip.Parent = model

	-- 3. Crown / Headpiece Collar
	local collar = Instance.new("Part")
	collar.Name = "CrystalCollar"
	collar.Size = Vector3.new(0.65, 0.5, 0.65)
	collar.Material = Enum.Material.Metal
	collar.Color = Color3.fromRGB(235, 195, 60)
	collar.CanCollide = false
	collar.Massless = true
	collar.Parent = model

	-- 4. Radiant Magic Crystal Tip
	local tip = Instance.new("Part")
	tip.Name = "StaffTip"
	tip.Size = Vector3.new(0.85, 1.3, 0.85)
	tip.Material = Enum.Material.Neon
	tip.Color = theme.Color
	tip.CanCollide = false
	tip.Massless = true
	tip.Parent = model

	-- Light & Particles on the crystal
	local light = Instance.new("PointLight")
	light.Name = "TipLight"
	light.Color = theme.LightColor
	light.Range = 9
	light.Brightness = 2.2
	light.Parent = tip

	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Name = "CrystalSparkles"
	sparkles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkles.Color = ColorSequence.new(theme.Color)
	sparkles.Size = NumberSequence.new(0.35, 0.05)
	sparkles.Rate = 6
	sparkles.Speed = NumberRange.new(0.5, 1.8)
	sparkles.Lifetime = NumberRange.new(0.6, 1.2)
	sparkles.SpreadAngle = Vector2.new(180, 180)
	sparkles.Parent = tip

	-- Position sub-parts relative to shaft
	local shaftCF = rightGrip.CFrame * CFrame.new(0, -0.4, -0.2) * CFrame.Angles(math.rad(85), 0, 0)
	shaft.CFrame = shaftCF
	grip.CFrame = shaftCF * CFrame.new(0, -0.5, 0)
	collar.CFrame = shaftCF * CFrame.new(0, 1.85, 0)
	tip.CFrame = shaftCF * CFrame.new(0, 2.45, 0)

	-- Weld parts internally
	local function weld(p1: BasePart, p2: BasePart)
		local wc = Instance.new("WeldConstraint")
		wc.Part0 = p1
		wc.Part1 = p2
		wc.Parent = p1
	end

	weld(shaft, grip)
	weld(shaft, collar)
	weld(shaft, tip)

	-- Weld the entire staff to player's hand
	local handWeld = Instance.new("WeldConstraint")
	handWeld.Name = "HandWeld"
	handWeld.Part0 = rightGrip
	handWeld.Part1 = shaft
	handWeld.Parent = shaft

	model.PrimaryPart = shaft
	model.Parent = character
	currentStaffModel = model
	currentTipPart = tip
end

-- Refreshes the staff from player profile data
function StaffVisualController.Refresh()
	local profile = DataController.GetProfile()
	local staffId = profile and profile.EquippedStaff or "Staff_R1_001_RamaAprendiz"
	buildAndAttachStaff(staffId)
end

-- Returns the world position of the staff crystal tip
function StaffVisualController.GetStaffTipPosition(): Vector3?
	if currentTipPart and currentTipPart.Parent then
		return currentTipPart.Position
	end
	local char = localPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	return hrp and (hrp.Position + hrp.CFrame.LookVector * 2 + Vector3.new(0, 1, 0)) or nil
end

-- Flashes the staff tip with a radiant punch on spellcast
function StaffVisualController.PulseStaffTip(customColor: Color3?)
	if not currentTipPart then return end
	local light = currentTipPart:FindFirstChild("TipLight") :: PointLight?
	if light then
		local origBrightness = 2.2
		light.Brightness = 5.5
		TweenService:Create(light, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = origBrightness,
		}):Play()
	end

	local origSize = currentTipPart.Size
	currentTipPart.Size = origSize * 1.35
	TweenService:Create(currentTipPart, TweenInfo.new(0.20, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = origSize,
	}):Play()
end

function StaffVisualController.Init()
	-- Refresh when character spawns or respawns
	localPlayer.CharacterAdded:Connect(function()
		task.wait(0.3)
		StaffVisualController.Refresh()
	end)

	-- Refresh when profile data changes (equipped staff changes)
	DataController.OnDataChanged:Connect(function()
		StaffVisualController.Refresh()
	end)

	-- Initial load if character already loaded
	if localPlayer.Character then
		task.defer(function()
			StaffVisualController.Refresh()
		end)
	end

	print("[StaffVisualController] Initialized successfully with 3D staff welds and elemental themes.")
end

return StaffVisualController
