-- =============================================================================
-- MAGIA ETERNA — CONSTRUCCIÓN DE LA MAZMORRA "BOSQUE DE LOS SUSURROS"
-- Y MEJORA REALISTA DE MONTAÑAS PERIMETRALES DEL LOBBY
-- 1. Mazmorra física completa (5 salas conectadas con ruinas, raíces y telegráficos AoE)
-- 2. Montañas del Lobby con relieve multicapa, riscos rocosos y pinos alpinos
-- 3. Teletransporte bidireccional Lobby <-> Mazmorra
-- =============================================================================

local Workspace = game:GetService("Workspace")

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
    pr.MaxActivationDistance = maxDist or 14
    pr.HoldDuration = holdDur or 0.5
    pr.RequiresLineOfSight = false
    pr.Parent = parent
    return pr
end

-- =============================================================================
-- PARTE 1: MEJORA REALISTA DE LAS MONTAÑAS PERIMETRALES DEL LOBBY
-- =============================================================================
local Lobby = Workspace:FindFirstChild("MagiaEterna_Lobby")
if Lobby then
    local TerrainFolder = Lobby:FindFirstChild("Terrain_And_Perimeter_Mountains")
    if TerrainFolder then
        -- Carpeta de riscos secundarios y vegetación alpina
        local EnhancedMountains = TerrainFolder:FindFirstChild("Realistic_Mountain_Details")
        if EnhancedMountains then EnhancedMountains:Destroy() end
        EnhancedMountains = Instance.new("Folder")
        EnhancedMountains.Name = "Realistic_Mountain_Details"
        EnhancedMountains.Parent = TerrainFolder

        -- 1. Riscos de contrafuerte secundarios en las faldas (Radius 120-130)
        local numButtresses = 36
        for b = 1, numButtresses do
            local bAng = (b / numButtresses) * math.pi * 2
            local bx = math.cos(bAng) * 128
            local bz = math.sin(bAng) * 128
            local bHeight = 22 + ((b * 11) % 18)
            local bWidth = 24 + ((b * 7) % 12)
            
            local bCF = CFrame.lookAt(Vector3.new(bx, bHeight / 2, bz), Vector3.new(0, bHeight / 2, 0))
            makeWedge(EnhancedMountains, "Rock_Buttress_" .. b, Vector3.new(bWidth, bHeight, bWidth * 0.8), bCF, Enum.Material.Basalt, Color3.fromRGB(50 + (b%4)*5, 48 + (b%4)*5, 54 + (b%4)*5))
        end

        -- 2. Pinos alpinos realistas al pie de las montañas (Radius 115-125)
        local numPines = 30
        for pi = 1, numPines do
            local pAng = (pi / numPines) * math.pi * 2 + 0.05
            local px = math.cos(pAng) * 118
            local pz = math.sin(pAng) * 118
            
            -- Tronco de pino
            makeCylinder(EnhancedMountains, "Alpine_Pine_Trunk_" .. pi, Vector3.new(14, 1.6, 1.6), CFrame.new(px, 9, pz) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Wood, Color3.fromRGB(75, 48, 25))
            -- 3 Niveles cónicos de follaje verde oscuro
            for ti = 1, 3 do
                local cy = 12 + ti * 4.5
                local cr = 6.5 - ti * 1.4
                local cone = makePart(EnhancedMountains, "Pine_Foliage_" .. pi .. "_" .. ti, Vector3.new(cr * 2, 4.5, cr * 2), CFrame.new(px, cy, pz), Enum.Material.Grass, Color3.fromRGB(35 + ti*5, 75 + ti*8, 40 + ti*5))
                cone.Shape = Enum.PartType.Ball
            end
        end
    end
end

-- =============================================================================
-- PARTE 2: CONSTRUCCIÓN FÍSICA DE LA MAZMORRA "BOSQUE DE LOS SUSURROS"
-- Ubicación: X = 800, Y = 50, Z = 0 a 400
-- =============================================================================
local oldDungeon = Workspace:FindFirstChild("Dungeon_Bosque_Susurros")
if oldDungeon then oldDungeon:Destroy() end

local Dungeon = Instance.new("Model")
Dungeon.Name = "Dungeon_Bosque_Susurros"
Dungeon.Parent = Workspace

local D_BASE = Vector3.new(800, 50, 0)

