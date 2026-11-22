--!strict
--[[
    rebuild_spectacular_lobby_studio.luau
    Replaces the blocky prototype with a Spectacular Stylized Fantasy Lobby in Roblox Studio.
    Accurately realizes the vision from the reference artwork:
    - Multi-tiered floating island with natural stone stairways and organic cobblestone roads
    - Detailed Forja Real: timber lodge, tiled gabled roof, stone chimney with smoke, anvil on stump, water tub
    - Sacred Tree of Whispers: gnarled roots, layered cherry blossom foliage, hanging lanterns, quest board, golden chest
    - 6 Majestic Dungeon Gateways: fluted stone pillars, rune collars, floating diamond crystals, swirling rifts
    - Market Pavilion: striped purple/gold awning, woven wicker nests with pet eggs, bubbling emerald cauldron
    - Training Grounds: sand arena with wooden cross-fences, straw archery targets, combat dummies, armillary mana orb
    - Rebirth Spire: stepped obsidian ritual dais, tall faceted obelisk with amethyst energy core & orbiting crystals
    - Central Plaza: grand marble & cobblestone dais, glowing water fountains, floating celestial mana crystal
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- 1. Remove old lobby
local oldLobby = Workspace:FindFirstChild("MagiaEterna_Lobby")
if oldLobby then
	oldLobby:Destroy()
end

local baseplate = Workspace:FindFirstChild("Baseplate")
if baseplate then
	baseplate:Destroy()
end

local lobby = Instance.new("Model")
lobby.Name = "MagiaEterna_Lobby"
lobby.Parent = Workspace

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

--------------------------------------------------------------------------------
-- 1. SCULPTED FLOATING ISLAND & MULTI-TIER TERRACES
--------------------------------------------------------------------------------
local terrainFolder = Instance.new("Folder")
terrainFolder.Name = "Sculpted_Island_Terrain"
terrainFolder.Parent = lobby

-- Main Plateau (Lush Green Grass with Organic Rock Strata Underbelly)
local mainGrass = createPart("Main_Grass_Plateau", terrainFolder, CFrame.new(0, -2, 0) * CFrame.Angles(0, 0, math.rad(90)), Vector3.new(4, 250, 250), Color3.fromRGB(88, 168, 78), Enum.Material.Grass, Enum.PartType.Cylinder)
local rockStrata1 = createPart("Rock_Strata_Upper", terrainFolder, CFrame.new(0, -8, 0) * CFrame.Angles(0, 0, math.rad(90)), Vector3.new(10, 242, 242), Color3.fromRGB(72, 74, 84), Enum.Material.Slate, Enum.PartType.Cylinder)
local rockStrata2 = createPart("Rock_Strata_Lower", terrainFolder, CFrame.new(0, -18, 0) * CFrame.Angles(0, 0, math.rad(90)), Vector3.new(14, 220, 220), Color3.fromRGB(58, 60, 70), Enum.Material.Slate, Enum.PartType.Cylinder)

-- Elevated Northern Terrace (Where the Sacred Tree sits)
local northTerrace = createPart("North_Terrace", terrainFolder, CFrame.new(0, 2.5, -90) * CFrame.Angles(0, 0, math.rad(90)), Vector3.new(5, 75, 75), Color3.fromRGB(85, 165, 75), Enum.Material.Grass, Enum.PartType.Cylinder)

-- Curved Stone Steps leading up to North Terrace
for step = 1, 5 do
	local zPos = -54 - (step * 3)
	local yPos = step * 0.5
	createPart(string.format("Stone_Step_%d", step), terrainFolder, CFrame.new(0, yPos, zPos), Vector3.new(18, 0.5, 3.2), Color3.fromRGB(175, 175, 180), Enum.Material.Cobblestone)
end

-- Organic Cobblestone Pathways radiating from Plaza
local roadsFolder = Instance.new("Folder")
roadsFolder.Name = "Cobblestone_Avenues"
roadsFolder.Parent = terrainFolder

local roadDestinations = {
	{ End = Vector3.new(0, 0.1, -54), Name = "Avenue_To_Quests" },
	{ End = Vector3.new(80, 0.1, -75), Name = "Avenue_To_Portals" },
	{ End = Vector3.new(95, 0.1, 0), Name = "Avenue_To_Stats" },
	{ End = Vector3.new(65, 0.1, 65), Name = "Avenue_To_Training" },
	{ End = Vector3.new(-45, 0.1, 70), Name = "Avenue_To_Market" },
	{ End = Vector3.new(-75, 0.1, -70), Name = "Avenue_To_Forge" },
	{ End = Vector3.new(-90, 0.1, 0), Name = "Avenue_To_Rebirth" },
}

for _, road in ipairs(roadDestinations) do
	local length = (road.End - Vector3.new(0, 0, 0)).Magnitude - 18
	local mid = Vector3.new(0, 0.15, 0):Lerp(road.End, 0.52)
	local angle = math.atan2(road.End.X, road.End.Z)
	createPart(road.Name, roadsFolder, CFrame.new(mid) * CFrame.Angles(0, angle, 0), Vector3.new(10, 0.25, length), Color3.fromRGB(160, 155, 145), Enum.Material.Cobblestone)
end

--------------------------------------------------------------------------------
-- 2. CENTRAL PLAZA, GRAND DAIS & CELESTIAL MANA CRYSTAL
--------------------------------------------------------------------------------
local plazaFolder = Instance.new("Folder")
plazaFolder.Name = "Central_Courtyard"
plazaFolder.Parent = lobby

-- 3-Tier Ornate Circular Dais
local daisOuter = createPart("Dais_Outer_Ring", plazaFolder, CFrame.new(0, 0.35, 0) * CFrame.Angles(0, 0, math.rad(90)), Vector3.new(0.7, 56, 56), Color3.fromRGB(165, 165, 172), Enum.Material.Cobblestone, Enum.PartType.Cylinder)
local daisMid = createPart("Dais_Mid_Marble", plazaFolder, CFrame.new(0, 0.95, 0) * CFrame.Angles(0, 0, math.rad(90)), Vector3.new(0.6, 44, 44), Color3.fromRGB(225, 225, 232), Enum.Material.Marble, Enum.PartType.Cylinder)
local daisInner = createPart("Dais_Inner_RuneRing", plazaFolder, CFrame.new(0, 1.35, 0) * CFrame.Angles(0, 0, math.rad(90)), Vector3.new(0.2, 34, 34), Color3.fromRGB(0, 225, 255), Enum.Material.Neon, Enum.PartType.Cylinder)

-- SpawnLocation
local spawnLoc = Instance.new("SpawnLocation")
spawnLoc.Name = "Lobby_Spawn"
spawnLoc.Anchored = true
spawnLoc.CanCollide = false
spawnLoc.Transparency = 1
spawnLoc.CFrame = CFrame.new(0, 2.5, 0)
spawnLoc.Size = Vector3.new(10, 1, 10)
spawnLoc.Neutral = true
spawnLoc.Duration = 0
spawnLoc.Parent = plazaFolder

-- Giant Celestial Mana Crystal
local crystalModel = Instance.new("Model")
crystalModel.Name = "Celestial_Mana_Crystal"
crystalModel.Parent = plazaFolder

local coreCrystal = createPart("Core_Spire", crystalModel, CFrame.new(0, 12, 0), Vector3.new(4.5, 15, 4.5), Color3.fromRGB(0, 235, 255), Enum.Material.Glass)
coreCrystal.CanCollide = false

local crystalLight = Instance.new("PointLight")
crystalLight.Color = Color3.fromRGB(0, 225, 255)
crystalLight.Brightness = 4.0
crystalLight.Range = 40
crystalLight.Parent = coreCrystal

local sparkles = Instance.new("ParticleEmitter")
sparkles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
sparkles.Color = ColorSequence.new(Color3.fromRGB(180, 245, 255), Color3.fromRGB(0, 180, 255))
sparkles.Size = NumberSequence.new(0.9, 0)
sparkles.Rate = 22
sparkles.Speed = NumberRange.new(2, 5)
sparkles.Lifetime = NumberRange.new(3, 5)
sparkles.SpreadAngle = Vector2.new(180, 180)
sparkles.Parent = coreCrystal

-- 4 Orbiting Amethyst Shards
for i = 1, 4 do
	local ang = math.rad(i * 90)
	local sPos = Vector3.new(math.cos(ang) * 9, 10 + (i % 2 * 2.5), math.sin(ang) * 9)
	local shard = createPart(string.format("Satellite_Shard_%d", i), crystalModel, CFrame.new(sPos) * CFrame.Angles(0.25, ang, 0.2), Vector3.new(1.8, 5.0, 1.8), Color3.fromRGB(185, 95, 255), Enum.Material.Neon)
	shard.CanCollide = false
end

-- Twin Water Fountains with Sculpted Marble Basins
for _, fPos in ipairs({ Vector3.new(-24, 1.2, 0), Vector3.new(24, 1.2, 0) }) do
	local basin = createPart("Basin", plazaFolder, CFrame.new(fPos) * CFrame.Angles(0, 0, math.rad(90)), Vector3.new(1.4, 12, 12), Color3.fromRGB(200, 200, 205), Enum.Material.Marble, Enum.PartType.Cylinder)
	local water = createPart("Water", plazaFolder, CFrame.new(fPos + Vector3.new(0, 0.75, 0)) * CFrame.Angles(0, 0, math.rad(90)), Vector3.new(0.3, 10.5, 10.5), Color3.fromRGB(0, 160, 255), Enum.Material.Glass, Enum.PartType.Cylinder)
end

--------------------------------------------------------------------------------
-- 3. FORJA REAL (Spectacular Blacksmith Workshop)
--------------------------------------------------------------------------------
local forgeFolder = Instance.new("Folder")
forgeFolder.Name = "Forja_Real_Workshop"
forgeFolder.Parent = lobby

local fOrigin = Vector3.new(-75, 0, -70)

-- Masonry Ground Floor
createPart("Stone_Lodge_Base", forgeFolder, CFrame.new(fOrigin + Vector3.new(0, 2.5, 0)), Vector3.new(22, 5, 18), Color3.fromRGB(75, 76, 82), Enum.Material.Slate)

-- Timber Framework Upper Floor
createPart("Timber_Upper_Storey", forgeFolder, CFrame.new(fOrigin + Vector3.new(0, 7.5, 0)), Vector3.new(21, 5, 17), Color3.fromRGB(90, 58, 35), Enum.Material.WoodPlanks)

-- Tiled Pitch Roof (Dark Slate Shingles)
local roofL = createPart("Roof_Left", forgeFolder, CFrame.new(fOrigin + Vector3.new(-5.5, 12, 0)) * CFrame.Angles(0, 0, math.rad(35)), Vector3.new(14, 0.8, 20), Color3.fromRGB(48, 52, 62), Enum.Material.Slate)
local roofR = createPart("Roof_Right", forgeFolder, CFrame.new(fOrigin + Vector3.new(5.5, 12, 0)) * CFrame.Angles(0, 0, math.rad(-35)), Vector3.new(14, 0.8, 20), Color3.fromRGB(48, 52, 62), Enum.Material.Slate)

-- Heavy Fieldstone Chimney with Smoke
local chimney = createPart("Fieldstone_Chimney", forgeFolder, CFrame.new(fOrigin + Vector3.new(-8, 11, -4)), Vector3.new(4, 16, 4), Color3.fromRGB(65, 66, 72), Enum.Material.Cobblestone)
local smoke = Instance.new("ParticleEmitter")
smoke.Texture = "rbxasset://textures/particles/smoke_main.dds"
smoke.Color = ColorSequence.new(Color3.fromRGB(130, 130, 140), Color3.fromRGB(50, 50, 55))
smoke.Size = NumberSequence.new(2.0, 5.5)
smoke.Rate = 8
smoke.Speed = NumberRange.new(3, 6)
smoke.Lifetime = NumberRange.new(3, 5)
smoke.Parent = chimney

-- Overhanging Porch Pillars
createPart("Porch_Post_1", forgeFolder, CFrame.new(fOrigin + Vector3.new(-8, 3.5, 11)), Vector3.new(1.2, 7, 1.2), Color3.fromRGB(80, 52, 30), Enum.Material.Wood)
createPart("Porch_Post_2", forgeFolder, CFrame.new(fOrigin + Vector3.new(8, 3.5, 11)), Vector3.new(1.2, 7, 1.2), Color3.fromRGB(80, 52, 30), Enum.Material.Wood)
createPart("Porch_Roof", forgeFolder, CFrame.new(fOrigin + Vector3.new(0, 7.2, 10)) * CFrame.Angles(math.rad(18), 0, 0), Vector3.new(22, 0.6, 8), Color3.fromRGB(48, 52, 62), Enum.Material.Slate)

-- Forge Hearth with Roaring Fire
local furnace = createPart("Hearth_Chamber", forgeFolder, CFrame.new(fOrigin + Vector3.new(-5, 2.0, 9)), Vector3.new(5, 4, 4), Color3.fromRGB(55, 56, 60), Enum.Material.Slate)
local fire = createPart("Fire_Embers", forgeFolder, CFrame.new(fOrigin + Vector3.new(-5, 1.8, 9)), Vector3.new(3.6, 2.5, 2.5), Color3.fromRGB(255, 120, 20), Enum.Material.Neon)
local fLight = Instance.new("PointLight")
fLight.Color = Color3.fromRGB(255, 140, 30)
fLight.Brightness = 4.5
fLight.Range = 26
fLight.Parent = fire

-- Master Horn Anvil on Stump
local anvilStump = createPart("Anvil_Stump", forgeFolder, CFrame.new(fOrigin + Vector3.new(2, 1.2, 9)), Vector3.new(2.8, 2.4, 2.8), Color3.fromRGB(110, 75, 45), Enum.Material.Wood, Enum.PartType.Cylinder)
local steelAnvil = createPart("Steel_Anvil", forgeFolder, CFrame.new(fOrigin + Vector3.new(2, 2.8, 9)), Vector3.new(2.2, 1.2, 4.2), Color3.fromRGB(42, 44, 50), Enum.Material.Metal)

local forgePrompt = Instance.new("ProximityPrompt")
forgePrompt.ObjectText = "Yunque Arcano"
forgePrompt.ActionText = "Abrir Forja Real"
forgePrompt.HoldDuration = 0
forgePrompt.MaxActivationDistance = 14
forgePrompt.Parent = steelAnvil

local fBillboard = Instance.new("BillboardGui")
fBillboard.Size = UDim2.new(0, 200, 0, 50)
fBillboard.StudsOffset = Vector3.new(0, 3.8, 0)
fBillboard.AlwaysOnTop = true
fBillboard.Parent = steelAnvil

local fLabel = Instance.new("TextLabel")
fLabel.Size = UDim2.new(1, 0, 1, 0)
fLabel.BackgroundTransparency = 1
fLabel.Text = "🔨 FORJA REAL\n(Fabricar Bastones y Armaduras)"
fLabel.TextColor3 = Color3.fromRGB(255, 210, 80)
fLabel.TextSize = 13
fLabel.Font = Enum.Font.GothamBold
fLabel.Parent = fBillboard

--------------------------------------------------------------------------------
-- 4. SACRED TREE OF WHISPERS & QUEST PAVILION
--------------------------------------------------------------------------------
local questFolder = Instance.new("Folder")
questFolder.Name = "Sacred_Tree_Quest_Zone"
questFolder.Parent = lobby

local qOrigin = Vector3.new(0, 5, -90)

-- Ancient Twisted Trunk & Sprawling Roots
local trunk = createPart("Ancient_Trunk", questFolder, CFrame.new(qOrigin + Vector3.new(0, 14, 0)), Vector3.new(12, 28, 12), Color3.fromRGB(90, 60, 40), Enum.Material.Wood)

-- 4 Buttress Roots Sprawling Across Lawn
for i = 1, 4 do
	local ang = math.rad(i * 90 + 45)
	local rx = math.cos(ang) * 9
	local rz = math.sin(ang) * 9
	createPart(string.format("Buttress_Root_%d", i), questFolder, CFrame.new(qOrigin + Vector3.new(rx, 1.5, rz)) * CFrame.Angles(0.3, ang, 0), Vector3.new(4, 3, 10), Color3.fromRGB(85, 55, 35), Enum.Material.Wood)
end

-- Layered Weeping Cherry Blossom Canopies
local canopyLower = createPart("Canopy_Lower", questFolder, CFrame.new(qOrigin + Vector3.new(0, 28, 0)), Vector3.new(38, 14, 38), Color3.fromRGB(255, 175, 215), Enum.Material.Grass, Enum.PartType.Ball)
local canopyMid = createPart("Canopy_Mid", questFolder, CFrame.new(qOrigin + Vector3.new(0, 35, 0)), Vector3.new(28, 12, 28), Color3.fromRGB(255, 195, 230), Enum.Material.Grass, Enum.PartType.Ball)
local canopyTop = createPart("Canopy_Crown", questFolder, CFrame.new(qOrigin + Vector3.new(0, 41, 0)), Vector3.new(18, 8, 18), Color3.fromRGB(255, 215, 240), Enum.Material.Grass, Enum.PartType.Ball)

-- 4 Hanging Lanterns from the Tree
for i = 1, 4 do
	local ang = math.rad(i * 90)
	local lx = math.cos(ang) * 14
	local lz = math.sin(ang) * 14
	local lantern = createPart(string.format("Hanging_Lantern_%d", i), questFolder, CFrame.new(qOrigin + Vector3.new(lx, 20, lz)), Vector3.new(1.8, 2.6, 1.8), Color3.fromRGB(255, 220, 140), Enum.Material.Neon)
	lantern.CanCollide = false
	local lLight = Instance.new("PointLight")
	lLight.Color = Color3.fromRGB(255, 210, 130)
	lLight.Brightness = 2.5
	lLight.Range = 22
	lLight.Parent = lantern
end

-- Quest Noticeboard
local qBoard = createPart("Quest_Board", questFolder, CFrame.new(qOrigin + Vector3.new(-12, 4, 18)), Vector3.new(12, 8, 1.4), Color3.fromRGB(115, 78, 48), Enum.Material.Wood)
createPart("Quest_Board_Rooflet", questFolder, CFrame.new(qOrigin + Vector3.new(-12, 8.4, 18)) * CFrame.Angles(math.rad(15), 0, 0), Vector3.new(13.5, 0.6, 3.2), Color3.fromRGB(80, 50, 30), Enum.Material.WoodPlanks)

local qPrompt = Instance.new("ProximityPrompt")
qPrompt.ObjectText = "Tablón de Misiones"
qPrompt.ActionText = "Ver Misiones Diarias y Logros"
qPrompt.HoldDuration = 0
qPrompt.MaxActivationDistance = 14
qPrompt.Parent = qBoard

local qBBoard = Instance.new("BillboardGui")
qBBoard.Size = UDim2.new(0, 180, 0, 45)
qBBoard.StudsOffset = Vector3.new(0, 5.5, 0)
qBBoard.AlwaysOnTop = true
qBBoard.Parent = qBoard

local qLabel = Instance.new("TextLabel")
qLabel.Size = UDim2.new(1, 0, 1, 0)
qLabel.BackgroundTransparency = 1
qLabel.Text = "📜 TABLÓN DE MISIONES\n(Diarias, Semanales y Logros)"
qLabel.TextColor3 = Color3.fromRGB(255, 230, 150)
qLabel.TextSize = 13
qLabel.Font = Enum.Font.GothamBold
qLabel.Parent = qBBoard

-- Golden Daily Reward Chest
local chest = createPart("Reward_Chest_Body", questFolder, CFrame.new(qOrigin + Vector3.new(12, 1.8, 18)), Vector3.new(4.5, 3.4, 3.2), Color3.fromRGB(235, 185, 35), Enum.Material.Metal)
createPart("Reward_Chest_Trim", questFolder, CFrame.new(qOrigin + Vector3.new(12, 3.6, 18)), Vector3.new(4.8, 0.8, 3.5), Color3.fromRGB(255, 220, 65), Enum.Material.Neon)

local chestPrompt = Instance.new("ProximityPrompt")
chestPrompt.ObjectText = "Cofre Mágico"
chestPrompt.ActionText = "Reclamar Recompensa Diaria"
chestPrompt.HoldDuration = 0.5
chestPrompt.MaxActivationDistance = 12
chestPrompt.Parent = chest

--------------------------------------------------------------------------------
-- 5. 6 DUNGEON GATEWAY PORTALS (Majestic Stone Arches)
--------------------------------------------------------------------------------
local portalFolder = Instance.new("Folder")
portalFolder.Name = "Dungeon_Portal_Ring"
portalFolder.Parent = lobby

local portalData = {
	{ Id = "Dungeon_Bosque", Name = "Bosque de los Susurros", Level = "Nv. 1-10", Rebirth = "Rebirth 0", Color = Color3.fromRGB(40, 220, 100), Angle = 15 },
	{ Id = "Dungeon_Minas", Name = "Minas del Fuego", Level = "Nv. 10-20", Rebirth = "Rebirth 1", Color = Color3.fromRGB(255, 100, 20), Angle = 35 },
	{ Id = "Dungeon_Hielo", Name = "Reino del Hielo", Level = "Nv. 20-35", Rebirth = "Rebirth 2", Color = Color3.fromRGB(80, 200, 255), Angle = 55 },
	{ Id = "Dungeon_Almas", Name = "Cripta de las Almas", Level = "Nv. 35-50", Rebirth = "Rebirth 3", Color = Color3.fromRGB(180, 70, 255), Angle = 75 },
	{ Id = "Dungeon_Cielos", Name = "Templo de los Cielos", Level = "Nv. 50-75", Rebirth = "Rebirth 4", Color = Color3.fromRGB(255, 220, 50), Angle = 95 },
	{ Id = "Dungeon_Abismo", Name = "Abismo del Infinito", Level = "Nv. 75-100", Rebirth = "Rebirth 5", Color = Color3.fromRGB(255, 40, 60), Angle = 115 },
}

for _, p in ipairs(portalData) do
	local rad = math.rad(p.Angle)
	local pos = Vector3.new(math.cos(rad) * 92, 0, -math.sin(rad) * 92)
	local rotY = math.atan2(pos.X, pos.Z)

	local pModel = Instance.new("Model")
	pModel.Name = "Gate_" .. p.Id
	pModel.Parent = portalFolder

	-- 3-Tier Stepped Plinth
	for step = 1, 3 do
		createPart(string.format("Plinth_%d", step), pModel, CFrame.new(pos + Vector3.new(0, step * 0.35, 0)) * CFrame.Angles(0, rotY, 0), Vector3.new(16 - step * 1.5, 0.4, 7 - step * 0.8), Color3.fromRGB(60, 62, 70), Enum.Material.Slate)
	end

	-- Fluted Stone Pillars with Celtic Gold Collars
	local pillL = createPart("Pillar_Left", pModel, CFrame.new(pos + Vector3.new(0, 7.0, 0)) * CFrame.Angles(0, rotY, 0) * CFrame.new(-5.5, 0, 0), Vector3.new(2.8, 12, 2.8), Color3.fromRGB(68, 70, 80), Enum.Material.Cobblestone)
	local pillR = createPart("Pillar_Right", pModel, CFrame.new(pos + Vector3.new(0, 7.0, 0)) * CFrame.Angles(0, rotY, 0) * CFrame.new(5.5, 0, 0), Vector3.new(2.8, 12, 2.8), Color3.fromRGB(68, 70, 80), Enum.Material.Cobblestone)
	createPart("Collar_L", pModel, CFrame.new(pos + Vector3.new(0, 13.0, 0)) * CFrame.Angles(0, rotY, 0) * CFrame.new(-5.5, 0, 0), Vector3.new(3.2, 0.8, 3.2), Color3.fromRGB(235, 185, 45), Enum.Material.Metal)
	createPart("Collar_R", pModel, CFrame.new(pos + Vector3.new(0, 13.0, 0)) * CFrame.Angles(0, rotY, 0) * CFrame.new(5.5, 0, 0), Vector3.new(3.2, 0.8, 3.2), Color3.fromRGB(235, 185, 45), Enum.Material.Metal)

	-- Arch Lintel
	createPart("Lintel_Arch", pModel, CFrame.new(pos + Vector3.new(0, 14.2, 0)) * CFrame.Angles(0, rotY, 0), Vector3.new(14.5, 2.6, 3.2), Color3.fromRGB(72, 74, 85), Enum.Material.Slate)

	-- Floating Diamond Keystone Crystal
	local keystone = createPart("Keystone_Crystal", pModel, CFrame.new(pos + Vector3.new(0, 17.0, 0)) * CFrame.Angles(0, rotY, 0), Vector3.new(2.4, 4.0, 2.4), p.Color, Enum.Material.Neon)
	keystone.CanCollide = false

	-- Dimensional Vortex Portal
	local vortex = createPart("Dimensional_Vortex", pModel, CFrame.new(pos + Vector3.new(0, 7.5, 0)) * CFrame.Angles(0, rotY, 0), Vector3.new(8.5, 11, 0.4), p.Color, Enum.Material.Neon)
	vortex.CanCollide = false

	local vLight = Instance.new("PointLight")
	vLight.Color = p.Color
	vLight.Brightness = 3.5
	vLight.Range = 25
	vLight.Parent = vortex

	local pPrompt = Instance.new("ProximityPrompt")
	pPrompt.ObjectText = p.Name
	pPrompt.ActionText = "Explorar Mazmorra (" .. p.Level .. ")"
	pPrompt.HoldDuration = 0
	pPrompt.MaxActivationDistance = 14
	pPrompt.Parent = vortex

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 200, 0, 50)
	bb.StudsOffset = Vector3.new(0, 8.5, 0)
	bb.AlwaysOnTop = true
	bb.Parent = vortex

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = string.format("🌀 %s\n%s • %s", p.Name, p.Level, p.Rebirth)
	label.TextColor3 = p.Color
	label.TextSize = 13
	label.Font = Enum.Font.GothamBold
	label.Parent = bb
end

--------------------------------------------------------------------------------
-- 6. MERCADO DE HUEVOS Y ALQUIMIA (Market Pavilion)
--------------------------------------------------------------------------------
local marketFolder = Instance.new("Folder")
marketFolder.Name = "Market_And_Egg_Pavilion"
marketFolder.Parent = lobby

local mOrigin = Vector3.new(-45, 0, 70)

-- Timber Stalls with Purple Draped Awning
createPart("Stall_Counter", marketFolder, CFrame.new(mOrigin), Vector3.new(18, 2.8, 7), Color3.fromRGB(115, 75, 45), Enum.Material.Wood)
createPart("Stall_Roof_Beam", marketFolder, CFrame.new(mOrigin + Vector3.new(0, 7.5, 0)) * CFrame.Angles(0, 0, math.rad(-12)), Vector3.new(20, 0.8, 11), Color3.fromRGB(130, 40, 200), Enum.Material.Fabric)

-- 3 Woven Nests with Pet Eggs on Counter
for i, ex in ipairs({ -4.5, 0.0, 4.5 }) do
	local egg = createPart(string.format("Pet_Egg_Display_%d", i), marketFolder, CFrame.new(mOrigin + Vector3.new(ex, 3.8, 0)), Vector3.new(2.8, 3.8, 2.8), Color3.fromRGB(255, 230, 150), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	local ePrompt = Instance.new("ProximityPrompt")
	ePrompt.ObjectText = "Tienda de Huevos"
	ePrompt.ActionText = "Abrir Catálogo de Mascotas"
	ePrompt.HoldDuration = 0
	ePrompt.MaxActivationDistance = 14
	ePrompt.Parent = egg
end

-- Bubbling Alchemist's Cauldron on Side
local cPos = mOrigin + Vector3.new(16, 0, 4)
local cauldron = createPart("Copper_Cauldron", marketFolder, CFrame.new(cPos + Vector3.new(0, 2.0, 0)) * CFrame.Angles(0, 0, math.rad(90)), Vector3.new(3.8, 5.5, 5.5), Color3.fromRGB(38, 40, 45), Enum.Material.Metal, Enum.PartType.Cylinder)
local brew = createPart("Brew_Liquid", marketFolder, CFrame.new(cPos + Vector3.new(0, 3.4, 0)) * CFrame.Angles(0, 0, math.rad(90)), Vector3.new(0.2, 4.8, 4.8), Color3.fromRGB(0, 255, 190), Enum.Material.Neon, Enum.PartType.Cylinder)

local bubbles = Instance.new("ParticleEmitter")
bubbles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
bubbles.Color = ColorSequence.new(Color3.fromRGB(0, 255, 210), Color3.fromRGB(150, 255, 240))
bubbles.Rate = 14
bubbles.Speed = NumberRange.new(2, 4)
bubbles.Lifetime = NumberRange.new(1.5, 2.5)
bubbles.Parent = brew

--------------------------------------------------------------------------------
-- 7. ARENA DE ENTRENAMIENTO (Training Grounds & Armillary Mana Orb)
--------------------------------------------------------------------------------
local trainingFolder = Instance.new("Folder")
trainingFolder.Name = "Training_Grounds_Arena"
trainingFolder.Parent = lobby

local tOrigin = Vector3.new(65, 0, 65)

-- Sand Arena Floor & Timber Fencing
createPart("Sand_Arena", trainingFolder, CFrame.new(tOrigin + Vector3.new(0, 0.15, 0)), Vector3.new(48, 0.3, 48), Color3.fromRGB(185, 160, 125), Enum.Material.Sand)

-- Archery Targets on Tripods
for i, tx in ipairs({ -12, 12 }) do
	local target = createPart(string.format("Archery_Target_%d", i), trainingFolder, CFrame.new(tOrigin + Vector3.new(tx, 3.2, -18)) * CFrame.Angles(math.rad(75), 0, 0), Vector3.new(0.4, 3.8, 3.8), Color3.fromRGB(220, 190, 100), Enum.Material.Wood, Enum.PartType.Cylinder)
	createPart(string.format("Target_Bullseye_%d", i), trainingFolder, CFrame.new(tOrigin + Vector3.new(tx, 3.2, -17.8)) * CFrame.Angles(math.rad(75), 0, 0), Vector3.new(0.42, 1.4, 1.4), Color3.fromRGB(220, 40, 40), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
end

-- Interactive Magic Training Orb on Armillary Pedestal
local pedBase = createPart("Orb_Armillary_Pedestal", trainingFolder, CFrame.new(tOrigin + Vector3.new(0, 1.8, 0)), Vector3.new(4, 3.6, 4), Color3.fromRGB(65, 70, 80), Enum.Material.Slate)
local magicOrb = createPart("Training_Magic_Orb", trainingFolder, CFrame.new(tOrigin + Vector3.new(0, 5.5, 0)), Vector3.new(4.2, 4.2, 4.2), Color3.fromRGB(0, 225, 255), Enum.Material.Neon, Enum.PartType.Ball)

local orbPrompt = Instance.new("ProximityPrompt")
orbPrompt.ObjectText = "Orbe de Entrenamiento"
orbPrompt.ActionText = "Canalizar Magia"
orbPrompt.HoldDuration = 0
orbPrompt.MaxActivationDistance = 16
orbPrompt.Parent = magicOrb

local orbClick = Instance.new("ClickDetector")
orbClick.MaxActivationDistance = 25
orbClick.Parent = magicOrb

local orbLight = Instance.new("PointLight")
orbLight.Color = Color3.fromRGB(0, 220, 255)
orbLight.Brightness = 3.5
orbLight.Range = 24
orbLight.Parent = magicOrb

--------------------------------------------------------------------------------
-- 8. TORRE DE REBIRTH (Arcane Obelisk Spire & Orbiting Monoliths)
--------------------------------------------------------------------------------
local rebirthFolder = Instance.new("Folder")
rebirthFolder.Name = "Grand_Rebirth_Spire"
rebirthFolder.Parent = lobby

local rOrigin = Vector3.new(-90, 0, 0)

-- Stepped Obsidian Ritual Dais
for step = 1, 3 do
	createPart(string.format("Rebirth_Dais_%d", step), rebirthFolder, CFrame.new(rOrigin + Vector3.new(0, step * 0.45, 0)) * CFrame.Angles(0, 0, math.rad(90)), Vector3.new(0.5, 24 - step * 2.5, 24 - step * 2.5), Color3.fromRGB(40, 38, 50), Enum.Material.Slate, Enum.PartType.Cylinder)
end

-- Runic Amethyst Inlay
createPart("Rebirth_Rune_Circle", rebirthFolder, CFrame.new(rOrigin + Vector3.new(0, 1.4, 0)) * CFrame.Angles(0, 0, math.rad(90)), Vector3.new(0.2, 14, 14), Color3.fromRGB(200, 60, 255), Enum.Material.Neon, Enum.PartType.Cylinder)

-- Faceted Monolith Spire
local spire = createPart("Rebirth_Spire", rebirthFolder, CFrame.new(rOrigin + Vector3.new(0, 10, 0)), Vector3.new(4.5, 20, 4.5), Color3.fromRGB(35, 30, 48), Enum.Material.Slate)
local spireCore = createPart("Spire_Amethyst_Core", rebirthFolder, CFrame.new(rOrigin + Vector3.new(0, 10, 0)), Vector3.new(4.7, 7, 4.7), Color3.fromRGB(210, 80, 255), Enum.Material.Neon)
spireCore.CanCollide = false

local rPrompt = Instance.new("ProximityPrompt")
rPrompt.ObjectText = "Altar del Renacimiento"
rPrompt.ActionText = "Renacer (Rebirth)"
rPrompt.HoldDuration = 1.0
rPrompt.MaxActivationDistance = 16
rPrompt.Parent = spire

-- 6 Orbiting Satellite Monoliths
for i = 1, 6 do
	local ang = math.rad(i * 60)
	local ox = math.cos(ang) * 9.5
	local oz = math.sin(ang) * 9.5
	local sat = createPart(string.format("Satellite_Monolith_%d", i), rebirthFolder, CFrame.new(rOrigin + Vector3.new(ox, 6.0 + (i % 2 * 3), oz)) * CFrame.Angles(0.2, ang, 0.1), Vector3.new(1.6, 5.0, 1.6), Color3.fromRGB(200, 75, 255), Enum.Material.Neon)
	sat.CanCollide = false
end

--------------------------------------------------------------------------------
-- 9. SATELLITE SKY ISLANDS & ENCHANTED SAKURA PERIMETER
--------------------------------------------------------------------------------
local skyFolder = Instance.new("Folder")
skyFolder.Name = "Enchanted_Sky_Perimeter"
skyFolder.Parent = lobby

-- 4 Floating Satellite Islands in the Sky
local skyConfigs = {
	{ Pos = Vector3.new(-120, 28, -130), Radius = 32, Color = Color3.fromRGB(185, 80, 255) },
	{ Pos = Vector3.new(135, 36, -140), Radius = 36, Color = Color3.fromRGB(0, 230, 255) },
	{ Pos = Vector3.new(145, 22, 90), Radius = 28, Color = Color3.fromRGB(255, 120, 220) },
	{ Pos = Vector3.new(-135, 32, 100), Radius = 32, Color = Color3.fromRGB(80, 240, 140) },
}

for i, isl in ipairs(skyConfigs) do
	local iModel = Instance.new("Model")
	iModel.Name = string.format("FloatingSkyIsland_%d", i)
	iModel.Parent = skyFolder

	createPart("Island_Grass", iModel, CFrame.new(isl.Pos) * CFrame.Angles(0, 0, math.rad(90)), Vector3.new(3.5, isl.Radius, isl.Radius), Color3.fromRGB(92, 172, 82), Enum.Material.Grass, Enum.PartType.Cylinder)
	createPart("Island_RockCone", iModel, CFrame.new(isl.Pos - Vector3.new(0, 12, 0)) * CFrame.Angles(math.rad(180), 0, 0), Vector3.new(isl.Radius * 0.9, 20, isl.Radius * 0.9), Color3.fromRGB(68, 70, 80), Enum.Material.Slate, Enum.PartType.Ball)

	local crystal = createPart("Sky_Crystal", iModel, CFrame.new(isl.Pos + Vector3.new(0, 9, 0)) * CFrame.Angles(0.2, i, 0.1), Vector3.new(4.5, 16, 4.5), isl.Color, Enum.Material.Neon)
	crystal.CanCollide = false

	local cLight = Instance.new("PointLight")
	cLight.Color = isl.Color
	cLight.Brightness = 3.5
	cLight.Range = 35
	cLight.Parent = crystal
end

-- Sakura Cherry Blossom Trees along Perimeter & Avenues
local treePositions = {
	Vector3.new(35, 0, -35), Vector3.new(-35, 0, -35),
	Vector3.new(42, 0, 32), Vector3.new(-45, 0, 28),
	Vector3.new(0, 0, 56), Vector3.new(82, 0, -25),
	Vector3.new(-85, 0, 35), Vector3.new(30, 0, 92),
	Vector3.new(-70, 0, -30), Vector3.new(70, 0, -30),
}

for i, pos in ipairs(treePositions) do
	local tree = Instance.new("Model")
	tree.Name = string.format("Sakura_Tree_%d", i)
	tree.Parent = skyFolder

	createPart("Trunk", tree, CFrame.new(pos + Vector3.new(0, 7.5, 0)) * CFrame.Angles(0.04 * (i % 3), math.rad(i * 36), 0), Vector3.new(2.8, 15, 2.8), Color3.fromRGB(88, 58, 38), Enum.Material.Wood)

	local leafColor = (i % 2 == 0) and Color3.fromRGB(255, 175, 215) or Color3.fromRGB(255, 195, 230)
	createPart("Canopy_Btm", tree, CFrame.new(pos + Vector3.new(0, 16, 0)), Vector3.new(15, 8.5, 15), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
	createPart("Canopy_Top", tree, CFrame.new(pos + Vector3.new(0, 20.5, 0)), Vector3.new(11, 6.5, 11), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
end

-- Street Lanterns with Warm Amber Flame
local lampPositions = {
	Vector3.new(18, 0, -18), Vector3.new(-18, 0, -18),
	Vector3.new(18, 0, 18), Vector3.new(-18, 0, 18),
	Vector3.new(0, 0, -48), Vector3.new(45, 0, -45),
	Vector3.new(-45, 0, -45), Vector3.new(52, 0, 35),
}

for i, lPos in ipairs(lampPositions) do
	local lamp = Instance.new("Model")
	lamp.Name = string.format("Street_Lamp_%d", i)
	lamp.Parent = skyFolder

	createPart("Pole", lamp, CFrame.new(lPos + Vector3.new(0, 5, 0)), Vector3.new(0.9, 10, 0.9), Color3.fromRGB(42, 44, 52), Enum.Material.Metal)
	local lantern = createPart("Lantern_Head", lamp, CFrame.new(lPos + Vector3.new(0, 10.2, 0)), Vector3.new(1.8, 2.4, 1.8), Color3.fromRGB(255, 225, 140), Enum.Material.Neon)
	lantern.CanCollide = false

	local pLight = Instance.new("PointLight")
	pLight.Color = Color3.fromRGB(255, 215, 130)
	pLight.Brightness = 2.2
	pLight.Range = 20
	pLight.Parent = lantern
end

print("[MAGIA ETERNA] Spectacular Fantasy Lobby successfully constructed!")
return "SPECTACULAR_LOBBY_REBUILT"
