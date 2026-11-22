--!strict
--[[
    build_lobby_studio.luau
    Automated World Builder for MAGIA ETERNA's Lobby in Roblox Studio.
    Builds:
    1. Fantasy Floating Island Terrain & Paths
    2. Central Plaza, Levitating Mana Crystal, Fountains & SpawnLocation
    3. Training Grounds: Runic Circle & Interactive Magic Training Orb
    4. Blacksmith Forge: Furnace, Anvil & ProximityPrompt
    5. Quest Zone: Ancient Tree, Quest Board & Daily Reward Chest
    6. Dungeon Portal Area: 6 Regional Portales with Billboards & Prompts
    7. Egg & Pet Market Stalls with Nests & Bubbling Cauldron
    8. Rebirth Altar / Spire
    9. Fantasy Lighting & Atmospheric Post-Processing
]]

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Clean up any existing Lobby model to allow clean re-generation
local existingLobby = Workspace:FindFirstChild("MagiaEterna_Lobby")
if existingLobby then
	existingLobby:Destroy()
end

local lobbyFolder = Instance.new("Model")
lobbyFolder.Name = "MagiaEterna_Lobby"
lobbyFolder.Parent = Workspace

-- Helper function to create anchored parts
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
-- 1. FLOATING ISLAND BASE & TERRAIN PLATFORMS
--------------------------------------------------------------------------------
local islandFolder = Instance.new("Folder")
islandFolder.Name = "Island_Terrain"
islandFolder.Parent = lobbyFolder

-- Main Central Island Plate (Large polygon with grass top and rock underbelly)
local mainGrass = createPart("MainIsland_Grass", islandFolder, CFrame.new(0, 0, 0), Vector3.new(240, 4, 240), Color3.fromRGB(90, 165, 80), Enum.Material.Grass, Enum.PartType.Cylinder)
mainGrass.CFrame = CFrame.new(0, -2, 0) * CFrame.Angles(0, 0, math.rad(90))

-- Rock Cliffs Rim
local rockRim = createPart("Island_RockBase", islandFolder, CFrame.new(0, -8, 0), Vector3.new(230, 12, 230), Color3.fromRGB(75, 75, 85), Enum.Material.Slate, Enum.PartType.Cylinder)
rockRim.CFrame = CFrame.new(0, -8, 0) * CFrame.Angles(0, 0, math.rad(90))

-- Radiating Cobblestone Pathways connecting Plaza to all 6 zones
local pathFolder = Instance.new("Folder")
pathFolder.Name = "Cobblestone_Paths"
pathFolder.Parent = islandFolder

local pathTargets = {
	{ EndPos = Vector3.new(0, 0.1, -85), Name = "Path_To_Quests" },
	{ EndPos = Vector3.new(75, 0.1, -75), Name = "Path_To_Dungeons" },
	{ EndPos = Vector3.new(90, 0.1, 0),   Name = "Path_To_Leaderboards" },
	{ EndPos = Vector3.new(65, 0.1, 65),  Name = "Path_To_Training" },
	{ EndPos = Vector3.new(-35, 0.1, 75), Name = "Path_To_Market" },
	{ EndPos = Vector3.new(-75, 0.1, -70), Name = "Path_To_Forge" },
	{ EndPos = Vector3.new(-90, 0.1, 0),  Name = "Path_To_Rebirth" },
}

for _, p in ipairs(pathTargets) do
	local length = (p.EndPos - Vector3.new(0, 0, 0)).Magnitude - 20
	local midPoint = Vector3.new(0, 0.1, 0):Lerp(p.EndPos, 0.55)
	local angle = math.atan2(p.EndPos.X, p.EndPos.Z)
	local path = createPart(p.Name, pathFolder, CFrame.new(midPoint) * CFrame.Angles(0, angle, 0), Vector3.new(12, 0.2, length), Color3.fromRGB(165, 155, 140), Enum.Material.Cobblestone)
end

--------------------------------------------------------------------------------
-- 2. CENTRAL PLAZA, SPAWN & FLOATING MANA CRYSTAL
--------------------------------------------------------------------------------
local plazaFolder = Instance.new("Folder")
plazaFolder.Name = "Central_Plaza"
plazaFolder.Parent = lobbyFolder

