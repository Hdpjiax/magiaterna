--!strict
--[[
    build_region4_dungeon.luau
    Construye físicamente la Región 4 completa: Cripta de las Almas en MAGIA ETERNA
    - Ubicación: baseX = 0, baseY = 50, baseZ = -800 (800 studs al Sur del Lobby, eje cardinal limpio).
    - 5 Salas Temáticas:
      1. Room1_Catacombs_Entrance: Nichos funerarios, paredes de obsidiana, antorchas de fuego espectral y 3 Esqueletos Malditos.
      2. Room2_Skull_Bridge: Puente de cráneos y huesos sobre foso de almas violetas y 2 Espectros de Cripta.
      3. Room3_Dark_Circle: Círculo ritual de invocación nigromántica, calderos de ectoplasma y 2 Nigromantes.
      4. Room4_DeathKnight_Arena: Anfiteatro circular de basalto con 4 estelas funerarias y el MiniJefe Caballero Sin Alma (11 studs).
      5. Room5_Lich_Mausoleum: Mausoleo colosal de 90 studs, anillos AoE de corrupción espectral, el Jefe Final Rey de las Almas (20 studs),
         Cofre de Plata Maldita y Portal de Retorno al Lobby.
    - 4 Puertas Rúnicas de Almas con AlwaysOnTop = false y MaxDistance = 25.
]]

local Workspace = game:GetService("Workspace")

local baseX = 0
local baseY = 50
local baseZ = -800

local dungeon = Instance.new("Model")
dungeon.Name = "Dungeon_Cripta_Almas"

-- Limpiar versión previa si existiera
local existing = Workspace:FindFirstChild("Dungeon_Cripta_Almas") or Workspace:FindFirstChild("Dungeon_Cripta")
if existing then
    existing:Destroy()
end

local function createPart(parent: Instance, name: string, size: Vector3, cf: CFrame, col: Color3, mat: Enum.Material, canCollide: boolean?, trans: number?): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Color = col
    p.Material = mat
    p.Anchored = true
    p.CanCollide = (canCollide ~= nil) and canCollide or true
    p.Transparency = trans or 0
    p.Parent = parent
    return p
end

local function createHealthTag(parent: Instance, name: string, lvl: string, hp: number, maxHp: number, isBoss: boolean?): BillboardGui
    local bb = Instance.new("BillboardGui")
    bb.Name = "EnemyHealthTag"
    bb.Size = isBoss and UDim2.new(0, 240, 0, 50) or UDim2.new(0, 160, 0, 36)
    bb.StudsOffset = isBoss and Vector3.new(0, 13, 0) or Vector3.new(0, 3.8, 0)
    bb.AlwaysOnTop = false
    bb.MaxDistance = isBoss and 60 or 35
    bb.Adornee = parent:IsA("BasePart") and parent or nil

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(20, 12, 28)
    bg.BackgroundTransparency = 0.25
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = bg

    local stroke = Instance.new("UIStroke")
    stroke.Color = isBoss and Color3.fromRGB(210, 90, 255) or Color3.fromRGB(170, 70, 240)
    stroke.Thickness = isBoss and 2 or 1.5
    stroke.Parent = bg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.5, 0)
    title.Position = UDim2.new(0, 0, 0.05, 0)
    title.BackgroundTransparency = 1
    title.Text = name .. " • " .. lvl
    title.TextColor3 = isBoss and Color3.fromRGB(245, 200, 255) or Color3.fromRGB(220, 180, 255)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = bg

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0.9, 0, 0.3, 0)
    track.Position = UDim2.new(0.05, 0, 0.6, 0)
    track.BackgroundColor3 = Color3.fromRGB(35, 20, 48)
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 4)
    tc.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(hp / maxHp, 0, 1, 0)
    fill.BackgroundColor3 = isBoss and Color3.fromRGB(190, 50, 255) or Color3.fromRGB(160, 40, 220)
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 4)
    fc.Parent = fill
    fill.Parent = track
    track.Parent = bg

    bg.Parent = bb
    bb.Parent = parent
    return bb
end

-- Contenedor de Puertas Rúnicas
local gatesFolder = Instance.new("Folder")
gatesFolder.Name = "Dungeon_Gates"
gatesFolder.Parent = dungeon

