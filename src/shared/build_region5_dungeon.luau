--!strict
--[[
    build_region5_dungeon.luau
    Construye físicamente la Región 5 completa: Templo de los Cielos en MAGIA ETERNA
    - Ubicación: baseX = 0, baseY = 350, baseZ = 0 (350 studs en el cielo directamente sobre el Lobby).
    - 5 Salas Celestiales:
      1. Room1_Celestial_Plaza: Mármol blanco, pilares dorados, orbes solares y 3 Centinelas Celestiales.
      2. Room2_Cloud_Bridges: Puentes entre islas de nubes translúcidas y 2 Grifos de los Cielos.
      3. Room3_Sanctuary_Light: Santuario de luz con cúpula solar y 2 Ángeles Caídos.
      4. Room4_Solar_Arena: Arena circular de mármol y oro con el MiniJefe Guardián Solar (11 studs).
      5. Room5_Archangel_Colosseum: Coliseo colosal de 92 studs, anillos de luz solar, el Jefe Final Arcángel del Caos (20 studs),
         Cofre de Oro Sagrado y Portal de Retorno al Lobby.
    - 4 Puertas Rúnicas Celestiales con AlwaysOnTop = false y MaxDistance = 25.
]]

local Workspace = game:GetService("Workspace")

local baseX = 0
local baseY = 350
local baseZ = 0

local dungeon = Instance.new("Model")
dungeon.Name = "Dungeon_Templo_Cielos"

-- Limpiar versión previa si existiera
local existing = Workspace:FindFirstChild("Dungeon_Templo_Cielos") or Workspace:FindFirstChild("Dungeon_Cielos")
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
    bg.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    bg.BackgroundTransparency = 0.25
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = bg

    local stroke = Instance.new("UIStroke")
    stroke.Color = isBoss and Color3.fromRGB(255, 215, 60) or Color3.fromRGB(240, 190, 70)
    stroke.Thickness = isBoss and 2 or 1.5
    stroke.Parent = bg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.5, 0)
    title.Position = UDim2.new(0, 0, 0.05, 0)
    title.BackgroundTransparency = 1
    title.Text = name .. " • " .. lvl
    title.TextColor3 = isBoss and Color3.fromRGB(255, 245, 200) or Color3.fromRGB(255, 235, 170)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = bg

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0.9, 0, 0.3, 0)
    track.Position = UDim2.new(0.05, 0, 0.6, 0)
    track.BackgroundColor3 = Color3.fromRGB(35, 30, 25)
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 4)
    tc.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(hp / maxHp, 0, 1, 0)
    fill.BackgroundColor3 = isBoss and Color3.fromRGB(255, 200, 30) or Color3.fromRGB(255, 170, 40)
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

local function createCelestialGate(gateName: string, cf: CFrame, roomFrom: number, roomTo: number)
    local gateModel = Instance.new("Model")
    gateModel.Name = gateName
    gateModel:SetAttribute("IsOpen", false)

    -- Columnas de mármol blanco con filigrana dorada
    createPart(gateModel, "Gate_Pillar_L", Vector3.new(4, 22, 4), cf * CFrame.new(-12, 11, 0), Color3.fromRGB(245, 245, 250), Enum.Material.Marble)
    createPart(gateModel, "Gate_Pillar_R", Vector3.new(4, 22, 4), cf * CFrame.new(12, 11, 0), Color3.fromRGB(245, 245, 250), Enum.Material.Marble)
    createPart(gateModel, "Gate_Arch", Vector3.new(28, 4, 4), cf * CFrame.new(0, 22, 0), Color3.fromRGB(255, 235, 150), Enum.Material.Marble)

    -- Joyas solares doradas
    createPart(gateModel, "SunGem_L", Vector3.new(1.8, 4, 1.8), cf * CFrame.new(-12, 14, 0), Color3.fromRGB(255, 220, 50), Enum.Material.Neon)
    createPart(gateModel, "SunGem_R", Vector3.new(1.8, 4, 1.8), cf * CFrame.new(12, 14, 0), Color3.fromRGB(255, 220, 50), Enum.Material.Neon)

    -- Barrera de luz dorada
    local barrier = createPart(gateModel, "Runic_Barrier", Vector3.new(20, 20, 1.5), cf * CFrame.new(0, 10, 0), Color3.fromRGB(255, 215, 80), Enum.Material.Glass, true, 0.4)

    local pl = Instance.new("PointLight")
    pl.Color = Color3.fromRGB(255, 215, 80)
    pl.Range = 28
    pl.Brightness = 2.8
    pl.Parent = barrier

    local bb = Instance.new("BillboardGui")
    bb.Name = "GatePromptGui"
    bb.Size = UDim2.new(0, 180, 0, 40)
    bb.StudsOffset = Vector3.new(0, 12, 0)
    bb.AlwaysOnTop = false
    bb.MaxDistance = 25
    bb.Adornee = barrier

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundColor3 = Color3.fromRGB(30, 25, 20)
    txt.BackgroundTransparency = 0.2
    txt.Text = string.format("🔒 BARRERA CELESTIAL\nSala %d → Sala %d", roomFrom, roomTo)
    txt.TextColor3 = Color3.fromRGB(255, 230, 140)
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
-- SALA 1: PLAZA CELESTIAL (Z: 0 a -40)
-- ============================================================================
local room1 = Instance.new("Model")
room1.Name = "Room1_Celestial_Plaza"

