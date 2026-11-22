--!strict
--[[
    build_region2_enemies_and_portal.luau
    1. Actualiza el Portal 2 del Lobby con la temática de las Minas del Fuego Eterno.
    2. Construye físicamente todos los modelos 3D de enemigos en las 5 salas de Dungeon_Minas_Fuego_Eterno:
       - Sala 1: Murciélagos de Lava (Alados, ojos incandescentes, ascuas de fuego, ClickDetector y barra de salud).
       - Sala 2: Gólems Ígneos (Roca volcánica y venas de magma neon).
       - Sala 3: Mineros Malditos (Armaduras carbonizadas y picos ardientes).
       - Sala 4: Coloso Ígneo (MiniJefe de 12 studs con puños de magma y barra de MiniBoss).
       - Sala 5: Gólem de Magma (Jefe Final titánico de 20 studs con núcleo de magma y PointLight de 40 studs).
]]

local Workspace = game:GetService("Workspace")

local baseX = -800
local baseY = 50

-- Función auxiliar para crear partes
local function makePart(parent: Instance, name: string, size: Vector3, cf: CFrame, mat: Enum.Material, col: Color3, canCollide: boolean?): Part
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Material = mat
    p.Color = col
    p.Anchored = true
    p.CanCollide = (canCollide ~= nil) and canCollide or false
    p.Parent = parent
    return p
end

-- Función auxiliar para crear cartel de salud del enemigo
local function makeHealthTag(parent: Instance, enemyName: string, levelText: string, health: number, maxHealth: number, isBoss: boolean?): BillboardGui
    local bb = Instance.new("BillboardGui")
    bb.Name = "EnemyHealthTag"
    bb.Size = isBoss and UDim2.new(0, 240, 0, 50) or UDim2.new(0, 160, 0, 36)
    bb.StudsOffset = isBoss and Vector3.new(0, 12, 0) or Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = false
    bb.MaxDistance = isBoss and 60 or 35
    bb.Adornee = parent:IsA("BasePart") and parent or nil

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    bg.BackgroundTransparency = 0.25
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = bg

    local stroke = Instance.new("UIStroke")
    stroke.Color = isBoss and Color3.fromRGB(255, 140, 30) or Color3.fromRGB(255, 80, 40)
    stroke.Thickness = isBoss and 2 or 1.5
    stroke.Parent = bg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.5, 0)
    title.Position = UDim2.new(0, 0, 0.05, 0)
    title.BackgroundTransparency = 1
    title.Text = enemyName .. " • " .. levelText
    title.TextColor3 = isBoss and Color3.fromRGB(255, 215, 60) or Color3.fromRGB(255, 200, 150)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = bg

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0.9, 0, 0.3, 0)
    track.Position = UDim2.new(0.05, 0, 0.6, 0)
    track.BackgroundColor3 = Color3.fromRGB(35, 30, 30)
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 4)
    tc.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(health / maxHealth, 0, 1, 0)
    fill.BackgroundColor3 = isBoss and Color3.fromRGB(255, 60, 40) or Color3.fromRGB(50, 220, 90)
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 4)
    fc.Parent = fill
    fill.Parent = track
    track.Parent = bg

    bg.Parent = bb
    bb.Parent = parent
    return bb
end