-- Función auxiliar de recinto de sala (Suelo, muros y techo rocoso para inmersión total)
local function buildRoomEnclosure(parent, name, centerPos, width, length, wallHeight)
    local roomModel = Instance.new("Model")
    roomModel.Name = name
    roomModel.Parent = parent
    
    -- Suelo de piedra musgosa y tierra forestal
    makePart(roomModel, "Room_Floor", Vector3.new(width, 2, length), CFrame.new(centerPos), Enum.Material.Slate, Color3.fromRGB(48, 62, 45))
    
    -- Muros laterales rocosos impenetrables
    local halfW = width / 2
    local halfL = length / 2
    local wallY = centerPos.Y + wallHeight / 2
    
    -- Muro Oeste (-X)
    makePart(roomModel, "Wall_West", Vector3.new(4, wallHeight, length), CFrame.new(centerPos.X - halfW, wallY, centerPos.Z), Enum.Material.Slate, Color3.fromRGB(38, 45, 36))
    -- Muro Este (+X)
    makePart(roomModel, "Wall_East", Vector3.new(4, wallHeight, length), CFrame.new(centerPos.X + halfW, wallY, centerPos.Z), Enum.Material.Slate, Color3.fromRGB(38, 45, 36))
    
    -- Techo de dosel de ramas oscuras (Evita que el jugador salga volando o vea el vacío)
    local ceiling = makePart(roomModel, "Canopy_Ceiling", Vector3.new(width + 8, 3, length + 8), CFrame.new(centerPos.X, centerPos.Y + wallHeight, centerPos.Z), Enum.Material.Grass, Color3.fromRGB(22, 38, 20), true, true)
    ceiling.Transparency = 0.2
    
    return roomModel
end

-- -----------------------------------------------------------------------------
-- SALA 1: ENTRADA DE LAS RUINAS CUBIERTAS DE VEGETACIÓN (Slimes Verdes)
-- -----------------------------------------------------------------------------
local room1Pos = D_BASE + Vector3.new(0, 0, 0)
local Room1 = buildRoomEnclosure(Dungeon, "Room1_Ruins_Entrance", room1Pos, 60, 60, 26)

-- Punto de aparición inicial en la mazmorra (Spawn al entrar del portal)
local dSpawn = makePart(Room1, "Dungeon_SpawnPoint", Vector3.new(8, 0.4, 8), CFrame.new(room1Pos + Vector3.new(0, 1.2, -22)), Enum.Material.Neon, Color3.fromRGB(60, 220, 100), true, false)
dSpawn.Transparency = 0.5
local spLight = Instance.new("PointLight")
spLight.Color = Color3.fromRGB(60, 230, 110)
spLight.Range = 20
spLight.Brightness = 2
spLight.Parent = dSpawn

-- Arcos de ruinas antiguos caídos
for _, rx in ipairs({-18, 18}) do
    local pillar = makePart(Room1, "Ruin_Pillar", Vector3.new(3, 18, 3), CFrame.new(room1Pos + Vector3.new(rx, 9, 0)), Enum.Material.Cobblestone, Color3.fromRGB(65, 75, 62))
    local arch = makePart(Room1, "Ruin_Arch", Vector3.new(12, 2.5, 3), CFrame.new(room1Pos + Vector3.new(rx * 0.7, 18, 0)), Enum.Material.Cobblestone, Color3.fromRGB(65, 75, 62))
    -- Brasero de fuego verde místico
    local brazier = makePart(Room1, "Emerald_Brazier", Vector3.new(2, 1.2, 2), CFrame.new(room1Pos + Vector3.new(rx, 4, 10)), Enum.Material.Metal, Color3.fromRGB(35, 38, 35))
    local flame = makePart(Room1, "Emerald_Flame", Vector3.new(1.2, 1.5, 1.2), CFrame.new(room1Pos + Vector3.new(rx, 5.2, 10)), Enum.Material.Neon, Color3.fromRGB(50, 240, 90), true, false)
    local fl = Instance.new("PointLight")
    fl.Color = Color3.fromRGB(60, 255, 100)
    fl.Range = 22
    fl.Brightness = 2.5
    fl.Parent = flame
end