createPart(room1, "Floor_R1", Vector3.new(65, 4, 65), CFrame.new(baseX, baseY, baseZ - 10), Color3.fromRGB(240, 240, 245), Enum.Material.Marble)
createPart(room1, "GoldTrim_R1", Vector3.new(67, 1, 67), CFrame.new(baseX, baseY - 1, baseZ - 10), Color3.fromRGB(255, 215, 70), Enum.Material.Metal)

-- Spawn Pad Dorado
local spawnPad = createPart(room1, "Dungeon_SpawnPad", Vector3.new(16, 1.5, 16), CFrame.new(baseX, baseY + 2.5, baseZ + 15), Color3.fromRGB(255, 245, 220), Enum.Material.Marble)
local spawnRune = createPart(room1, "SpawnRune", Vector3.new(12, 0.4, 12), CFrame.new(baseX, baseY + 3.4, baseZ + 15), Color3.fromRGB(255, 220, 60), Enum.Material.Neon, false)

-- 4 Pilares con Alas y Orbes de Luz Solar
local pillarOffsetsR1 = {
    Vector3.new(-24, 0, 15),
    Vector3.new(24, 0, 15),
    Vector3.new(-24, 0, -25),
    Vector3.new(24, 0, -25),
}
for i, off in ipairs(pillarOffsetsR1) do
    local pil = createPart(room1, "Pillar_" .. i, Vector3.new(3.5, 20, 3.5), CFrame.new(baseX + off.X, baseY + 10, baseZ + off.Z), Color3.fromRGB(250, 250, 255), Enum.Material.Marble)
    local orb = createPart(room1, "SunOrb_" .. i, Vector3.new(3, 3, 3), CFrame.new(baseX + off.X, baseY + 22, baseZ + off.Z), Color3.fromRGB(255, 225, 70), Enum.Material.Neon, false)
    local pl = Instance.new("PointLight")
    pl.Color = Color3.fromRGB(255, 220, 80)
    pl.Range = 30
    pl.Brightness = 2.5
    pl.Parent = orb
end