-- Tiered circular stone dais
local dais1 = createPart("Dais_Outer", plazaFolder, CFrame.new(0, 0.3, 0), Vector3.new(0.6, 54, 54), Color3.fromRGB(180, 180, 185), Enum.Material.Cobblestone, Enum.PartType.Cylinder)
dais1.CFrame = CFrame.new(0, 0.3, 0) * CFrame.Angles(0, 0, math.rad(90))

local dais2 = createPart("Dais_Inner", plazaFolder, CFrame.new(0, 0.9, 0), Vector3.new(0.6, 42, 42), Color3.fromRGB(210, 210, 215), Enum.Material.Marble, Enum.PartType.Cylinder)
dais2.CFrame = CFrame.new(0, 0.9, 0) * CFrame.Angles(0, 0, math.rad(90))

-- Glowing Runic Inlay
local runeRing = createPart("Rune_Ring", plazaFolder, CFrame.new(0, 1.25, 0), Vector3.new(0.1, 32, 32), Color3.fromRGB(0, 220, 255), Enum.Material.Neon, Enum.PartType.Cylinder)
runeRing.CFrame = CFrame.new(0, 1.25, 0) * CFrame.Angles(0, 0, math.rad(90))

-- SpawnLocation
local spawn = Instance.new("SpawnLocation")
spawn.Name = "Lobby_Spawn"
spawn.Anchored = true
spawn.CanCollide = false
spawn.Transparency = 1
spawn.CFrame = CFrame.new(0, 2.5, 0)
spawn.Size = Vector3.new(8, 1, 8)
spawn.Neutral = true
spawn.Duration = 0
spawn.Parent = plazaFolder

-- Giant Levitating Mana Crystal in Center
local crystalModel = Instance.new("Model")
crystalModel.Name = "Levitating_Mana_Crystal"
crystalModel.Parent = plazaFolder

local mainCrystal = createPart("Crystal_Core", crystalModel, CFrame.new(0, 12, 0), Vector3.new(5, 14, 5), Color3.fromRGB(0, 230, 255), Enum.Material.Glass)
mainCrystal.CanCollide = false

local crystalLight = Instance.new("PointLight")
crystalLight.Color = Color3.fromRGB(0, 220, 255)
crystalLight.Brightness = 3.5
crystalLight.Range = 36
crystalLight.Parent = mainCrystal

local sparkles = Instance.new("ParticleEmitter")
sparkles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
sparkles.Color = ColorSequence.new(Color3.fromRGB(150, 240, 255), Color3.fromRGB(0, 180, 255))
sparkles.Size = NumberSequence.new(0.8, 0)
sparkles.Rate = 18
sparkles.Speed = NumberRange.new(1.5, 3.5)
sparkles.Lifetime = NumberRange.new(2.5, 4.0)
sparkles.SpreadAngle = Vector2.new(180, 180)
sparkles.Parent = mainCrystal

-- Floating Satellite Crystals
for i = 1, 4 do
	local angle = math.rad(i * 90)
	local satPos = Vector3.new(math.cos(angle) * 8, 10 + (i % 2 * 2), math.sin(angle) * 8)
	local sat = createPart(string.format("Satellite_Crystal_%d", i), crystalModel, CFrame.new(satPos) * CFrame.Angles(0.3, angle, 0.2), Vector3.new(1.8, 4.5, 1.8), Color3.fromRGB(180, 100, 255), Enum.Material.Neon)
	sat.CanCollide = false
end

-- Decorative Water Fountains on sides of plaza
for _, offset in ipairs({ Vector3.new(-22, 1.2, 0), Vector3.new(22, 1.2, 0) }) do
	local basin = createPart("Fountain_Basin", plazaFolder, CFrame.new(offset), Vector3.new(1.5, 10, 10), Color3.fromRGB(190, 190, 195), Enum.Material.Marble, Enum.PartType.Cylinder)
	basin.CFrame = CFrame.new(offset) * CFrame.Angles(0, 0, math.rad(90))
	local water = createPart("Fountain_Water", plazaFolder, CFrame.new(offset + Vector3.new(0, 0.8, 0)), Vector3.new(0.4, 8.5, 8.5), Color3.fromRGB(0, 150, 255), Enum.Material.Glass, Enum.PartType.Cylinder)
	water.CFrame = CFrame.new(offset + Vector3.new(0, 0.8, 0)) * CFrame.Angles(0, 0, math.rad(90))