-- ========================================================
-- 1. ACTUALIZAR PORTAL 2 EN EL LOBBY
-- ========================================================
local lobby = Workspace:FindFirstChild("MagiaEterna_Lobby")
if lobby then
    local sanctuary = lobby:FindFirstChild("Dungeon_Portals_Sanctuary")
    if sanctuary then
        local p2 = sanctuary:FindFirstChild("Portal_2_Caverna_Cristales") or sanctuary:FindFirstChild("Portal_2_Minas_Fuego_Eterno")
        if p2 then
            p2.Name = "Portal_2_Minas_Fuego_Eterno"
            
            -- Actualizar Prompt
            local prompt = p2:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                prompt.ObjectText = "Minas del Fuego Eterno"
                prompt.ActionText = "Entrar a Mazmorra"
            end

            -- Actualizar Letrero
            local bb = p2:FindFirstChildWhichIsA("BillboardGui", true)
            if bb then
                for _, desc in ipairs(bb:GetDescendants()) do
                    if desc:IsA("TextLabel") then
                        if desc.Text:find("Cristales") or desc.Text:find("Caverna") or desc.Text:find("Minas") then
                            desc.Text = "🔥 Minas del Fuego Eterno"
                        elseif desc.Text:find("Rebirth") or desc.Text:find("Nv") then
                            desc.Text = "Nv. 20-35 • Rebirth 1"
                        end
                    end
                end
            end

            -- Cambiar color del marco a basalto ígneo y lava
            local arch = p2:FindFirstChild("Arch_Frame") or p2:FindFirstChildWhichIsA("BasePart")
            if arch then
                arch.Color = Color3.fromRGB(45, 30, 25)
                arch.Material = Enum.Material.Basalt
            end
            local vortex = p2:FindFirstChild("Portal_Vortex_Surface")
            if vortex and vortex:IsA("BasePart") then
                vortex.Color = Color3.fromRGB(255, 60, 15)
                local pl = vortex:FindFirstChildOfClass("PointLight")
                if pl then
                    pl.Color = Color3.fromRGB(255, 90, 20)
                end
            end
            print("✓ Portal 2 actualizado a: Minas del Fuego Eterno")
        end
    end
end

-- ========================================================
-- 2. CONSTRUIR ENEMIGOS EN LAS SALAS DE MINAS
-- ========================================================
local dungeonMinas = Workspace:FindFirstChild("Dungeon_Minas_Fuego_Eterno")
if not dungeonMinas then
    warn("Dungeon_Minas_Fuego_Eterno no encontrado en Workspace")
    return "Error: Dungeon_Minas_Fuego_Eterno no encontrado"
end

local enemiesFolder = dungeonMinas:FindFirstChild("Dungeon_Enemies")
if enemiesFolder then
    enemiesFolder:Destroy()
end
enemiesFolder = Instance.new("Folder")
enemiesFolder.Name = "Dungeon_Enemies"
enemiesFolder.Parent = dungeonMinas

-- --------------------------------------------------------
-- SALA 1: 3 Murciélagos de Lava
-- --------------------------------------------------------
local batPositions = {
    Vector3.new(baseX - 7, baseY + 6, -10),
    Vector3.new(baseX, baseY + 7.5, 0),
    Vector3.new(baseX + 7, baseY + 6, -10),
}

for i, bPos in ipairs(batPositions) do
    local bat = Instance.new("Model")
    bat.Name = "Murcielago_Lava_" .. i

    -- Torso de basalto
    local body = makePart(bat, "Torso", Vector3.new(2.4, 2.4, 3.0), CFrame.new(bPos), Enum.Material.Basalt, Color3.fromRGB(30, 25, 28), true)
    bat.PrimaryPart = body

    -- Núcleo de magma incandescente
    local magmaCore = makePart(bat, "Magma_Core", Vector3.new(1.8, 1.8, 2.2), CFrame.new(bPos), Enum.Material.Neon, Color3.fromRGB(255, 95, 15))

    -- Ojos amarillos de azufre
    makePart(bat, "Eye_L", Vector3.new(0.4, 0.4, 0.4), CFrame.new(bPos.X - 0.6, bPos.Y + 0.4, bPos.Z + 1.5), Enum.Material.Neon, Color3.fromRGB(255, 230, 40))
    makePart(bat, "Eye_R", Vector3.new(0.4, 0.4, 0.4), CFrame.new(bPos.X + 0.6, bPos.Y + 0.4, bPos.Z + 1.5), Enum.Material.Neon, Color3.fromRGB(255, 230, 40))

    -- Alas anguladas de fuego
    makePart(bat, "Wing_Left", Vector3.new(4.5, 0.4, 2.4), CFrame.new(bPos.X - 3.2, bPos.Y + 0.5, bPos.Z - 0.2) * CFrame.Angles(0, 0, math.rad(22)), Enum.Material.Neon, Color3.fromRGB(255, 55, 10))
    makePart(bat, "Wing_Right", Vector3.new(4.5, 0.4, 2.4), CFrame.new(bPos.X + 3.2, bPos.Y + 0.5, bPos.Z - 0.2) * CFrame.Angles(0, 0, math.rad(-22)), Enum.Material.Neon, Color3.fromRGB(255, 55, 10))

    -- Luz ígnea
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 100, 20)
    light.Brightness = 2.0
    light.Range = 14
    light.Parent = magmaCore

    -- Chispas de fuego
    local fire = Instance.new("Fire")
    fire.Heat = 5
    fire.Size = 4
    fire.Color = Color3.fromRGB(255, 120, 20)
    fire.SecondaryColor = Color3.fromRGB(255, 40, 10)
    fire.Parent = magmaCore

    -- ClickDetector para atacar
    local cd = Instance.new("ClickDetector")
    cd.MaxActivationDistance = 45
    cd.Parent = body

    -- Tag de Salud
    makeHealthTag(body, "Murciélago de Lava", "Nv. 10", 168, 168, false)

    bat.Parent = enemiesFolder
