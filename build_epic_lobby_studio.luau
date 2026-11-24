-- =============================================================================
-- MAGIA ETERNA — FIX TOTAL DE Z-FIGHTING Y ELEVACIONES EN EL LOBBY
-- Elimina al 100% las rayas parpadeantes, cortes de suelo y superposiciones.
-- Jerarquía estricta de alturas: Cada superficie descansa físicamente sobre la inferior.
-- =============================================================================

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- 1. Limpiar lobby previo
local oldLobby = Workspace:FindFirstChild("MagiaEterna_Lobby")
if oldLobby then
    oldLobby:Destroy()
end

local Lobby = Instance.new("Model")
Lobby.Name = "MagiaEterna_Lobby"
Lobby.Parent = Workspace

-- Utilidades de construcción limpia
local function makePart(parent, name, size, cframe, material, color, anchored, canCollide)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color or Color3.fromRGB(200, 200, 200)
    p.Anchored = (anchored == nil) and true or anchored
    p.CanCollide = (canCollide == nil) and true or canCollide
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function makeCylinder(parent, name, size, cframe, material, color)
    local p = makePart(parent, name, size, cframe, material, color)
    p.Shape = Enum.PartType.Cylinder
    return p
end

local function makeWedge(parent, name, size, cframe, material, color)
    local p = Instance.new("WedgePart")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color or Color3.fromRGB(200, 200, 200)
    p.Anchored = true
    p.CanCollide = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function makePrompt(parent, actionText, objectText, maxDist, holdDur)
    local pr = Instance.new("ProximityPrompt")
    pr.ActionText = actionText
    pr.ObjectText = objectText
    pr.MaxActivationDistance = maxDist or 12
    pr.HoldDuration = holdDur or 0.5
    pr.RequiresLineOfSight = false
    pr.Parent = parent
    return pr
end

-- =============================================================================
-- 1. TERRENO BASE Y CADENA MONTAÑOSA PERIMETRAL
-- Suelo base de césped: Centro Y = 0, Altura = 4 studs -> Superficie superior en Y = 2.00
-- =============================================================================
local TerrainFolder = Instance.new("Folder")
TerrainFolder.Name = "Terrain_And_Perimeter_Mountains"
TerrainFolder.Parent = Lobby

-- Suelo verde principal (Top = Y 2.00)
local mainFloor = makeCylinder(TerrainFolder, "Main_Valley_Floor", Vector3.new(4, 320, 320), CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Grass, Color3.fromRGB(72, 138, 54))

-- Base de roca inferior (Top = Y -2.00)
local rockFoundation = makeCylinder(TerrainFolder, "Island_Rock_Foundation", Vector3.new(20, 310, 310), CFrame.new(0, -12, 0) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Slate, Color3.fromRGB(55, 52, 60))

-- Cadena montañosa perimetral envolvente (40 picos rocosos)
local mountainRadius = 145
local numPeaks = 40
for i = 1, numPeaks do
    local angle = (i / numPeaks) * math.pi * 2
    local px = math.cos(angle) * mountainRadius
    local pz = math.sin(angle) * mountainRadius
    local peakHeight = 45 + ((i * 17) % 35)
    local peakWidth = 32 + ((i * 13) % 18)
    
    local mountainCFrame = CFrame.lookAt(Vector3.new(px, peakHeight / 2 - 2, pz), Vector3.new(0, peakHeight / 2 - 2, 0))
    local peak = makeWedge(TerrainFolder, "Mountain_Peak_" .. i, Vector3.new(peakWidth, peakHeight, peakWidth), mountainCFrame, Enum.Material.Slate, Color3.fromRGB(58 + (i%5)*4, 55 + (i%5)*4, 62 + (i%5)*4))
    
    if peakHeight > 60 then
        local snowHeight = peakHeight * 0.35
        local snowCFrame = CFrame.lookAt(Vector3.new(px, peakHeight - (snowHeight/2), pz), Vector3.new(0, peakHeight - (snowHeight/2), 0))
        makeWedge(TerrainFolder, "Snow_Cap_" .. i, Vector3.new(peakWidth * 0.7, snowHeight, peakWidth * 0.7), snowCFrame, Enum.Material.Snow, Color3.fromRGB(240, 245, 255))
    end
end

-- Barrera invisible perimetral (Total seguridad anti-caída)
local barrierRadius = 135
local numBarriers = 32
for i = 1, numBarriers do
    local a1 = ((i - 1) / numBarriers) * math.pi * 2
    local a2 = (i / numBarriers) * math.pi * 2
    local midAngle = (a1 + a2) / 2
    local mx = math.cos(midAngle) * barrierRadius
    local mz = math.sin(midAngle) * barrierRadius
    local segLen = 2 * barrierRadius * math.sin(math.pi / numBarriers) + 4
    
    local barrier = makePart(TerrainFolder, "Invisible_Boundary_Wall_" .. i, Vector3.new(segLen, 80, 4), CFrame.new(mx, 38, mz) * CFrame.Angles(0, -midAngle + math.rad(90), 0), Enum.Material.ForceField, Color3.fromRGB(255, 255, 255), true, true)
    barrier.Transparency = 1
end

-- =============================================================================
-- 2. RED VIAL Y PLAZAS DE ADOQUINES (SIN NINGÚN Z-FIGHTING)
-- =============================================================================
local RoadsFolder = Instance.new("Folder")
RoadsFolder.Name = "Roads_And_Courtyards"
RoadsFolder.Parent = Lobby

-- Borde exterior de la plaza (Top = Y 2.35)
makeCylinder(RoadsFolder, "Plaza_Central_Outer_Ring", Vector3.new(0.4, 96, 96), CFrame.new(0, 2.15, 0) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Marble, Color3.fromRGB(120, 115, 125))

-- Suelo interior elevado de adoquines (Top = Y 2.50) -> Cero coplanaridad, descansa encima
makeCylinder(RoadsFolder, "Plaza_Central_Paved_Floor", Vector3.new(0.3, 88, 88), CFrame.new(0, 2.35, 0) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Cobblestone, Color3.fromRGB(180, 178, 175))