-- 3 Enemigos: Centinelas Celestiales (Nv. 50, HP 2,100)
local centinelaSpawns = {
    Vector3.new(baseX - 14, baseY + 5, baseZ - 15),
    Vector3.new(baseX, baseY + 5, baseZ - 25),
    Vector3.new(baseX + 14, baseY + 5, baseZ - 15),
}
for i, pos in ipairs(centinelaSpawns) do
    local enemy = Instance.new("Model")
    enemy.Name = "Enemy_CentinelaCielos_" .. i
    enemy:SetAttribute("EnemyId", "Enemy_CentinelaCielos")
    enemy:SetAttribute("MaxHealth", 2100)
    enemy:SetAttribute("CurrentHealth", 2100)

    local hrp = createPart(enemy, "HumanoidRootPart", Vector3.new(3, 6, 2.5), CFrame.new(pos), Color3.fromRGB(240, 240, 250), Enum.Material.DiamondPlate)
    local head = createPart(enemy, "Head", Vector3.new(2.2, 2.2, 2.2), CFrame.new(pos + Vector3.new(0, 3.5, 0)), Color3.fromRGB(255, 220, 90), Enum.Material.Metal)
    local halo = createPart(enemy, "Halo", Vector3.new(3, 0.4, 3), head.CFrame * CFrame.new(0, 1.8, 0), Color3.fromRGB(255, 230, 80), Enum.Material.Neon, false)
    local spear = createPart(enemy, "Spear", Vector3.new(0.6, 9, 0.6), hrp.CFrame * CFrame.new(2.5, 0.5, 0.5), Color3.fromRGB(255, 215, 60), Enum.Material.Metal)

    local hum = Instance.new("Humanoid")
    hum.MaxHealth = 2100
    hum.Health = 2100
    hum.DisplayName = "Centinela Celestial"
    hum.Parent = enemy

    createHealthTag(hrp, "Centinela Celestial", "Nv. 50", 2100, 2100)
    enemy.PrimaryPart = hrp
    enemy.Parent = room1
end

room1.Parent = dungeon

-- PUERTA 1 -> 2
createCelestialGate("Gate_Room1_To_Room2", CFrame.new(baseX, baseY + 2, baseZ - 45), 1, 2)

-- ============================================================================
-- SALA 2: PUENTES DE NUBES Y GRIFOS (Z: -50 a -115)
-- ============================================================================
local room2 = Instance.new("Model")
room2.Name = "Room2_Cloud_Bridges"

local r2CenterZ = baseZ - 85
-- Puente suspendido de cristal y nubes
local bridge = createPart(room2, "CloudBridge", Vector3.new(18, 3, 65), CFrame.new(baseX, baseY + 1, r2CenterZ), Color3.fromRGB(235, 245, 255), Enum.Material.Glass, true, 0.25)
local bridgeRune = createPart(room2, "BridgeRune", Vector3.new(4, 0.3, 63), CFrame.new(baseX, baseY + 2.7, r2CenterZ), Color3.fromRGB(255, 220, 60), Enum.Material.Neon, false)

-- Islas de nubes esponjosas flotantes alrededor
local cloudOffsets = {
    Vector3.new(-22, -3, 15),
    Vector3.new(22, -3, -15),
    Vector3.new(-24, 2, -20),
}
for i, off in ipairs(cloudOffsets) do
    local cloud = createPart(room2, "CloudPlatform_" .. i, Vector3.new(16, 5, 16), CFrame.new(baseX + off.X, baseY + off.Y, r2CenterZ + off.Z), Color3.fromRGB(250, 250, 255), Enum.Material.Sandstone, true, 0.2)
end

-- 2 Enemigos: Grifos de los Cielos (Nv. 54, HP 2,625)
local grifoSpawns = {
    Vector3.new(baseX - 4, baseY + 5.5, r2CenterZ + 12),
    Vector3.new(baseX + 4, baseY + 5.5, r2CenterZ - 12),
}
for i, pos in ipairs(grifoSpawns) do
    local grifo = Instance.new("Model")
    grifo.Name = "Enemy_GrifoCielos_" .. i
    grifo:SetAttribute("EnemyId", "Enemy_GrifoCielos")
    grifo:SetAttribute("MaxHealth", 2625)
    grifo:SetAttribute("CurrentHealth", 2625)

    local hrp = createPart(grifo, "HumanoidRootPart", Vector3.new(4, 5, 6), CFrame.new(pos), Color3.fromRGB(230, 215, 175), Enum.Material.Slate)
    local head = createPart(grifo, "Head", Vector3.new(2.8, 2.8, 3.2), CFrame.new(pos + Vector3.new(0, 3, 2)), Color3.fromRGB(240, 230, 200), Enum.Material.SmoothPlastic)
    local beak = createPart(grifo, "Beak", Vector3.new(1.2, 1.2, 1.8), head.CFrame * CFrame.new(0, -0.4, 2), Color3.fromRGB(255, 190, 40), Enum.Material.Metal)
    local wingL = createPart(grifo, "WingL", Vector3.new(8, 0.8, 3), hrp.CFrame * CFrame.new(-5, 1.5, 0) * CFrame.Angles(0, 0, math.rad(25)), Color3.fromRGB(255, 250, 230), Enum.Material.Fabric)
    local wingR = createPart(grifo, "WingR", Vector3.new(8, 0.8, 3), hrp.CFrame * CFrame.new(5, 1.5, 0) * CFrame.Angles(0, 0, math.rad(-25)), Color3.fromRGB(255, 250, 230), Enum.Material.Fabric)

    local hum = Instance.new("Humanoid")
    hum.MaxHealth = 2625
    hum.Health = 2625
    hum.DisplayName = "Grifo de los Cielos"
    hum.Parent = grifo

    createHealthTag(hrp, "Grifo de los Cielos", "Nv. 54", 2625, 2625)
    grifo.PrimaryPart = hrp
    grifo.Parent = room2