end

--------------------------------------------------------------------------------
-- 3. TRAINING GROUNDS (Campo de Entrenamiento)
--------------------------------------------------------------------------------
local trainingFolder = Instance.new("Folder")
trainingFolder.Name = "Training_Grounds"
trainingFolder.Parent = lobbyFolder

local tCenter = Vector3.new(65, 0, 65)

-- Sand / Dirt Training Pitch
local pitch = createPart("Training_Pitch", trainingFolder, CFrame.new(tCenter + Vector3.new(0, 0.1, 0)), Vector3.new(46, 0.3, 46), Color3.fromRGB(180, 155, 120), Enum.Material.Sand)

-- Fencing around Pitch
for side = 1, 4 do
	local angle = math.rad((side - 1) * 90)
	local fPos = tCenter + Vector3.new(math.cos(angle) * 23, 1.5, math.sin(angle) * 23)
	local fence = createPart("Fence", trainingFolder, CFrame.new(fPos) * CFrame.Angles(0, -angle, 0), Vector3.new(1.0, 3.0, 46), Color3.fromRGB(110, 75, 45), Enum.Material.Wood)
end

-- Interactive Magic Training Orb (Active Clicker Orb)
local orbPedestal = createPart("Orb_Pedestal", trainingFolder, CFrame.new(tCenter + Vector3.new(0, 1.8, -8)), Vector3.new(3.5, 3.6, 3.5), Color3.fromRGB(60, 65, 75), Enum.Material.Slate)
local magicOrb = createPart("Training_Magic_Orb", trainingFolder, CFrame.new(tCenter + Vector3.new(0, 5.5, -8)), Vector3.new(4, 4, 4), Color3.fromRGB(0, 220, 255), Enum.Material.Neon, Enum.PartType.Ball)

local orbPrompt = Instance.new("ProximityPrompt")
orbPrompt.ObjectText = "Orbe de Entrenamiento"
orbPrompt.ActionText = "Canalizar Magia"
orbPrompt.HoldDuration = 0
orbPrompt.MaxActivationDistance = 14
orbPrompt.Parent = magicOrb

local orbClick = Instance.new("ClickDetector")
orbClick.MaxActivationDistance = 25
orbClick.Parent = magicOrb

local orbLight = Instance.new("PointLight")
orbLight.Color = Color3.fromRGB(0, 210, 255)
orbLight.Brightness = 2.5
orbLight.Range = 20
orbLight.Parent = magicOrb

-- Passive Meditation Runic Circle
local runeTraining = createPart("Passive_Meditation_Circle", trainingFolder, CFrame.new(tCenter + Vector3.new(0, 0.25, 8)), Vector3.new(0.1, 16, 16), Color3.fromRGB(180, 100, 255), Enum.Material.Neon, Enum.PartType.Cylinder)
runeTraining.CFrame = CFrame.new(tCenter + Vector3.new(0, 0.25, 8)) * CFrame.Angles(0, 0, math.rad(90))

local runeLabel = Instance.new("BillboardGui")
runeLabel.Size = UDim2.new(0, 160, 0, 40)
runeLabel.StudsOffset = Vector3.new(0, 5, 0)
runeLabel.AlwaysOnTop = true
runeLabel.Parent = runeTraining

local runeText = Instance.new("TextLabel")
runeText.Size = UDim2.new(1, 0, 1, 0)
runeText.BackgroundTransparency = 1
runeText.Text = "🧘 Círculo de Meditación\n(Entrenamiento Pasivo)"
runeText.TextColor3 = Color3.fromRGB(220, 180, 255)
runeText.TextSize = 14
runeText.Font = Enum.Font.GothamBold
runeText.Parent = runeLabel