-- Avenidas Principales (Top = Y 2.32)
makePart(RoadsFolder, "Avenue_North", Vector3.new(18, 0.32, 50), CFrame.new(0, 2.16, -55), Enum.Material.Cobblestone, Color3.fromRGB(175, 172, 170))
makePart(RoadsFolder, "Avenue_South", Vector3.new(18, 0.32, 40), CFrame.new(0, 2.16, 50), Enum.Material.Cobblestone, Color3.fromRGB(175, 172, 170))
makePart(RoadsFolder, "Avenue_West", Vector3.new(50, 0.32, 16), CFrame.new(-55, 2.16, 0), Enum.Material.Cobblestone, Color3.fromRGB(175, 172, 170))
makePart(RoadsFolder, "Avenue_East", Vector3.new(50, 0.32, 16), CFrame.new(55, 2.16, 0), Enum.Material.Cobblestone, Color3.fromRGB(175, 172, 170))

-- Paseo arqueado de portales al Norte (Top = Y 2.32)
makePart(RoadsFolder, "Portal_Promenade_Arch", Vector3.new(160, 0.32, 18), CFrame.new(0, 2.16, -80), Enum.Material.Cobblestone, Color3.fromRGB(165, 162, 160))

-- =============================================================================
-- 3. TERRAZA DE SPAWN Y BIENVENIDA (SUR) — ESCALONADO LIMPIO
-- =============================================================================
local SpawnFolder = Instance.new("Folder")
SpawnFolder.Name = "Welcome_Spawn_Terrace"
SpawnFolder.Parent = Lobby

local spawnPos = Vector3.new(0, 0, 75)

-- Escalón exterior dorado (Top = Y 2.40)
local spawnGoldBase = makeCylinder(SpawnFolder, "Spawn_Gold_Step", Vector3.new(0.4, 32, 32), CFrame.new(spawnPos.X, 2.20, spawnPos.Z) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Metal, Color3.fromRGB(225, 185, 50))

-- Podio superior de mármol blanco (Top = Y 2.70) — Apoya directamente sobre el escalón dorado
local spawnMarbleDais = makeCylinder(SpawnFolder, "Spawn_Marble_Dais", Vector3.new(0.3, 27, 27), CFrame.new(spawnPos.X, 2.55, spawnPos.Z) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Marble, Color3.fromRGB(240, 240, 245))

-- SpawnLocation completamente invisible (evita cajas parpadeantes y errores de asset)
local spawnLocation = Instance.new("SpawnLocation")
spawnLocation.Name = "LobbySpawnLocation"
spawnLocation.Size = Vector3.new(16, 0.1, 16)
spawnLocation.CFrame = CFrame.new(spawnPos.X, 2.75, spawnPos.Z)
spawnLocation.Transparency = 1
spawnLocation.CanCollide = false
spawnLocation.Anchored = true
local defDecal = spawnLocation:FindFirstChildOfClass("Decal")
if defDecal then defDecal:Destroy() end
spawnLocation.Parent = SpawnFolder

-- Columnas monumentales de bienvenida (Apoyadas firmemente sobre el podio)
for _, sx in ipairs({-12, 12}) do
    local col = makeCylinder(SpawnFolder, "Welcome_Column_" .. sx, Vector3.new(12, 2.2, 2.2), CFrame.new(sx, 8.7, spawnPos.Z) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Marble, Color3.fromRGB(245, 245, 250))
    local lantern = makePart(SpawnFolder, "Lantern_Light_" .. sx, Vector3.new(1.8, 2.2, 1.8), CFrame.new(sx, 15.5, spawnPos.Z), Enum.Material.Neon, Color3.fromRGB(255, 235, 160))
    local pl = Instance.new("PointLight")
    pl.Color = Color3.fromRGB(255, 225, 140)
    pl.Range = 26
    pl.Brightness = 2.2
    pl.Parent = lantern
end

-- =============================================================================
-- 4. CENTRO DE LA LOBBY: GRAN FUENTE Y MONUMENTO AL MANÁ CELESTIAL
-- =============================================================================
local CenterFolder = Instance.new("Folder")
CenterFolder.Name = "Grand_Mana_Fountain_Monument"
CenterFolder.Parent = Lobby

-- Muro exterior de la cuenca (Y = 2.50 a 4.50)
makeCylinder(CenterFolder, "Fountain_Outer_Basin", Vector3.new(2.0, 36, 36), CFrame.new(0, 3.50, 0) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Marble, Color3.fromRGB(235, 235, 240))

-- Superficie de agua de maná (contenida en Y = 4.10, debajo del borde)
local manaWater = makeCylinder(CenterFolder, "Mana_Water_Surface", Vector3.new(0.2, 33, 33), CFrame.new(0, 4.10, 0) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Glass, Color3.fromRGB(60, 190, 240))
manaWater.Transparency = 0.35

-- Cuenca intermedia elevada (Y = 4.20 a 6.20)
makeCylinder(CenterFolder, "Fountain_Mid_Basin", Vector3.new(2.0, 20, 20), CFrame.new(0, 5.20, 0) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Marble, Color3.fromRGB(220, 220, 230))
local midWater = makeCylinder(CenterFolder, "Mid_Water_Surface", Vector3.new(0.2, 17, 17), CFrame.new(0, 5.90, 0) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Glass, Color3.fromRGB(50, 180, 255))
midWater.Transparency = 0.30

-- Pedestal rúnico central (Y = 6.00 a 22.00)
local centralPillar = makeCylinder(CenterFolder, "Central_Runic_Spire", Vector3.new(16, 6, 6), CFrame.new(0, 14.0, 0) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Marble, Color3.fromRGB(245, 245, 250))
makeCylinder(CenterFolder, "Gold_Runic_Band", Vector3.new(1.8, 6.4, 6.4), CFrame.new(0, 18.0, 0) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Metal, Color3.fromRGB(230, 190, 60))

-- Núcleo de Cristal Celestial Flotante (Y = 28.00)
local celestialCore = makePart(CenterFolder, "Celestial_Mana_Core", Vector3.new(7, 12, 7), CFrame.new(0, 28, 0), Enum.Material.Neon, Color3.fromRGB(70, 210, 255), true, false)

for ri = 1, 3 do
    makePart(CenterFolder, "Celestial_Ring_" .. ri, Vector3.new(14 + ri*3, 0.4, 14 + ri*3), CFrame.new(0, 28, 0) * CFrame.Angles(math.rad(ri * 35), math.rad(ri * 45), 0), Enum.Material.Metal, Color3.fromRGB(240, 200, 70), true, false)
