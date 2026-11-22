--!strict
-- upgrade_dungeon_with_epic_assets_and_gates.luau
-- Construye las 4 Puertas Rúnicas físicas entre salas, actualiza los modelos épicos de enemigos
-- e implementa el controlador de puertas automáticas que desbloquea cada sección al vencer la oleada.

local TweenService = game:GetService("TweenService")
local dungeon = workspace:FindFirstChild("Dungeon_Bosque_Susurros")
if not dungeon then
    return "ERROR: Dungeon_Bosque_Susurros not found"
end

local gatesFolder = dungeon:FindFirstChild("Dungeon_Gates")
if gatesFolder then
    gatesFolder:Destroy()
end
gatesFolder = Instance.new("Folder")
gatesFolder.Name = "Dungeon_Gates"
gatesFolder.Parent = dungeon

local function createMaterial(name, col, mat)
    local p = Instance.new("Part")
    p.Name = name
    p.Color = col
    p.Material = mat
    p.Anchored = true
    return p
end

-- Función para construir una Puerta Rúnica interactiva
local function buildRunicGate(gateName: string, centerPos: Vector3, roomRequirement: number)
    local gateModel = Instance.new("Model")
    gateModel.Name = gateName
    gateModel:SetAttribute("RoomRequirement", roomRequirement)
    gateModel:SetAttribute("IsOpen", false)

    local cx, cy, cz = centerPos.X, centerPos.Y, centerPos.Z

    -- Pilares de piedra laterales
    for _, sign in ipairs({-1, 1}) do
        local pilar = Instance.new("Part")
        pilar.Name = "Arch_Pillar_" .. (sign == -1 and "Left" or "Right")
        pilar.Size = Vector3.new(2.4, 14, 2.8)
        pilar.CFrame = CFrame.new(cx + sign * 8.5, cy + 7, cz)
        pilar.Color = Color3.fromRGB(60, 65, 75)
        pilar.Material = Enum.Material.Slate
        pilar.Anchored = true
        pilar.Parent = gateModel

        -- Runa brillante en el pilar
        local rune = Instance.new("Part")
        rune.Name = "Rune_Glow"
        rune.Size = Vector3.new(0.5, 8, 0.2)
        rune.CFrame = CFrame.new(cx + sign * 8.5, cy + 7, cz - 1.45)
        rune.Color = Color3.fromRGB(0, 220, 255)
        rune.Material = Enum.Material.Neon
        rune.Anchored = true
        rune.Parent = gateModel
    end

    -- Dintel / Arco superior
    local dintel = Instance.new("Part")
    dintel.Name = "Arch_Header"
    dintel.Size = Vector3.new(19.4, 3.2, 3.2)
    dintel.CFrame = CFrame.new(cx, cy + 15.6, cz)
    dintel.Color = Color3.fromRGB(50, 55, 65)
    dintel.Material = Enum.Material.Slate
    dintel.Anchored = true
    dintel.Parent = gateModel

    -- Medallón rúnico central
    local medallion = Instance.new("Part")
    medallion.Name = "Medallion_Lock"
    medallion.Shape = Enum.PartType.Cylinder
    medallion.Size = Vector3.new(0.6, 2.8, 2.8)
    medallion.CFrame = CFrame.new(cx, cy + 15.6, cz - 1.7) * CFrame.Angles(0, 0, math.rad(90))
    medallion.Color = Color3.fromRGB(220, 180, 50)
    medallion.Material = Enum.Material.Metal
    medallion.Anchored = true
    medallion.Parent = gateModel

    local gem = Instance.new("Part")
    gem.Name = "Lock_Gem"
    gem.Shape = Enum.PartType.Ball
    gem.Size = Vector3.new(1.4, 1.4, 1.4)
    gem.CFrame = CFrame.new(cx, cy + 15.6, cz - 2.1)
    gem.Color = Color3.fromRGB(255, 50, 50) -- Rojo cuando está bloqueada
    gem.Material = Enum.Material.Neon
    gem.Anchored = true
    gem.Parent = gateModel

    -- Barrera de energía que bloquea el paso físico
    local barrier = Instance.new("Part")
    barrier.Name = "Runic_Barrier"
    barrier.Size = Vector3.new(14.6, 14, 0.4)
    barrier.CFrame = CFrame.new(cx, cy + 7, cz)
    barrier.Color = Color3.fromRGB(255, 60, 40) -- Rojo = bloqueada
    barrier.Material = Enum.Material.ForceField
    barrier.Transparency = 0.35
    barrier.CanCollide = true
    barrier.Anchored = true
    barrier.Parent = gateModel

    -- Letrero Rúnico flotante
    local bb = Instance.new("BillboardGui")
    bb.Name = "GateSign"
    bb.Size = UDim2.new(0, 220, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = medallion
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.Text = "🔒 PUERTA BLOQUEADA (Derrota la Sala " .. roomRequirement .. ")"
    tl.TextColor3 = Color3.fromRGB(255, 100, 100)
    tl.TextScaled = true
    tl.Font = Enum.Font.GothamBold
    tl.Parent = bb
    bb.Parent = gateModel

    -- Batientes de madera reforzados con hierro
    -- Hoja Izquierda
    local doorL = Instance.new("Part")
    doorL.Name = "Door_Left"
    doorL.Size = Vector3.new(7.3, 13.8, 0.8)
    doorL.CFrame = CFrame.new(cx - 3.65, cy + 6.9, cz)
    doorL.Color = Color3.fromRGB(80, 50, 30)
    doorL.Material = Enum.Material.WoodPlanks
    doorL.CanCollide = true
    doorL.Anchored = true
    doorL.Parent = gateModel

    -- Hoja Derecha
    local doorR = Instance.new("Part")
    doorR.Name = "Door_Right"
    doorR.Size = Vector3.new(7.3, 13.8, 0.8)
    doorR.CFrame = CFrame.new(cx + 3.65, cy + 6.9, cz)
    doorR.Color = Color3.fromRGB(80, 50, 30)
    doorR.Material = Enum.Material.WoodPlanks
    doorR.CanCollide = true
    doorR.Anchored = true
    doorR.Parent = gateModel

    -- Script de Apertura dentro de cada puerta
    local gateScript = Instance.new("Script")
    gateScript.Name = "GateController"
    gateScript.Source = [[
local gate = script.Parent
local doorL = gate:WaitForChild("Door_Left")
local doorR = gate:WaitForChild("Door_Right")
local barrier = gate:WaitForChild("Runic_Barrier")
local gem = gate:WaitForChild("Lock_Gem")
local sign = gate:FindFirstChild("GateSign", true)
local TweenService = game:GetService("TweenService")

local function openGate()
    if gate:GetAttribute("IsOpen") then return end
    gate:SetAttribute("IsOpen", true)

    -- Cambio de color de gema y barrera a verde victoria
    gem.Color = Color3.fromRGB(50, 255, 120)
    barrier.Color = Color3.fromRGB(50, 255, 180)
    barrier.CanCollide = false

    if sign and sign:FindFirstChildOfClass("TextLabel") then
        local lbl = sign:FindFirstChildOfClass("TextLabel")
        lbl.Text = "✨ ¡DESBLOQUEADA! PASA A LA SIGUIENTE SALA"
        lbl.TextColor3 = Color3.fromRGB(100, 255, 150)
    end

    -- Animación suave de apertura de puertas
    local cL = doorL.CFrame
    local cR = doorR.CFrame
    local hingeL = CFrame.new(cL.Position.X - 3.65, cL.Position.Y, cL.Position.Z)
    local hingeR = CFrame.new(cR.Position.X + 3.65, cR.Position.Y, cR.Position.Z)

    local targetL = hingeL * CFrame.Angles(0, math.rad(-85), 0) * CFrame.new(3.65, 0, 0)
    local targetR = hingeR * CFrame.Angles(0, math.rad(85), 0) * CFrame.new(-3.65, 0, 0)

    local tweenInfo = TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(doorL, tweenInfo, {CFrame = targetL, Transparency = 0.3}):Play()
    TweenService:Create(doorR, tweenInfo, {CFrame = targetR, Transparency = 0.3}):Play()
    TweenService:Create(barrier, tweenInfo, {Transparency = 0.95}):Play()
    doorL.CanCollide = false
    doorR.CanCollide = false
end

gate:GetAttributeChangedSignal("IsOpen"):Connect(function()
    if gate:GetAttribute("IsOpen") == true then
        openGate()
    end
end)

-- Permite prueba interactiva manual por ProximityPrompt si se desea probar
local prompt = Instance.new("ProximityPrompt")
prompt.ObjectText = "Puerta Rúnica"
prompt.ActionText = "Abrir (Desbloqueo de Mazmorra)"
prompt.HoldDuration = 0.5
prompt.RequiresLineOfSight = false
prompt.MaxActivationDistance = 15
prompt.Parent = gem
prompt.Triggered:Connect(function()
    openGate()
end)
]]
    gateScript.Parent = gateModel
    gateModel.Parent = gatesFolder
    return gateModel
end

-- 1. Construir las 4 Puertas en los corredores entre salas
buildRunicGate("Gate_Room1_To_Room2", Vector3.new(800, 50, 37.5), 1)
buildRunicGate("Gate_Room2_To_Room3", Vector3.new(800, 50, 117.5), 2)
buildRunicGate("Gate_Room3_To_Room4", Vector3.new(800, 50, 207.5), 3)
buildRunicGate("Gate_Room4_To_Room5", Vector3.new(800, 50, 310.0), 4)

-- 2. Actualizar los Modelos 3D de Enemigos en las Salas (NO MÁS PALOS)
-- Sala 1: Slimes Verdes Orgánicos
local r1 = dungeon:FindFirstChild("Room1_Ruins_Entrance")
if r1 then
    for i, c in ipairs(r1:GetChildren()) do
        if c.Name:find("Slime") then
            c:Destroy()
        end
    end
    -- Crear 4 Slimes con la nueva anatomía épica
    local slimePos = {
        Vector3.new(788, 51.5, -8),
        Vector3.new(812, 51.5, -8),
        Vector3.new(792, 51.5, 12),
        Vector3.new(808, 51.5, 12)
    }
    for idx, pos in ipairs(slimePos) do
        local slimeModel = Instance.new("Model")
        slimeModel.Name = "Slime_Verde_Epico_" .. idx

        -- Cuerpo orgánico
        local body = Instance.new("Part")
        body.Name = "Body"
        body.Shape = Enum.PartType.Ball
        body.Size = Vector3.new(4.2, 3.2, 4.2)
        body.CFrame = CFrame.new(pos.X, pos.Y + 1.2, pos.Z)
        body.Color = Color3.fromRGB(30, 210, 70)
        body.Material = Enum.Material.Glass
        body.Transparency = 0.25
        body.Anchored = true
        body.Parent = slimeModel

        -- Núcleo de maná flotante
        local core = Instance.new("Part")
        core.Name = "Mana_Core"
        core.Shape = Enum.PartType.Ball
        core.Size = Vector3.new(1.6, 1.6, 1.6)
        core.CFrame = CFrame.new(pos.X, pos.Y + 1.2, pos.Z)
        core.Color = Color3.fromRGB(80, 255, 130)
        core.Material = Enum.Material.Neon
        core.Anchored = true
        core.Parent = slimeModel

        -- Ojos
        for _, sign in ipairs({-1, 1}) do
            local eye = Instance.new("Part")
            eye.Name = "Eye"
            eye.Shape = Enum.PartType.Ball
            eye.Size = Vector3.new(0.6, 0.8, 0.6)
            eye.CFrame = CFrame.new(pos.X + sign * 0.9, pos.Y + 1.5, pos.Z - 1.8)
            eye.Color = Color3.fromRGB(20, 20, 25)
            eye.Material = Enum.Material.SmoothPlastic
            eye.Anchored = true
            eye.Parent = slimeModel
        end

        slimeModel.PrimaryPart = body
        slimeModel.Parent = r1
    end
end

-- Sala 2: Duendes Mágicos con Capucha y Báculo
local r2 = dungeon:FindFirstChild("Room2_Forest_Canyon")
if r2 then
    for _, c in ipairs(r2:GetChildren()) do
        if c.Name:find("Goblin") or c.Name:find("Duende") then
            c:Destroy()
        end
    end
    local gobPos = {
        Vector3.new(792, 51.5, 65),
        Vector3.new(808, 51.5, 65),
        Vector3.new(790, 51.5, 85),
        Vector3.new(810, 51.5, 85)
    }
    for idx, pos in ipairs(gobPos) do
        local gob = Instance.new("Model")
        gob.Name = "Duende_Magico_Epico_" .. idx

        -- Túnica de mago
        local robe = Instance.new("Part")
        robe.Name = "Robe"
        robe.Size = Vector3.new(2.4, 3.8, 2.4)
        robe.CFrame = CFrame.new(pos.X, pos.Y + 1.9, pos.Z)
        robe.Color = Color3.fromRGB(90, 30, 110)
        robe.Material = Enum.Material.Fabric
        robe.Anchored = true
        robe.Parent = gob

        -- Cabeza de duende verde
        local head = Instance.new("Part")
        head.Name = "Head"
        head.Shape = Enum.PartType.Ball
        head.Size = Vector3.new(1.8, 1.8, 1.8)
        head.CFrame = CFrame.new(pos.X, pos.Y + 4.2, pos.Z)
        head.Color = Color3.fromRGB(90, 180, 70)
        head.Material = Enum.Material.SmoothPlastic
        head.Anchored = true
        head.Parent = gob

        -- Orejas puntiagudas
        for _, sign in ipairs({-1, 1}) do
            local ear = Instance.new("Part")
            ear.Name = "Ear"
            ear.Size = Vector3.new(1.4, 0.4, 0.6)
            ear.CFrame = CFrame.new(pos.X + sign * 1.5, pos.Y + 4.2, pos.Z) * CFrame.Angles(0, 0, math.rad(sign * 25))
            ear.Color = Color3.fromRGB(90, 180, 70)
            ear.Material = Enum.Material.SmoothPlastic
            ear.Anchored = true
            ear.Parent = gob
        end

        -- Capucha puntiaguda
        local hat = Instance.new("Part")
        hat.Name = "Hat"
        hat.Size = Vector3.new(2.2, 2.2, 2.2)
        hat.CFrame = CFrame.new(pos.X, pos.Y + 5.8, pos.Z)
        hat.Color = Color3.fromRGB(70, 20, 90)
        hat.Material = Enum.Material.Fabric
        hat.Anchored = true
        hat.Parent = gob

        -- Báculo con cristal brillante
        local staff = Instance.new("Part")
        staff.Name = "Staff"
        staff.Size = Vector3.new(0.3, 6.0, 0.3)
        staff.CFrame = CFrame.new(pos.X + 1.8, pos.Y + 3.0, pos.Z - 0.5)
        staff.Color = Color3.fromRGB(75, 45, 20)
        staff.Material = Enum.Material.Wood
        staff.Anchored = true
        staff.Parent = gob

        local crystal = Instance.new("Part")
        crystal.Name = "Staff_Crystal"
        crystal.Shape = Enum.PartType.Ball
        crystal.Size = Vector3.new(1.0, 1.0, 1.0)
        crystal.CFrame = CFrame.new(pos.X + 1.8, pos.Y + 6.2, pos.Z - 0.5)
        crystal.Color = Color3.fromRGB(0, 220, 255)
        crystal.Material = Enum.Material.Neon
        crystal.Anchored = true
        crystal.Parent = gob

        gob.PrimaryPart = robe
        gob.Parent = r2
    end
end

-- Sala 3: Lobos Mágicos con Melenas y Marcas de Runas
local r3 = dungeon:FindFirstChild("Room3_Corrupted_Glade")
if r3 then
    for _, c in ipairs(r3:GetChildren()) do
        if c.Name:find("Wolf") or c.Name:find("Lobo") then
            c:Destroy()
        end
    end
    local wolfPos = {
        Vector3.new(788, 51.5, 145),
        Vector3.new(812, 51.5, 145),
        Vector3.new(786, 51.5, 175),
        Vector3.new(814, 51.5, 175)
    }
    for idx, pos in ipairs(wolfPos) do
        local wolf = Instance.new("Model")
        wolf.Name = "Lobo_Magico_Epico_" .. idx

        -- Torso
        local body = Instance.new("Part")
        body.Name = "Body"
        body.Size = Vector3.new(2.4, 2.6, 5.5)
        body.CFrame = CFrame.new(pos.X, pos.Y + 2.5, pos.Z)
        body.Color = Color3.fromRGB(40, 50, 70)
        body.Material = Enum.Material.Slate
        body.Anchored = true
        body.Parent = wolf

        -- Melena espinosa
        local mane = Instance.new("Part")
        mane.Name = "Mane"
        mane.Shape = Enum.PartType.Ball
        mane.Size = Vector3.new(3.2, 3.4, 3.0)
        mane.CFrame = CFrame.new(pos.X, pos.Y + 3.2, pos.Z - 1.8)
        mane.Color = Color3.fromRGB(25, 30, 45)
        mane.Material = Enum.Material.Slate
        mane.Anchored = true
        mane.Parent = wolf

        -- Cabeza y hocico
        local snout = Instance.new("Part")
        snout.Name = "Snout"
        snout.Size = Vector3.new(1.2, 1.2, 2.2)
        snout.CFrame = CFrame.new(pos.X, pos.Y + 3.0, pos.Z - 3.6)
        snout.Color = Color3.fromRGB(35, 45, 65)
        snout.Material = Enum.Material.Slate
        snout.Anchored = true
        snout.Parent = wolf

        -- Ojos brillantes
        for _, sign in ipairs({-1, 1}) do
            local eye = Instance.new("Part")
            eye.Name = "Eye"
            eye.Size = Vector3.new(0.3, 0.3, 0.3)
            eye.CFrame = CFrame.new(pos.X + sign * 0.7, pos.Y + 3.5, pos.Z - 3.0)
            eye.Color = Color3.fromRGB(0, 220, 255)
            eye.Material = Enum.Material.Neon
            eye.Anchored = true
            eye.Parent = wolf
        end

        -- Runas en el lomo
        local rune = Instance.new("Part")
        rune.Name = "Back_Rune"
        rune.Size = Vector3.new(1.2, 0.2, 4.0)
        rune.CFrame = CFrame.new(pos.X, pos.Y + 3.9, pos.Z)
        rune.Color = Color3.fromRGB(0, 200, 255)
        rune.Material = Enum.Material.Neon
        rune.Anchored = true
        rune.Parent = wolf

        wolf.PrimaryPart = body
        wolf.Parent = r3
    end
end

-- Sala 4: Guardián de Raíces Mini-Jefe (Gólem Colosal)
local r4 = dungeon:FindFirstChild("Room4_Roots_Chamber_MiniBoss")
if r4 then
    local oldGuardian = r4:FindFirstChild("Guardian_De_Raices")
    if oldGuardian then oldGuardian:Destroy() end

    local gPos = Vector3.new(800, 50, 255)
    local guardian = Instance.new("Model")
    guardian.Name = "Guardian_De_Raices_Epico"

    -- Torso
    local torso = Instance.new("Part")
    torso.Name = "Torso"
    torso.Size = Vector3.new(6.0, 7.5, 4.5)
    torso.CFrame = CFrame.new(gPos.X, gPos.Y + 7.0, gPos.Z)
    torso.Color = Color3.fromRGB(65, 40, 22)
    torso.Material = Enum.Material.Wood
    torso.Anchored = true
    torso.Parent = guardian

    -- Placa pectoral de roca
    local plate = Instance.new("Part")
    plate.Name = "Chest_Plate"
    plate.Size = Vector3.new(5.0, 5.0, 1.2)
    plate.CFrame = CFrame.new(gPos.X, gPos.Y + 7.5, gPos.Z - 2.4)
    plate.Color = Color3.fromRGB(90, 95, 105)
    plate.Material = Enum.Material.Rock
    plate.Anchored = true
    plate.Parent = guardian

    -- Núcleo de maná esmeralda
    local core = Instance.new("Part")
    core.Name = "Core"
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(2.2, 2.2, 2.2)
    core.CFrame = CFrame.new(gPos.X, gPos.Y + 7.5, gPos.Z - 2.9)
    core.Color = Color3.fromRGB(50, 255, 120)
    core.Material = Enum.Material.Neon
    core.Anchored = true
    core.Parent = guardian

    -- Hombreras colosales
    for _, sign in ipairs({-1, 1}) do
        local pauldron = Instance.new("Part")
        pauldron.Name = "Pauldron"
        pauldron.Shape = Enum.PartType.Ball
        pauldron.Size = Vector3.new(4.5, 4.0, 4.5)
        pauldron.CFrame = CFrame.new(gPos.X + sign * 5.2, gPos.Y + 10.0, gPos.Z)
        pauldron.Color = Color3.fromRGB(100, 105, 115)
        pauldron.Material = Enum.Material.Rock
        pauldron.Anchored = true
        pauldron.Parent = guardian

        -- Brazos y puños de roca
        local fist = Instance.new("Part")
        fist.Name = "Fist"
        fist.Size = Vector3.new(3.0, 4.0, 3.0)
        fist.CFrame = CFrame.new(gPos.X + sign * 5.2, gPos.Y + 3.0, gPos.Z - 1.0)
        fist.Color = Color3.fromRGB(90, 95, 105)
        fist.Material = Enum.Material.Rock
        fist.Anchored = true
        fist.Parent = guardian
    end

    -- Cabeza monolítica
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(3.2, 3.0, 2.8)
    head.CFrame = CFrame.new(gPos.X, gPos.Y + 11.5, gPos.Z - 0.5)
    head.Color = Color3.fromRGB(90, 95, 105)
    head.Material = Enum.Material.Rock
    head.Anchored = true
    head.Parent = guardian

    -- Visor rúnico
    local visor = Instance.new("Part")
    visor.Name = "Visor"
    visor.Size = Vector3.new(2.2, 0.5, 0.4)
    visor.CFrame = CFrame.new(gPos.X, gPos.Y + 11.6, gPos.Z - 2.0)
    visor.Color = Color3.fromRGB(50, 255, 120)
    visor.Material = Enum.Material.Neon
    visor.Anchored = true
    visor.Parent = guardian

    guardian.PrimaryPart = torso
    guardian.Parent = r4
end

-- Sala 5: Cofre Deluxe Mejorado
local r5 = dungeon:FindFirstChild("Room5_Treant_Boss_Lair")
if r5 then
    local oldChest = r5:FindFirstChild("Cofre_Ancestral")
    if oldChest then oldChest:Destroy() end

    local chestModel = Instance.new("Model")
    chestModel.Name = "Cofre_Ancestral_Deluxe"

    local cPos = Vector3.new(800, 50, 400)

    -- Caja base
    local box = Instance.new("Part")
    box.Name = "Chest_Box"
    box.Size = Vector3.new(7.0, 4.2, 4.5)
    box.CFrame = CFrame.new(cPos.X, cPos.Y + 2.1, cPos.Z)
    box.Color = Color3.fromRGB(85, 45, 20)
    box.Material = Enum.Material.WoodPlanks
    box.Anchored = true
    box.Parent = chestModel

    -- Bandas doradas
    local trim = Instance.new("Part")
    trim.Name = "Chest_Gold_Trim"
    trim.Size = Vector3.new(7.2, 4.4, 0.8)
    trim.CFrame = CFrame.new(cPos.X, cPos.Y + 2.1, cPos.Z)
    trim.Color = Color3.fromRGB(240, 190, 40)
    trim.Material = Enum.Material.Metal
    trim.Anchored = true
    trim.Parent = chestModel

    -- Tapa abombada
    local lid = Instance.new("Part")
    lid.Name = "Chest_Lid"
    lid.Shape = Enum.PartType.Cylinder
    lid.Size = Vector3.new(2.5, 4.6, 4.6)
    lid.CFrame = CFrame.new(cPos.X, cPos.Y + 4.5, cPos.Z) * CFrame.Angles(0, 0, math.rad(90))
    lid.Color = Color3.fromRGB(95, 50, 25)
    lid.Material = Enum.Material.WoodPlanks
    lid.Anchored = true
    lid.Parent = chestModel

    -- Gema de cerradura
    local ruby = Instance.new("Part")
    ruby.Name = "Ruby_Lock"
    ruby.Shape = Enum.PartType.Ball
    ruby.Size = Vector3.new(1.0, 1.0, 1.0)
    ruby.CFrame = CFrame.new(cPos.X, cPos.Y + 3.5, cPos.Z - 2.4)
    ruby.Color = Color3.fromRGB(255, 40, 60)
    ruby.Material = Enum.Material.Neon
    ruby.Anchored = true
    ruby.Parent = chestModel

    -- ProximityPrompt para reclamar botín
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Reclamar Botín Ancestral"
    prompt.ObjectText = "Cofre Deluxe de la Mazmorra"
    prompt.HoldDuration = 1.0
    prompt.MaxActivationDistance = 14
    prompt.Parent = ruby

    chestModel.PrimaryPart = box
    chestModel.Parent = r5
end

return "DUNGEON_UPGRADE_SUCCESS"
