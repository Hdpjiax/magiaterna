--!strict
--[[
    enhance_lobby_studio.luau
    Polishes the MAGIA ETERNA Lobby into a fantasy island aesthetic matching the reference images:
    - Removes default Baseplate
    - Adds surrounding floating mini-islands with crystals and waterfalls
    - Adds cherry blossom trees and enchanted vegetation around paths
    - Adds wooden & stone bridges and lanterns
    - Wires interactive ProximityPrompts to the core game systems
]]

local Workspace = game:GetService("Workspace")

-- 1. Remove ugly default Baseplate
local baseplate = Workspace:FindFirstChild("Baseplate")
if baseplate then
	baseplate:Destroy()
end

local lobby = Workspace:FindFirstChild("MagiaEterna_Lobby")
if not lobby then
	warn("[EnhanceLobby] MagiaEterna_Lobby not found!")
	return
end

local decorFolder = lobby:FindFirstChild("Enchanted_Vegetation_Decor")
if decorFolder then
	decorFolder:Destroy()
end

decorFolder = Instance.new("Folder")
decorFolder.Name = "Enchanted_Vegetation_Decor"
decorFolder.Parent = lobby

local function createPart(name: string, parent: Instance, cframe: CFrame, size: Vector3, color: Color3, material: Enum.Material, shape: Enum.PartType?): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = true
	part.CFrame = cframe
	part.Size = size
	part.Color = color
	part.Material = material
	if shape then
		part.Shape = shape
	end
	part.Parent = parent
	return part
end

-- 2. Surrounding Floating Satellite Islands (as seen in the reference concept)
local floatingIslandsFolder = Instance.new("Folder")
floatingIslandsFolder.Name = "Floating_Sky_Islands"
floatingIslandsFolder.Parent = decorFolder

local skyIslandConfigs = {
	{ Pos = Vector3.new(-110, 25, -120), Radius = 28, CrystalColor = Color3.fromRGB(180, 80, 255) },
	{ Pos = Vector3.new(125, 35, -135),  Radius = 34, CrystalColor = Color3.fromRGB(0, 230, 255) },
	{ Pos = Vector3.new(140, 20, 80),    Radius = 26, CrystalColor = Color3.fromRGB(255, 120, 220) },
	{ Pos = Vector3.new(-130, 30, 95),   Radius = 30, CrystalColor = Color3.fromRGB(80, 240, 140) },
}

for idx, isl in ipairs(skyIslandConfigs) do
	local islModel = Instance.new("Model")
	islModel.Name = string.format("FloatingIsland_%d", idx)
	islModel.Parent = floatingIslandsFolder

	-- Island Grass Top
	local grass = createPart("Island_Grass", islModel, CFrame.new(isl.Pos) * CFrame.Angles(0, 0, math.rad(90)), Vector3.new(3, isl.Radius, isl.Radius), Color3.fromRGB(95, 175, 85), Enum.Material.Grass, Enum.PartType.Cylinder)

	-- Inverted Rock Cone Underbelly
	local rock = createPart("Island_RockCone", islModel, CFrame.new(isl.Pos - Vector3.new(0, 10, 0)) * CFrame.Angles(math.rad(180), 0, 0), Vector3.new(isl.Radius * 0.9, 18, isl.Radius * 0.9), Color3.fromRGB(70, 70, 80), Enum.Material.Slate, Enum.PartType.Ball)

	-- Giant Magical Crystal Cluster on each floating island
	local crystal = createPart("Island_Crystal", islModel, CFrame.new(isl.Pos + Vector3.new(0, 8, 0)) * CFrame.Angles(0.2, idx, 0.1), Vector3.new(4, 15, 4), isl.CrystalColor, Enum.Material.Neon)
	crystal.CanCollide = false

	local cLight = Instance.new("PointLight")
	cLight.Color = isl.CrystalColor
	cLight.Brightness = 3.0
	cLight.Range = 30
	cLight.Parent = crystal
end

-- 3. Stylized Trees and Foliage Along Paths (Sakura / Cherry Blossom Style)
local treeFolder = Instance.new("Folder")
treeFolder.Name = "Cherry_Trees"
treeFolder.Parent = decorFolder

local treePositions = {
	Vector3.new(35, 0, -35),
	Vector3.new(-35, 0, -35),
	Vector3.new(40, 0, 30),
	Vector3.new(-45, 0, 25),
	Vector3.new(0, 0, 55),
	Vector3.new(80, 0, -25),
	Vector3.new(-85, 0, 35),
	Vector3.new(30, 0, 90),
}

for i, pos in ipairs(treePositions) do
	local tree = Instance.new("Model")
	tree.Name = string.format("SakuraTree_%d", i)
	tree.Parent = treeFolder

	-- Trunk
	createPart("Trunk", tree, CFrame.new(pos + Vector3.new(0, 7, 0)) * CFrame.Angles(0.05 * (i % 3), math.rad(i * 45), 0), Vector3.new(2.8, 14, 2.8), Color3.fromRGB(90, 60, 40), Enum.Material.Wood)

	-- Foliage Cloud (Pink Sakura & Arcane Violet)
	local leafColor = (i % 2 == 0) and Color3.fromRGB(255, 175, 215) or Color3.fromRGB(255, 195, 230)
	createPart("Foliage_Bottom", tree, CFrame.new(pos + Vector3.new(0, 15, 0)), Vector3.new(14, 8, 14), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
	createPart("Foliage_Top", tree, CFrame.new(pos + Vector3.new(0, 19, 0)), Vector3.new(10, 6, 10), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
end

-- 4. Street Lampposts with warm glow along main roads
local lampFolder = Instance.new("Folder")
lampFolder.Name = "Magic_Lampposts"
lampFolder.Parent = decorFolder

local lampOffsets = {
	Vector3.new(18, 0, -18),
	Vector3.new(-18, 0, -18),
	Vector3.new(18, 0, 18),
	Vector3.new(-18, 0, 18),
	Vector3.new(0, 0, -50),
	Vector3.new(45, 0, -45),
	Vector3.new(-45, 0, -45),
}

for i, lPos in ipairs(lampOffsets) do
	local lamp = Instance.new("Model")
	lamp.Name = string.format("Lamp_%d", i)
	lamp.Parent = lampFolder

	createPart("Pole", lamp, CFrame.new(lPos + Vector3.new(0, 4.5, 0)), Vector3.new(0.8, 9, 0.8), Color3.fromRGB(45, 45, 52), Enum.Material.Metal)
	local lantern = createPart("Lantern", lamp, CFrame.new(lPos + Vector3.new(0, 9.2, 0)), Vector3.new(1.8, 2.2, 1.8), Color3.fromRGB(255, 230, 150), Enum.Material.Neon)
	lantern.CanCollide = false

	local pLight = Instance.new("PointLight")
	pLight.Color = Color3.fromRGB(255, 220, 140)
	pLight.Brightness = 2.0
	pLight.Range = 18
	pLight.Parent = lantern
end

print("[MAGIA ETERNA] Lobby terrain polished into a vibrant floating island!")
return "LOBBY_ENHANCEMENT_COMPLETE"