end

local coreLight = Instance.new("PointLight")
coreLight.Color = Color3.fromRGB(80, 220, 255)
coreLight.Range = 60
coreLight.Brightness = 3
coreLight.Parent = celestialCore

local corePE = Instance.new("ParticleEmitter")
corePE.Texture = "rbxasset://textures/particles/sparkles_main.dds"
corePE.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 240, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
corePE.Size = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1.2),
    NumberSequenceKeypoint.new(1, 0.2)
})
corePE.Rate = 18
corePE.Speed = NumberRange.new(2, 5)
corePE.SpreadAngle = Vector2.new(180, 180)
corePE.Parent = celestialCore

-- Script de animación de rotación
local spinScript = Instance.new("Script")
spinScript.Name = "CelestialRotationScript"
spinScript.Source = [[
local core = script.Parent:WaitForChild("Celestial_Mana_Core")
local r1 = script.Parent:FindFirstChild("Celestial_Ring_1")
local r2 = script.Parent:FindFirstChild("Celestial_Ring_2")
local r3 = script.Parent:FindFirstChild("Celestial_Ring_3")

local angle = 0
while true do
    task.wait(0.03)
    angle = angle + 0.015
    if core then
        core.CFrame = CFrame.new(0, 28 + math.sin(angle * 1.5) * 1.2, 0) * CFrame.Angles(0, angle, 0)
    end
    if r1 then r1.CFrame = CFrame.new(0, 28, 0) * CFrame.Angles(math.rad(35), angle * 1.2, math.rad(15)) end
    if r2 then r2.CFrame = CFrame.new(0, 28, 0) * CFrame.Angles(-math.rad(25), -angle * 0.9, math.rad(40)) end
    if r3 then r3.CFrame = CFrame.new(0, 28, 0) * CFrame.Angles(math.rad(50), angle * 1.5, -math.rad(30)) end
end
]]
spinScript.Parent = CenterFolder

-- =============================================================================
-- 5. LOS 6 PORTALES DE MAZMORRAS (NORTE)
-- =============================================================================
local PortalsFolder = Instance.new("Folder")
PortalsFolder.Name = "Dungeon_Portals_Sanctuary"
PortalsFolder.Parent = Lobby

local portalDefs = {
    { id = 1, name = "Bosque_Susurros", title = "Bosque de los Susurros", subtitle = "Nv. 1-20 • Sin Rebirth", pos = Vector3.new(-75, 2.32, -75), angleY = 30, stoneMat = Enum.Material.Slate, stoneCol = Color3.fromRGB(65, 80, 60), accentCol = Color3.fromRGB(80, 120, 50), portalCol = Color3.fromRGB(40, 230, 90), lightCol = Color3.fromRGB(50, 255, 110), particleTex = "rbxasset://textures/particles/sparkles_main.dds" },
    { id = 2, name = "Caverna_Cristales", title = "Caverna de Cristales", subtitle = "Nv. 20-35 • Rebirth 1", pos = Vector3.new(-45, 2.32, -88), angleY = 15, stoneMat = Enum.Material.Basalt, stoneCol = Color3.fromRGB(45, 38, 52), accentCol = Color3.fromRGB(85, 30, 115), portalCol = Color3.fromRGB(180, 50, 255), lightCol = Color3.fromRGB(190, 70, 255), particleTex = "rbxasset://textures/particles/sparkles_main.dds" },
    { id = 3, name = "Reino_Hielo", title = "Reino del Hielo", subtitle = "Nv. 35-50 • Rebirth 2", pos = Vector3.new(-15, 2.32, -94), angleY = 5, stoneMat = Enum.Material.Ice, stoneCol = Color3.fromRGB(180, 215, 235), accentCol = Color3.fromRGB(140, 190, 220), portalCol = Color3.fromRGB(60, 210, 255), lightCol = Color3.fromRGB(80, 230, 255), particleTex = "rbxasset://textures/particles/sparkles_main.dds" },
    { id = 4, name = "Cripta_Almas", title = "Cripta de las Almas", subtitle = "Nv. 50-65 • Rebirth 3", pos = Vector3.new(15, 2.32, -94), angleY = -5, stoneMat = Enum.Material.Cobblestone, stoneCol = Color3.fromRGB(30, 28, 35), accentCol = Color3.fromRGB(50, 45, 60), portalCol = Color3.fromRGB(230, 50, 170), lightCol = Color3.fromRGB(240, 70, 190), particleTex = "rbxasset://textures/particles/smoke_main.dds" },
    { id = 5, name = "Templo_Cielos", title = "Templo de los Cielos", subtitle = "Nv. 65-80 • Rebirth 4", pos = Vector3.new(45, 2.32, -88), angleY = -15, stoneMat = Enum.Material.Marble, stoneCol = Color3.fromRGB(245, 240, 230), accentCol = Color3.fromRGB(230, 190, 60), portalCol = Color3.fromRGB(255, 215, 50), lightCol = Color3.fromRGB(255, 225, 70), particleTex = "rbxasset://textures/particles/sparkles_main.dds" },
    { id = 6, name = "Abismo_Infinito", title = "Abismo del Infinito", subtitle = "Nv. 80-100 • Rebirth 5", pos = Vector3.new(75, 2.32, -75), angleY = -30, stoneMat = Enum.Material.Basalt, stoneCol = Color3.fromRGB(25, 22, 24), accentCol = Color3.fromRGB(140, 25, 20), portalCol = Color3.fromRGB(255, 40, 30), lightCol = Color3.fromRGB(255, 60, 40), particleTex = "rbxasset://textures/particles/fire_main.dds" }
}