local function createSpectralGate(gateName: string, cf: CFrame, roomFrom: number, roomTo: number)
    local gateModel = Instance.new("Model")
    gateModel.Name = gateName
    gateModel:SetAttribute("IsOpen", false)

    -- Columnas de obsidiana
    createPart(gateModel, "Gate_Pillar_L", Vector3.new(4, 22, 4), cf * CFrame.new(-12, 11, 0), Color3.fromRGB(25, 20, 30), Enum.Material.Slate)
    createPart(gateModel, "Gate_Pillar_R", Vector3.new(4, 22, 4), cf * CFrame.new(12, 11, 0), Color3.fromRGB(25, 20, 30), Enum.Material.Slate)
    createPart(gateModel, "Gate_Arch", Vector3.new(28, 4, 4), cf * CFrame.new(0, 22, 0), Color3.fromRGB(30, 24, 38), Enum.Material.Slate)

    -- Cristales de amatista espectral en las jambas
    local gemL = createPart(gateModel, "RuneGem_L", Vector3.new(1.8, 4, 1.8), cf * CFrame.new(-12, 14, 0), Color3.fromRGB(190, 60, 255), Enum.Material.Neon)
    local gemR = createPart(gateModel, "RuneGem_R", Vector3.new(1.8, 4, 1.8), cf * CFrame.new(12, 14, 0), Color3.fromRGB(190, 60, 255), Enum.Material.Neon)

    -- Barrera espectral de almas
    local barrier = createPart(gateModel, "Runic_Barrier", Vector3.new(20, 20, 1.5), cf * CFrame.new(0, 10, 0), Color3.fromRGB(140, 30, 210), Enum.Material.Glass, true, 0.4)

    -- Luz espectral violeta
    local pl = Instance.new("PointLight")
    pl.Color = Color3.fromRGB(170, 50, 255)
    pl.Range = 25
    pl.Brightness = 2.5
    pl.Parent = barrier

    -- Billboard indicativo con AlwaysOnTop = false y MaxDistance = 25
    local bb = Instance.new("BillboardGui")
    bb.Name = "GatePromptGui"
    bb.Size = UDim2.new(0, 180, 0, 40)
    bb.StudsOffset = Vector3.new(0, 12, 0)
    bb.AlwaysOnTop = false
    bb.MaxDistance = 25
    bb.Adornee = barrier

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundColor3 = Color3.fromRGB(25, 15, 35)
    txt.BackgroundTransparency = 0.2
    txt.Text = string.format("🔒 BARRERA DE ALMAS\nSala %d → Sala %d", roomFrom, roomTo)
    txt.TextColor3 = Color3.fromRGB(230, 170, 255)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 11
    txt.Parent = bb
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = txt

    bb.Parent = gateModel
    gateModel.Parent = gatesFolder
end

-- ============================================================================
-- SALA 1: ENTRADA A LAS CATACUMBAS (Z: -780 a -830)
-- ============================================================================
local room1 = Instance.new("Model")
room1.Name = "Room1_Catacombs_Entrance"

-- Suelo y paredes de basalto pulido
createPart(room1, "Floor_R1", Vector3.new(65, 4, 70), CFrame.new(baseX, baseY, baseZ - 10), Color3.fromRGB(30, 26, 36), Enum.Material.Slate)
createPart(room1, "Wall_Back", Vector3.new(65, 24, 4), CFrame.new(baseX, baseY + 12, baseZ + 25), Color3.fromRGB(22, 18, 28), Enum.Material.Slate)
createPart(room1, "Wall_Left", Vector3.new(4, 24, 70), CFrame.new(baseX - 32, baseY + 12, baseZ - 10), Color3.fromRGB(22, 18, 28), Enum.Material.Slate)
createPart(room1, "Wall_Right", Vector3.new(4, 24, 70), CFrame.new(baseX + 32, baseY + 12, baseZ - 10), Color3.fromRGB(22, 18, 28), Enum.Material.Slate)
createPart(room1, "Ceiling_R1", Vector3.new(65, 4, 70), CFrame.new(baseX, baseY + 24, baseZ - 10), Color3.fromRGB(18, 14, 24), Enum.Material.Slate)

-- 4 Antorchas funerarias de fuego espectral violeta
local torchPositionsR1 = {
    Vector3.new(baseX - 25, baseY + 6, baseZ + 15),
    Vector3.new(baseX + 25, baseY + 6, baseZ + 15),
    Vector3.new(baseX - 25, baseY + 6, baseZ - 30),
    Vector3.new(baseX + 25, baseY + 6, baseZ - 30),
}
for i, pos in ipairs(torchPositionsR1) do
    local stand = createPart(room1, "Torch_Stand_" .. i, Vector3.new(1.8, 8, 1.8), CFrame.new(pos), Color3.fromRGB(45, 40, 50), Enum.Material.Metal)
    local flame = createPart(room1, "Flame_" .. i, Vector3.new(2, 2.5, 2), CFrame.new(pos + Vector3.new(0, 4.5, 0)), Color3.fromRGB(175, 45, 255), Enum.Material.Neon, false)
    local pl = Instance.new("PointLight")
    pl.Color = Color3.fromRGB(180, 50, 255)
    pl.Range = 26
    pl.Brightness = 2.2
    pl.Parent = flame
end

-- Plataforma de Entrada / Spawn de la Mazmorra
local spawnPad = createPart(room1, "Dungeon_SpawnPad", Vector3.new(16, 1.5, 16), CFrame.new(baseX, baseY + 2.5, baseZ + 15), Color3.fromRGB(50, 30, 75), Enum.Material.Marble)
local spawnRune = createPart(room1, "SpawnRune", Vector3.new(12, 0.4, 12), CFrame.new(baseX, baseY + 3.4, baseZ + 15), Color3.fromRGB(190, 70, 255), Enum.Material.Neon, false)

-- Nichos funerarios en las paredes laterales con calaveras ornamentales
for _, xOffset in ipairs({ -30, 30 }) do
    for zOffset = -25, 15, 18 do
        local niche = createPart(room1, "Niche", Vector3.new(2, 6, 8), CFrame.new(baseX + xOffset, baseY + 7, baseZ + zOffset), Color3.fromRGB(15, 10, 22), Enum.Material.Slate)
        local skull = createPart(room1, "BoneUrn", Vector3.new(2.5, 2.5, 2.5), CFrame.new(baseX + (xOffset * 0.94), baseY + 5.5, baseZ + zOffset), Color3.fromRGB(225, 220, 205), Enum.Material.SmoothPlastic)
    end
end