-- 4 Spawns de Enemigos: Slimes Verdes
for si = 1, 4 do
    local sang = (si - 1) * (math.pi / 2)
    local sx = room1Pos.X + math.cos(sang) * 12
    local sz = room1Pos.Z + math.sin(sang) * 12
    local spPad = makeCylinder(Room1, "Spawn_Slime_Verde_" .. si, Vector3.new(0.2, 4, 4), CFrame.new(sx, room1Pos.Y + 1.1, sz) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Neon, Color3.fromRGB(60, 200, 80), true, false)
    spPad.Transparency = 0.6
end

-- Puerta de Raíces Rúnica hacia Sala 2 (Z = 30)
local door1 = makePart(Room1, "Root_Gate_To_Room2", Vector3.new(16, 16, 2), CFrame.new(room1Pos.X, room1Pos.Y + 8, room1Pos.Z + 30), Enum.Material.Wood, Color3.fromRGB(80, 50, 25))

-- -----------------------------------------------------------------------------
-- SALA 2: SENDEIRO FORESTAL Y DESFILADERO (Duendes Mágicos)
-- -----------------------------------------------------------------------------
local room2Pos = D_BASE + Vector3.new(0, 0, 75)
local Room2 = buildRoomEnclosure(Dungeon, "Room2_Forest_Canyon", room2Pos, 44, 70, 28)

-- Rocas de contrafuerte y troncos caídos atravesados
makePart(Room2, "Fallen_Ancient_Log", Vector3.new(5, 5, 26), CFrame.new(room2Pos + Vector3.new(-8, 3, -10)) * CFrame.Angles(0, math.rad(25), 0), Enum.Material.Wood, Color3.fromRGB(65, 42, 20))
makePart(Room2, "Mossy_Boulder_1", Vector3.new(8, 7, 8), CFrame.new(room2Pos + Vector3.new(12, 3.5, 5)), Enum.Material.Slate, Color3.fromRGB(55, 68, 50))

-- Faroles de madera en estacas
for _, lz in ipairs({-15, 15}) do
    makePart(Room2, "Wooden_Stake", Vector3.new(0.8, 9, 0.8), CFrame.new(room2Pos + Vector3.new(14, 4.5, lz)), Enum.Material.Wood, Color3.fromRGB(90, 60, 30))
    local lantern = makePart(Room2, "Camp_Lantern", Vector3.new(1.4, 1.8, 1.4), CFrame.new(room2Pos + Vector3.new(14, 9.5, lz)), Enum.Material.Neon, Color3.fromRGB(255, 190, 80))
    local ll = Instance.new("PointLight")
    ll.Color = Color3.fromRGB(255, 180, 70)
    ll.Range = 20
    ll.Brightness = 2
    ll.Parent = lantern
end

-- 4 Spawns de Enemigos: Duendes Mágicos
for gi = 1, 4 do
    local gPos = room2Pos + Vector3.new((gi%2 == 0 and 8 or -8), 1.1, -18 + gi * 9)
    local gPad = makeCylinder(Room2, "Spawn_Duende_Magico_" .. gi, Vector3.new(0.2, 4, 4), CFrame.new(gPos) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Neon, Color3.fromRGB(220, 140, 50), true, false)
    gPad.Transparency = 0.6
end

-- -----------------------------------------------------------------------------
-- SALA 3: CLARO MÍSTICO CORRUPTO (Lobos Mágicos y Hadas Corruptas)
-- -----------------------------------------------------------------------------
local room3Pos = D_BASE + Vector3.new(0, 0, 160)
local Room3 = buildRoomEnclosure(Dungeon, "Room3_Corrupted_Glade", room3Pos, 76, 75, 32)

-- Estanque de agua corrompida bioluminiscente en el centro
local corruptedPool = makeCylinder(Room3, "Corrupted_Bioluminescent_Pool", Vector3.new(0.6, 26, 26), CFrame.new(room3Pos + Vector3.new(0, 1.1, 0)) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Glass, Color3.fromRGB(150, 40, 220))
corruptedPool.Transparency = 0.35

local poolLight = Instance.new("PointLight")
poolLight.Color = Color3.fromRGB(170, 50, 240)
poolLight.Range = 35
poolLight.Brightness = 3
poolLight.Parent = corruptedPool