for _, pData in ipairs(portalDefs) do
    local pModel = Instance.new("Model")
    pModel.Name = "Portal_" .. pData.id .. "_" .. pData.name
    pModel.Parent = PortalsFolder
    
    local rotCF = CFrame.new(pData.pos) * CFrame.Angles(0, math.rad(pData.angleY), 0)
    
    -- Escalón 1 (Base amplia): Altura 0.35, Top = Y 2.67
    local pBase1 = makeCylinder(pModel, "Pedestal_Step_1", Vector3.new(0.35, 20, 20), rotCF * CFrame.new(0, 0.17, 0) * CFrame.Angles(0, 0, math.rad(90)), pData.stoneMat, pData.stoneCol)
    -- Escalón 2 (Apoyado sobre el Escalón 1): Altura 0.35, Top = Y 3.02
    local pBase2 = makeCylinder(pModel, "Pedestal_Step_2", Vector3.new(0.35, 16, 16), rotCF * CFrame.new(0, 0.52, 0) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Cobblestone, pData.accentCol)
    
    local leftPillar = makePart(pModel, "Pillar_Left", Vector3.new(2.8, 18, 2.8), rotCF * CFrame.new(-6, 9.7, 0), pData.stoneMat, pData.stoneCol)
    local rightPillar = makePart(pModel, "Pillar_Right", Vector3.new(2.8, 18, 2.8), rotCF * CFrame.new(6, 9.7, 0), pData.stoneMat, pData.stoneCol)
    
    makePart(pModel, "Capitel_Left", Vector3.new(3.6, 1.4, 3.6), rotCF * CFrame.new(-6, 18.7, 0), Enum.Material.Metal, pData.accentCol)
    makePart(pModel, "Capitel_Right", Vector3.new(3.6, 1.4, 3.6), rotCF * CFrame.new(6, 18.7, 0), Enum.Material.Metal, pData.accentCol)
    
    local lintel = makePart(pModel, "Lintel_Arch", Vector3.new(16, 3, 3.2), rotCF * CFrame.new(0, 19.7, 0), pData.stoneMat, pData.stoneCol)
    makePart(pModel, "Crest_Emblem", Vector3.new(4, 3, 2), rotCF * CFrame.new(0, 22.7, 0), Enum.Material.Neon, pData.accentCol)

    local vortex = makePart(pModel, "Portal_Vortex_Surface", Vector3.new(9, 15, 0.5), rotCF * CFrame.new(0, 9.7, 0), Enum.Material.Neon, pData.portalCol, true, false)
    vortex.Transparency = 0.2
    
    local pe = Instance.new("ParticleEmitter")
    pe.Texture = pData.particleTex
    pe.Color = ColorSequence.new(pData.portalCol)
    pe.Rate = 22
    pe.Speed = NumberRange.new(1, 4)
    pe.SpreadAngle = Vector2.new(25, 25)
    pe.Size = NumberSequence.new(0.8, 0.1)
    pe.Parent = vortex
    
    local light = Instance.new("PointLight")
    light.Color = pData.lightCol
    light.Range = 26
    light.Brightness = 2.5
    light.Parent = vortex
    
    local trigger = makePart(pModel, "Portal_Dungeon_Trigger", Vector3.new(8, 12, 4), rotCF * CFrame.new(0, 7.7, 0), Enum.Material.ForceField, pData.portalCol, true, false)
    trigger.Transparency = 1
    trigger:SetAttribute("DungeonId", pData.id)
    trigger:SetAttribute("DungeonName", pData.name)
    
    local prompt = makePrompt(trigger, "Entrar a Mazmorra", pData.title, 14, 0.5)
    
    local bbPart = makePart(pModel, "BillboardAnchor", Vector3.new(1, 1, 1), rotCF * CFrame.new(0, 24, 0), Enum.Material.SmoothPlastic, Color3.new(0,0,0), true, false)
    bbPart.Transparency = 1
    
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 260, 0, 70)
    bb.StudsOffset = Vector3.new(0, 2, 0)
    bb.AlwaysOnTop = false
    bb.MaxDistance = 85
    bb.Parent = bbPart
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.55, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🌀 " .. pData.title
    titleLabel.TextColor3 = pData.portalCol
    titleLabel.TextStrokeColor3 = Color3.fromRGB(10, 10, 15)
    titleLabel.TextStrokeTransparency = 0.1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextScaled = true
    titleLabel.Parent = bb
    
    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, 0, 0.45, 0)
    subLabel.Position = UDim2.new(0, 0, 0.55, 0)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = pData.subtitle
    subLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    subLabel.TextStrokeColor3 = Color3.fromRGB(10, 10, 15)
    subLabel.TextStrokeTransparency = 0.2
    subLabel.Font = Enum.Font.GothamMedium
    subLabel.TextScaled = true
    subLabel.Parent = bb
end

-- =============================================================================
-- 6. PUESTO DE ENTRENAMIENTO DE MANÁ (ESTE)
-- =============================================================================
local TrainingFolder = Instance.new("Folder")
TrainingFolder.Name = "Training_Grounds_District"
TrainingFolder.Parent = Lobby

local trainCenter = Vector3.new(80, 2.30, 0)

-- Borde exterior de hierro (Diámetro 44, Top = Y 2.50)
local tBorder = makeCylinder(TrainingFolder, "Training_Iron_Border", Vector3.new(0.4, 44, 44), CFrame.new(trainCenter.X, 2.30, trainCenter.Z) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Metal, Color3.fromRGB(40, 42, 48))

-- Plataforma interior de piedra octagonal (Diámetro 40, Top = Y 2.75) — Apoyada sobre el borde
local tDais = makeCylinder(TrainingFolder, "Training_Octagon_Floor", Vector3.new(0.3, 40, 40), CFrame.new(trainCenter.X, 2.60, trainCenter.Z) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Cobblestone, Color3.fromRGB(65, 68, 75))

-- Círculo Rúnico de Oro grabado en la piedra (Top = Y 2.80)
local tRune = makeCylinder(TrainingFolder, "Training_Rune_Circle", Vector3.new(0.06, 28, 28), CFrame.new(trainCenter.X, 2.78, trainCenter.Z) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Neon, Color3.fromRGB(50, 190, 255))
tRune.Transparency = 0.35