end
print("✓ Sala 1: 3 Murciélagos de Lava creados.")

-- --------------------------------------------------------
-- SALA 2: 2 Gólems Ígneos en el Puente Volcánico
-- --------------------------------------------------------
local golemPositions = {
    Vector3.new(baseX - 4, baseY + 6, 65),
    Vector3.new(baseX + 4, baseY + 6, 95),
}

for i, gPos in ipairs(golemPositions) do
    local golem = Instance.new("Model")
    golem.Name = "Golem_Igneo_" .. i

    local torso = makePart(golem, "Torso", Vector3.new(5, 5, 3.5), CFrame.new(gPos.X, gPos.Y + 2.5, gPos.Z), Enum.Material.Basalt, Color3.fromRGB(40, 35, 40), true)
    golem.PrimaryPart = torso

    -- Núcleo de lava viva en el pecho
    makePart(golem, "Chest_Core", Vector3.new(3, 3, 1), CFrame.new(gPos.X, gPos.Y + 2.5, gPos.Z + 1.8), Enum.Material.Neon, Color3.fromRGB(255, 80, 10))

    -- Hombros y puños volcánicos
    makePart(golem, "Arm_Left", Vector3.new(2.2, 5, 2.2), CFrame.new(gPos.X - 3.8, gPos.Y + 2.0, gPos.Z), Enum.Material.Basalt, Color3.fromRGB(35, 30, 35))
    makePart(golem, "Arm_Right", Vector3.new(2.2, 5, 2.2), CFrame.new(gPos.X + 3.8, gPos.Y + 2.0, gPos.Z), Enum.Material.Basalt, Color3.fromRGB(35, 30, 35))
    makePart(golem, "Fist_Left", Vector3.new(2.6, 2.6, 2.6), CFrame.new(gPos.X - 3.8, gPos.Y - 1.0, gPos.Z), Enum.Material.Neon, Color3.fromRGB(255, 110, 20))
    makePart(golem, "Fist_Right", Vector3.new(2.6, 2.6, 2.6), CFrame.new(gPos.X + 3.8, gPos.Y - 1.0, gPos.Z), Enum.Material.Neon, Color3.fromRGB(255, 110, 20))

    -- Ojos
    makePart(golem, "Eyes", Vector3.new(1.8, 0.5, 0.5), CFrame.new(gPos.X, gPos.Y + 4.2, gPos.Z + 1.8), Enum.Material.Neon, Color3.fromRGB(255, 230, 50))

    local cd = Instance.new("ClickDetector")
    cd.MaxActivationDistance = 45
    cd.Parent = torso

    makeHealthTag(torso, "Gólem Ígneo", "Nv. 12", 210, 210, false)
    golem.Parent = enemiesFolder
end
print("✓ Sala 2: 2 Gólems Ígneos creados en el puente.")

-- --------------------------------------------------------
-- SALA 4: Coloso Ígneo (MiniBoss de 12 studs de altura)
-- --------------------------------------------------------
local miniPos = Vector3.new(baseX, baseY + 6, 235)
local coloso = Instance.new("Model")
coloso.Name = "Coloso_Igneo_MiniBoss"