--------------------------------------------------------------------------------
-- 4. TALLER DE LA FORJA REAL (Blacksmith Forge Area)
--------------------------------------------------------------------------------
local forgeFolder = Instance.new("Folder")
forgeFolder.Name = "Taller_Forja_Real"
forgeFolder.Parent = lobbyFolder

local fCenter = Vector3.new(-75, 0, -70)

-- Building Base & Floor
local forgeFloor = createPart("Forge_StoneFloor", forgeFolder, CFrame.new(fCenter + Vector3.new(0, 0.2, 0)), Vector3.new(34, 0.4, 28), Color3.fromRGB(60, 60, 65), Enum.Material.Slate)

-- Heavy Hearth & Furnace
local furnace = createPart("Furnace_Hearth", forgeFolder, CFrame.new(fCenter + Vector3.new(0, 4, -10)), Vector3.new(12, 8, 6), Color3.fromRGB(70, 70, 75), Enum.Material.Slate)
local fireGlow = createPart("Furnace_Fire", forgeFolder, CFrame.new(fCenter + Vector3.new(0, 2.5, -7.5)), Vector3.new(6, 4, 3), Color3.fromRGB(255, 120, 20), Enum.Material.Neon)
local furnaceLight = Instance.new("PointLight")
furnaceLight.Color = Color3.fromRGB(255, 140, 40)
furnaceLight.Brightness = 4.0
furnaceLight.Range = 24
furnaceLight.Parent = fireGlow

-- Chimney
local chimney = createPart("Chimney", forgeFolder, CFrame.new(fCenter + Vector3.new(0, 12, -10)), Vector3.new(4, 10, 4), Color3.fromRGB(65, 65, 70), Enum.Material.Slate)
local smoke = Instance.new("ParticleEmitter")
smoke.Texture = "rbxasset://textures/particles/smoke_main.dds"
smoke.Color = ColorSequence.new(Color3.fromRGB(120, 120, 130), Color3.fromRGB(60, 60, 65))
smoke.Size = NumberSequence.new(1.5, 4.5)
smoke.Rate = 6
smoke.Speed = NumberRange.new(3, 6)
smoke.Lifetime = NumberRange.new(3, 5)
smoke.Parent = chimney

-- Master Anvil & Interaction Prompt
local anvilBlock = createPart("Anvil_Stump", forgeFolder, CFrame.new(fCenter + Vector3.new(0, 1.5, 0)), Vector3.new(3, 3, 3), Color3.fromRGB(100, 70, 40), Enum.Material.Wood)
local anvil = createPart("Steel_Anvil", forgeFolder, CFrame.new(fCenter + Vector3.new(0, 3.4, 0)), Vector3.new(2.4, 1.4, 4.5), Color3.fromRGB(40, 42, 48), Enum.Material.Metal)

local forgePrompt = Instance.new("ProximityPrompt")
forgePrompt.ObjectText = "Yunque Arcano"
forgePrompt.ActionText = "Abrir Forja Real"
forgePrompt.HoldDuration = 0
forgePrompt.MaxActivationDistance = 12
forgePrompt.Parent = anvil

local forgeLabel = Instance.new("BillboardGui")
forgeLabel.Size = UDim2.new(0, 180, 0, 45)
forgeLabel.StudsOffset = Vector3.new(0, 3.5, 0)
forgeLabel.AlwaysOnTop = true
forgeLabel.Parent = anvil

local forgeTitle = Instance.new("TextLabel")
forgeTitle.Size = UDim2.new(1, 0, 1, 0)
forgeTitle.BackgroundTransparency = 1
forgeTitle.Text = "🔨 FORJA REAL\n(Fabricar Bastones y Armaduras)"
forgeTitle.TextColor3 = Color3.fromRGB(255, 200, 80)
forgeTitle.TextSize = 13
forgeTitle.Font = Enum.Font.GothamBold
forgeTitle.Parent = forgeLabel

--------------------------------------------------------------------------------
-- 5. QUEST ZONE & ANCIENT TREE (Salón de Misiones & Árbol Sagrado)
--------------------------------------------------------------------------------
local questFolder = Instance.new("Folder")
questFolder.Name = "Quest_Zone"
questFolder.Parent = lobbyFolder