-- 3 Enemigos: Esqueletos de la Cripta (Nv. 30, HP 900)
local skeletonSpawns = {
    Vector3.new(baseX - 14, baseY + 4.5, baseZ - 20),
    Vector3.new(baseX, baseY + 4.5, baseZ - 30),
    Vector3.new(baseX + 14, baseY + 4.5, baseZ - 20),
}
for i, pos in ipairs(skeletonSpawns) do
    local skel = Instance.new("Model")
    skel.Name = "Enemy_EsqueletoCripta_" .. i
    skel:SetAttribute("EnemyId", "Enemy_EsqueletoCripta")
    skel:SetAttribute("MaxHealth", 900)
    skel:SetAttribute("CurrentHealth", 900)

    local hrp = createPart(skel, "HumanoidRootPart", Vector3.new(2.5, 5, 2), CFrame.new(pos), Color3.fromRGB(215, 210, 200), Enum.Material.Sandstone)
    local skull = createPart(skel, "Head", Vector3.new(2, 2, 2), CFrame.new(pos + Vector3.new(0, 3.2, 0)), Color3.fromRGB(230, 225, 215), Enum.Material.SmoothPlastic)
    local ribcage = createPart(skel, "Torso", Vector3.new(2.8, 3.2, 1.8), CFrame.new(pos + Vector3.new(0, 0.8, 0)), Color3.fromRGB(195, 190, 180), Enum.Material.Sandstone)
    local eyesL = createPart(skel, "EyeL", Vector3.new(0.4, 0.4, 0.4), skull.CFrame * CFrame.new(-0.5, 0.2, 1), Color3.fromRGB(190, 40, 255), Enum.Material.Neon, false)
    local eyesR = createPart(skel, "EyeR", Vector3.new(0.4, 0.4, 0.4), skull.CFrame * CFrame.new(0.5, 0.2, 1), Color3.fromRGB(190, 40, 255), Enum.Material.Neon, false)

    -- Espada oxidada de hueso
    createPart(skel, "BoneBlade", Vector3.new(0.6, 5, 1.2), hrp.CFrame * CFrame.new(2.2, 0, 0.5) * CFrame.Angles(0, 0, math.rad(-25)), Color3.fromRGB(120, 115, 125), Enum.Material.Metal)

    local hum = Instance.new("Humanoid")
    hum.MaxHealth = 900
    hum.Health = 900
    hum.DisplayName = "Esqueleto Maldito"
    hum.Parent = skel

    createHealthTag(hrp, "Esqueleto Maldito", "Nv. 30", 900, 900)
    skel.PrimaryPart = hrp
    skel.Parent = room1
end

room1.Parent = dungeon

-- PUERTA 1 -> 2
createSpectralGate("Gate_Room1_To_Room2", CFrame.new(baseX, baseY + 2, baseZ - 48), 1, 2)

-- ============================================================================
-- SALA 2: EL PUENTE DE CRÁNEOS (Z: -850 a -915)
-- ============================================================================
local room2 = Instance.new("Model")
room2.Name = "Room2_Skull_Bridge"

-- Foso colosal de almas espectrales (abismo de 25 studs hacia abajo)
local soulPit = createPart(room2, "SoulPit_Floor", Vector3.new(80, 2, 85), CFrame.new(baseX, baseY - 22, baseZ - 85), Color3.fromRGB(10, 5, 18), Enum.Material.Basalt)
local soulMist = createPart(room2, "SoulMist_Surface", Vector3.new(78, 1, 83), CFrame.new(baseX, baseY - 18, baseZ - 85), Color3.fromRGB(140, 20, 210), Enum.Material.Neon, false, 0.6)
local mistLight = Instance.new("PointLight")
mistLight.Color = Color3.fromRGB(150, 40, 240)
mistLight.Range = 45
mistLight.Brightness = 2.0
mistLight.Parent = soulMist

-- Paredes del foso
createPart(room2, "Abyss_Wall_L", Vector3.new(4, 46, 85), CFrame.new(baseX - 38, baseY, baseZ - 85), Color3.fromRGB(20, 16, 26), Enum.Material.Slate)
createPart(room2, "Abyss_Wall_R", Vector3.new(4, 46, 85), CFrame.new(baseX + 38, baseY, baseZ - 85), Color3.fromRGB(20, 16, 26), Enum.Material.Slate)

-- El Gran Puente de Huesos y Cráneos (ancho 16 studs, longitud 65 studs)
local bridgeFloor = createPart(room2, "Skull_Bridge_Deck", Vector3.new(16, 3, 65), CFrame.new(baseX, baseY + 1, baseZ - 85), Color3.fromRGB(215, 210, 195), Enum.Material.Sandstone)
local bridgeRune = createPart(room2, "Bridge_Rune_Spine", Vector3.new(3, 0.3, 63), CFrame.new(baseX, baseY + 2.7, baseZ - 85), Color3.fromRGB(180, 50, 255), Enum.Material.Neon, false)