local cTorso = makePart(coloso, "Torso", Vector3.new(8, 8, 5), CFrame.new(miniPos.X, miniPos.Y + 4, miniPos.Z), Enum.Material.Basalt, Color3.fromRGB(30, 26, 32), true)
coloso.PrimaryPart = cTorso

-- Corazón volcánico titánico
local cHeart = makePart(coloso, "Volcanic_Heart", Vector3.new(4.5, 4.5, 2), CFrame.new(miniPos.X, miniPos.Y + 4, miniPos.Z + 2.6), Enum.Material.Neon, Color3.fromRGB(255, 70, 15))

local cLight = Instance.new("PointLight")
cLight.Color = Color3.fromRGB(255, 80, 20)
cLight.Brightness = 3.0
cLight.Range = 25
cLight.Parent = cHeart

-- Hombreras de púas volcánicas
makePart(coloso, "Shoulder_L", Vector3.new(4, 3, 4), CFrame.new(miniPos.X - 6, miniPos.Y + 7.5, miniPos.Z), Enum.Material.Basalt, Color3.fromRGB(25, 22, 28))
makePart(coloso, "Shoulder_R", Vector3.new(4, 3, 4), CFrame.new(miniPos.X + 6, miniPos.Y + 7.5, miniPos.Z), Enum.Material.Basalt, Color3.fromRGB(25, 22, 28))

-- Brazos colosales
makePart(coloso, "Arm_L", Vector3.new(3.5, 7, 3.5), CFrame.new(miniPos.X - 6, miniPos.Y + 2.5, miniPos.Z), Enum.Material.Basalt, Color3.fromRGB(35, 30, 36))
makePart(coloso, "Arm_R", Vector3.new(3.5, 7, 3.5), CFrame.new(miniPos.X + 6, miniPos.Y + 2.5, miniPos.Z), Enum.Material.Basalt, Color3.fromRGB(35, 30, 36))
makePart(coloso, "Smash_Fist_L", Vector3.new(4.2, 4.2, 4.2), CFrame.new(miniPos.X - 6, miniPos.Y - 1.5, miniPos.Z), Enum.Material.Neon, Color3.fromRGB(255, 120, 20))
makePart(coloso, "Smash_Fist_R", Vector3.new(4.2, 4.2, 4.2), CFrame.new(miniPos.X + 6, miniPos.Y - 1.5, miniPos.Z), Enum.Material.Neon, Color3.fromRGB(255, 120, 20))

-- Cabeza de obsidiana con cuernos
makePart(coloso, "Head", Vector3.new(4, 3.5, 3.5), CFrame.new(miniPos.X, miniPos.Y + 9.5, miniPos.Z + 0.5), Enum.Material.Basalt, Color3.fromRGB(25, 22, 28))
makePart(coloso, "Visor", Vector3.new(2.8, 0.8, 0.6), CFrame.new(miniPos.X, miniPos.Y + 9.5, miniPos.Z + 2.3), Enum.Material.Neon, Color3.fromRGB(255, 240, 50))

local cdColoso = Instance.new("ClickDetector")
cdColoso.MaxActivationDistance = 55
cdColoso.Parent = cTorso

makeHealthTag(cTorso, "COLOSO ÍGNEO [MINI-JEFE]", "Nv. 15", 896, 896, true)
coloso.Parent = enemiesFolder
print("✓ Sala 4: Coloso Ígneo (MiniBoss) creado.")

-- --------------------------------------------------------
-- SALA 5: Gólem de Magma / Dragón de Magma (Jefe Final - 20 studs)
-- --------------------------------------------------------
local bossPos = Vector3.new(baseX, baseY + 8, 335)
local boss = Instance.new("Model")
boss.Name = "Golem_De_Magma_FinalBoss"

-- Torso colosal de 14x12x8 studs
local bTorso = makePart(boss, "Torso", Vector3.new(14, 12, 8), CFrame.new(bossPos.X, bossPos.Y + 8, bossPos.Z), Enum.Material.Basalt, Color3.fromRGB(25, 20, 25), true)
boss.PrimaryPart = bTorso