end

room2.Parent = dungeon

-- PUERTA 2 -> 3
createCelestialGate("Gate_Room2_To_Room3", CFrame.new(baseX, baseY + 2, baseZ - 125), 2, 3)

-- ============================================================================
-- SALA 3: SANTUARIO DE LUZ (Z: -130 a -195)
-- ============================================================================
local room3 = Instance.new("Model")
room3.Name = "Room3_Sanctuary_Light"

local r3CenterZ = baseZ - 165
createPart(room3, "Floor_R3", Vector3.new(72, 4, 72), CFrame.new(baseX, baseY, r3CenterZ), Color3.fromRGB(245, 245, 250), Enum.Material.Marble)
createPart(room3, "Altar_Light", Vector3.new(28, 2, 28), CFrame.new(baseX, baseY + 2.5, r3CenterZ), Color3.fromRGB(255, 245, 210), Enum.Material.Marble)
createPart(room3, "Rune_Sun", Vector3.new(24, 0.4, 24), CFrame.new(baseX, baseY + 3.4, r3CenterZ), Color3.fromRGB(255, 215, 60), Enum.Material.Neon, false)

-- 2 Enemigos: Ángeles Caídos (Nv. 58, HP 3,150)
local angelSpawns = {
    Vector3.new(baseX - 12, baseY + 5.5, r3CenterZ),
    Vector3.new(baseX + 12, baseY + 5.5, r3CenterZ),
}
for i, pos in ipairs(angelSpawns) do
    local angel = Instance.new("Model")
    angel.Name = "Enemy_AngelCaido_" .. i
    angel:SetAttribute("EnemyId", "Enemy_AngelCaido")
    angel:SetAttribute("MaxHealth", 3150)
    angel:SetAttribute("CurrentHealth", 3150)

    local hrp = createPart(angel, "HumanoidRootPart", Vector3.new(3, 6, 2.5), CFrame.new(pos), Color3.fromRGB(45, 40, 60), Enum.Material.Metal)
    local head = createPart(angel, "Head", Vector3.new(2.2, 2.2, 2.2), CFrame.new(pos + Vector3.new(0, 3.5, 0)), Color3.fromRGB(220, 210, 205), Enum.Material.SmoothPlastic)
    local darkWingL = createPart(angel, "DarkWingL", Vector3.new(7, 0.6, 2.5), hrp.CFrame * CFrame.new(-4.5, 1, -0.5) * CFrame.Angles(0, 0, math.rad(30)), Color3.fromRGB(25, 20, 35), Enum.Material.Fabric)
    local darkWingR = createPart(angel, "DarkWingR", Vector3.new(7, 0.6, 2.5), hrp.CFrame * CFrame.new(4.5, 1, -0.5) * CFrame.Angles(0, 0, math.rad(-30)), Color3.fromRGB(25, 20, 35), Enum.Material.Fabric)

    local hum = Instance.new("Humanoid")
    hum.MaxHealth = 3150
    hum.Health = 3150
    hum.DisplayName = "Ángel Caído"
    hum.Parent = angel

    createHealthTag(hrp, "Ángel Caído", "Nv. 58", 3150, 3150)
    angel.PrimaryPart = hrp
    angel.Parent = room3
end

room3.Parent = dungeon

-- PUERTA 3 -> 4
createCelestialGate("Gate_Room3_To_Room4", CFrame.new(baseX, baseY + 2, baseZ - 205), 3, 4)

