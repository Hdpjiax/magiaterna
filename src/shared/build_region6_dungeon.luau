--!strict
--[[
    build_region6_dungeon.luau
    Construye físicamente la Región 6 completa: Abismo del Infinito en MAGIA ETERNA
    - Ubicación: baseX = 0, baseY = -350, baseZ = 0 (350 studs por debajo del Lobby en el vacío cósmico).
    - 5 Salas del Vacío Infinito:
      1. Room1_Void_Rift: Plataforma de obsidiana cósmica, cristales astrales cian y 3 Devoradores del Abismo.
      2. Room2_Nebula_Bridge: Puente de antimateria sobre el vacío cósmico y 2 Sombras del Abismo.
      3. Room3_Cosmic_Singularity: Singularidad gravitacional con fragmentos dimensionales y 2 Magos del Vacío.
      4. Room4_Dimensional_Rift: Arena circular cósmica con 4 monolitos pulsantes y el MiniJefe Destructor Dimensional (12 studs).
      5. Room5_Void_God_Sanctum: Coliseo colosal del Fin del Tiempo de 95 studs, anillos de energía cósmica, el Jefe Final Supremo
         Dios del Vacío (22 studs, 72,000 HP), Cofre del Vacío Infinito y Portal de Retorno al Lobby.
    - 4 Puertas Rúnicas del Abismo con AlwaysOnTop = false y MaxDistance = 25.
]]

local Workspace = game:GetService("Workspace")

local baseX = 0
local baseY = -350
local baseZ = 0

local dungeon = Instance.new("Model")
dungeon.Name = "Dungeon_Abismo_Infinito"

-- Limpiar versión previa si existiera
local existing = Workspace:FindFirstChild("Dungeon_Abismo_Infinito") or Workspace:FindFirstChild("Dungeon_Abismo")
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
    bb.StudsOffset = isBoss and Vector3.new(0, 14, 0) or Vector3.new(0, 3.8, 0)
    bb.AlwaysOnTop = false
    bb.MaxDistance = isBoss and 60 or 35
    bb.Adornee = parent:IsA("BasePart") and parent or nil

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 8, 20)
    bg.BackgroundTransparency = 0.25
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = bg

    local stroke = Instance.new("UIStroke")
    stroke.Color = isBoss and Color3.fromRGB(220, 50, 255) or Color3.fromRGB(80, 220, 255)
    stroke.Thickness = isBoss and 2 or 1.5
    stroke.Parent = bg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.5, 0)
    title.Position = UDim2.new(0, 0, 0.05, 0)
    title.BackgroundTransparency = 1
    title.Text = name .. " • " .. lvl
    title.TextColor3 = isBoss and Color3.fromRGB(240, 180, 255) or Color3.fromRGB(180, 240, 255)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = bg

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0.9, 0, 0.3, 0)
    track.Position = UDim2.new(0.05, 0, 0.6, 0)
    track.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 4)
    tc.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(hp / maxHp, 0, 1, 0)
    fill.BackgroundColor3 = isBoss and Color3.fromRGB(180, 40, 255) or Color3.fromRGB(0, 200, 255)
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