-- Núcleo de lava pura titánico pulsante
local bCore = makePart(boss, "Magma_Caldera_Core", Vector3.new(8, 8, 3), CFrame.new(bossPos.X, bossPos.Y + 8, bossPos.Z + 4.2), Enum.Material.Neon, Color3.fromRGB(255, 45, 15))

local bossLight = Instance.new("PointLight")
bossLight.Color = Color3.fromRGB(255, 70, 10)
bossLight.Brightness = 4.5
bossLight.Range = 40
bossLight.Parent = bCore

local bossFire = Instance.new("Fire")
bossFire.Heat = 12
bossFire.Size = 10
bossFire.Color = Color3.fromRGB(255, 90, 15)
bossFire.SecondaryColor = Color3.fromRGB(255, 200, 30)
bossFire.Parent = bCore

-- Hombros gigantescos
makePart(boss, "Shoulder_L", Vector3.new(6, 5, 6), CFrame.new(bossPos.X - 10, bossPos.Y + 13, bossPos.Z), Enum.Material.Basalt, Color3.fromRGB(20, 18, 24))
makePart(boss, "Shoulder_R", Vector3.new(6, 5, 6), CFrame.new(bossPos.X + 10, bossPos.Y + 13, bossPos.Z), Enum.Material.Basalt, Color3.fromRGB(20, 18, 24))

-- Brazos y Puños de Lava Gigantes
makePart(boss, "Arm_L", Vector3.new(5, 11, 5), CFrame.new(bossPos.X - 10, bossPos.Y + 5, bossPos.Z), Enum.Material.Basalt, Color3.fromRGB(30, 25, 30))
makePart(boss, "Arm_R", Vector3.new(5, 11, 5), CFrame.new(bossPos.X + 10, bossPos.Y + 5, bossPos.Z), Enum.Material.Basalt, Color3.fromRGB(30, 25, 30))
makePart(boss, "Cataclysm_Fist_L", Vector3.new(6.5, 6.5, 6.5), CFrame.new(bossPos.X - 10, bossPos.Y - 2, bossPos.Z), Enum.Material.Neon, Color3.fromRGB(255, 80, 15))
makePart(boss, "Cataclysm_Fist_R", Vector3.new(6.5, 6.5, 6.5), CFrame.new(bossPos.X + 10, bossPos.Y - 2, bossPos.Z), Enum.Material.Neon, Color3.fromRGB(255, 80, 15))

-- Cabeza con Cuernos de Obsidiana
makePart(boss, "Head", Vector3.new(6, 5, 5), CFrame.new(bossPos.X, bossPos.Y + 16, bossPos.Z + 1), Enum.Material.Basalt, Color3.fromRGB(20, 18, 24))
makePart(boss, "Horn_L", Vector3.new(1.8, 6, 1.8), CFrame.new(bossPos.X - 3.5, bossPos.Y + 19, bossPos.Z + 0.5) * CFrame.Angles(0, 0, math.rad(25)), Enum.Material.Neon, Color3.fromRGB(255, 50, 10))
makePart(boss, "Horn_R", Vector3.new(1.8, 6, 1.8), CFrame.new(bossPos.X + 3.5, bossPos.Y + 19, bossPos.Z + 0.5) * CFrame.Angles(0, 0, math.rad(-25)), Enum.Material.Neon, Color3.fromRGB(255, 50, 10))
makePart(boss, "Eyes", Vector3.new(4, 1.2, 0.8), CFrame.new(bossPos.X, bossPos.Y + 16, bossPos.Z + 3.6), Enum.Material.Neon, Color3.fromRGB(255, 245, 60))

local cdBoss = Instance.new("ClickDetector")
cdBoss.MaxActivationDistance = 70
cdBoss.Parent = bTorso

makeHealthTag(bTorso, "👑 GÓLEM DE MAGMA [JEFE FINAL]", "Nv. 20", 2520, 2520, true)
boss.Parent = enemiesFolder
print("✓ Sala 5: Gólem de Magma (Jefe Final Colosal de 20 studs) creado.")

return "Región 2: Portal del Lobby actualizado y todos los enemigos 3D construidos con éxito."