local qCenter = Vector3.new(0, 0, -90)

-- Ancient Sacred Tree (Trunk + Foliage Clusters)
local treeTrunk = createPart("SacredTree_Trunk", questFolder, CFrame.new(qCenter + Vector3.new(0, 14, 0)), Vector3.new(10, 28, 10), Color3.fromRGB(95, 65, 45), Enum.Material.Wood)

-- Canopy Clusters (Pink Cherry / Arcane Blossom style)
local canopy1 = createPart("Canopy_Main", questFolder, CFrame.new(qCenter + Vector3.new(0, 28, 0)), Vector3.new(32, 14, 32), Color3.fromRGB(255, 175, 210), Enum.Material.Grass, Enum.PartType.Ball)
local canopy2 = createPart("Canopy_Top", questFolder, CFrame.new(qCenter + Vector3.new(0, 34, 0)), Vector3.new(22, 10, 22), Color3.fromRGB(255, 195, 225), Enum.Material.Grass, Enum.PartType.Ball)

-- Quest Board (Tablón de Misiones)
local questBoard = createPart("Quest_Board", questFolder, CFrame.new(qCenter + Vector3.new(-12, 4, 14)), Vector3.new(10, 8, 1.2), Color3.fromRGB(120, 80, 50), Enum.Material.Wood)
local qBoardPrompt = Instance.new("ProximityPrompt")
qBoardPrompt.ObjectText = "Tablón de Misiones"
qBoardPrompt.ActionText = "Ver Misiones Diarias"
qBoardPrompt.HoldDuration = 0
qBoardPrompt.MaxActivationDistance = 14
qBoardPrompt.Parent = questBoard

local qBoardLabel = Instance.new("BillboardGui")
qBoardLabel.Size = UDim2.new(0, 160, 0, 40)
qBoardLabel.StudsOffset = Vector3.new(0, 5, 0)
qBoardLabel.AlwaysOnTop = true
qBoardLabel.Parent = questBoard

local qBoardText = Instance.new("TextLabel")
qBoardText.Size = UDim2.new(1, 0, 1, 0)
qBoardText.BackgroundTransparency = 1
qBoardText.Text = "📜 TABLÓN DE MISIONES"
qBoardText.TextColor3 = Color3.fromRGB(255, 230, 140)
qBoardText.TextSize = 14
qBoardText.Font = Enum.Font.GothamBold
qBoardText.Parent = qBoardLabel

-- Golden Reward Chest (Cofre Diario)
local chest = createPart("Reward_Chest_Body", questFolder, CFrame.new(qCenter + Vector3.new(12, 1.6, 14)), Vector3.new(4, 3.2, 3), Color3.fromRGB(230, 180, 30), Enum.Material.Metal)
local chestTrim = createPart("Reward_Chest_Trim", questFolder, CFrame.new(qCenter + Vector3.new(12, 3.4, 14)), Vector3.new(4.2, 0.8, 3.2), Color3.fromRGB(255, 215, 60), Enum.Material.Neon)

local chestPrompt = Instance.new("ProximityPrompt")
chestPrompt.ObjectText = "Cofre Mágico"
chestPrompt.ActionText = "Reclamar Recompensa Diaria"
chestPrompt.HoldDuration = 0.5
chestPrompt.MaxActivationDistance = 12
chestPrompt.Parent = chest

local chestSparkles = Instance.new("ParticleEmitter")
chestSparkles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
chestSparkles.Color = ColorSequence.new(Color3.fromRGB(255, 230, 100), Color3.fromRGB(255, 170, 0))
chestSparkles.Rate = 8
chestSparkles.Parent = chest

--------------------------------------------------------------------------------
-- 6. DUNGEON PORTALS AREA (6 Portales Regionales)
--------------------------------------------------------------------------------
local portalFolder = Instance.new("Folder")
portalFolder.Name = "Dungeon_Portals"
portalFolder.Parent = lobbyFolder