local function createVoidGate(gateName: string, cf: CFrame, roomFrom: number, roomTo: number)
    local gateModel = Instance.new("Model")
    gateModel.Name = gateName
    gateModel:SetAttribute("IsOpen", false)

    -- Columnas de materia oscura con cristales cósmicos
    createPart(gateModel, "Gate_Pillar_L", Vector3.new(4, 22, 4), cf * CFrame.new(-12, 11, 0), Color3.fromRGB(15, 12, 25), Enum.Material.Slate)
    createPart(gateModel, "Gate_Pillar_R", Vector3.new(4, 22, 4), cf * CFrame.new(12, 11, 0), Color3.fromRGB(15, 12, 25), Enum.Material.Slate)
    createPart(gateModel, "Gate_Arch", Vector3.new(28, 4, 4), cf * CFrame.new(0, 22, 0), Color3.fromRGB(25, 18, 40), Enum.Material.Slate)

    createPart(gateModel, "CosmicGem_L", Vector3.new(2, 4, 2), cf * CFrame.new(-12, 14, 0), Color3.fromRGB(0, 220, 255), Enum.Material.Neon)
    createPart(gateModel, "CosmicGem_R", Vector3.new(2, 4, 2), cf * CFrame.new(12, 14, 0), Color3.fromRGB(180, 50, 255), Enum.Material.Neon)

    -- Barrera de distorsión del vacío
    local barrier = createPart(gateModel, "Runic_Barrier", Vector3.new(20, 20, 1.5), cf * CFrame.new(0, 10, 0), Color3.fromRGB(60, 20, 120), Enum.Material.Glass, true, 0.4)

    local pl = Instance.new("PointLight")
    pl.Color = Color3.fromRGB(140, 50, 255)
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
    txt.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
    txt.BackgroundTransparency = 0.2
    txt.Text = string.format("🔒 GRIETA DIMENSIONAL\nSala %d → Sala %d", roomFrom, roomTo)
    txt.TextColor3 = Color3.fromRGB(200, 150, 255)
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
-- SALA 1: GRIETA DEL VACÍO (Z: 0 a -40)
-- ============================================================================
local room1 = Instance.new("Model")
room1.Name = "Room1_Void_Rift"

createPart(room1, "Floor_R1", Vector3.new(65, 4, 65), CFrame.new(baseX, baseY, baseZ - 10), Color3.fromRGB(18, 14, 28), Enum.Material.Basalt)
createPart(room1, "CosmicTrim_R1", Vector3.new(67, 1, 67), CFrame.new(baseX, baseY - 1, baseZ - 10), Color3.fromRGB(0, 180, 240), Enum.Material.Neon, false, 0.4)

-- Spawn Pad Cósmico
local spawnPad = createPart(room1, "Dungeon_SpawnPad", Vector3.new(16, 1.5, 16), CFrame.new(baseX, baseY + 2.5, baseZ + 15), Color3.fromRGB(25, 18, 38), Enum.Material.Marble)
createPart(room1, "SpawnRune", Vector3.new(12, 0.4, 12), CFrame.new(baseX, baseY + 3.4, baseZ + 15), Color3.fromRGB(160, 40, 255), Enum.Material.Neon, false)

-- 4 Cristales Astrales Flotantes
local crystalOffsetsR1 = {
    Vector3.new(-22, 0, 15),
    Vector3.new(22, 0, 15),
    Vector3.new(-22, 0, -25),
    Vector3.new(22, 0, -25),
}
for i, off in ipairs(crystalOffsetsR1) do
    local pillar = createPart(room1, "VoidPillar_" .. i, Vector3.new(3.5, 18, 3.5), CFrame.new(baseX + off.X, baseY + 9, baseZ + off.Z), Color3.fromRGB(22, 16, 32), Enum.Material.Slate)
    local crystal = createPart(room1, "AstralCrystal_" .. i, Vector3.new(3, 7, 3), CFrame.new(baseX + off.X, baseY + 20, baseZ + off.Z) * CFrame.Angles(math.rad(15), math.rad(45), 0), Color3.fromRGB(0, 220, 255), Enum.Material.Glass)
    local pl = Instance.new("PointLight")
    pl.Color = Color3.fromRGB(0, 200, 255)
    pl.Range = 28
    pl.Brightness = 2.4
    pl.Parent = crystal
end