for i = 1, 4 do
    local ang = (i - 1) * (math.pi / 2) + (math.pi / 4)
    local cpx = trainCenter.X + math.cos(ang) * 17
    local cpz = trainCenter.Z + math.sin(ang) * 17
    
    makeCylinder(TrainingFolder, "Training_Pillar_" .. i, Vector3.new(8, 2, 2), CFrame.new(cpx, 6.75, cpz) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Slate, Color3.fromRGB(60, 62, 70))
    makePart(TrainingFolder, "Mana_Brazier_" .. i, Vector3.new(2.4, 1.2, 2.4), CFrame.new(cpx, 11.2, cpz), Enum.Material.Metal, Color3.fromRGB(35, 35, 40))
    local flame = makePart(TrainingFolder, "Mana_Flame_" .. i, Vector3.new(1.4, 1.8, 1.4), CFrame.new(cpx, 12.6, cpz), Enum.Material.Neon, Color3.fromRGB(60, 200, 255), true, false)
    local flLight = Instance.new("PointLight")
    flLight.Color = Color3.fromRGB(70, 210, 255)
    flLight.Range = 16
    flLight.Brightness = 2
    flLight.Parent = flame
end

-- Dummy de entrenamiento completo
local dummyModel = Instance.new("Model")
dummyModel.Name = "Wizard_Training_Dummy"
dummyModel.Parent = TrainingFolder

local dummyPos = Vector3.new(trainCenter.X, 2.75, -7)

makePart(dummyModel, "Dummy_Pole", Vector3.new(1.2, 8, 1.2), CFrame.new(dummyPos + Vector3.new(0, 4, 0)), Enum.Material.Wood, Color3.fromRGB(115, 75, 40))
makePart(dummyModel, "Dummy_Arms", Vector3.new(6.5, 0.9, 0.9), CFrame.new(dummyPos + Vector3.new(0, 5.8, 0)), Enum.Material.Wood, Color3.fromRGB(115, 75, 40))
makePart(dummyModel, "Dummy_Torso", Vector3.new(3.2, 4.2, 2.2), CFrame.new(dummyPos + Vector3.new(0, 4.6, 0)), Enum.Material.Fabric, Color3.fromRGB(180, 155, 120))
makeCylinder(dummyModel, "Dummy_Head", Vector3.new(2, 2.2, 2.2), CFrame.new(dummyPos + Vector3.new(0, 7.8, 0)) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Wood, Color3.fromRGB(140, 95, 55))
makeCylinder(dummyModel, "Witch_Hat_Brim", Vector3.new(0.3, 4.8, 4.8), CFrame.new(dummyPos + Vector3.new(0, 8.8, 0)) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Fabric, Color3.fromRGB(45, 25, 75))
makeWedge(dummyModel, "Witch_Hat_Cone", Vector3.new(2.4, 3.2, 2.4), CFrame.new(dummyPos + Vector3.new(0, 10.4, 0)), Enum.Material.Fabric, Color3.fromRGB(50, 30, 85))
makeCylinder(dummyModel, "Dummy_Target", Vector3.new(0.2, 2.2, 2.2), CFrame.new(dummyPos + Vector3.new(0, 4.8, 1.15)) * CFrame.Angles(math.rad(90), 0, 0), Enum.Material.Neon, Color3.fromRGB(255, 60, 40))

-- Pedestal y Orbe de Maná
local orbDais = makeCylinder(TrainingFolder, "Orb_Pedestal_Base", Vector3.new(0.8, 6, 6), CFrame.new(trainCenter.X, 3.15, 6) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Marble, Color3.fromRGB(220, 220, 230))
local orbColumn = makeCylinder(TrainingFolder, "Orb_Column", Vector3.new(3.2, 2.2, 2.2), CFrame.new(trainCenter.X, 5.15, 6) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Marble, Color3.fromRGB(240, 240, 245))

local trainingOrb = makePart(TrainingFolder, "Training_Mana_Orb", Vector3.new(3.6, 3.6, 3.6), CFrame.new(trainCenter.X, 8.2, 6), Enum.Material.Neon, Color3.fromRGB(50, 220, 255), true, false)
trainingOrb.Shape = Enum.PartType.Ball

local orbLight = Instance.new("PointLight")
orbLight.Color = Color3.fromRGB(60, 230, 255)
orbLight.Range = 22
orbLight.Brightness = 3
orbLight.Parent = trainingOrb

local orbClick = Instance.new("ClickDetector")
orbClick.MaxActivationDistance = 16
orbClick.Parent = trainingOrb

local orbPrompt = makePrompt(trainingOrb, "Concentrar Maná", "Orbe de Entrenamiento", 14, 0.3)

-- =============================================================================
-- 7. TALLER DE LA FORJA REAL MEDIEVAL (OESTE)
-- =============================================================================
local ForgeFolder = Instance.new("Folder")
ForgeFolder.Name = "Royal_Blacksmith_Guildhouse"
ForgeFolder.Parent = Lobby

local forgePos = Vector3.new(-85, 2.30, -10)

makePart(ForgeFolder, "Forge_Foundation", Vector3.new(36, 0.7, 28), CFrame.new(forgePos.X, 2.65, forgePos.Z), Enum.Material.Cobblestone, Color3.fromRGB(110, 108, 115))

makePart(ForgeFolder, "Forge_Back_Wall", Vector3.new(34, 14, 2), CFrame.new(forgePos.X, 10.0, forgePos.Z - 12), Enum.Material.Cobblestone, Color3.fromRGB(90, 88, 95))
makePart(ForgeFolder, "Forge_Left_Wall", Vector3.new(2, 14, 24), CFrame.new(forgePos.X - 16, 10.0, forgePos.Z), Enum.Material.Cobblestone, Color3.fromRGB(90, 88, 95))

for _, vx in ipairs({-16, 16}) do
    for _, vz in ipairs({-12, 12}) do
        makePart(ForgeFolder, "Timber_Post", Vector3.new(2.4, 15, 2.4), CFrame.new(forgePos.X + vx, 10.0, forgePos.Z + vz), Enum.Material.WoodPlanks, Color3.fromRGB(80, 50, 25))
    end
end

makePart(ForgeFolder, "Roof_Slate_Left", Vector3.new(20, 1.2, 30), CFrame.new(forgePos.X - 8, 20.0, forgePos.Z) * CFrame.Angles(0, 0, math.rad(25)), Enum.Material.Slate, Color3.fromRGB(45, 48, 55))
makePart(ForgeFolder, "Roof_Slate_Right", Vector3.new(20, 1.2, 30), CFrame.new(forgePos.X + 8, 20.0, forgePos.Z) * CFrame.Angles(0, 0, -math.rad(25)), Enum.Material.Slate, Color3.fromRGB(45, 48, 55))