-- Barandillas con pilastras de cráneos
for z = -110, -60, 12 do
    createPart(room2, "Skull_Post_L", Vector3.new(1.8, 5, 1.8), CFrame.new(baseX - 7.5, baseY + 3.5, baseZ + (z + 85) - 85), Color3.fromRGB(45, 38, 52), Enum.Material.Basalt)
    createPart(room2, "Skull_Head_L", Vector3.new(2, 2, 2), CFrame.new(baseX - 7.5, baseY + 6.5, baseZ + (z + 85) - 85), Color3.fromRGB(230, 225, 210), Enum.Material.SmoothPlastic)

    createPart(room2, "Skull_Post_R", Vector3.new(1.8, 5, 1.8), CFrame.new(baseX + 7.5, baseY + 3.5, baseZ + (z + 85) - 85), Color3.fromRGB(45, 38, 52), Enum.Material.Basalt)
    createPart(room2, "Skull_Head_R", Vector3.new(2, 2, 2), CFrame.new(baseX + 7.5, baseY + 6.5, baseZ + (z + 85) - 85), Color3.fromRGB(230, 225, 210), Enum.Material.SmoothPlastic)
end

-- 2 Enemigos: Espectros de la Cripta (Nv. 34, HP 1,125) flotando sobre el puente
local wraithSpawns = {
    Vector3.new(baseX - 3.5, baseY + 5.5, baseZ - 75),
    Vector3.new(baseX + 3.5, baseY + 5.5, baseZ - 95),
}
for i, pos in ipairs(wraithSpawns) do
    local wraith = Instance.new("Model")
    wraith.Name = "Enemy_EspectroCripta_" .. i
    wraith:SetAttribute("EnemyId", "Enemy_EspectroCripta")
    wraith:SetAttribute("MaxHealth", 1125)
    wraith:SetAttribute("CurrentHealth", 1125)

    local hrp = createPart(wraith, "HumanoidRootPart", Vector3.new(3, 5.5, 3), CFrame.new(pos), Color3.fromRGB(150, 40, 220), Enum.Material.ForceField, true, 0.4)
    local head = createPart(wraith, "Head", Vector3.new(2.2, 2.2, 2.2), CFrame.new(pos + Vector3.new(0, 3, 0)), Color3.fromRGB(25, 10, 35), Enum.Material.Glass)
    local cowl = createPart(wraith, "Cowl", Vector3.new(3.2, 1.8, 3.2), head.CFrame * CFrame.new(0, 0.8, 0), Color3.fromRGB(35, 15, 50), Enum.Material.Fabric)
    local eyes = createPart(wraith, "SpectralEyes", Vector3.new(1.5, 0.4, 0.4), head.CFrame * CFrame.new(0, 0.2, 1), Color3.fromRGB(230, 90, 255), Enum.Material.Neon, false)

    -- Manto espectral flotante
    local shroud = createPart(wraith, "Shroud", Vector3.new(3.8, 6.5, 2.8), hrp.CFrame * CFrame.new(0, -1, 0), Color3.fromRGB(25, 8, 40), Enum.Material.Fabric, false, 0.25)

    local hum = Instance.new("Humanoid")
    hum.MaxHealth = 1125
    hum.Health = 1125
    hum.DisplayName = "Espectro de Cripta"
    hum.Parent = wraith

    createHealthTag(hrp, "Espectro de Cripta", "Nv. 34", 1125, 1125)
    wraith.PrimaryPart = hrp
    wraith.Parent = room2
end

room2.Parent = dungeon

-- PUERTA 2 -> 3
createSpectralGate("Gate_Room2_To_Room3", CFrame.new(baseX, baseY + 2, baseZ - 120), 2, 3)

-- ============================================================================
-- SALA 3: CRIPTA DEL CÍRCULO OSCURO (Z: -925 a -990)
-- ============================================================================
local room3 = Instance.new("Model")
room3.Name = "Room3_Dark_Circle"

-- Amplio salón octogonal
createPart(room3, "Floor_R3", Vector3.new(75, 4, 75), CFrame.new(baseX, baseY, baseZ - 160), Color3.fromRGB(28, 22, 34), Enum.Material.Basalt)
createPart(room3, "Wall_Left_R3", Vector3.new(4, 26, 75), CFrame.new(baseX - 37, baseY + 13, baseZ - 160), Color3.fromRGB(20, 16, 26), Enum.Material.Slate)
createPart(room3, "Wall_Right_R3", Vector3.new(4, 26, 75), CFrame.new(baseX + 37, baseY + 13, baseZ - 160), Color3.fromRGB(20, 16, 26), Enum.Material.Slate)
createPart(room3, "Ceiling_R3", Vector3.new(75, 4, 75), CFrame.new(baseX, baseY + 26, baseZ - 160), Color3.fromRGB(16, 12, 22), Enum.Material.Slate)

-- Círculo Ritual de Invocación Nigromántica en el centro
local ritualBase = createPart(room3, "Ritual_Altar", Vector3.new(32, 1.5, 32), CFrame.new(baseX, baseY + 2.5, baseZ - 160), Color3.fromRGB(42, 24, 60), Enum.Material.Marble)
local ritualRuneOuter = createPart(room3, "Ritual_RuneRing", Vector3.new(28, 0.4, 28), CFrame.new(baseX, baseY + 3.4, baseZ - 160), Color3.fromRGB(180, 45, 255), Enum.Material.Neon, false)
local ritualRuneInner = createPart(room3, "Ritual_Star", Vector3.new(18, 0.5, 18), CFrame.new(baseX, baseY + 3.6, baseZ - 160), Color3.fromRGB(230, 80, 255), Enum.Material.Neon, false)