-- 3 Enemigos: Devoradores del Abismo (Nv. 70, HP 4,800)
local devoradorSpawns = {
    Vector3.new(baseX - 14, baseY + 5, baseZ - 15),
    Vector3.new(baseX, baseY + 5, baseZ - 25),
    Vector3.new(baseX + 14, baseY + 5, baseZ - 15),
}
for i, pos in ipairs(devoradorSpawns) do
    local dev = Instance.new("Model")
    dev.Name = "Enemy_DevoradorAbismo_" .. i
    dev:SetAttribute("EnemyId", "Enemy_DevoradorAbismo")
    dev:SetAttribute("MaxHealth", 4800)
    dev:SetAttribute("CurrentHealth", 4800)

    local hrp = createPart(dev, "HumanoidRootPart", Vector3.new(3.5, 6.5, 3), CFrame.new(pos), Color3.fromRGB(30, 20, 45), Enum.Material.Basalt)
    local head = createPart(dev, "Head", Vector3.new(2.8, 2.8, 2.8), CFrame.new(pos + Vector3.new(0, 3.8, 0)), Color3.fromRGB(15, 10, 25), Enum.Material.Slate)
    local eye = createPart(dev, "VoidEye", Vector3.new(1.4, 1.4, 0.4), head.CFrame * CFrame.new(0, 0, 1.4), Color3.fromRGB(240, 40, 255), Enum.Material.Neon, false)
    local hornL = createPart(dev, "HornL", Vector3.new(0.8, 3, 0.8), head.CFrame * CFrame.new(-1.2, 1.8, -0.4) * CFrame.Angles(0, 0, math.rad(25)), Color3.fromRGB(0, 220, 255), Enum.Material.Neon)
    local hornR = createPart(dev, "HornR", Vector3.new(0.8, 3, 0.8), head.CFrame * CFrame.new(1.2, 1.8, -0.4) * CFrame.Angles(0, 0, math.rad(-25)), Color3.fromRGB(0, 220, 255), Enum.Material.Neon)

    local hum = Instance.new("Humanoid")
    hum.MaxHealth = 4800
    hum.Health = 4800
    hum.DisplayName = "Devorador del Abismo"
    hum.Parent = dev

    createHealthTag(hrp, "Devorador del Abismo", "Nv. 70", 4800, 4800)
    dev.PrimaryPart = hrp
    dev.Parent = room1
end

room1.Parent = dungeon

-- PUERTA 1 -> 2
createVoidGate("Gate_Room1_To_Room2", CFrame.new(baseX, baseY + 2, baseZ - 45), 1, 2)

-- ============================================================================
-- SALA 2: PUENTE DE ANTIMATERIA (Z: -50 a -115)
-- ============================================================================
local room2 = Instance.new("Model")
room2.Name = "Room2_Nebula_Bridge"

local r2CenterZ = baseZ - 85
local bridge = createPart(room2, "AntimatterBridge", Vector3.new(18, 3, 65), CFrame.new(baseX, baseY + 1, r2CenterZ), Color3.fromRGB(20, 15, 32), Enum.Material.Basalt)
createPart(room2, "CosmicSpine", Vector3.new(4, 0.4, 63), CFrame.new(baseX, baseY + 2.7, r2CenterZ), Color3.fromRGB(170, 40, 255), Enum.Material.Neon, false)

-- 2 Enemigos: Sombras del Abismo (Nv. 75, HP 6,000)
local sombraSpawns = {
    Vector3.new(baseX - 4, baseY + 5.5, r2CenterZ + 12),
    Vector3.new(baseX + 4, baseY + 5.5, r2CenterZ - 12),
}
for i, pos in ipairs(sombraSpawns) do
    local sombra = Instance.new("Model")
    sombra.Name = "Enemy_SombraAbismo_" .. i
    sombra:SetAttribute("EnemyId", "Enemy_SombraAbismo")
    sombra:SetAttribute("MaxHealth", 6000)
    sombra:SetAttribute("CurrentHealth", 6000)

    local hrp = createPart(sombra, "HumanoidRootPart", Vector3.new(3.2, 6, 3), CFrame.new(pos), Color3.fromRGB(25, 18, 38), Enum.Material.ForceField, true, 0.3)
    local head = createPart(sombra, "Head", Vector3.new(2.4, 2.4, 2.4), CFrame.new(pos + Vector3.new(0, 3.4, 0)), Color3.fromRGB(10, 5, 20), Enum.Material.Glass)
    local eyeA = createPart(sombra, "EyeA", Vector3.new(0.5, 0.5, 0.5), head.CFrame * CFrame.new(-0.6, 0.2, 1.2), Color3.fromRGB(0, 255, 220), Enum.Material.Neon, false)
    local eyeB = createPart(sombra, "EyeB", Vector3.new(0.5, 0.5, 0.5), head.CFrame * CFrame.new(0.6, 0.2, 1.2), Color3.fromRGB(0, 255, 220), Enum.Material.Neon, false)

    local hum = Instance.new("Humanoid")
    hum.MaxHealth = 6000
    hum.Health = 6000
    hum.DisplayName = "Sombra del Abismo"
    hum.Parent = sombra

    createHealthTag(hrp, "Sombra del Abismo", "Nv. 75", 6000, 6000)
    sombra.PrimaryPart = hrp
    sombra.Parent = room2