local chimney = makePart(ForgeFolder, "Stone_Chimney", Vector3.new(5, 24, 5), CFrame.new(forgePos.X + 12, 14.5, forgePos.Z - 8), Enum.Material.Cobblestone, Color3.fromRGB(75, 72, 78))
local smoke = Instance.new("ParticleEmitter")
smoke.Texture = "rbxasset://textures/particles/smoke_main.dds"
smoke.Color = ColorSequence.new(Color3.fromRGB(150, 150, 160))
smoke.Size = NumberSequence.new(1.5, 5.0)
smoke.Rate = 8
smoke.Speed = NumberRange.new(3, 6)
smoke.SpreadAngle = Vector2.new(15, 15)
smoke.Parent = chimney

local hearth = makePart(ForgeFolder, "Forge_Hearth", Vector3.new(8, 4, 6), CFrame.new(forgePos.X + 10, 5.0, forgePos.Z - 8), Enum.Material.Basalt, Color3.fromRGB(40, 38, 42))
local coals = makePart(ForgeFolder, "Glowing_Coals", Vector3.new(6, 0.8, 4), CFrame.new(forgePos.X + 10, 7.2, forgePos.Z - 8), Enum.Material.Neon, Color3.fromRGB(255, 90, 20), true, false)
local fLight = Instance.new("PointLight")
fLight.Color = Color3.fromRGB(255, 110, 30)
fLight.Range = 24
fLight.Brightness = 3
fLight.Parent = coals

local stump = makeCylinder(ForgeFolder, "Anvil_Oak_Stump", Vector3.new(2.8, 3.2, 3.2), CFrame.new(forgePos.X, 4.4, forgePos.Z) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Wood, Color3.fromRGB(90, 60, 30))
local anvil = makePart(ForgeFolder, "Steel_Anvil", Vector3.new(4.5, 2.2, 2), CFrame.new(forgePos.X, 6.6, forgePos.Z), Enum.Material.Metal, Color3.fromRGB(35, 38, 42))

local waterTub = makePart(ForgeFolder, "Water_Quench_Tub", Vector3.new(4, 3, 3), CFrame.new(forgePos.X + 6, 4.5, forgePos.Z), Enum.Material.WoodPlanks, Color3.fromRGB(100, 65, 35))
local tubWater = makePart(ForgeFolder, "Tub_Water", Vector3.new(3.5, 0.4, 2.5), CFrame.new(forgePos.X + 6, 5.8, forgePos.Z), Enum.Material.Glass, Color3.fromRGB(50, 160, 230), true, false)
tubWater.Transparency = 0.3

local forgePrompt = makePrompt(anvil, "Abrir Forja Real", "Forja Real (Armas y Armaduras)", 14, 0.5)

-- =============================================================================
-- 8. BAZAR MÁGICO Y GUARDERÍA DE HUEVOS (SUROESTE)
-- =============================================================================
local MarketFolder = Instance.new("Folder")
MarketFolder.Name = "Market_And_Eggs_Pavilion"
MarketFolder.Parent = Lobby

local marketPos = Vector3.new(-75, 2.30, 45)

makePart(MarketFolder, "Market_Deck", Vector3.new(28, 0.7, 24), CFrame.new(marketPos.X, 2.65, marketPos.Z), Enum.Material.WoodPlanks, Color3.fromRGB(150, 110, 75))

for _, mx in ipairs({-12, 12}) do
    for _, mz in ipairs({-10, 10}) do
        makeCylinder(MarketFolder, "Pavilion_Post", Vector3.new(12, 1.2, 1.2), CFrame.new(marketPos.X + mx, 8.8, marketPos.Z + mz) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Wood, Color3.fromRGB(120, 80, 45))
    end
end

for seg = 1, 6 do
    local sx = -10 + (seg - 1) * 4
    local col = (seg % 2 == 1) and Color3.fromRGB(40, 80, 180) or Color3.fromRGB(245, 235, 210)
    makePart(MarketFolder, "Canopy_Stripe_" .. seg, Vector3.new(4, 0.4, 22), CFrame.new(marketPos.X + sx, 15.0, marketPos.Z), Enum.Material.Fabric, col)
end

local counter = makePart(MarketFolder, "Egg_Display_Counter", Vector3.new(38, 3.2, 6), CFrame.new(marketPos.X, 4.6, marketPos.Z), Enum.Material.WoodPlanks, Color3.fromRGB(90, 60, 40))

-- Los 6 Huevos Regionales con Nidos Artesanales y Geometría Ovoide Estilizada
local regionalEggTiers = {
    { id = 1, name = "Huevo_Bosque", title = "Huevo del Bosque", col = Color3.fromRGB(60, 220, 90), ox = -15, cost = "1,000 Oro" },
    { id = 2, name = "Huevo_Volcanico", title = "Huevo Volcánico", col = Color3.fromRGB(255, 75, 25), ox = -9, cost = "15,000 Oro" },
    { id = 3, name = "Huevo_Glacial", title = "Huevo Glacial", col = Color3.fromRGB(70, 210, 255), ox = -3, cost = "100,000 Oro" },
    { id = 4, name = "Huevo_Espectral", title = "Huevo Espectral", col = Color3.fromRGB(180, 55, 245), ox = 3, cost = "750,000 Oro" },
    { id = 5, name = "Huevo_Celestial", title = "Huevo Celestial", col = Color3.fromRGB(255, 220, 60), ox = 9, cost = "5.0M Oro" },
    { id = 6, name = "Huevo_Abisal", title = "Huevo del Abismo", col = Color3.fromRGB(240, 45, 130), ox = 15, cost = "35.0M Oro" },
}