-- ============================================================================
-- SALA 4: ARENA DEL GUARDIÁN SOLAR (Z: -210 a -280)
-- ============================================================================
local room4 = Instance.new("Model")
room4.Name = "Room4_Solar_Arena"

local r4CenterZ = baseZ - 250
local arenaFloor = createPart(room4, "ArenaFloor_R4", Vector3.new(74, 4, 74), CFrame.new(baseX, baseY, r4CenterZ), Color3.fromRGB(250, 250, 255), Enum.Material.Marble)
createPart(room4, "SunRuneCircle", Vector3.new(62, 0.4, 62), CFrame.new(baseX, baseY + 2.2, r4CenterZ), Color3.fromRGB(255, 215, 60), Enum.Material.Neon, false)

-- 4 Obeliscos Solares
local obeliskOffsets = {
    Vector3.new(0, 0, -24),
    Vector3.new(0, 0, 24),
    Vector3.new(-24, 0, 0),
    Vector3.new(24, 0, 0),
}
for i, off in ipairs(obeliskOffsets) do
    local ob = createPart(room4, "Obelisk_" .. i, Vector3.new(4, 18, 4), CFrame.new(baseX + off.X, baseY + 10, r4CenterZ + off.Z), Color3.fromRGB(245, 240, 230), Enum.Material.Marble)
    local sunGem = createPart(room4, "ObeliskSun_" .. i, Vector3.new(2.5, 3.5, 2.5), ob.CFrame * CFrame.new(0, 10, 0), Color3.fromRGB(255, 220, 50), Enum.Material.Neon, false)
    local pl = Instance.new("PointLight")
    pl.Color = Color3.fromRGB(255, 220, 50)
    pl.Range = 26
    pl.Brightness = 2.5
    pl.Parent = sunGem
end

-- MiniJefe: Guardián Solar (11 studs de altura, Nv. 64, HP 11,200)
local guardian = Instance.new("Model")
guardian.Name = "Enemy_GuardianSolar"
guardian:SetAttribute("EnemyId", "Enemy_GuardianSolar")
guardian:SetAttribute("MaxHealth", 11200)
guardian:SetAttribute("CurrentHealth", 11200)
guardian:SetAttribute("IsMiniBoss", true)

local gPos = Vector3.new(baseX, baseY + 7.5, r4CenterZ)
local gHrp = createPart(guardian, "HumanoidRootPart", Vector3.new(5, 9, 4), CFrame.new(gPos), Color3.fromRGB(255, 225, 90), Enum.Material.Metal)
local gHead = createPart(guardian, "Head", Vector3.new(3.2, 3.2, 3.2), CFrame.new(gPos + Vector3.new(0, 5.5, 0)), Color3.fromRGB(255, 240, 140), Enum.Material.DiamondPlate)
local gSunHelm = createPart(guardian, "SunHelm", Vector3.new(4.5, 1.5, 4.5), gHead.CFrame * CFrame.new(0, 1.8, 0), Color3.fromRGB(255, 200, 40), Enum.Material.Neon, false)
local gAxe = createPart(guardian, "SolarHalberd", Vector3.new(1.2, 14, 2.5), gHrp.CFrame * CFrame.new(4, 0.5, 1), Color3.fromRGB(255, 215, 60), Enum.Material.Metal)

local gHum = Instance.new("Humanoid")
gHum.MaxHealth = 11200
gHum.Health = 11200
gHum.DisplayName = "Guardián Solar"
gHum.Parent = guardian

createHealthTag(gHrp, "Guardián Solar [MINIBOSS]", "Nv. 64", 11200, 11200, true)
guardian.PrimaryPart = gHrp
guardian.Parent = room4

room4.Parent = dungeon

-- PUERTA 4 -> 5
createCelestialGate("Gate_Room4_To_Room5", CFrame.new(baseX, baseY + 2, baseZ - 290), 4, 5)

-- ============================================================================
-- SALA 5: COLISEO DEL ARCÁNGEL DEL CAOS (Z: -295 a -410)
-- ============================================================================
local room5 = Instance.new("Model")
room5.Name = "Room5_Archangel_Colosseum"

local r5CenterZ = baseZ - 355
local colosseumFloor = createPart(room5, "Floor_Colosseum", Vector3.new(94, 5, 94), CFrame.new(baseX, baseY, r5CenterZ), Color3.fromRGB(245, 245, 252), Enum.Material.Marble)