end

room2.Parent = dungeon

-- PUERTA 2 -> 3
createVoidGate("Gate_Room2_To_Room3", CFrame.new(baseX, baseY + 2, baseZ - 125), 2, 3)

-- ============================================================================
-- SALA 3: SINGULARIDAD CÓSMICA (Z: -130 a -195)
-- ============================================================================
local room3 = Instance.new("Model")
room3.Name = "Room3_Cosmic_Singularity"

local r3CenterZ = baseZ - 165
createPart(room3, "Floor_R3", Vector3.new(72, 4, 72), CFrame.new(baseX, baseY, r3CenterZ), Color3.fromRGB(16, 12, 26), Enum.Material.Basalt)
local singularity = createPart(room3, "BlackHoleCenter", Vector3.new(16, 0.5, 16), CFrame.new(baseX, baseY + 2.3, r3CenterZ), Color3.fromRGB(5, 2, 10), Enum.Material.Neon)
local singularityRing = createPart(room3, "AccretionDisk", Vector3.new(28, 0.3, 28), CFrame.new(baseX, baseY + 2.4, r3CenterZ), Color3.fromRGB(190, 50, 255), Enum.Material.Neon, false, 0.3)

-- 2 Enemigos: Magos del Vacío (Nv. 80, HP 8,400)
local magoSpawns = {
    Vector3.new(baseX - 12, baseY + 5.5, r3CenterZ),
    Vector3.new(baseX + 12, baseY + 5.5, r3CenterZ),
}
for i, pos in ipairs(magoSpawns) do
    local mago = Instance.new("Model")
    mago.Name = "Enemy_MagoVacio_" .. i
    mago:SetAttribute("EnemyId", "Enemy_MagoVacio")
    mago:SetAttribute("MaxHealth", 8400)
    mago:SetAttribute("CurrentHealth", 8400)

    local hrp = createPart(mago, "HumanoidRootPart", Vector3.new(3, 6, 2.5), CFrame.new(pos), Color3.fromRGB(22, 16, 35), Enum.Material.Slate)
    local head = createPart(mago, "Head", Vector3.new(2.2, 2.2, 2.2), CFrame.new(pos + Vector3.new(0, 3.5, 0)), Color3.fromRGB(12, 8, 20), Enum.Material.SmoothPlastic)
    local orb = createPart(mago, "VoidOrbStaff", Vector3.new(2, 2, 2), hrp.CFrame * CFrame.new(2.5, 3, 0), Color3.fromRGB(0, 220, 255), Enum.Material.Neon, false)

    local hum = Instance.new("Humanoid")
    hum.MaxHealth = 8400
    hum.Health = 8400
    hum.DisplayName = "Mago del Vacío"
    hum.Parent = mago

    createHealthTag(hrp, "Mago del Vacío", "Nv. 80", 8400, 8400)
    mago.PrimaryPart = hrp
    mago.Parent = room3
end

room3.Parent = dungeon

-- PUERTA 3 -> 4
createVoidGate("Gate_Room3_To_Room4", CFrame.new(baseX, baseY + 2, baseZ - 205), 3, 4)

-- ============================================================================
-- SALA 4: ARENA DEL DESTRUCTOR DIMENSIONAL (Z: -210 a -280)
-- ============================================================================
local room4 = Instance.new("Model")
room4.Name = "Room4_Dimensional_Rift"

local r4CenterZ = baseZ - 250
createPart(room4, "ArenaFloor_R4", Vector3.new(74, 4, 74), CFrame.new(baseX, baseY, r4CenterZ), Color3.fromRGB(18, 12, 28), Enum.Material.Basalt)
createPart(room4, "VoidRuneCircle", Vector3.new(62, 0.4, 62), CFrame.new(baseX, baseY + 2.2, r4CenterZ), Color3.fromRGB(160, 40, 255), Enum.Material.Neon, false)