local portalData = {
	{ Id = "Dungeon_Bosque", Name = "Bosque de los Susurros", Level = "Nv. 1-10", RebirthReq = "Rebirth 0", Color = Color3.fromRGB(40, 220, 100), AngleDeg = 15 },
	{ Id = "Dungeon_Minas",  Name = "Minas del Fuego",       Level = "Nv. 10-20", RebirthReq = "Rebirth 1", Color = Color3.fromRGB(255, 100, 20), AngleDeg = 35 },
	{ Id = "Dungeon_Hielo",  Name = "Reino del Hielo",       Level = "Nv. 20-35", RebirthReq = "Rebirth 2", Color = Color3.fromRGB(80, 200, 255), AngleDeg = 55 },
	{ Id = "Dungeon_Almas",  Name = "Cripta de las Almas",   Level = "Nv. 35-50", RebirthReq = "Rebirth 3", Color = Color3.fromRGB(180, 70, 255), AngleDeg = 75 },
	{ Id = "Dungeon_Cielos", Name = "Templo de los Cielos",  Level = "Nv. 50-75", RebirthReq = "Rebirth 4", Color = Color3.fromRGB(255, 220, 50), AngleDeg = 95 },
	{ Id = "Dungeon_Abismo", Name = "Abismo del Infinito",   Level = "Nv. 75-100", RebirthReq = "Rebirth 5", Color = Color3.fromRGB(255, 40, 60),  AngleDeg = 115 },
}

local portalRadius = 90
for _, pInfo in ipairs(portalData) do
	local rad = math.rad(pInfo.AngleDeg)
	local pPos = Vector3.new(math.cos(rad) * portalRadius, 0, -math.sin(rad) * portalRadius)
	local rotY = math.atan2(pPos.X, pPos.Z)

	local pModel = Instance.new("Model")
	pModel.Name = "Portal_" .. pInfo.Id
	pModel.Parent = portalFolder

	-- Stone Arch Base
	local base = createPart("Portal_Base", pModel, CFrame.new(pPos + Vector3.new(0, 0.4, 0)) * CFrame.Angles(0, rotY, 0), Vector3.new(14, 0.8, 6), Color3.fromRGB(55, 58, 68), Enum.Material.Slate)

	-- Arch Pillars
	local pillarL = createPart("Pillar_L", pModel, CFrame.new(pPos + Vector3.new(0, 6, 0)) * CFrame.Angles(0, rotY, 0) * CFrame.new(-5, 0, 0), Vector3.new(2.4, 12, 2.4), Color3.fromRGB(65, 68, 78), Enum.Material.Slate)
	local pillarR = createPart("Pillar_R", pModel, CFrame.new(pPos + Vector3.new(0, 6, 0)) * CFrame.Angles(0, rotY, 0) * CFrame.new(5, 0, 0), Vector3.new(2.4, 12, 2.4), Color3.fromRGB(65, 68, 78), Enum.Material.Slate)
	local lintel = createPart("Lintel", pModel, CFrame.new(pPos + Vector3.new(0, 12, 0)) * CFrame.Angles(0, rotY, 0), Vector3.new(13, 2.5, 2.8), Color3.fromRGB(70, 72, 82), Enum.Material.Slate)

	-- Swirling Portal Vortex
	local vortex = createPart("Vortex", pModel, CFrame.new(pPos + Vector3.new(0, 6.5, 0)) * CFrame.Angles(0, rotY, 0), Vector3.new(8, 9.5, 0.4), pInfo.Color, Enum.Material.Neon)
	vortex.CanCollide = false

	local vortexLight = Instance.new("PointLight")
	vortexLight.Color = pInfo.Color
	vortexLight.Brightness = 3.0
	vortexLight.Range = 22
	vortexLight.Parent = vortex

	-- Proximity Prompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = pInfo.Name
	prompt.ActionText = "Explorar Mazmorra (" .. pInfo.Level .. ")"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 14
	prompt.Parent = vortex

	-- Floating Billboard Info
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 200, 0, 50)
	bb.StudsOffset = Vector3.new(0, 7.5, 0)
	bb.AlwaysOnTop = true
	bb.Parent = vortex

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = string.format("🌀 %s\n%s • %s", pInfo.Name, pInfo.Level, pInfo.RebirthReq)
	label.TextColor3 = pInfo.Color
	label.TextSize = 13
	label.Font = Enum.Font.GothamBold
	label.Parent = bb