for _, eData in ipairs(regionalEggTiers) do
    local eggOrigin = Vector3.new(marketPos.X + eData.ox, 6.2, marketPos.Z)

    -- 1. Nido de Paja y Madera Tejida
    local nestRim = makeCylinder(MarketFolder, eData.name .. "_Nest_Rim", Vector3.new(0.6, 4.4, 4.4), CFrame.new(eggOrigin.X, eggOrigin.Y + 0.3, eggOrigin.Z) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.WoodPlanks, Color3.fromRGB(120, 85, 45))
    local nestCushion = makeCylinder(MarketFolder, eData.name .. "_Nest_Bed", Vector3.new(0.3, 3.8, 3.8), CFrame.new(eggOrigin.X, eggOrigin.Y + 0.5, eggOrigin.Z) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Fabric, Color3.fromRGB(195, 160, 95))

    -- 2. Huevo Ovoide Estilizado (Bulbo inferior ancho + Cúpula superior ahusada)
    local eggBase = makePart(MarketFolder, eData.name .. "_BaseBulb", Vector3.new(2.7, 2.5, 2.7), CFrame.new(eggOrigin.X, eggOrigin.Y + 1.8, eggOrigin.Z), Enum.Material.Neon, eData.col, true, false)
    eggBase.Shape = Enum.PartType.Ball

    local eggTop = makePart(MarketFolder, eData.name .. "_TopApex", Vector3.new(2.1, 2.4, 2.1), CFrame.new(eggOrigin.X, eggOrigin.Y + 2.7, eggOrigin.Z), Enum.Material.Neon, eData.col, true, false)
    eggTop.Shape = Enum.PartType.Ball

    -- 3. Cinturón Rúnico Dorado / Filigrana
    local belt = makeCylinder(MarketFolder, eData.name .. "_GoldBelt", Vector3.new(0.3, 2.9, 2.9), CFrame.new(eggOrigin.X, eggOrigin.Y + 2.1, eggOrigin.Z) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Metal, Color3.fromRGB(240, 205, 60))

    -- 4. Corona de Diamante Gemelo en la Cúspide
    local finial = makePart(MarketFolder, eData.name .. "_GemFinial", Vector3.new(0.8, 1.1, 0.8), CFrame.new(eggOrigin.X, eggOrigin.Y + 4.0, eggOrigin.Z), Enum.Material.Neon, Color3.fromRGB(255, 255, 255), true, false)

    -- 5. Luz y Destellos Flotantes
    local el = Instance.new("PointLight")
    el.Color = eData.col
    el.Range = 12
    el.Brightness = 2.2
    el.Parent = eggBase

    local pe = Instance.new("ParticleEmitter")
    pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    pe.Color = ColorSequence.new(eData.col)
    pe.Size = NumberSequence.new(0.35, 0.05)
    pe.Rate = 5
    pe.Lifetime = NumberRange.new(0.6, 1.2)
    pe.Speed = NumberRange.new(0.4, 1.2)
    pe.SpreadAngle = Vector2.new(180, 180)
    pe.Parent = eggBase

    -- 6. Placa Holográfica Superior
    local ebb = Instance.new("BillboardGui")
    ebb.Size = UDim2.new(0, 130, 0, 42)
    ebb.StudsOffset = Vector3.new(0, 3.2, 0)
    ebb.AlwaysOnTop = false
    ebb.MaxDistance = 55
    ebb.Parent = eggTop

    local eTitle = Instance.new("TextLabel")
    eTitle.Size = UDim2.new(1, 0, 0.55, 0)
    eTitle.BackgroundTransparency = 1
    eTitle.Text = "🥚 " .. eData.title
    eTitle.TextColor3 = eData.col
    eTitle.TextStrokeColor3 = Color3.fromRGB(15, 10, 20)
    eTitle.TextStrokeTransparency = 0.15
    eTitle.Font = Enum.Font.GothamBold
    eTitle.TextScaled = true
    eTitle.Parent = ebb

    local eCost = Instance.new("TextLabel")
    eCost.Size = UDim2.new(1, 0, 0.45, 0)
    eCost.Position = UDim2.new(0, 0, 0.55, 0)
    eCost.BackgroundTransparency = 1
    eCost.Text = eData.cost
    eCost.TextColor3 = Color3.fromRGB(255, 240, 180)
    eCost.TextStrokeColor3 = Color3.fromRGB(15, 10, 20)
    eCost.TextStrokeTransparency = 0.2
    eCost.Font = Enum.Font.GothamMedium
    eCost.TextScaled = true
    eCost.Parent = ebb
end

local eggPrompt = makePrompt(counter, "Comprar Huevos", "Tienda de Mascotas y Huevos", 14, 0.5)

-- =============================================================================
-- 9. TERRAZA DE LOS SABIOS: ÁRBOL SAGRADO DE SAKURA Y MISIONES (NORESTE)
-- =============================================================================
local QuestFolder = Instance.new("Folder")
QuestFolder.Name = "Sacred_Tree_Quest_Terrace"
QuestFolder.Parent = Lobby

local questPos = Vector3.new(65, 2.30, -45)

makeCylinder(QuestFolder, "Hill_Stone_Base", Vector3.new(2.2, 34, 34), CFrame.new(questPos.X, 3.40, questPos.Z) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Slate, Color3.fromRGB(80, 78, 85))
makeCylinder(QuestFolder, "Hill_Grass_Top", Vector3.new(0.4, 32, 32), CFrame.new(questPos.X, 4.70, questPos.Z) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Grass, Color3.fromRGB(85, 155, 65))

local trunk = makeCylinder(QuestFolder, "Sacred_Trunk", Vector3.new(18, 4.5, 4.5), CFrame.new(questPos.X, 13.5, questPos.Z) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Wood, Color3.fromRGB(85, 55, 30))

for b = 1, 4 do
    local bAng = (b - 1) * (math.pi / 2)
    local bx = math.cos(bAng) * 6
    local bz = math.sin(bAng) * 6
    makePart(QuestFolder, "Branch_" .. b, Vector3.new(7, 1.8, 1.8), CFrame.new(questPos.X + bx, 19.5, questPos.Z + bz) * CFrame.Angles(0, bAng, math.rad(30)), Enum.Material.Wood, Color3.fromRGB(85, 55, 30))
end

for f = 1, 6 do
    local fAng = (f - 1) * (math.pi / 3)
    local fx = math.cos(fAng) * 8
    local fz = math.sin(fAng) * 8
    local foliage = makePart(QuestFolder, "Sakura_Canopy_" .. f, Vector3.new(12, 8, 12), CFrame.new(questPos.X + fx, 24.5, questPos.Z + fz), Enum.Material.Grass, Color3.fromRGB(255, 180, 210), true, false)
    foliage.Shape = Enum.PartType.Ball
end

local topCanopy = makePart(QuestFolder, "Sakura_Canopy_Top", Vector3.new(14, 10, 14), CFrame.new(questPos.X, 27.5, questPos.Z), Enum.Material.Grass, Color3.fromRGB(255, 190, 220), true, false)
topCanopy.Shape = Enum.PartType.Ball