-- 4 Monolitos Cósmicos
local voidPillars = {
    Vector3.new(0, 0, -24),
    Vector3.new(0, 0, 24),
    Vector3.new(-24, 0, 0),
    Vector3.new(24, 0, 0),
}
for i, off in ipairs(voidPillars) do
    local ob = createPart(room4, "VoidMonolith_" .. i, Vector3.new(4.5, 20, 4.5), CFrame.new(baseX + off.X, baseY + 10, r4CenterZ + off.Z), Color3.fromRGB(12, 8, 20), Enum.Material.Basalt)
    local gem = createPart(room4, "MonolithGem_" .. i, Vector3.new(2.5, 5, 2.5), ob.CFrame * CFrame.new(0, 11, 0), Color3.fromRGB(0, 220, 255), Enum.Material.Neon, false)
    local pl = Instance.new("PointLight")
    pl.Color = Color3.fromRGB(0, 220, 255)
    pl.Range = 26
    pl.Brightness = 2.5
    pl.Parent = gem
end

-- MiniJefe: Destructor Dimensional (12 studs, Nv. 90, HP 25,600)
local destructor = Instance.new("Model")
destructor.Name = "Enemy_DestructorDimensional"
destructor:SetAttribute("EnemyId", "Enemy_DestructorDimensional")
destructor:SetAttribute("MaxHealth", 25600)
destructor:SetAttribute("CurrentHealth", 25600)
destructor:SetAttribute("IsMiniBoss", true)

local dPos = Vector3.new(baseX, baseY + 8, r4CenterZ)
local dHrp = createPart(destructor, "HumanoidRootPart", Vector3.new(6, 10, 5), CFrame.new(dPos), Color3.fromRGB(28, 18, 42), Enum.Material.Metal)
local dHead = createPart(destructor, "Head", Vector3.new(3.8, 3.8, 3.8), CFrame.new(dPos + Vector3.new(0, 6, 0)), Color3.fromRGB(15, 8, 25), Enum.Material.DiamondPlate)
local bladeL = createPart(destructor, "VoidBladeL", Vector3.new(1.5, 14, 2.5), dHrp.CFrame * CFrame.new(-4.5, 0.5, 1) * CFrame.Angles(0, 0, math.rad(20)), Color3.fromRGB(180, 50, 255), Enum.Material.Neon, false)
local bladeR = createPart(destructor, "VoidBladeR", Vector3.new(1.5, 14, 2.5), dHrp.CFrame * CFrame.new(4.5, 0.5, 1) * CFrame.Angles(0, 0, math.rad(-20)), Color3.fromRGB(0, 220, 255), Enum.Material.Neon, false)

local dHum = Instance.new("Humanoid")
dHum.MaxHealth = 25600
dHum.Health = 25600
dHum.DisplayName = "Destructor Dimensional"
dHum.Parent = destructor

createHealthTag(dHrp, "Destructor Dimensional [MINIBOSS]", "Nv. 90", 25600, 25600, true)
destructor.PrimaryPart = dHrp
destructor.Parent = room4

room4.Parent = dungeon

-- PUERTA 4 -> 5
createVoidGate("Gate_Room4_To_Room5", CFrame.new(baseX, baseY + 2, baseZ - 290), 4, 5)

-- ============================================================================
-- SALA 5: SANTUARIO DEL DIOS DEL VACÍO (Z: -295 a -410)
-- ============================================================================
local room5 = Instance.new("Model")
room5.Name = "Room5_Void_God_Sanctum"

local r5CenterZ = baseZ - 355
local colosseumFloor = createPart(room5, "Floor_Sanctum", Vector3.new(96, 5, 96), CFrame.new(baseX, baseY, r5CenterZ), Color3.fromRGB(12, 8, 20), Enum.Material.Basalt)