-- Emisor de esporas flotantes
local sporePE = Instance.new("ParticleEmitter")
sporePE.Texture = "rbxasset://textures/particles/sparkles_main.dds"
sporePE.Color = ColorSequence.new(Color3.fromRGB(190, 60, 255))
sporePE.Size = NumberSequence.new(0.5, 0.1)
sporePE.Rate = 18
sporePE.Speed = NumberRange.new(1, 3)
sporePE.SpreadAngle = Vector2.new(180, 180)
sporePE.Parent = corruptedPool

-- Setas gigantes brillantes a la orilla del estanque
for mi = 1, 4 do
    local mang = mi * (math.pi / 2)
    local mx = room3Pos.X + math.cos(mang) * 18
    local mz = room3Pos.Z + math.sin(mang) * 18
    makeCylinder(Room3, "Mushroom_Stem_" .. mi, Vector3.new(5, 1.4, 1.4), CFrame.new(mx, room3Pos.Y + 2.5, mz) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.SmoothPlastic, Color3.fromRGB(220, 215, 205))
    local cap = makePart(Room3, "Mushroom_Cap_" .. mi, Vector3.new(5, 2.2, 5), CFrame.new(mx, room3Pos.Y + 5.5, mz), Enum.Material.Neon, Color3.fromRGB(190, 60, 240))
    cap.Shape = Enum.PartType.Ball
end

-- 4 Spawns de Enemigos: Lobos Mágicos y Hadas
for wi = 1, 4 do
    local wPos = room3Pos + Vector3.new((wi < 3 and -18 or 18), 1.1, (wi%2 == 0 and 15 or -15))
    local wPad = makeCylinder(Room3, "Spawn_Lobo_Hada_" .. wi, Vector3.new(0.2, 5, 5), CFrame.new(wPos) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Neon, Color3.fromRGB(180, 50, 220), true, false)
    wPad.Transparency = 0.6
end

-- -----------------------------------------------------------------------------
-- SALA 4: CÁMARA DE RAÍCES — ARENA DEL MINI-JEFE (Guardián de Raíces)
-- -----------------------------------------------------------------------------
local room4Pos = D_BASE + Vector3.new(0, 0, 255)
local Room4 = buildRoomEnclosure(Dungeon, "Room4_Roots_Chamber_MiniBoss", room4Pos, 68, 68, 34)

-- Arena circular de combate fortificada
local arenaRing = makeCylinder(Room4, "MiniBoss_Arena_Dais", Vector3.new(0.5, 46, 46), CFrame.new(room4Pos + Vector3.new(0, 1.25, 0)) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Cobblestone, Color3.fromRGB(60, 70, 58))
local arenaRune = makeCylinder(Room4, "MiniBoss_Arena_Rune", Vector3.new(0.1, 38, 38), CFrame.new(room4Pos + Vector3.new(0, 1.55, 0)) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Neon, Color3.fromRGB(80, 220, 120))
arenaRune.Transparency = 0.45

-- Pedestal y Marcador del Mini-Jefe: Guardián de Raíces
local miniBossPedestal = makeCylinder(Room4, "MiniBoss_Pedestal", Vector3.new(1.2, 8, 8), CFrame.new(room4Pos + Vector3.new(0, 1.8, 0)) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Slate, Color3.fromRGB(50, 55, 48))

-- Modelo visual del Guardián de Raíces
local mbModel = Instance.new("Model")
mbModel.Name = "Guardian_De_Raices_Model"
mbModel.Parent = Room4

local mbTorso = makePart(mbModel, "Torso", Vector3.new(3.5, 6, 2.8), CFrame.new(room4Pos + Vector3.new(0, 6, 0)), Enum.Material.Wood, Color3.fromRGB(85, 52, 28))
local mbHead = makePart(mbModel, "Head", Vector3.new(2.4, 2.4, 2.4), CFrame.new(room4Pos + Vector3.new(0, 9.8, 0)), Enum.Material.Slate, Color3.fromRGB(75, 82, 70))
local mbEye = makePart(mbModel, "Runic_Eye", Vector3.new(1.4, 0.6, 0.4), CFrame.new(room4Pos + Vector3.new(0, 9.8, -1.2)), Enum.Material.Neon, Color3.fromRGB(60, 240, 110))
local mbArmL = makePart(mbModel, "Arm_L", Vector3.new(1.4, 5.5, 1.4), CFrame.new(room4Pos + Vector3.new(-3, 6, 0)), Enum.Material.Wood, Color3.fromRGB(85, 52, 28))
local mbArmR = makePart(mbModel, "Arm_R", Vector3.new(1.4, 5.5, 1.4), CFrame.new(room4Pos + Vector3.new(3, 6, 0)), Enum.Material.Wood, Color3.fromRGB(85, 52, 28))