end

--------------------------------------------------------------------------------
-- 7. TIENDA DE HUEVOS Y MERCADO (Pet Egg Shop & Merchant Stalls)
--------------------------------------------------------------------------------
local marketFolder = Instance.new("Folder")
marketFolder.Name = "Tienda_Huevos_Mercado"
marketFolder.Parent = lobbyFolder

local mCenter = Vector3.new(-45, 0, 70)

-- Market Stall 1: Tienda de Huevos
local stall1 = createPart("EggShop_Counter", marketFolder, CFrame.new(mCenter), Vector3.new(16, 2.4, 6), Color3.fromRGB(115, 75, 45), Enum.Material.Wood)
local canopy = createPart("EggShop_Canopy", marketFolder, CFrame.new(mCenter + Vector3.new(0, 7, 0)) * CFrame.Angles(0, 0, math.rad(-15)), Vector3.new(18, 0.8, 10), Color3.fromRGB(150, 60, 220), Enum.Material.Fabric)

-- Giant Egg Display on counter
local eggDisplay = createPart("Display_Egg", marketFolder, CFrame.new(mCenter + Vector3.new(0, 3.8, 0)), Vector3.new(3, 4.2, 3), Color3.fromRGB(255, 230, 140), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
local eggPrompt = Instance.new("ProximityPrompt")
eggPrompt.ObjectText = "Tienda de Huevos"
eggPrompt.ActionText = "Abrir Catálogo de Mascotas"
eggPrompt.HoldDuration = 0
eggPrompt.MaxActivationDistance = 14
eggPrompt.Parent = eggDisplay

local eggLabel = Instance.new("BillboardGui")
eggLabel.Size = UDim2.new(0, 180, 0, 45)
eggLabel.StudsOffset = Vector3.new(0, 3.5, 0)
eggLabel.AlwaysOnTop = true
eggLabel.Parent = eggDisplay

local eggText = Instance.new("TextLabel")
eggText.Size = UDim2.new(1, 0, 1, 0)
eggText.BackgroundTransparency = 1
eggText.Text = "🐾 TIENDA DE HUEVOS\n(Incubar Mascotas)"
eggText.TextColor3 = Color3.fromRGB(255, 235, 160)
eggText.TextSize = 13
eggText.Font = Enum.Font.GothamBold
eggText.Parent = eggLabel

-- Bubbling Cauldron (Alquimia / Mercado)
local cauldronPos = mCenter + Vector3.new(16, 0, 4)
local cauldron = createPart("Cauldron_Body", marketFolder, CFrame.new(cauldronPos + Vector3.new(0, 1.8, 0)), Vector3.new(5, 3.6, 5), Color3.fromRGB(30, 32, 36), Enum.Material.Metal, Enum.PartType.Cylinder)
cauldron.CFrame = CFrame.new(cauldronPos + Vector3.new(0, 1.8, 0)) * CFrame.Angles(0, 0, math.rad(90))

local potionLiquid = createPart("Potion_Liquid", marketFolder, CFrame.new(cauldronPos + Vector3.new(0, 3.2, 0)), Vector3.new(0.2, 4.4, 4.4), Color3.fromRGB(0, 255, 180), Enum.Material.Neon, Enum.PartType.Cylinder)
potionLiquid.CFrame = CFrame.new(cauldronPos + Vector3.new(0, 3.2, 0)) * CFrame.Angles(0, 0, math.rad(90))

local bubbles = Instance.new("ParticleEmitter")
bubbles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
bubbles.Color = ColorSequence.new(Color3.fromRGB(0, 255, 200), Color3.fromRGB(150, 255, 230))
bubbles.Rate = 12
bubbles.Speed = NumberRange.new(2, 4)
bubbles.Lifetime = NumberRange.new(1, 2)
bubbles.Parent = potionLiquid

--------------------------------------------------------------------------------
-- 8. REBIRTH MONOLITH / ALTAR
--------------------------------------------------------------------------------
local rebirthFolder = Instance.new("Folder")
rebirthFolder.Name = "Rebirth_Zone"
rebirthFolder.Parent = lobbyFolder

local rCenter = Vector3.new(-90, 0, 0)

-- Elevated Rebirth Dais
local rDais = createPart("Rebirth_Dais", rebirthFolder, CFrame.new(rCenter + Vector3.new(0, 0.6, 0)), Vector3.new(0.8, 22, 22), Color3.fromRGB(45, 40, 55), Enum.Material.Slate, Enum.PartType.Cylinder)
rDais.CFrame = CFrame.new(rCenter + Vector3.new(0, 0.6, 0)) * CFrame.Angles(0, 0, math.rad(90))

-- Spire Monolith
local spire = createPart("Rebirth_Spire", rebirthFolder, CFrame.new(rCenter + Vector3.new(0, 9, 0)), Vector3.new(4, 18, 4), Color3.fromRGB(35, 30, 48), Enum.Material.Slate)
local spireGlow = createPart("Rebirth_Glow_Core", rebirthFolder, CFrame.new(rCenter + Vector3.new(0, 9, 0)), Vector3.new(4.2, 8, 4.2), Color3.fromRGB(200, 80, 255), Enum.Material.Neon)
spireGlow.CanCollide = false

local spireLight = Instance.new("PointLight")
spireLight.Color = Color3.fromRGB(200, 80, 255)
spireLight.Brightness = 3.5
spireLight.Range = 28
spireLight.Parent = spireGlow

local rPrompt = Instance.new("ProximityPrompt")
rPrompt.ObjectText = "Altar del Renacimiento"
rPrompt.ActionText = "Renacer (Rebirth)"
rPrompt.HoldDuration = 1.0
rPrompt.MaxActivationDistance = 14
rPrompt.Parent = spire

local rLabel = Instance.new("BillboardGui")
rLabel.Size = UDim2.new(0, 180, 0, 45)
rLabel.StudsOffset = Vector3.new(0, 11, 0)
rLabel.AlwaysOnTop = true
rLabel.Parent = spire

local rText = Instance.new("TextLabel")
rText.Size = UDim2.new(1, 0, 1, 0)
rText.BackgroundTransparency = 1
rText.Text = "🔁 ALTAR DE RENACIMIENTO\n(Multiplicadores y Poder Eterno)"
rText.TextColor3 = Color3.fromRGB(230, 150, 255)
rText.TextSize = 13
rText.Font = Enum.Font.GothamBold
rText.Parent = rLabel

--------------------------------------------------------------------------------
-- 9. ATMOSPHERIC LIGHTING & POST-PROCESSING
--------------------------------------------------------------------------------
Lighting.ClockTime = 17.6 -- Golden hour / magical sunset matching the reference concept
Lighting.GeographicLatitude = 24
Lighting.Ambient = Color3.fromRGB(90, 80, 105)
Lighting.OutdoorAmbient = Color3.fromRGB(130, 115, 140)
Lighting.Brightness = 2.4
Lighting.EnvironmentDiffuseScale = 1.0
Lighting.EnvironmentSpecularScale = 1.0

-- Atmosphere
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if not atmosphere then
	atmosphere = Instance.new("Atmosphere")
	atmosphere.Parent = Lighting
end
atmosphere.Density = 0.32
atmosphere.Offset = 0.25
atmosphere.Color = Color3.fromRGB(200, 180, 215)
atmosphere.Decay = Color3.fromRGB(150, 110, 175)
atmosphere.Glare = 0.3
atmosphere.Haze = 1.5

-- Bloom
local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
if not bloom then
	bloom = Instance.new("BloomEffect")
	bloom.Parent = Lighting
end
bloom.Intensity = 0.65
bloom.Size = 24
bloom.Threshold = 0.95

-- ColorCorrection
local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
if not cc then
	cc = Instance.new("ColorCorrectionEffect")
	cc.Parent = Lighting
end
cc.Brightness = 0.04
cc.Contrast = 0.12
cc.Saturation = 0.15
cc.TintColor = Color3.fromRGB(255, 248, 240)

print("[MAGIA ETERNA] Lobby successfully built and atmospheric lighting configured!")
return "Lobby Built Successfully"