-- Anillos Cósmicos AoE de Antimateria
createPart(room5, "AoE_Ring_1", Vector3.new(82, 0.4, 82), CFrame.new(baseX, baseY + 2.7, r5CenterZ), Color3.fromRGB(180, 40, 255), Enum.Material.Neon, false)
createPart(room5, "AoE_Ring_2", Vector3.new(54, 0.5, 54), CFrame.new(baseX, baseY + 2.8, r5CenterZ), Color3.fromRGB(0, 220, 255), Enum.Material.Neon, false)

-- 8 Monolitos del Fin del Tiempo
for angle = 0, 315, 45 do
    local rad = math.rad(angle)
    local px = baseX + math.cos(rad) * 44
    local pz = r5CenterZ + math.sin(rad) * 44
    local col = createPart(room5, "VoidPillar_" .. angle, Vector3.new(6, 42, 6), CFrame.new(px, baseY + 21, pz), Color3.fromRGB(16, 10, 25), Enum.Material.Slate)
    local flame = createPart(room5, "CosmicPyre_" .. angle, Vector3.new(4, 6, 4), CFrame.new(px, baseY + 36, pz), Color3.fromRGB(190, 50, 255), Enum.Material.Neon, false)
    local pl = Instance.new("PointLight")
    pl.Color = Color3.fromRGB(190, 50, 255)
    pl.Range = 36
    pl.Brightness = 2.6
    pl.Parent = flame
end

-- ============================================================================
-- JEFE FINAL SUPREMO: DIOS DEL VACÍO (22 studs de altura, Nv. 100, HP 72,000)
-- ============================================================================
local boss = Instance.new("Model")
boss.Name = "Enemy_DiosVacio"
boss:SetAttribute("EnemyId", "Enemy_DiosVacio")
boss:SetAttribute("MaxHealth", 72000)
boss:SetAttribute("CurrentHealth", 72000)
boss:SetAttribute("IsBoss", true)

local bPos = Vector3.new(baseX, baseY + 15, r5CenterZ - 10)
local bHrp = createPart(boss, "HumanoidRootPart", Vector3.new(9, 20, 7), CFrame.new(bPos), Color3.fromRGB(15, 8, 28), Enum.Material.ForceField, true, 0.3)
local bTorso = createPart(boss, "Torso", Vector3.new(10, 12, 7.5), CFrame.new(bPos + Vector3.new(0, 1.5, 0)), Color3.fromRGB(22, 12, 38), Enum.Material.Basalt)
local bHead = createPart(boss, "Head", Vector3.new(6, 6, 6), CFrame.new(bPos + Vector3.new(0, 10.5, 0)), Color3.fromRGB(10, 4, 18), Enum.Material.Slate)

-- Ojo Cósmico Central y Cuernos Astrales
createPart(boss, "CosmicEye", Vector3.new(2.8, 2.8, 0.8), bHead.CFrame * CFrame.new(0, 0, 3.1), Color3.fromRGB(0, 255, 230), Enum.Material.Neon, false)
createPart(boss, "VoidHornL", Vector3.new(1.8, 8, 1.8), bHead.CFrame * CFrame.new(-3.5, 4, 0) * CFrame.Angles(0, 0, math.rad(30)), Color3.fromRGB(180, 40, 255), Enum.Material.Neon, false)
createPart(boss, "VoidHornR", Vector3.new(1.8, 8, 1.8), bHead.CFrame * CFrame.new(3.5, 4, 0) * CFrame.Angles(0, 0, math.rad(-30)), Color3.fromRGB(180, 40, 255), Enum.Material.Neon, false)

-- 4 Tentáculos Astrales de Energía Cósmica
local tentacle1 = createPart(boss, "Tentacle1", Vector3.new(2.2, 16, 2.2), bHrp.CFrame * CFrame.new(-8, 3, -2) * CFrame.Angles(0, 0, math.rad(40)), Color3.fromRGB(160, 40, 255), Enum.Material.Neon, false)
local tentacle2 = createPart(boss, "Tentacle2", Vector3.new(2.2, 16, 2.2), bHrp.CFrame * CFrame.new(8, 3, -2) * CFrame.Angles(0, 0, math.rad(-40)), Color3.fromRGB(0, 220, 255), Enum.Material.Neon, false)
local tentacle3 = createPart(boss, "Tentacle3", Vector3.new(2.2, 14, 2.2), bHrp.CFrame * CFrame.new(-6, -3, -2) * CFrame.Angles(0, 0, math.rad(20)), Color3.fromRGB(0, 220, 255), Enum.Material.Neon, false)
local tentacle4 = createPart(boss, "Tentacle4", Vector3.new(2.2, 14, 2.2), bHrp.CFrame * CFrame.new(6, -3, -2) * CFrame.Angles(0, 0, math.rad(-20)), Color3.fromRGB(160, 40, 255), Enum.Material.Neon, false)