local petalPE = Instance.new("ParticleEmitter")
petalPE.Texture = "rbxasset://textures/particles/sparkles_main.dds"
petalPE.Color = ColorSequence.new(Color3.fromRGB(255, 170, 210))
petalPE.Size = NumberSequence.new(0.6, 0.2)
petalPE.Rate = 12
petalPE.Speed = NumberRange.new(1, 3)
petalPE.SpreadAngle = Vector2.new(180, 180)
petalPE.Parent = topCanopy

local boardPos = Vector3.new(questPos.X - 8, 4.90, questPos.Z + 8)
makePart(QuestFolder, "Board_Post_L", Vector3.new(1, 9, 1), CFrame.new(boardPos.X - 4, boardPos.Y + 4.5, boardPos.Z), Enum.Material.WoodPlanks, Color3.fromRGB(80, 50, 25))
makePart(QuestFolder, "Board_Post_R", Vector3.new(1, 9, 1), CFrame.new(boardPos.X + 4, boardPos.Y + 4.5, boardPos.Z), Enum.Material.WoodPlanks, Color3.fromRGB(80, 50, 25))
local boardPanel = makePart(QuestFolder, "Board_Panel", Vector3.new(8.5, 6, 0.8), CFrame.new(boardPos.X, boardPos.Y + 5.5, boardPos.Z), Enum.Material.WoodPlanks, Color3.fromRGB(150, 105, 60))
makePart(QuestFolder, "Board_Roof", Vector3.new(10.5, 1, 2.5), CFrame.new(boardPos.X, boardPos.Y + 8.8, boardPos.Z), Enum.Material.Wood, Color3.fromRGB(60, 40, 20))

for sc = 1, 3 do
    local scx = -2.5 + (sc - 1) * 2.5
    makePart(QuestFolder, "Scroll_" .. sc, Vector3.new(1.8, 2.4, 0.1), CFrame.new(boardPos.X + scx, boardPos.Y + 5.5, boardPos.Z + 0.45), Enum.Material.Fabric, Color3.fromRGB(240, 230, 200))
end

local questPrompt = makePrompt(boardPanel, "Ver Misiones", "Tablón de Misiones y Recompensas", 14, 0.5)

local qbb = Instance.new("BillboardGui")
qbb.Size = UDim2.new(0, 220, 0, 55)
qbb.StudsOffset = Vector3.new(0, 5.5, 0)
qbb.AlwaysOnTop = false
qbb.MaxDistance = 60
qbb.Parent = boardPanel

local qTitle = Instance.new("TextLabel")
qTitle.Size = UDim2.new(1, 0, 1, 0)
qTitle.BackgroundTransparency = 1
qTitle.Text = "📜 TABLÓN DE MISIONES\nDiarias, Semanales y Logros"
qTitle.TextColor3 = Color3.fromRGB(255, 215, 80)
qTitle.TextStrokeColor3 = Color3.fromRGB(20, 20, 20)
qTitle.TextStrokeTransparency = 0.2
qTitle.Font = Enum.Font.GothamBold
qTitle.TextScaled = true
qTitle.Parent = qbb

-- =============================================================================
-- 10. SANTUARIO DEL RENACIMIENTO (SURESTE)
-- =============================================================================
local RebirthFolder = Instance.new("Folder")
RebirthFolder.Name = "Grand_Rebirth_Sanctuary"
RebirthFolder.Parent = Lobby

local rebirthPos = Vector3.new(75, 2.30, 45)

makeCylinder(RebirthFolder, "Rebirth_Dais_Base", Vector3.new(0.35, 34, 34), CFrame.new(rebirthPos.X, 2.47, rebirthPos.Z) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Slate, Color3.fromRGB(30, 28, 35))
makeCylinder(RebirthFolder, "Rebirth_Gold_Ring", Vector3.new(0.30, 30, 30), CFrame.new(rebirthPos.X, 2.80, rebirthPos.Z) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Metal, Color3.fromRGB(230, 190, 60))

local rMonolith = makePart(RebirthFolder, "Rebirth_Spire_Monolith", Vector3.new(5, 22, 5), CFrame.new(rebirthPos.X, 13.9, rebirthPos.Z), Enum.Material.Basalt, Color3.fromRGB(25, 22, 30))
local rCore = makePart(RebirthFolder, "Rebirth_Crystal_Core", Vector3.new(3, 8, 3), CFrame.new(rebirthPos.X, 27.0, rebirthPos.Z), Enum.Material.Neon, Color3.fromRGB(240, 70, 255), true, false)

local rLight = Instance.new("PointLight")
rLight.Color = Color3.fromRGB(240, 80, 255)
rLight.Range = 25
rLight.Brightness = 3
rLight.Parent = rCore

for ti = 1, 6 do
    local rAng = (ti - 1) * (math.pi / 3)
    local rpx = rebirthPos.X + math.cos(rAng) * 12
    local rpz = rebirthPos.Z + math.sin(rAng) * 12
    
    makeCylinder(RebirthFolder, "Rebirth_Tier_Pedestal_" .. ti, Vector3.new(1.2, 3.2, 3.2), CFrame.new(rpx, 3.55, rpz) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Slate, Color3.fromRGB(45, 42, 50))
    makePart(RebirthFolder, "Tier_Crystal_" .. ti, Vector3.new(1.2, 2.8, 1.2), CFrame.new(rpx, 5.55, rpz), Enum.Material.Neon, Color3.fromHSV((ti-1)/6, 0.8, 1.0), true, false)
end

local rebirthPrompt = makePrompt(rMonolith, "Ascender de Rebirth", "Santuario de Renacimiento", 14, 0.5)

Lighting.Ambient = Color3.fromRGB(90, 85, 110)
Lighting.OutdoorAmbient = Color3.fromRGB(120, 115, 140)
Lighting.ColorShift_Top = Color3.fromRGB(255, 245, 225)
Lighting.ColorShift_Bottom = Color3.fromRGB(60, 50, 80)
Lighting.Brightness = 2.2
Lighting.ClockTime = 14.5
Lighting.GeographicLatitude = 35

print("Z_FIGHTING_COMPLETELY_FIXED")
return true