-- 4 Calderos de Ectoplasma Arcano en las esquinas del altar
local caldronOffsets = {
    Vector3.new(-18, 0, -18),
    Vector3.new(18, 0, -18),
    Vector3.new(-18, 0, 18),
    Vector3.new(18, 0, 18),
}
for i, off in ipairs(caldronOffsets) do
    local pot = createPart(room3, "Caldron_" .. i, Vector3.new(6, 5, 6), CFrame.new(baseX + off.X, baseY + 4.5, baseZ - 160 + off.Z), Color3.fromRGB(45, 40, 52), Enum.Material.Metal)
    local goo = createPart(room3, "EctoLiquid_" .. i, Vector3.new(4.8, 0.8, 4.8), CFrame.new(baseX + off.X, baseY + 6.8, baseZ - 160 + off.Z), Color3.fromRGB(150, 40, 255), Enum.Material.Neon, false)
    local pl = Instance.new("PointLight")
    pl.Color = Color3.fromRGB(175, 45, 255)
    pl.Range = 22
    pl.Brightness = 2.0
    pl.Parent = goo
end

-- 2 Enemigos: Nigromantes de la Cripta (Nv. 38, HP 1,575)
local necroSpawns = {
    Vector3.new(baseX - 10, baseY + 5.5, baseZ - 160),
    Vector3.new(baseX + 10, baseY + 5.5, baseZ - 160),
}
for i, pos in ipairs(necroSpawns) do
    local necro = Instance.new("Model")
    necro.Name = "Enemy_NigromanteCripta_" .. i
    necro:SetAttribute("EnemyId", "Enemy_NigromanteCripta")
    necro:SetAttribute("MaxHealth", 1575)
    necro:SetAttribute("CurrentHealth", 1575)

    local hrp = createPart(necro, "HumanoidRootPart", Vector3.new(2.8, 5.5, 2.2), CFrame.new(pos), Color3.fromRGB(30, 15, 45), Enum.Material.Slate)
    local head = createPart(necro, "Head", Vector3.new(2, 2, 2), CFrame.new(pos + Vector3.new(0, 3.2, 0)), Color3.fromRGB(220, 210, 200), Enum.Material.SmoothPlastic)
    local hood = createPart(necro, "Hood", Vector3.new(2.8, 2.2, 2.8), head.CFrame * CFrame.new(0, 0.3, 0), Color3.fromRGB(45, 20, 65), Enum.Material.Fabric)
    local robe = createPart(necro, "DarkRobe", Vector3.new(3.2, 4.5, 2.6), hrp.CFrame * CFrame.new(0, -0.6, 0), Color3.fromRGB(25, 10, 38), Enum.Material.Fabric)

    -- Báculo Nigromántico con Cráneo Resplandeciente
    local staff = createPart(necro, "StaffPole", Vector3.new(0.6, 7.5, 0.6), hrp.CFrame * CFrame.new(2.4, 0.5, 0.5), Color3.fromRGB(60, 45, 75), Enum.Material.Wood)
    local staffSkull = createPart(necro, "StaffSkull", Vector3.new(1.8, 1.8, 1.8), staff.CFrame * CFrame.new(0, 4, 0), Color3.fromRGB(235, 230, 220), Enum.Material.SmoothPlastic)
    local skullGem = createPart(necro, "SkullGem", Vector3.new(1.2, 1.2, 1.2), staffSkull.CFrame, Color3.fromRGB(210, 60, 255), Enum.Material.Neon, false)

    local hum = Instance.new("Humanoid")
    hum.MaxHealth = 1575
    hum.Health = 1575
    hum.DisplayName = "Nigromante de Cripta"
    hum.Parent = necro

    createHealthTag(hrp, "Nigromante de Cripta", "Nv. 38", 1575, 1575)
    necro.PrimaryPart = hrp
    necro.Parent = room3
end

room3.Parent = dungeon

-- PUERTA 3 -> 4
createSpectralGate("Gate_Room3_To_Room4", CFrame.new(baseX, baseY + 2, baseZ - 200), 3, 4)

-- ============================================================================
-- SALA 4: ARENA DEL CABALLERO SIN ALMA (Z: -205 a -275 -> Real Z: -1005 a -1075)
-- ============================================================================
local room4 = Instance.new("Model")
room4.Name = "Room4_DeathKnight_Arena"

local r4CenterZ = baseZ - 240

-- Gran Anfiteatro Cilíndrico de Basalto
local arenaFloor = createPart(room4, "ArenaFloor_R4", Vector3.new(72, 4, 72), CFrame.new(baseX, baseY, r4CenterZ), Color3.fromRGB(25, 20, 30), Enum.Material.Basalt)
local runeBorder = createPart(room4, "ArenaRuneCircle", Vector3.new(62, 0.4, 62), CFrame.new(baseX, baseY + 2.2, r4CenterZ), Color3.fromRGB(150, 40, 220), Enum.Material.Neon, false)

-- Paredes circulares / cilíndricas formadas por 16 segmentos de columnas de piedra
for angle = 0, 340, 22.5 do
    local rad = math.rad(angle)
    local px = baseX + math.cos(rad) * 36
    local pz = r4CenterZ + math.sin(rad) * 36
    local col = createPart(room4, "Arena_Col_" .. angle, Vector3.new(5, 30, 5), CFrame.new(px, baseY + 15, pz), Color3.fromRGB(32, 26, 38), Enum.Material.Slate)
end