-- Orbe del Fin de los Tiempos
local doomOrb = createPart(boss, "DoomOrb", Vector3.new(5, 5, 5), bHrp.CFrame * CFrame.new(0, 14, 5), Color3.fromRGB(230, 40, 255), Enum.Material.Neon, false)
local bossLight = Instance.new("PointLight")
bossLight.Color = Color3.fromRGB(200, 50, 255)
bossLight.Range = 50
bossLight.Brightness = 4.0
bossLight.Parent = doomOrb

local bHum = Instance.new("Humanoid")
bHum.MaxHealth = 72000
bHum.Health = 72000
bHum.DisplayName = "Dios del Vacío"
bHum.Parent = boss

createHealthTag(bHrp, "👑 DIOS DEL VACÍO [JEFE SUPREMO]", "Nv. 100", 72000, 72000, true)
boss.PrimaryPart = bHrp
boss.Parent = room5

-- Cofre del Vacío Infinito
local chest = Instance.new("Model")
chest.Name = "Deluxe_Infinite_Void_Chest"
local cPos = Vector3.new(baseX + 18, baseY + 5.5, r5CenterZ + 18)
local cBase = createPart(chest, "ChestBase", Vector3.new(7, 4.5, 5), CFrame.new(cPos), Color3.fromRGB(25, 15, 38), Enum.Material.Metal)
createPart(chest, "ChestLid", Vector3.new(7.4, 2.8, 5.4), CFrame.new(cPos + Vector3.new(0, 3.2, 0)), Color3.fromRGB(15, 10, 25), Enum.Material.Basalt)
createPart(chest, "ChestRune", Vector3.new(7.8, 0.8, 5.8), CFrame.new(cPos + Vector3.new(0, 2, 0)), Color3.fromRGB(0, 220, 255), Enum.Material.Neon, false)
local cPrompt = Instance.new("ProximityPrompt")
cPrompt.ObjectText = "Cofre del Vacío Infinito"
cPrompt.ActionText = "Abrir Botín del Fin del Tiempo"
cPrompt.HoldDuration = 1.0
cPrompt.MaxActivationDistance = 14
cPrompt.Parent = cBase
chest.Parent = room5

-- Portal de Retorno al Lobby
local exitPortal = Instance.new("Model")
exitPortal.Name = "Exit_Portal_To_Lobby"
local epPos = Vector3.new(baseX - 18, baseY + 10, r5CenterZ + 20)
createPart(exitPortal, "Portal_Arch", Vector3.new(14.5, 2.5, 2.5), CFrame.new(epPos + Vector3.new(0, 8, 0)), Color3.fromRGB(30, 20, 45), Enum.Material.Metal)
local vortex = createPart(exitPortal, "Vortex", Vector3.new(10, 14, 1.2), CFrame.new(epPos), Color3.fromRGB(180, 50, 255), Enum.Material.Neon, false, 0.3)
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
print("  ✓ REGIÓN 6: ABISMO DEL INFINITO CONSTRUIDO EXITOSAMENTE EN 3D")
print("  ✓ Ubicación: baseX = 0, baseY = -350, baseZ = 0 (350 studs bajo el Lobby)")
print("  ✓ 5 Salas: Grieta del Vacío -> Puente Antimateria -> Singularidad -> Destructor -> Dios del Vacío")
print("  ✓ Jefe Final: Dios del Vacío (22 studs, 72,000 HP, Tentáculos Astrales, Orbe del Juicio)")
print("  ✓ Cofre del Vacío Infinito & Portal de Retorno al Lobby")
print("======================================================================")