-- Anillos AoE dorados
createPart(room5, "AoE_Ring_1", Vector3.new(80, 0.4, 80), CFrame.new(baseX, baseY + 2.7, r5CenterZ), Color3.fromRGB(255, 215, 60), Enum.Material.Neon, false)
createPart(room5, "AoE_Ring_2", Vector3.new(52, 0.5, 52), CFrame.new(baseX, baseY + 2.8, r5CenterZ), Color3.fromRGB(255, 230, 90), Enum.Material.Neon, false)

-- 8 Monolitos Celestiales con Altar de Luz
for angle = 0, 315, 45 do
    local rad = math.rad(angle)
    local px = baseX + math.cos(rad) * 42
    local pz = r5CenterZ + math.sin(rad) * 42
    local col = createPart(room5, "Colosseum_Pillar_" .. angle, Vector3.new(6, 40, 6), CFrame.new(px, baseY + 20, pz), Color3.fromRGB(250, 250, 255), Enum.Material.Marble)
    local flame = createPart(room5, "SunTorch_" .. angle, Vector3.new(4, 5, 4), CFrame.new(px, baseY + 34, pz), Color3.fromRGB(255, 220, 50), Enum.Material.Neon, false)
    local pl = Instance.new("PointLight")
    pl.Color = Color3.fromRGB(255, 220, 60)
    pl.Range = 36
    pl.Brightness = 2.5
    pl.Parent = flame
end

-- ============================================================================
-- JEFE FINAL: ARCÁNGEL DEL CAOS (20 studs de altura, Nv. 70, HP 31,500)
-- ============================================================================
local boss = Instance.new("Model")
boss.Name = "Enemy_ArcangelCaos"
boss:SetAttribute("EnemyId", "Enemy_ArcangelCaos")
boss:SetAttribute("MaxHealth", 31500)
boss:SetAttribute("CurrentHealth", 31500)
boss:SetAttribute("IsBoss", true)

local bPos = Vector3.new(baseX, baseY + 14, r5CenterZ - 10)
local bHrp = createPart(boss, "HumanoidRootPart", Vector3.new(8, 18, 6), CFrame.new(bPos), Color3.fromRGB(255, 245, 230), Enum.Material.Marble, true, 0.3)
local bTorso = createPart(boss, "Torso", Vector3.new(9, 11, 6.5), CFrame.new(bPos + Vector3.new(0, 1.5, 0)), Color3.fromRGB(255, 220, 80), Enum.Material.Metal)
local bHead = createPart(boss, "Head", Vector3.new(5.5, 5.5, 5.5), CFrame.new(bPos + Vector3.new(0, 9.5, 0)), Color3.fromRGB(255, 245, 235), Enum.Material.SmoothPlastic)

-- Corona / Halo Sagrado Divino
local bHalo = createPart(boss, "ArchangelHalo", Vector3.new(9, 0.8, 9), bHead.CFrame * CFrame.new(0, 4.5, 0), Color3.fromRGB(255, 235, 70), Enum.Material.Neon, false)

-- 4 Alas Celestiales Gigantes de Oro y Luz
local wingUpperL = createPart(boss, "WingUpperL", Vector3.new(16, 1.2, 5), bHrp.CFrame * CFrame.new(-10, 5, -2) * CFrame.Angles(0, 0, math.rad(35)), Color3.fromRGB(255, 230, 80), Enum.Material.Neon, false)
local wingUpperR = createPart(boss, "WingUpperR", Vector3.new(16, 1.2, 5), bHrp.CFrame * CFrame.new(10, 5, -2) * CFrame.Angles(0, 0, math.rad(-35)), Color3.fromRGB(255, 230, 80), Enum.Material.Neon, false)
local wingLowerL = createPart(boss, "WingLowerL", Vector3.new(12, 1, 4), bHrp.CFrame * CFrame.new(-8, -2, -2) * CFrame.Angles(0, 0, math.rad(15)), Color3.fromRGB(255, 215, 60), Enum.Material.Neon, false)
local wingLowerR = createPart(boss, "WingLowerR", Vector3.new(12, 1, 4), bHrp.CFrame * CFrame.new(8, -2, -2) * CFrame.Angles(0, 0, math.rad(-15)), Color3.fromRGB(255, 215, 60), Enum.Material.Neon, false)