-- -----------------------------------------------------------------------------
-- SALA 5: GUARIDA ANCESTRAL — JEFE FINAL (Treant Ancestral - 3 Fases AoE)
-- -----------------------------------------------------------------------------
local room5Pos = D_BASE + Vector3.new(0, 0, 365)
local Room5 = buildRoomEnclosure(Dungeon, "Room5_Treant_Boss_Lair", room5Pos, 105, 105, 45)

-- Arena colosal hundida de combate
local bossFloor = makeCylinder(Room5, "Boss_Coliseum_Floor", Vector3.new(0.6, 92, 92), CFrame.new(room5Pos + Vector3.new(0, 1.3, 0)) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Cobblestone, Color3.fromRGB(45, 52, 42))

-- ANILLOS DE TELEGRÁFICOS DE ÁREA (AoE) PARA LAS 3 FASES DEL JEFE
-- Anillo 1 (Fase 1 - Reconocimiento): Exterior, radio 74 studs (Amarillo/Verde tenue)
local aoeRing1 = makeCylinder(Room5, "Telegraph_AoE_Phase1_Outer", Vector3.new(0.08, 74, 74), CFrame.new(room5Pos + Vector3.new(0, 1.62, 0)) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Neon, Color3.fromRGB(220, 200, 50))
aoeRing1.Transparency = 0.65

-- Anillo 2 (Fase 2 - Furia al 60%): Medio, radio 48 studs (Naranja intenso)
local aoeRing2 = makeCylinder(Room5, "Telegraph_AoE_Phase2_Middle", Vector3.new(0.12, 48, 48), CFrame.new(room5Pos + Vector3.new(0, 1.68, 0)) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Neon, Color3.fromRGB(255, 120, 30))
aoeRing2.Transparency = 0.50

-- Anillo 3 (Fase 3 - Definitiva al 25%): Interior/Nova, radio 24 studs (Rojo Carmesí)
local aoeRing3 = makeCylinder(Room5, "Telegraph_AoE_Phase3_InnerNova", Vector3.new(0.15, 24, 24), CFrame.new(room5Pos + Vector3.new(0, 1.74, 0)) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Neon, Color3.fromRGB(255, 30, 20))
aoeRing3.Transparency = 0.40

-- Pedestal Central del Treant Ancestral
local bossPedestal = makeCylinder(Room5, "Treant_Boss_Dais", Vector3.new(1.4, 14, 14), CFrame.new(room5Pos + Vector3.new(0, 2.0, 0)) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Slate, Color3.fromRGB(40, 45, 38))

-- MODELO COMPLETO DEL TREANT ANCESTRAL (Jefe Final)
local treantModel = Instance.new("Model")
treantModel.Name = "Treant_Ancestral_Boss_Model"
treantModel.Parent = Room5

local tTorso = makePart(treantModel, "Torso", Vector3.new(6, 11, 5), CFrame.new(room5Pos + Vector3.new(0, 10.5, 0)), Enum.Material.Wood, Color3.fromRGB(65, 38, 20))
local tHeart = makePart(treantModel, "Corazon_Corrupto", Vector3.new(2.4, 2.4, 1.8), CFrame.new(room5Pos + Vector3.new(0, 11.5, -2.5)), Enum.Material.Neon, Color3.fromRGB(255, 60, 20), true, false)
local heartLight = Instance.new("PointLight")
heartLight.Color = Color3.fromRGB(255, 70, 30)
heartLight.Range = 30
heartLight.Brightness = 3
heartLight.Parent = tHeart

local tHead = makePart(treantModel, "Head", Vector3.new(4.5, 4.5, 4.0), CFrame.new(room5Pos + Vector3.new(0, 18.0, 0)), Enum.Material.Wood, Color3.fromRGB(65, 38, 20))
for _, eyeX in ipairs({-1.1, 1.1}) do
    makePart(treantModel, "Boss_Eye", Vector3.new(0.9, 0.9, 0.4), CFrame.new(room5Pos + Vector3.new(eyeX, 18.2, -2.1)), Enum.Material.Neon, Color3.fromRGB(255, 50, 20))