-- 4 Estelas Funerarias de Hueso y Amatista en los puntos cardinales de la arena
local stelaOffsets = {
    Vector3.new(0, 0, -22),
    Vector3.new(0, 0, 22),
    Vector3.new(-22, 0, 0),
    Vector3.new(22, 0, 0),
}
for i, off in ipairs(stelaOffsets) do
    local stela = createPart(room4, "Stela_" .. i, Vector3.new(4, 16, 2.5), CFrame.new(baseX + off.X, baseY + 9, r4CenterZ + off.Z), Color3.fromRGB(40, 32, 48), Enum.Material.Marble)
    local stelaRune = createPart(room4, "StelaRune_" .. i, Vector3.new(2.2, 10, 0.4), stela.CFrame * CFrame.new(0, 0, 1.3), Color3.fromRGB(200, 70, 255), Enum.Material.Neon, false)
    local pl = Instance.new("PointLight")
    pl.Color = Color3.fromRGB(190, 55, 255)
    pl.Range = 24
    pl.Brightness = 2.2
    pl.Parent = stelaRune
end

-- MiniJefe: Caballero Sin Alma (11 studs de altura, Nv. 42, HP 4,800)
local knightModel = Instance.new("Model")
knightModel.Name = "Enemy_CaballeroSinAlma"
knightModel:SetAttribute("EnemyId", "Enemy_CaballeroSinAlma")
knightModel:SetAttribute("MaxHealth", 4800)
knightModel:SetAttribute("CurrentHealth", 4800)
knightModel:SetAttribute("IsMiniBoss", true)

local kPos = Vector3.new(baseX, baseY + 7.5, r4CenterZ)
local kHrp = createPart(knightModel, "HumanoidRootPart", Vector3.new(4.5, 9, 3.5), CFrame.new(kPos), Color3.fromRGB(35, 25, 45), Enum.Material.Metal)
local kTorso = createPart(knightModel, "Torso", Vector3.new(5.2, 6, 3.8), CFrame.new(kPos + Vector3.new(0, 1.2, 0)), Color3.fromRGB(45, 35, 55), Enum.Material.DiamondPlate)
local kHead = createPart(knightModel, "Head", Vector3.new(3.2, 3.2, 3.2), CFrame.new(kPos + Vector3.new(0, 5.2, 0)), Color3.fromRGB(30, 20, 40), Enum.Material.Metal)

-- Ojos espectrales del yelmo
local eyeLeft = createPart(knightModel, "HelmEyeL", Vector3.new(0.6, 0.6, 0.6), kHead.CFrame * CFrame.new(-0.7, 0.3, 1.6), Color3.fromRGB(220, 60, 255), Enum.Material.Neon, false)
local eyeRight = createPart(knightModel, "HelmEyeR", Vector3.new(0.6, 0.6, 0.6), kHead.CFrame * CFrame.new(0.7, 0.3, 1.6), Color3.fromRGB(220, 60, 255), Enum.Material.Neon, false)

-- Hombreras de placas de obsidiana
local shoulderL = createPart(knightModel, "ShoulderL", Vector3.new(2.8, 3.5, 3.5), kTorso.CFrame * CFrame.new(-3.8, 2, 0), Color3.fromRGB(20, 15, 28), Enum.Material.Basalt)
local shoulderR = createPart(knightModel, "ShoulderR", Vector3.new(2.8, 3.5, 3.5), kTorso.CFrame * CFrame.new(3.8, 2, 0), Color3.fromRGB(20, 15, 28), Enum.Material.Basalt)

-- Mandoble Corrupto Gigante (14 studs de longitud)
local greatsword = createPart(knightModel, "GreatswordBlade", Vector3.new(1.2, 14, 2.2), kHrp.CFrame * CFrame.new(4.2, 0.5, 1) * CFrame.Angles(0, 0, math.rad(-15)), Color3.fromRGB(15, 10, 20), Enum.Material.Glass)
local swordEdge = createPart(knightModel, "GreatswordEdge", Vector3.new(0.4, 13.5, 0.5), greatsword.CFrame * CFrame.new(0, 0, 1.1), Color3.fromRGB(210, 50, 255), Enum.Material.Neon, false)

local kHum = Instance.new("Humanoid")
kHum.MaxHealth = 4800
kHum.Health = 4800
kHum.DisplayName = "Caballero Sin Alma"
kHum.Parent = knightModel

createHealthTag(kHrp, "Caballero Sin Alma [MINIBOSS]", "Nv. 42", 4800, 4800, true)
knightModel.PrimaryPart = kHrp
knightModel.Parent = room4

room4.Parent = dungeon

-- PUERTA 4 -> 5
createSpectralGate("Gate_Room4_To_Room5", CFrame.new(baseX, baseY + 2, baseZ - 280), 4, 5)

-- ============================================================================
-- SALA 5: MAUSOLEO DEL REY DE LAS ALMAS (Z: -285 a -400 -> Real Z: -1085 a -1200)
-- ============================================================================
local room5 = Instance.new("Model")
room5.Name = "Room5_Lich_Mausoleum"

local r5CenterZ = baseZ - 345

-- Colosal Coliseo Mausoleo de 92 studs de diámetro
local mausoleumFloor = createPart(room5, "Floor_Mausoleum", Vector3.new(94, 5, 94), CFrame.new(baseX, baseY, r5CenterZ), Color3.fromRGB(22, 18, 28), Enum.Material.Basalt)

