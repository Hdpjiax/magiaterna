--!strict
--[[
    build_region3_dungeon.luau
    Construye físicamente la Región 3 completa: Reino del Hielo
    - Ubicación: baseX = 0, baseY = 50, baseZ = 800 (Separación limpia de 800 studs del Lobby).
    - 5 Salas Conectadas:
      1. Room1_Glacial_Cavern: Caverna de hielo translúcido, estalactitas gigantes y 3 Lobos Árticos.
      2. Room2_Frost_Bridge: Puente colgante de cristal de hielo sobre el abismo glacial con 2 Espectros de Hielo.
      3. Room3_Frost_Foundry: Salón de agujas de zafiro místico y 2 Yetis de Hielo.
      4. Room4_Queen_Arena: Arena cilíndrica con la Reina de Escarcha (MiniBoss de 11 studs).
      5. Room5_Titan_Temple: Coliseo colosal de 90 studs con el Titán Glacial (Jefe Final de 20 studs),
         anillos AoE de ventisca, Cofre de Zafiro Glacial y Portal de Retorno al Lobby.
    - 4 Puertas Rúnicas de Escarcha entre salas con AlwaysOnTop = false y MaxDistance = 25.
]]

local Workspace = game:GetService("Workspace")

local baseX = 0
local baseY = 50
local baseZ = 800

local dungeon = Instance.new("Model")
dungeon.Name = "Dungeon_Reino_Hielo"

-- Limpiar versión previa si existiera
local existing = Workspace:FindFirstChild("Dungeon_Reino_Hielo")
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
    bb.StudsOffset = isBoss and Vector3.new(0, 12, 0) or Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = false
    bb.MaxDistance = isBoss and 60 or 35
    bb.Adornee = parent:IsA("BasePart") and parent or nil

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    bg.BackgroundTransparency = 0.25
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = bg

    local stroke = Instance.new("UIStroke")
    stroke.Color = isBoss and Color3.fromRGB(100, 220, 255) or Color3.fromRGB(140, 190, 240)
    stroke.Thickness = isBoss and 2 or 1.5
    stroke.Parent = bg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.5, 0)
    title.Position = UDim2.new(0, 0, 0.05, 0)
    title.BackgroundTransparency = 1
    title.Text = name .. " • " .. lvl
    title.TextColor3 = isBoss and Color3.fromRGB(220, 245, 255) or Color3.fromRGB(180, 225, 255)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = bg

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0.9, 0, 0.3, 0)
    track.Position = UDim2.new(0.05, 0, 0.6, 0)
    track.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 4)
    tc.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(hp / maxHp, 0, 1, 0)
    fill.BackgroundColor3 = isBoss and Color3.fromRGB(0, 210, 255) or Color3.fromRGB(70, 220, 150)
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