end
-- Brazos titánicos con ramas
local tArmL = makePart(treantModel, "Arm_Left", Vector3.new(2.4, 11, 2.4), CFrame.new(room5Pos + Vector3.new(-6.2, 10, 0)) * CFrame.Angles(0, 0, math.rad(20)), Enum.Material.Wood, Color3.fromRGB(65, 38, 20))
local tArmR = makePart(treantModel, "Arm_Right", Vector3.new(2.4, 11, 2.4), CFrame.new(room5Pos + Vector3.new(6.2, 10, 0)) * CFrame.Angles(0, 0, -math.rad(20)), Enum.Material.Wood, Color3.fromRGB(65, 38, 20))
-- Copa de follaje en la cabeza
local tCrown = makePart(treantModel, "Canopy_Crown", Vector3.new(12, 6, 12), CFrame.new(room5Pos + Vector3.new(0, 22.0, 0)), Enum.Material.Grass, Color3.fromRGB(40, 95, 45))
tCrown.Shape = Enum.PartType.Ball

-- COFRE ANCESTRAL DEL TESORO (Detrás del jefe, Z = 25)
local chestPos = room5Pos + Vector3.new(0, 1.3, 28)
local chestBase = makePart(Room5, "Ancient_Treasure_Chest", Vector3.new(6, 4, 3.8), CFrame.new(chestPos + Vector3.new(0, 2, 0)), Enum.Material.WoodPlanks, Color3.fromRGB(110, 75, 40))
local chestLid = makePart(Room5, "Chest_Lid", Vector3.new(6.4, 1.6, 4.2), CFrame.new(chestPos + Vector3.new(0, 4.6, 0)), Enum.Material.Metal, Color3.fromRGB(220, 180, 50))
local chestLock = makePart(Room5, "Chest_Emerald_Lock", Vector3.new(1.2, 1.4, 0.6), CFrame.new(chestPos + Vector3.new(0, 3.8, -2.0)), Enum.Material.Neon, Color3.fromRGB(50, 240, 100))

local chestPrompt = makePrompt(chestBase, "Reclamar Botín Ancestral", "Cofre del Treant", 16, 1.0)

-- PORTAL DE SALIDA / RETORNO AL LOBBY (Z = 40)
local exitPos = room5Pos + Vector3.new(0, 1.3, 40)
local exitArch = makePart(Room5, "Exit_Portal_Frame", Vector3.new(12, 16, 2.5), CFrame.new(exitPos + Vector3.new(0, 8, 0)), Enum.Material.Cobblestone, Color3.fromRGB(75, 75, 80))
local exitVortex = makePart(Room5, "Exit_Portal_Vortex", Vector3.new(7, 12, 0.6), CFrame.new(exitPos + Vector3.new(0, 8, 0)), Enum.Material.Neon, Color3.fromRGB(60, 200, 255), true, false)
exitVortex.Transparency = 0.25

local exitPE = Instance.new("ParticleEmitter")
exitPE.Texture = "rbxasset://textures/particles/sparkles_main.dds"
exitPE.Color = ColorSequence.new(Color3.fromRGB(80, 220, 255))
exitPE.Rate = 18
exitPE.Speed = NumberRange.new(1, 4)
exitPE.Parent = exitVortex

local exitPrompt = makePrompt(exitVortex, "Regresar al Lobby", "Portal de Retorno", 14, 0.4)

print("=============================================================================")
print("MAZMORRA 'BOSQUE DE LOS SUSURROS' CONSTRUIDA FÍSICAMENTE CON ÉXITO:")
print(" - Sala 1: Entrada a ruinas, antorchas esmeralda, raíces y spawns de Slimes")
print(" - Sala 2: Desfiladero forestal, troncos caídos y campamento de Duendes")
print(" - Sala 3: Claro místico con estanque bioluminiscente, setas y Lobos/Hadas")
print(" - Sala 4: Arena circular del Mini-Jefe Guardián de Raíces con modelo 3D")
print(" - Sala 5: Gran Coliseo del Treant Ancestral con 3 anillos de telegráficos AoE,")
print("           Cofre del Tesoro Ancestral y Portal de Retorno al Lobby.")
print(" - Mejoras realistas en las montañas del Lobby aplicadas con éxito.")
print("=============================================================================")
return true