-- Anillos concéntricos AoE de corrupción espectral en el suelo
local aoeRingOuter = createPart(room5, "AoE_Ring_Outer", Vector3.new(80, 0.4, 80), CFrame.new(baseX, baseY + 2.7, r5CenterZ), Color3.fromRGB(160, 40, 240), Enum.Material.Neon, false)
local aoeRingMid = createPart(room5, "AoE_Ring_Mid", Vector3.new(54, 0.5, 54), CFrame.new(baseX, baseY + 2.8, r5CenterZ), Color3.fromRGB(190, 60, 255), Enum.Material.Neon, false)
local aoeRingCenter = createPart(room5, "AoE_Ring_Center", Vector3.new(26, 0.6, 26), CFrame.new(baseX, baseY + 2.9, r5CenterZ), Color3.fromRGB(230, 90, 255), Enum.Material.Neon, false)

-- 8 Columnas funerarias monolíticas de obsidiana con pebeteros de fuego espectral
for angle = 0, 315, 45 do
    local rad = math.rad(angle)
    local px = baseX + math.cos(rad) * 42
    local pz = r5CenterZ + math.sin(rad) * 42
    local pilar = createPart(room5, "Mausoleum_Pillar_" .. angle, Vector3.new(6, 42, 6), CFrame.new(px, baseY + 21, pz), Color3.fromRGB(18, 14, 24), Enum.Material.Slate)
    local burner = createPart(room5, "Burner_" .. angle, Vector3.new(8, 2, 8), CFrame.new(px, baseY + 32, pz), Color3.fromRGB(45, 38, 52), Enum.Material.Metal)
    local flame = createPart(room5, "PyreFlame_" .. angle, Vector3.new(4, 5, 4), CFrame.new(px, baseY + 35, pz), Color3.fromRGB(190, 50, 255), Enum.Material.Neon, false)

    local pl = Instance.new("PointLight")
    pl.Color = Color3.fromRGB(190, 60, 255)
    pl.Range = 38
    pl.Brightness = 2.4
    pl.Parent = flame
end

-- Pared Perimetral del Mausoleo
for angle = 0, 345, 15 do
    local rad = math.rad(angle)
    local px = baseX + math.cos(rad) * 47
    local pz = r5CenterZ + math.sin(rad) * 47
    createPart(room5, "Mausoleum_Wall_" .. angle, Vector3.new(12, 35, 4), CFrame.new(px, baseY + 17.5, pz) * CFrame.Angles(0, -rad, 0), Color3.fromRGB(26, 20, 32), Enum.Material.Slate)
end

-- ============================================================================
-- JEFE FINAL: REY DE LAS ALMAS (20 studs de altura, Nv. 50, HP 13,500)
-- ============================================================================
local bossModel = Instance.new("Model")
bossModel.Name = "Enemy_ReyAlmas"
bossModel:SetAttribute("EnemyId", "Enemy_ReyAlmas")
bossModel:SetAttribute("MaxHealth", 13500)
bossModel:SetAttribute("CurrentHealth", 13500)
bossModel:SetAttribute("IsBoss", true)

local bPos = Vector3.new(baseX, baseY + 14, r5CenterZ - 10)
local bHrp = createPart(bossModel, "HumanoidRootPart", Vector3.new(8, 18, 6), CFrame.new(bPos), Color3.fromRGB(25, 12, 38), Enum.Material.ForceField, true, 0.4)
local bTorso = createPart(bossModel, "Torso", Vector3.new(9, 11, 6.5), CFrame.new(bPos + Vector3.new(0, 1.5, 0)), Color3.fromRGB(35, 18, 52), Enum.Material.Fabric)
local bHead = createPart(bossModel, "Head", Vector3.new(5.5, 5.5, 5.5), CFrame.new(bPos + Vector3.new(0, 9.5, 0)), Color3.fromRGB(225, 218, 208), Enum.Material.SmoothPlastic)

-- Corona colosal de obsidiana con agujas de amatista
local crownBase = createPart(bossModel, "CrownBase", Vector3.new(6.2, 1.5, 6.2), bHead.CFrame * CFrame.new(0, 3, 0), Color3.fromRGB(15, 8, 22), Enum.Material.Basalt)
for spike = 1, 5 do
    local sX = (spike - 3) * 1.3
    createPart(bossModel, "CrownSpike_" .. spike, Vector3.new(1, 3.5, 1), crownBase.CFrame * CFrame.new(sX, 2, 0), Color3.fromRGB(210, 65, 255), Enum.Material.Neon, false)
end

-- Manto espectral de almas atormentadas
local spectralRobe = createPart(bossModel, "SpectralRobe", Vector3.new(11, 14, 7.5), bTorso.CFrame * CFrame.new(0, -3.5, 0), Color3.fromRGB(20, 8, 32), Enum.Material.Fabric, false, 0.2)

-- Rostro Exánime con cuencas de fuego espectral
local lichEyeL = createPart(bossModel, "LichEyeL", Vector3.new(1, 1, 1), bHead.CFrame * CFrame.new(-1.3, 0.6, 2.7), Color3.fromRGB(240, 70, 255), Enum.Material.Neon, false)
local lichEyeR = createPart(bossModel, "LichEyeR", Vector3.new(1, 1, 1), bHead.CFrame * CFrame.new(1.3, 0.6, 2.7), Color3.fromRGB(240, 70, 255), Enum.Material.Neon, false)