-- Espada Sagrada del Caos Celestial (22 studs)
local sword = createPart(boss, "CelestialSword", Vector3.new(1.4, 22, 3), bHrp.CFrame * CFrame.new(8, 2, 1) * CFrame.Angles(0, 0, math.rad(-12)), Color3.fromRGB(255, 240, 120), Enum.Material.Neon, false)
local bossLight = Instance.new("PointLight")
bossLight.Color = Color3.fromRGB(255, 220, 80)
bossLight.Range = 45
bossLight.Brightness = 3.8
bossLight.Parent = sword

local bHum = Instance.new("Humanoid")
bHum.MaxHealth = 31500
bHum.Health = 31500
bHum.DisplayName = "Arcángel del Caos"
bHum.Parent = boss

createHealthTag(bHrp, "👑 ARCÁNGEL DEL CAOS [JEFE FINAL]", "Nv. 70", 31500, 31500, true)
boss.PrimaryPart = bHrp
boss.Parent = room5

-- Cofre de Oro Sagrado
local chest = Instance.new("Model")
chest.Name = "Deluxe_Sacred_Gold_Chest"
local cPos = Vector3.new(baseX + 18, baseY + 5.5, r5CenterZ + 18)
local cBase = createPart(chest, "ChestBase", Vector3.new(7, 4.5, 5), CFrame.new(cPos), Color3.fromRGB(255, 215, 60), Enum.Material.Metal)
createPart(chest, "ChestLid", Vector3.new(7.4, 2.8, 5.4), CFrame.new(cPos + Vector3.new(0, 3.2, 0)), Color3.fromRGB(245, 245, 255), Enum.Material.Marble)
createPart(chest, "ChestRune", Vector3.new(7.8, 0.8, 5.8), CFrame.new(cPos + Vector3.new(0, 2, 0)), Color3.fromRGB(255, 230, 80), Enum.Material.Neon, false)
local cPrompt = Instance.new("ProximityPrompt")
cPrompt.ObjectText = "Cofre de Oro Sagrado"
cPrompt.ActionText = "Abrir Botín Celestial"
cPrompt.HoldDuration = 1.0
cPrompt.MaxActivationDistance = 14
cPrompt.Parent = cBase
chest.Parent = room5

-- Portal de Retorno al Lobby
local exitPortal = Instance.new("Model")
exitPortal.Name = "Exit_Portal_To_Lobby"
local epPos = Vector3.new(baseX - 18, baseY + 10, r5CenterZ + 20)
createPart(exitPortal, "Portal_Arch", Vector3.new(14.5, 2.5, 2.5), CFrame.new(epPos + Vector3.new(0, 8, 0)), Color3.fromRGB(255, 215, 60), Enum.Material.Metal)
local vortex = createPart(exitPortal, "Vortex", Vector3.new(10, 14, 1.2), CFrame.new(epPos), Color3.fromRGB(255, 230, 90), Enum.Material.Neon, false, 0.3)
local epPrompt = Instance.new("ProximityPrompt")
epPrompt.ObjectText = "Portal de Retorno"
epPrompt.ActionText = "Volver al Santuario (Lobby)"
epPrompt.HoldDuration = 0.5
epPrompt.MaxActivationDistance = 12
epPrompt.Parent = vortex
exitPortal.Parent = room5

room5.Parent = dungeon
dungeon.Parent = Workspace

print("======================================================================")
print("  ✓ REGIÓN 5: TEMPLO DE LOS CIELOS CONSTRUIDO EXITOSAMENTE EN 3D")
print("  ✓ Ubicación: baseX = 0, baseY = 350, baseZ = 0 (350 studs sobre el Lobby)")
print("  ✓ 5 Salas: Plaza Celestial -> Puentes de Nubes -> Santuario -> Guardián -> Arcángel")
print("  ✓ Jefe Final: Arcángel del Caos (20 studs, 31,500 HP, 4 Alas Divinas, Espada Solar)")
print("  ✓ Cofre de Oro Sagrado & Portal de Retorno al Lobby")
print("======================================================================")