local function createFrostRuneGate(gateName: string, cfPos: Vector3, reqText: string): Model
    local gate = Instance.new("Model")
    gate.Name = gateName

    -- Pilares de Hielo Arcano
    local pL = createPart(gate, "Pillar_Left", Vector3.new(4, 20, 4), CFrame.new(cfPos.X - 9, cfPos.Y + 10, cfPos.Z), Color3.fromRGB(160, 210, 245), Enum.Material.Ice)
    local pR = createPart(gate, "Pillar_Right", Vector3.new(4, 20, 4), CFrame.new(cfPos.X + 9, cfPos.Y + 10, cfPos.Z), Color3.fromRGB(160, 210, 245), Enum.Material.Ice)
    local top = createPart(gate, "Pillar_Top", Vector3.new(22, 4, 4), CFrame.new(cfPos.X, cfPos.Y + 20, cfPos.Z), Color3.fromRGB(140, 195, 235), Enum.Material.Ice)

    -- Barrera de Fuerza de Escarcha
    local barrier = createPart(gate, "Runic_Barrier", Vector3.new(14, 18, 0.6), CFrame.new(cfPos.X, cfPos.Y + 9, cfPos.Z), Color3.fromRGB(80, 210, 255), Enum.Material.ForceField, true, 0.4)

    -- Medallón de Zafiro
    local lock = createPart(gate, "Medallion_Lock", Vector3.new(2.4, 2.4, 2.4), CFrame.new(cfPos.X, cfPos.Y + 10, cfPos.Z), Color3.fromRGB(120, 230, 255), Enum.Material.Neon)
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(80, 220, 255)
    light.Range = 16
    light.Brightness = 2.0
    light.Parent = lock

    -- BillboardGui con MaxDistance = 25 y AlwaysOnTop = false
    local bb = Instance.new("BillboardGui")
    bb.Name = "GateSign"
    bb.Size = UDim2.new(0, 220, 0, 45)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = false
    bb.MaxDistance = 25
    bb.Adornee = lock

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "❄️ PUERTA DE ESCARCHA\n(" .. reqText .. ")"
    lbl.TextColor3 = Color3.fromRGB(140, 230, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextScaled = true
    lbl.Parent = bb
    bb.Parent = lock

    gate:SetAttribute("IsOpen", false)
    gate.Parent = gatesFolder
    return gate
end

-- ========================================================
-- SALA 1: Caverna Glacial de Entrada (Z = 800)
-- ========================================================
local room1 = Instance.new("Model")
room1.Name = "Room1_Glacial_Cavern"

-- Suelo de Hielo Translúcido
createPart(room1, "Floor_Ice", Vector3.new(50, 4, 60), CFrame.new(baseX, baseY, baseZ), Color3.fromRGB(180, 220, 245), Enum.Material.Ice, true, 0.15)
-- Zanjas de Nieve en laterales
createPart(room1, "Snow_Bank_Left", Vector3.new(8, 3.8, 60), CFrame.new(baseX - 22, baseY + 0.1, baseZ), Color3.fromRGB(240, 245, 255), Enum.Material.Snow)
createPart(room1, "Snow_Bank_Right", Vector3.new(8, 3.8, 60), CFrame.new(baseX + 22, baseY + 0.1, baseZ), Color3.fromRGB(240, 245, 255), Enum.Material.Snow)

-- Paredes Glaciales
createPart(room1, "Wall_West", Vector3.new(6, 24, 60), CFrame.new(baseX - 28, baseY + 12, baseZ), Color3.fromRGB(60, 75, 90), Enum.Material.Slate)
createPart(room1, "Wall_East", Vector3.new(6, 24, 60), CFrame.new(baseX + 28, baseY + 12, baseZ), Color3.fromRGB(60, 75, 90), Enum.Material.Slate)
createPart(room1, "Wall_Back", Vector3.new(50, 24, 6), CFrame.new(baseX, baseY + 12, baseZ - 33), Color3.fromRGB(60, 75, 90), Enum.Material.Slate)

-- Techo con Estalactitas Colgantes Gigantes
for sx = -15, 15, 10 do
    for sz = -15, 15, 15 do
        local stalactite = createPart(room1, "Stalactite", Vector3.new(2.4, 10, 2.4), CFrame.new(baseX + sx, baseY + 19, baseZ + sz), Color3.fromRGB(170, 225, 255), Enum.Material.Ice, false, 0.2)
        local pl = Instance.new("PointLight")
        pl.Color = Color3.fromRGB(100, 210, 255)
        pl.Range = 12
        pl.Brightness = 1.0
        pl.Parent = stalactite
    end
end

-- 3 Lobos Árticos en Sala 1
local wolfPositions = {
    Vector3.new(baseX - 8, baseY + 4.5, baseZ - 5),
    Vector3.new(baseX, baseY + 4.5, baseZ + 8),
    Vector3.new(baseX + 8, baseY + 4.5, baseZ - 5),
}

for i, wPos in ipairs(wolfPositions) do
    local wolf = Instance.new("Model")
    wolf.Name = "Lobo_Artico_" .. i

    local torso = createPart(wolf, "Torso", Vector3.new(2.8, 2.6, 4.2), CFrame.new(wPos), Color3.fromRGB(240, 245, 255), Enum.Material.SmoothPlastic, true)
    wolf.PrimaryPart = torso

    -- Cabeza y Hocico
    createPart(wolf, "Head", Vector3.new(2.2, 2.0, 2.4), CFrame.new(wPos.X, wPos.Y + 1.2, wPos.Z + 2.5), Color3.fromRGB(240, 245, 255), Enum.Material.SmoothPlastic)
    createPart(wolf, "Snout", Vector3.new(1.4, 1.0, 1.4), CFrame.new(wPos.X, wPos.Y + 0.8, wPos.Z + 3.8), Color3.fromRGB(220, 225, 240), Enum.Material.SmoothPlastic)

    -- Ojos de Zafiro
    createPart(wolf, "Eye_L", Vector3.new(0.35, 0.35, 0.35), CFrame.new(wPos.X - 0.7, wPos.Y + 1.6, wPos.Z + 3.0), Color3.fromRGB(50, 220, 255), Enum.Material.Neon)
    createPart(wolf, "Eye_R", Vector3.new(0.35, 0.35, 0.35), CFrame.new(wPos.X + 0.7, wPos.Y + 1.6, wPos.Z + 3.0), Color3.fromRGB(50, 220, 255), Enum.Material.Neon)

    -- Orejas afiladas
    createPart(wolf, "Ear_L", Vector3.new(0.5, 1.0, 0.5), CFrame.new(wPos.X - 0.8, wPos.Y + 2.4, wPos.Z + 2.2), Color3.fromRGB(240, 245, 255), Enum.Material.SmoothPlastic)
    createPart(wolf, "Ear_R", Vector3.new(0.5, 1.0, 0.5), CFrame.new(wPos.X + 0.8, wPos.Y + 2.4, wPos.Z + 2.2), Color3.fromRGB(240, 245, 255), Enum.Material.SmoothPlastic)

    -- Patas
    createPart(wolf, "Leg_FL", Vector3.new(0.8, 2.4, 0.8), CFrame.new(wPos.X - 1.1, wPos.Y - 1.3, wPos.Z + 1.4), Color3.fromRGB(225, 230, 245), Enum.Material.SmoothPlastic)
    createPart(wolf, "Leg_FR", Vector3.new(0.8, 2.4, 0.8), CFrame.new(wPos.X + 1.1, wPos.Y - 1.3, wPos.Z + 1.4), Color3.fromRGB(225, 230, 245), Enum.Material.SmoothPlastic)
    createPart(wolf, "Leg_BL", Vector3.new(0.8, 2.4, 0.8), CFrame.new(wPos.X - 1.1, wPos.Y - 1.3, wPos.Z - 1.4), Color3.fromRGB(225, 230, 245), Enum.Material.SmoothPlastic)
    createPart(wolf, "Leg_BR", Vector3.new(0.8, 2.4, 0.8), CFrame.new(wPos.X + 1.1, wPos.Y - 1.3, wPos.Z - 1.4), Color3.fromRGB(225, 230, 245), Enum.Material.SmoothPlastic)

    local cd = Instance.new("ClickDetector")
    cd.MaxActivationDistance = 45
    cd.Parent = torso

    createHealthTag(torso, "Lobo Ártico", "Nv. 25", 390, 390, false)
    wolf.Parent = room1
end

room1.Parent = dungeon
createFrostRuneGate("Gate_Room1_To_Room2", Vector3.new(baseX, baseY + 2, baseZ + 30), "Derrota a los Lobos Árticos")

-- ========================================================
-- SALA 2: Puente de Escarcha Suspendido (Z = 880)
-- ========================================================
local room2 = Instance.new("Model")
room2.Name = "Room2_Frost_Bridge"

-- Abismo Gélido 18 studs abajo
createPart(room2, "Glacial_Abyss_Floor", Vector3.new(90, 4, 75), CFrame.new(baseX, baseY - 16, baseZ + 80), Color3.fromRGB(20, 35, 55), Enum.Material.Ice)
-- Púas de hielo en el abismo
for px = -35, 35, 14 do
    createPart(room2, "Abyss_Spike", Vector3.new(3, 14, 3), CFrame.new(baseX + px, baseY - 9, baseZ + 80), Color3.fromRGB(120, 200, 255), Enum.Material.Glass, false, 0.3)
end

-- Puente de Cristal Glacial Arqueado
createPart(room2, "Bridge_Floor", Vector3.new(14, 2.6, 75), CFrame.new(baseX, baseY + 1.3, baseZ + 80), Color3.fromRGB(150, 220, 255), Enum.Material.Ice, true, 0.2)
createPart(room2, "Bridge_Rail_Left", Vector3.new(1, 3.5, 75), CFrame.new(baseX - 6.5, baseY + 3.8, baseZ + 80), Color3.fromRGB(120, 205, 245), Enum.Material.Glass, true, 0.3)
createPart(room2, "Bridge_Rail_Right", Vector3.new(1, 3.5, 75), CFrame.new(baseX + 6.5, baseY + 3.8, baseZ + 80), Color3.fromRGB(120, 205, 245), Enum.Material.Glass, true, 0.3)

-- Arco de Escarcha Transitable en la mitad del puente
createPart(room2, "Arch_Pillar_L", Vector3.new(3, 18, 3), CFrame.new(baseX - 6.5, baseY + 10, baseZ + 80), Color3.fromRGB(160, 215, 250), Enum.Material.Ice)
createPart(room2, "Arch_Pillar_R", Vector3.new(3, 18, 3), CFrame.new(baseX + 6.5, baseY + 10, baseZ + 80), Color3.fromRGB(160, 215, 250), Enum.Material.Ice)
createPart(room2, "Arch_Lintel", Vector3.new(16, 3, 3), CFrame.new(baseX, baseY + 19, baseZ + 80), Color3.fromRGB(180, 230, 255), Enum.Material.Neon)

-- Paredes del Cañón Glacial
createPart(room2, "Canyon_Wall_West", Vector3.new(8, 38, 75), CFrame.new(baseX - 45, baseY + 8, baseZ + 80), Color3.fromRGB(40, 55, 70), Enum.Material.Slate)
createPart(room2, "Canyon_Wall_East", Vector3.new(8, 38, 75), CFrame.new(baseX + 45, baseY + 8, baseZ + 80), Color3.fromRGB(40, 55, 70), Enum.Material.Slate)

-- 2 Espectros de Hielo en el Puente
local specterPositions = {
    Vector3.new(baseX - 3.5, baseY + 6.5, baseZ + 65),
    Vector3.new(baseX + 3.5, baseY + 6.5, baseZ + 95),
}

for i, sPos in ipairs(specterPositions) do
    local specter = Instance.new("Model")
    specter.Name = "Espectro_Hielo_" .. i

    local sTorso = createPart(specter, "Torso", Vector3.new(3, 4, 2), CFrame.new(sPos), Color3.fromRGB(140, 220, 255), Enum.Material.Glass, true, 0.35)
    specter.PrimaryPart = sTorso

    createPart(specter, "Core", Vector3.new(1.8, 1.8, 1.8), CFrame.new(sPos), Color3.fromRGB(80, 225, 255), Enum.Material.Neon)
    createPart(specter, "Eyes", Vector3.new(1.6, 0.4, 0.4), CFrame.new(sPos.X, sPos.Y + 1.2, sPos.Z + 1.1), Color3.fromRGB(240, 255, 255), Enum.Material.Neon)

    local sFire = Instance.new("Fire")
    sFire.Heat = 4
    sFire.Size = 4
    sFire.Color = Color3.fromRGB(80, 210, 255)
    sFire.SecondaryColor = Color3.fromRGB(200, 240, 255)
    sFire.Parent = sTorso

    local cd = Instance.new("ClickDetector")
    cd.MaxActivationDistance = 45
    cd.Parent = sTorso

    createHealthTag(sTorso, "Espectro de Hielo", "Nv. 28", 488, 488, false)
    specter.Parent = room2
end

room2.Parent = dungeon
createFrostRuneGate("Gate_Room2_To_Room3", Vector3.new(baseX, baseY + 2, baseZ + 120), "Supera a los Espectros de Hielo")

-- ========================================================
-- SALA 3: Forja de Escarcha & Agujas de Zafiro (Z = 955)
-- ========================================================
local room3 = Instance.new("Model")
room3.Name = "Room3_Frost_Foundry"

createPart(room3, "Floor_Cobblestone_Ice", Vector3.new(65, 4, 65), CFrame.new(baseX, baseY, baseZ + 155), Color3.fromRGB(150, 180, 205), Enum.Material.Cobblestone)
createPart(room3, "Wall_West", Vector3.new(6, 26, 65), CFrame.new(baseX - 35, baseY + 12, baseZ + 155), Color3.fromRGB(45, 60, 75), Enum.Material.Slate)
createPart(room3, "Wall_East", Vector3.new(6, 26, 65), CFrame.new(baseX + 35, baseY + 12, baseZ + 155), Color3.fromRGB(45, 60, 75), Enum.Material.Slate)

-- Agujas de Zafiro Místico
local needleAngles = { 0, 60, 120, 180, 240, 300 }
for _, ang in ipairs(needleAngles) do
    local rad = math.rad(ang)
    local nx = baseX + math.cos(rad) * 22
    local nz = baseZ + 155 + math.sin(rad) * 22
    local needle = createPart(room3, "Sapphire_Spire", Vector3.new(3, 16, 3), CFrame.new(nx, baseY + 8, nz), Color3.fromRGB(70, 190, 255), Enum.Material.Glass, true, 0.2)
    local nLight = Instance.new("PointLight")
    nLight.Color = Color3.fromRGB(90, 215, 255)
    nLight.Range = 18
    nLight.Brightness = 2.5
    nLight.Parent = needle
end

-- Altar de Escarcha Central
createPart(room3, "Frost_Altar_Base", Vector3.new(12, 2, 12), CFrame.new(baseX, baseY + 2, baseZ + 155), Color3.fromRGB(120, 150, 180), Enum.Material.Slate)
createPart(room3, "Altar_Crystal", Vector3.new(4, 5, 4), CFrame.new(baseX, baseY + 5, baseZ + 155), Color3.fromRGB(100, 230, 255), Enum.Material.Neon)

-- 2 Yetis de Hielo en Sala 3
local yetiPositions = {
    Vector3.new(baseX - 10, baseY + 6, baseZ + 155),
    Vector3.new(baseX + 10, baseY + 6, baseZ + 155),
}

for i, yPos in ipairs(yetiPositions) do
    local yeti = Instance.new("Model")
    yeti.Name = "Yeti_Hielo_" .. i

    local yTorso = createPart(yeti, "Torso", Vector3.new(6, 6, 4.5), CFrame.new(yPos.X, yPos.Y + 3, yPos.Z), Color3.fromRGB(230, 240, 255), Enum.Material.Fabric, true)
    yeti.PrimaryPart = yTorso

    -- Brazos gigantescos y puños de nieve
    createPart(yeti, "Arm_L", Vector3.new(2.4, 5.5, 2.4), CFrame.new(yPos.X - 4.2, yPos.Y + 2.5, yPos.Z), Color3.fromRGB(220, 230, 245), Enum.Material.Fabric)
    createPart(yeti, "Arm_R", Vector3.new(2.4, 5.5, 2.4), CFrame.new(yPos.X + 4.2, yPos.Y + 2.5, yPos.Z), Color3.fromRGB(220, 230, 245), Enum.Material.Fabric)
    createPart(yeti, "Snow_Fist_L", Vector3.new(3, 3, 3), CFrame.new(yPos.X - 4.2, yPos.Y - 0.5, yPos.Z), Color3.fromRGB(245, 250, 255), Enum.Material.Snow)
    createPart(yeti, "Snow_Fist_R", Vector3.new(3, 3, 3), CFrame.new(yPos.X + 4.2, yPos.Y - 0.5, yPos.Z), Color3.fromRGB(245, 250, 255), Enum.Material.Snow)

    -- Cabeza y Cuernos de hielo
    createPart(yeti, "Head", Vector3.new(3.5, 3.2, 3.2), CFrame.new(yPos.X, yPos.Y + 7, yPos.Z + 0.5), Color3.fromRGB(235, 242, 255), Enum.Material.Fabric)
    createPart(yeti, "Horn_L", Vector3.new(0.8, 3, 0.8), CFrame.new(yPos.X - 1.8, yPos.Y + 8.5, yPos.Z + 0.3) * CFrame.Angles(0, 0, math.rad(25)), Color3.fromRGB(140, 210, 255), Enum.Material.Ice)
    createPart(yeti, "Horn_R", Vector3.new(0.8, 3, 0.8), CFrame.new(yPos.X + 1.8, yPos.Y + 8.5, yPos.Z + 0.3) * CFrame.Angles(0, 0, math.rad(-25)), Color3.fromRGB(140, 210, 255), Enum.Material.Ice)
    createPart(yeti, "Eyes", Vector3.new(2, 0.5, 0.4), CFrame.new(yPos.X, yPos.Y + 7.2, yPos.Z + 2.2), Color3.fromRGB(70, 220, 255), Enum.Material.Neon)

    local cd = Instance.new("ClickDetector")
    cd.MaxActivationDistance = 45
    cd.Parent = yTorso

    createHealthTag(yTorso, "Yeti de Hielo", "Nv. 30", 682, 682, false)
    yeti.Parent = room3
end

room3.Parent = dungeon
createFrostRuneGate("Gate_Room3_To_Room4", Vector3.new(baseX, baseY + 2, baseZ + 190), "Vence a los Yetis de Hielo")

-- ========================================================
-- SALA 4: Arena Cilíndrica de la Reina de Escarcha - MiniBoss (Z = 1035)
-- ========================================================
local room4 = Instance.new("Model")
room4.Name = "Room4_Queen_Arena"

-- Arena Circular de Hielo Comprimido (Cilindro horizontal: Thickness = 4, Diameter = 58)
local arenaBase = Instance.new("Part")
arenaBase.Name = "Arena_Disc_Base"
arenaBase.Shape = Enum.PartType.Cylinder
arenaBase.Size = Vector3.new(4, 58, 58)
arenaBase.CFrame = CFrame.new(baseX, baseY, baseZ + 235) * CFrame.Angles(0, 0, math.rad(90))
arenaBase.Color = Color3.fromRGB(170, 215, 245)
arenaBase.Material = Enum.Material.Ice
arenaBase.Anchored = true
arenaBase.Parent = room4

-- Borde Rúnico Celeste
local arenaBorder = Instance.new("Part")
arenaBorder.Name = "Arena_Rune_Border"
arenaBorder.Shape = Enum.PartType.Cylinder
arenaBorder.Size = Vector3.new(3.8, 64, 64)
arenaBorder.CFrame = CFrame.new(baseX, baseY - 0.2, baseZ + 235) * CFrame.Angles(0, 0, math.rad(90))
arenaBorder.Color = Color3.fromRGB(80, 215, 255)
arenaBorder.Material = Enum.Material.Neon
arenaBorder.Anchored = true
arenaBorder.Parent = room4

-- 4 Pilares Centinela de Cristal
local pillarPositions = {
    Vector3.new(baseX - 24, baseY + 12, baseZ + 215),
    Vector3.new(baseX + 24, baseY + 12, baseZ + 215),
    Vector3.new(baseX - 24, baseY + 12, baseZ + 255),
    Vector3.new(baseX + 24, baseY + 12, baseZ + 255),
}
for _, pp in ipairs(pillarPositions) do
    local pillar = createPart(room4, "Frost_Pillar", Vector3.new(4.5, 26, 4.5), CFrame.new(pp), Color3.fromRGB(150, 210, 250), Enum.Material.Ice)
    local pl = Instance.new("PointLight")
    pl.Color = Color3.fromRGB(100, 220, 255)
    pl.Range = 22
    pl.Brightness = 2.5
    pl.Parent = pillar
end

-- Reina de Escarcha (MiniBoss de 11 studs de altura)
local qPos = Vector3.new(baseX, baseY + 6, baseZ + 235)
local queen = Instance.new("Model")
queen.Name = "Reina_De_Escarcha_MiniBoss"

local qTorso = createPart(queen, "Torso", Vector3.new(4, 7, 3), CFrame.new(qPos.X, qPos.Y + 3.5, qPos.Z), Color3.fromRGB(180, 230, 255), Enum.Material.Glass, true, 0.2)
queen.PrimaryPart = qTorso

-- Vestidura de Escarcha Pura
createPart(queen, "Robe_Skirt", Vector3.new(5.5, 4, 4.5), CFrame.new(qPos.X, qPos.Y + 1.5, qPos.Z), Color3.fromRGB(150, 220, 255), Enum.Material.Ice, false, 0.25)

-- Corona de Hielo Afilado
createPart(queen, "Head", Vector3.new(2.4, 2.4, 2.4), CFrame.new(qPos.X, qPos.Y + 8.2, qPos.Z), Color3.fromRGB(220, 245, 255), Enum.Material.SmoothPlastic)
createPart(queen, "Crown", Vector3.new(3.2, 1.8, 3.2), CFrame.new(qPos.X, qPos.Y + 9.6, qPos.Z), Color3.fromRGB(100, 230, 255), Enum.Material.Neon)

-- Báculo Glacial con Orbe Flotante
local staff = createPart(queen, "Frost_Staff", Vector3.new(0.6, 11, 0.6), CFrame.new(qPos.X + 3.8, qPos.Y + 4.5, qPos.Z), Color3.fromRGB(160, 190, 220), Enum.Material.Metal)
local orb = createPart(queen, "Staff_Sapphire_Orb", Vector3.new(2, 2, 2), CFrame.new(qPos.X + 3.8, qPos.Y + 10.5, qPos.Z), Color3.fromRGB(70, 225, 255), Enum.Material.Neon)
local orbLight = Instance.new("PointLight")
orbLight.Color = Color3.fromRGB(80, 220, 255)
orbLight.Brightness = 3.0
orbLight.Range = 20
orbLight.Parent = orb

local cdQueen = Instance.new("ClickDetector")
cdQueen.MaxActivationDistance = 55
cdQueen.Parent = qTorso

createHealthTag(qTorso, "REINA DE ESCARCHA [MINI-JEFE]", "Nv. 32", 2080, 2080, true)
queen.Parent = room4

room4.Parent = dungeon
createFrostRuneGate("Gate_Room4_To_Room5", Vector3.new(baseX, baseY + 2, baseZ + 270), "Derrota a la Reina de Escarcha")

-- ========================================================
-- SALA 5: Gran Templo del Titán Glacial - Jefe Final (Z = 1135)
-- ========================================================
local room5 = Instance.new("Model")
room5.Name = "Room5_Titan_Temple"

-- Coliseo Glacial de 90 studs de diámetro
local coliseumFloor = Instance.new("Part")
coliseumFloor.Name = "Coliseum_Floor_Disc"
coliseumFloor.Shape = Enum.PartType.Cylinder
coliseumFloor.Size = Vector3.new(4, 90, 90)
coliseumFloor.CFrame = CFrame.new(baseX, baseY, baseZ + 335) * CFrame.Angles(0, 0, math.rad(90))
coliseumFloor.Color = Color3.fromRGB(175, 220, 250)
coliseumFloor.Material = Enum.Material.Ice
coliseumFloor.Anchored = true
coliseumFloor.Parent = room5

-- Foso Glacial Exterior (Diámetro 98 studs)
local outerPit = Instance.new("Part")
outerPit.Name = "Outer_Glacial_Pit"
outerPit.Shape = Enum.PartType.Cylinder
outerPit.Size = Vector3.new(3.8, 98, 98)
outerPit.CFrame = CFrame.new(baseX, baseY - 0.2, baseZ + 335) * CFrame.Angles(0, 0, math.rad(90))
outerPit.Color = Color3.fromRGB(60, 200, 255)
outerPit.Material = Enum.Material.Neon
outerPit.Anchored = true
outerPit.Parent = room5

-- Anillos de Ataque AoE (Fases 1, 2 y 3)
local aoeRing1 = Instance.new("Part")
aoeRing1.Name = "AoE_Telegraph_Phase1"
aoeRing1.Shape = Enum.PartType.Cylinder
aoeRing1.Size = Vector3.new(0.4, 76, 76)
aoeRing1.CFrame = CFrame.new(baseX, baseY + 2.1, baseZ + 335) * CFrame.Angles(0, 0, math.rad(90))
aoeRing1.Color = Color3.fromRGB(90, 225, 255)
aoeRing1.Material = Enum.Material.Neon
aoeRing1.Transparency = 0.65
aoeRing1.Anchored = true
aoeRing1.CanCollide = false
aoeRing1.Parent = room5

local aoeRing2 = Instance.new("Part")
aoeRing2.Name = "AoE_Telegraph_Phase2"
aoeRing2.Shape = Enum.PartType.Cylinder
aoeRing2.Size = Vector3.new(0.5, 48, 48)
aoeRing2.CFrame = CFrame.new(baseX, baseY + 2.15, baseZ + 335) * CFrame.Angles(0, 0, math.rad(90))
aoeRing2.Color = Color3.fromRGB(40, 180, 255)
aoeRing2.Material = Enum.Material.Neon
aoeRing2.Transparency = 0.55
aoeRing2.Anchored = true
aoeRing2.CanCollide = false
aoeRing2.Parent = room5

-- Estrado del Trono del Titán
createPart(room5, "Titan_Dais", Vector3.new(28, 3, 20), CFrame.new(baseX, baseY + 2.5, baseZ + 365), Color3.fromRGB(140, 185, 225), Enum.Material.Slate)

-- ========================================================
-- TITÁN GLACIAL (Jefe Final Colosal de 20 studs de altura)
-- ========================================================
local tPos = Vector3.new(baseX, baseY + 8, baseZ + 335)
local titan = Instance.new("Model")
titan.Name = "Titan_Glacial_FinalBoss"

-- Torso Colosal de 14x12x8 studs
local tTorso = createPart(titan, "Torso", Vector3.new(14, 12, 8), CFrame.new(tPos.X, tPos.Y + 8, tPos.Z), Color3.fromRGB(160, 215, 250), Enum.Material.Ice, true, 0.15)
titan.PrimaryPart = tTorso

-- Corazón de Zafiro Eterno
local tHeart = createPart(titan, "Eternal_Sapphire_Heart", Vector3.new(8, 8, 3), CFrame.new(tPos.X, tPos.Y + 8, tPos.Z + 4.2), Color3.fromRGB(60, 220, 255), Enum.Material.Neon)
local tLight = Instance.new("PointLight")
tLight.Color = Color3.fromRGB(80, 225, 255)
tLight.Brightness = 4.5
tLight.Range = 40
tLight.Parent = tHeart

-- Hombreras de Estalagmitas Afiladas
createPart(titan, "Shoulder_L", Vector3.new(6, 6, 6), CFrame.new(tPos.X - 10, tPos.Y + 13, tPos.Z), Color3.fromRGB(140, 200, 245), Enum.Material.Ice)
createPart(titan, "Shoulder_R", Vector3.new(6, 6, 6), CFrame.new(tPos.X + 10, tPos.Y + 13, tPos.Z), Color3.fromRGB(140, 200, 245), Enum.Material.Ice)

-- Brazos y Puños de Avalancha
createPart(titan, "Arm_L", Vector3.new(5, 11, 5), CFrame.new(tPos.X - 10, tPos.Y + 5, tPos.Z), Color3.fromRGB(150, 210, 245), Enum.Material.Ice)
createPart(titan, "Arm_R", Vector3.new(5, 11, 5), CFrame.new(tPos.X + 10, tPos.Y + 5, tPos.Z), Color3.fromRGB(150, 210, 245), Enum.Material.Ice)
createPart(titan, "Avalanche_Fist_L", Vector3.new(6.5, 6.5, 6.5), CFrame.new(tPos.X - 10, tPos.Y - 2, tPos.Z), Color3.fromRGB(90, 225, 255), Enum.Material.Neon)
createPart(titan, "Avalanche_Fist_R", Vector3.new(6.5, 6.5, 6.5), CFrame.new(tPos.X + 10, tPos.Y - 2, tPos.Z), Color3.fromRGB(90, 225, 255), Enum.Material.Neon)

-- Cabeza y Cuernos Glaciales
createPart(titan, "Head", Vector3.new(6, 5, 5), CFrame.new(tPos.X, tPos.Y + 16, tPos.Z + 1), Color3.fromRGB(170, 225, 255), Enum.Material.Ice)
createPart(titan, "Horn_L", Vector3.new(1.8, 6.5, 1.8), CFrame.new(tPos.X - 3.8, tPos.Y + 19.5, tPos.Z + 0.5) * CFrame.Angles(0, 0, math.rad(28)), Color3.fromRGB(80, 230, 255), Enum.Material.Neon)
createPart(titan, "Horn_R", Vector3.new(1.8, 6.5, 1.8), CFrame.new(tPos.X + 3.8, tPos.Y + 19.5, tPos.Z + 0.5) * CFrame.Angles(0, 0, math.rad(-28)), Color3.fromRGB(80, 230, 255), Enum.Material.Neon)
createPart(titan, "Eyes", Vector3.new(4, 1.2, 0.8), CFrame.new(tPos.X, tPos.Y + 16, tPos.Z + 3.6), Color3.fromRGB(240, 255, 255), Enum.Material.Neon)

local cdTitan = Instance.new("ClickDetector")
cdTitan.MaxActivationDistance = 70
cdTitan.Parent = tTorso

createHealthTag(tTorso, "👑 TITÁN GLACIAL [JEFE FINAL]", "Nv. 35", 5850, 5850, true)
titan.Parent = room5

-- ========================================================
-- COFRE DELUXE DE ZAFIRO GLACIAL
-- ========================================================
local chest = Instance.new("Model")
chest.Name = "Cofre_Zafiro_Glacial"
local cBox = createPart(chest, "Chest_Base", Vector3.new(6, 4, 4), CFrame.new(baseX + 10, baseY + 4, baseZ + 360), Color3.fromRGB(150, 215, 250), Enum.Material.Ice)
chest.PrimaryPart = cBox
createPart(chest, "Chest_Silver_Trim", Vector3.new(6.4, 1.2, 4.4), CFrame.new(baseX + 10, baseY + 5.5, baseZ + 360), Color3.fromRGB(210, 230, 245), Enum.Material.Metal)
local sapphireLock = createPart(chest, "Chest_Sapphire_Core", Vector3.new(1.4, 1.4, 1.4), CFrame.new(baseX + 10, baseY + 4.5, baseZ + 358), Color3.fromRGB(60, 220, 255), Enum.Material.Neon)

local cPrompt = Instance.new("ProximityPrompt")
cPrompt.ActionText = "Reclamar Botín Glacial"
cPrompt.ObjectText = "Cofre de Zafiro"
cPrompt.HoldDuration = 1.0
cPrompt.MaxActivationDistance = 14
cPrompt.Parent = sapphireLock
chest.Parent = room5

-- ========================================================
-- PORTAL DE RETORNO AL LOBBY
-- ========================================================
local returnPortal = Instance.new("Model")
returnPortal.Name = "Exit_Portal_To_Lobby"
createPart(returnPortal, "Arch_L", Vector3.new(3, 16, 3), CFrame.new(baseX - 10, baseY + 9, baseZ + 360), Color3.fromRGB(160, 205, 240), Enum.Material.Ice)
createPart(returnPortal, "Arch_R", Vector3.new(3, 16, 3), CFrame.new(baseX - 16, baseY + 9, baseZ + 360), Color3.fromRGB(160, 205, 240), Enum.Material.Ice)
createPart(returnPortal, "Arch_Top", Vector3.new(9, 3, 3), CFrame.new(baseX - 13, baseY + 17, baseZ + 360), Color3.fromRGB(180, 225, 250), Enum.Material.Ice)

local vortex = createPart(returnPortal, "Vortex", Vector3.new(6, 12, 0.6), CFrame.new(baseX - 13, baseY + 9, baseZ + 360), Color3.fromRGB(90, 230, 255), Enum.Material.Neon)
local pPrompt = Instance.new("ProximityPrompt")
pPrompt.ActionText = "Volver al Lobby"
pPrompt.ObjectText = "Portal de Retorno"
pPrompt.HoldDuration = 0.5
pPrompt.MaxActivationDistance = 14
pPrompt.Parent = vortex
returnPortal.Parent = room5

room5.Parent = dungeon
dungeon.Parent = Workspace

print("✓ Dungeon_Reino_Hielo construido con éxito en (0, 50, 800) con 5 salas, 4 puertas, enemigos 3D, cofre y portal de retorno!")
return "Dungeon_Reino_Hielo construido con éxito!"