-- Cetro del Fin de las Almas (22 studs de altura)
local scepter = createPart(bossModel, "ScepterPole", Vector3.new(1.2, 22, 1.2), bHrp.CFrame * CFrame.new(7.5, 1, 1) * CFrame.Angles(0, 0, math.rad(-10)), Color3.fromRGB(45, 30, 60), Enum.Material.Basalt)
local scepterSkull = createPart(bossModel, "ScepterSkull", Vector3.new(3.8, 3.8, 3.8), scepter.CFrame * CFrame.new(0, 11, 0), Color3.fromRGB(230, 225, 210), Enum.Material.SmoothPlastic)
local scepterOrb = createPart(bossModel, "ScepterOrb", Vector3.new(3, 3, 3), scepterSkull.CFrame * CFrame.new(0, 3, 0), Color3.fromRGB(220, 50, 255), Enum.Material.Neon, false)

local bossLight = Instance.new("PointLight")
bossLight.Color = Color3.fromRGB(210, 60, 255)
bossLight.Range = 45
bossLight.Brightness = 3.5
bossLight.Parent = scepterOrb

local bHum = Instance.new("Humanoid")
bHum.MaxHealth = 13500
bHum.Health = 13500
bHum.DisplayName = "Rey de las Almas"
bHum.Parent = bossModel

createHealthTag(bHrp, "👑 REY DE LAS ALMAS [JEFE FINAL]", "Nv. 50", 13500, 13500, true)
bossModel.PrimaryPart = bHrp
bossModel.Parent = room5

-- ============================================================================
-- COFRE DE RECOMPENSA: COFRE DE PLATA MALDITA
-- ============================================================================
local chestModel = Instance.new("Model")
chestModel.Name = "Deluxe_Cursed_Silver_Chest"

local cPos = Vector3.new(baseX + 18, baseY + 5.5, r5CenterZ + 18)
local cBase = createPart(chestModel, "ChestBase", Vector3.new(7, 4.5, 5), CFrame.new(cPos), Color3.fromRGB(175, 185, 205), Enum.Material.Metal)
local cLid = createPart(chestModel, "ChestLid", Vector3.new(7.4, 2.8, 5.4), CFrame.new(cPos + Vector3.new(0, 3.2, 0)), Color3.fromRGB(35, 25, 45), Enum.Material.Slate)
local cTrim = createPart(chestModel, "ChestTrim", Vector3.new(7.8, 0.8, 5.8), CFrame.new(cPos + Vector3.new(0, 2, 0)), Color3.fromRGB(210, 65, 255), Enum.Material.Neon, false)

local cPrompt = Instance.new("ProximityPrompt")
cPrompt.ObjectText = "Cofre de Plata Maldita"
cPrompt.ActionText = "Abrir Botín Espectral"
cPrompt.HoldDuration = 1.0
cPrompt.MaxActivationDistance = 14
cPrompt.Parent = cBase

chestModel.Parent = room5

-- ============================================================================
-- PORTAL DE RETORNO AL LOBBY
-- ============================================================================
local exitPortalModel = Instance.new("Model")
exitPortalModel.Name = "Exit_Portal_To_Lobby"

local epPos = Vector3.new(baseX - 18, baseY + 10, r5CenterZ + 20)
-- Marco de obsidiana
createPart(exitPortalModel, "Portal_Frame_L", Vector3.new(2.5, 16, 2.5), CFrame.new(epPos + Vector3.new(-6, 0, 0)), Color3.fromRGB(20, 15, 28), Enum.Material.Slate)
createPart(exitPortalModel, "Portal_Frame_R", Vector3.new(2.5, 16, 2.5), CFrame.new(epPos + Vector3.new(6, 0, 0)), Color3.fromRGB(20, 15, 28), Enum.Material.Slate)
createPart(exitPortalModel, "Portal_Arch", Vector3.new(14.5, 2.5, 2.5), CFrame.new(epPos + Vector3.new(0, 8, 0)), Color3.fromRGB(25, 18, 35), Enum.Material.Slate)

-- Vórtice espectral de retorno al Lobby
local vortex = createPart(exitPortalModel, "Vortex", Vector3.new(10, 14, 1.2), CFrame.new(epPos), Color3.fromRGB(190, 60, 255), Enum.Material.Neon, false, 0.3)
local epPrompt = Instance.new("ProximityPrompt")
epPrompt.ObjectText = "Portal de Retorno"
epPrompt.ActionText = "Volver al Santuario (Lobby)"
epPrompt.HoldDuration = 0.5
epPrompt.MaxActivationDistance = 12
epPrompt.Parent = vortex

local epLight = Instance.new("PointLight")
epLight.Color = Color3.fromRGB(180, 50, 255)
epLight.Range = 25
epLight.Brightness = 2.5
epLight.Parent = vortex

exitPortalModel.Parent = room5
room5.Parent = dungeon

dungeon.Parent = Workspace

print("======================================================================")
print("  ✓ REGIÓN 4: CRIPTA DE LAS ALMAS CONSTRUIDA EXITOSAMENTE EN 3D")
print("  ✓ Ubicación: baseX = 0, baseY = 50, baseZ = -800 (800 studs al Sur)")
print("  ✓ 5 Salas: Catacumbas -> Puente Cráneos -> Círculo -> Caballero -> Rey")
print("  ✓ Jefe Final: Rey de las Almas (20 studs, 13,500 HP, Cetro y Corona)")
print("  ✓ Cofre de Plata Maldita & Portal de Retorno al Lobby")
print("======================================================================")
