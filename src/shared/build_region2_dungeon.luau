local Workspace = game:GetService("Workspace")

local oldDungeon = Workspace:FindFirstChild("Dungeon_Minas_Fuego_Eterno")
if oldDungeon then
    oldDungeon:Destroy()
end

local dungeon = Instance.new("Model")
dungeon.Name = "Dungeon_Minas_Fuego_Eterno"
dungeon.Parent = Workspace

local function createPart(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material): Part
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cf
    part.Color = color
    part.Material = material
    part.Anchored = true
    part.CanCollide = true
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local baseX = -800
local baseY = 50

-- Gates Container
local gatesFolder = Instance.new("Folder")
gatesFolder.Name = "Dungeon_Gates"
gatesFolder.Parent = dungeon

local function createRuneGate(gateName: string, pos: Vector3, reqText: string): Model
    local gateModel = Instance.new("Model")
    gateModel.Name = gateName

    -- Side Pillars
    createPart(gateModel, "Pillar_Left", Vector3.new(4, 18, 4), CFrame.new(pos + Vector3.new(-8, 9, 0)), Color3.fromRGB(30, 25, 28), Enum.Material.Slate)
    createPart(gateModel, "Pillar_Right", Vector3.new(4, 18, 4), CFrame.new(pos + Vector3.new(8, 9, 0)), Color3.fromRGB(30, 25, 28), Enum.Material.Slate)
    -- Top Arch
    createPart(gateModel, "Pillar_Arch", Vector3.new(20, 4, 5), CFrame.new(pos + Vector3.new(0, 18, 0)), Color3.fromRGB(35, 28, 30), Enum.Material.Slate)

    -- Energy Barrier
    local barrier = createPart(gateModel, "Fire_Barrier", Vector3.new(12, 16, 1.5), CFrame.new(pos + Vector3.new(0, 8, 0)), Color3.fromRGB(255, 40, 20), Enum.Material.ForceField)
    barrier.Transparency = 0.35

    -- Medallion Lock
    local lock = createPart(gateModel, "Medallion_Lock", Vector3.new(3, 3, 2), CFrame.new(pos + Vector3.new(0, 8, 0)), Color3.fromRGB(255, 120, 20), Enum.Material.Neon)
    lock.Shape = Enum.PartType.Cylinder
    lock.CFrame = CFrame.new(pos + Vector3.new(0, 8, 0)) * CFrame.Angles(0, 0, math.rad(90))

    -- BillboardGui (MaxDistance = 45 studs, AlwaysOnTop = false)
    local bb = Instance.new("BillboardGui")
    bb.Name = "GateSign"
    bb.Adornee = lock
    bb.Size = UDim2.new(0, 180, 0, 45)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = false
    bb.MaxDistance = 45
    bb.Parent = lock

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundColor3 = Color3.fromRGB(15, 10, 12)
    lbl.BackgroundTransparency = 0.25
    lbl.Text = "🔥 PUERTA ÍGNEA BLOQUEADA\n(" .. reqText .. ")"
    lbl.TextColor3 = Color3.fromRGB(255, 90, 40)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.Parent = bb

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = lbl

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 120, 30)
    stroke.Thickness = 1.2
    stroke.Parent = lbl

    gateModel.Parent = gatesFolder
    return gateModel
end

-- ==========================================================
-- SALA 1: ENTRADA DE LA MINA Y DESFILADERO DE LAVA
-- ==========================================================
local room1 = Instance.new("Model")
room1.Name = "Room1_Mine_Entrance"
createPart(room1, "Floor_Basalt", Vector3.new(50, 4, 60), CFrame.new(baseX, baseY, 0), Color3.fromRGB(38, 32, 34), Enum.Material.Slate)
local lavaLeft = createPart(room1, "Lava_Trench_Left", Vector3.new(8, 3.8, 60), CFrame.new(baseX - 22, baseY + 0.1, 0), Color3.fromRGB(255, 80, 10), Enum.Material.Neon)
createPart(room1, "Lava_Trench_Right", Vector3.new(8, 3.8, 60), CFrame.new(baseX + 22, baseY + 0.1, 0), Color3.fromRGB(255, 80, 10), Enum.Material.Neon)

for zOffset = -24, 24, 6 do
    createPart(room1, "RailTie", Vector3.new(7, 0.4, 2), CFrame.new(baseX, baseY + 2.2, zOffset), Color3.fromRGB(55, 40, 30), Enum.Material.WoodPlanks)
end
createPart(room1, "Rail_Left", Vector3.new(0.6, 0.5, 56), CFrame.new(baseX - 2.5, baseY + 2.5, 0), Color3.fromRGB(150, 150, 160), Enum.Material.Metal)
createPart(room1, "Rail_Right", Vector3.new(0.6, 0.5, 56), CFrame.new(baseX + 2.5, baseY + 2.5, 0), Color3.fromRGB(150, 150, 160), Enum.Material.Metal)

createPart(room1, "Overturned_Minecart", Vector3.new(6, 4, 8), CFrame.new(baseX + 12, baseY + 3.5, -8) * CFrame.Angles(0, math.rad(25), math.rad(18)), Color3.fromRGB(70, 60, 55), Enum.Material.CorrodedMetal)
local crystal1 = createPart(room1, "Fire_Crystal_Deposit", Vector3.new(3, 4, 3), CFrame.new(baseX + 14, baseY + 4, -6), Color3.fromRGB(255, 45, 30), Enum.Material.Neon)
crystal1.Shape = Enum.PartType.Cylinder

createPart(room1, "Wall_West", Vector3.new(6, 22, 60), CFrame.new(baseX - 28, baseY + 11, 0), Color3.fromRGB(30, 24, 26), Enum.Material.Basalt)
createPart(room1, "Wall_East", Vector3.new(6, 22, 60), CFrame.new(baseX + 28, baseY + 11, 0), Color3.fromRGB(30, 24, 26), Enum.Material.Basalt)
createPart(room1, "Wall_Back", Vector3.new(50, 22, 6), CFrame.new(baseX, baseY + 11, -33), Color3.fromRGB(30, 24, 26), Enum.Material.Basalt)

local pLight = Instance.new("PointLight")
pLight.Color = Color3.fromRGB(255, 120, 30)
pLight.Range = 35
pLight.Brightness = 2.5
pLight.Parent = lavaLeft
room1.Parent = dungeon
createRuneGate("Gate_Room1_To_Room2", Vector3.new(baseX, baseY + 2, 30), "Supera los Murciélagos de Lava")

-- ==========================================================
-- SALA 2: PUENTE VOLCÁNICO SUSPENDIDO SOBRE MAGMA
-- ==========================================================
local room2 = Instance.new("Model")
room2.Name = "Room2_Volcanic_Bridge"

local sea = createPart(room2, "Lava_Sea", Vector3.new(90, 4, 75), CFrame.new(baseX, baseY - 12, 80), Color3.fromRGB(255, 75, 12), Enum.Material.Neon)
local seaLight = Instance.new("PointLight")
seaLight.Color = Color3.fromRGB(255, 100, 20)
seaLight.Range = 60
seaLight.Brightness = 3
seaLight.Parent = sea

createPart(room2, "Bridge_Walkway", Vector3.new(16, 4, 65), CFrame.new(baseX, baseY, 80), Color3.fromRGB(48, 40, 42), Enum.Material.Cobblestone)
createPart(room2, "Bridge_Rail_Left", Vector3.new(1.5, 3.5, 65), CFrame.new(baseX - 8, baseY + 3.5, 80), Color3.fromRGB(35, 28, 30), Enum.Material.Slate)
createPart(room2, "Bridge_Rail_Right", Vector3.new(1.5, 3.5, 65), CFrame.new(baseX + 8, baseY + 3.5, 80), Color3.fromRGB(35, 28, 30), Enum.Material.Slate)
createPart(room2, "Arch_Center", Vector3.new(22, 24, 4), CFrame.new(baseX, baseY + 8, 80), Color3.fromRGB(30, 25, 27), Enum.Material.Basalt)
createPart(room2, "Canyon_Wall_West", Vector3.new(8, 36, 75), CFrame.new(baseX - 45, baseY + 6, 80), Color3.fromRGB(25, 20, 22), Enum.Material.Basalt)
createPart(room2, "Canyon_Wall_East", Vector3.new(8, 36, 75), CFrame.new(baseX + 45, baseY + 6, 80), Color3.fromRGB(25, 20, 22), Enum.Material.Basalt)

room2.Parent = dungeon
createRuneGate("Gate_Room2_To_Room3", Vector3.new(baseX, baseY + 2, 116), "Supera los Mineros Malditos")

-- ==========================================================
-- SALA 3: CÁMARA DE FUNDICIÓN Y MAQUINARIA ANTIGUA
-- ==========================================================
local room3 = Instance.new("Model")
room3.Name = "Room3_Ancient_Foundry"

createPart(room3, "Foundry_Floor", Vector3.new(65, 4, 65), CFrame.new(baseX, baseY, 155), Color3.fromRGB(42, 36, 38), Enum.Material.Cobblestone)
createPart(room3, "Blast_Furnace_Body", Vector3.new(18, 16, 12), CFrame.new(baseX, baseY + 8, 182), Color3.fromRGB(35, 28, 30), Enum.Material.Basalt)
local furnaceMouth = createPart(room3, "Furnace_Molten_Core", Vector3.new(10, 6, 2), CFrame.new(baseX, baseY + 4, 175.5), Color3.fromRGB(255, 110, 15), Enum.Material.Neon)
createPart(room3, "Furnace_Chimney", Vector3.new(8, 18, 8), CFrame.new(baseX, baseY + 24, 182), Color3.fromRGB(30, 24, 26), Enum.Material.Basalt)

local fLight = Instance.new("PointLight")
fLight.Color = Color3.fromRGB(255, 140, 30)
fLight.Range = 40
fLight.Brightness = 3
fLight.Parent = furnaceMouth

createPart(room3, "Ingot_Stack", Vector3.new(8, 3, 5), CFrame.new(baseX - 18, baseY + 2.5, 150), Color3.fromRGB(180, 50, 30), Enum.Material.Metal)
createPart(room3, "Foundry_Anvil", Vector3.new(5, 5, 4), CFrame.new(baseX - 12, baseY + 3.5, 158), Color3.fromRGB(50, 50, 55), Enum.Material.DiamondPlate)
createPart(room3, "Wall_West", Vector3.new(6, 26, 65), CFrame.new(baseX - 35, baseY + 12, 155), Color3.fromRGB(28, 22, 24), Enum.Material.Basalt)
createPart(room3, "Wall_East", Vector3.new(6, 26, 65), CFrame.new(baseX + 35, baseY + 12, 155), Color3.fromRGB(28, 22, 24), Enum.Material.Basalt)

room3.Parent = dungeon
createRuneGate("Gate_Room3_To_Room4", Vector3.new(baseX, baseY + 2, 192), "Supera los Gólems de Magma")

-- ==========================================================
-- SALA 4: CÁMARA DEL NÚCLEO ÍGNEO (ARENA DEL MINI-JEFE)
-- ==========================================================
local room4 = Instance.new("Model")
room4.Name = "Room4_Fiery_Core_MiniBoss"

local arenaBase = createPart(room4, "Arena_Base", Vector3.new(58, 4, 58), CFrame.new(baseX, baseY, 235), Color3.fromRGB(35, 30, 34), Enum.Material.Slate)
arenaBase.Shape = Enum.PartType.Cylinder
arenaBase.CFrame = CFrame.new(baseX, baseY, 235) * CFrame.Angles(0, 0, math.rad(90))

local ring = createPart(room4, "Rune_Border", Vector3.new(64, 2, 64), CFrame.new(baseX, baseY - 1, 235), Color3.fromRGB(255, 60, 20), Enum.Material.Neon)
ring.Shape = Enum.PartType.Cylinder
ring.CFrame = CFrame.new(baseX, baseY - 1, 235) * CFrame.Angles(0, 0, math.rad(90))

local core = createPart(room4, "Floating_Fiery_Crystal", Vector3.new(5, 10, 5), CFrame.new(baseX, baseY + 14, 235), Color3.fromRGB(255, 45, 15), Enum.Material.Neon)
local cLight = Instance.new("PointLight")
cLight.Color = Color3.fromRGB(255, 80, 20)
cLight.Range = 50
cLight.Brightness = 4
cLight.Parent = core

local angles = { 0, math.rad(90), math.rad(180), math.rad(270) }
for _, ang in ipairs(angles) do
    local offset = Vector3.new(math.cos(ang) * 22, 10, math.sin(ang) * 22)
    createPart(room4, "Obsidian_Pillar", Vector3.new(4, 22, 4), CFrame.new(Vector3.new(baseX, baseY, 235) + offset), Color3.fromRGB(22, 18, 20), Enum.Material.Basalt)
end

room4.Parent = dungeon
createRuneGate("Gate_Room4_To_Room5", Vector3.new(baseX, baseY + 2, 270), "Derrota al Coloso Ígneo")

-- ==========================================================
-- SALA 5: CALDERA DEL MAGMA (ARENA DEL JEFE FINAL)
-- ==========================================================
local room5 = Instance.new("Model")
room5.Name = "Room5_Magma_Colosseum_Boss"

local bossColosseum = createPart(room5, "Colosseum_Floor", Vector3.new(90, 4, 90), CFrame.new(baseX, baseY, 335), Color3.fromRGB(32, 26, 28), Enum.Material.Slate)
bossColosseum.Shape = Enum.PartType.Cylinder
bossColosseum.CFrame = CFrame.new(baseX, baseY, 335) * CFrame.Angles(0, 0, math.rad(90))

local bossLavaRing = createPart(room5, "Outer_Lava_Ring", Vector3.new(98, 2, 98), CFrame.new(baseX, baseY - 1.5, 335), Color3.fromRGB(255, 80, 10), Enum.Material.Neon)
bossLavaRing.Shape = Enum.PartType.Cylinder
bossLavaRing.CFrame = CFrame.new(baseX, baseY - 1.5, 335) * CFrame.Angles(0, 0, math.rad(90))

-- 3 AoE Telegraph Visual Rings
local aoeRing1 = createPart(room5, "AoE_Phase1_Ring", Vector3.new(65, 0.4, 65), CFrame.new(baseX, baseY + 2.1, 335), Color3.fromRGB(255, 140, 20), Enum.Material.Neon)
aoeRing1.Shape = Enum.PartType.Cylinder
aoeRing1.CFrame = CFrame.new(baseX, baseY + 2.1, 335) * CFrame.Angles(0, 0, math.rad(90))
aoeRing1.Transparency = 0.75

createPart(room5, "AoE_Phase2_FissureX", Vector3.new(70, 0.4, 3), CFrame.new(baseX, baseY + 2.15, 335), Color3.fromRGB(255, 80, 15), Enum.Material.Neon)
createPart(room5, "AoE_Phase2_FissureZ", Vector3.new(3, 0.4, 70), CFrame.new(baseX, baseY + 2.15, 335), Color3.fromRGB(255, 80, 15), Enum.Material.Neon)

local aoeNova = createPart(room5, "AoE_Phase3_NovaCore", Vector3.new(35, 0.5, 35), CFrame.new(baseX, baseY + 2.2, 335), Color3.fromRGB(255, 30, 20), Enum.Material.Neon)
aoeNova.Shape = Enum.PartType.Cylinder
aoeNova.CFrame = CFrame.new(baseX, baseY + 2.2, 335) * CFrame.Angles(0, 0, math.rad(90))
aoeNova.Transparency = 0.65

createPart(room5, "Boss_Dais", Vector3.new(20, 3, 14), CFrame.new(baseX, baseY + 3, 365), Color3.fromRGB(25, 20, 22), Enum.Material.Basalt)
createPart(room5, "Throne_Back", Vector3.new(16, 12, 3), CFrame.new(baseX, baseY + 9, 372), Color3.fromRGB(20, 16, 18), Enum.Material.Basalt)

-- Deluxe Volcanic Treasure Chest
createPart(room5, "Volcanic_Chest_Base", Vector3.new(6, 4, 4), CFrame.new(baseX + 10, baseY + 4, 360), Color3.fromRGB(80, 30, 20), Enum.Material.WoodPlanks)
createPart(room5, "Chest_Gold_Trim", Vector3.new(6.4, 1.2, 4.4), CFrame.new(baseX + 10, baseY + 5.5, 360), Color3.fromRGB(255, 190, 40), Enum.Material.Metal)
local rubyLock = createPart(room5, "Chest_Ruby_Core", Vector3.new(1.4, 1.4, 1.4), CFrame.new(baseX + 10, baseY + 4.5, 358), Color3.fromRGB(255, 20, 50), Enum.Material.Neon)
rubyLock.Shape = Enum.PartType.Ball

-- Exit Portal back to Lobby Spawn
local returnPortal = Instance.new("Model")
returnPortal.Name = "Exit_Portal_To_Lobby"
createPart(returnPortal, "Frame_Left", Vector3.new(2, 14, 2), CFrame.new(baseX - 12, baseY + 9, 362), Color3.fromRGB(50, 35, 20), Enum.Material.Slate)
createPart(returnPortal, "Frame_Right", Vector3.new(2, 14, 2), CFrame.new(baseX - 6, baseY + 9, 362), Color3.fromRGB(50, 35, 20), Enum.Material.Slate)
createPart(returnPortal, "Frame_Top", Vector3.new(8, 2, 2), CFrame.new(baseX - 9, baseY + 16, 362), Color3.fromRGB(50, 35, 20), Enum.Material.Slate)
local vortex = createPart(returnPortal, "Portal_Vortex", Vector3.new(5.6, 12, 0.5), CFrame.new(baseX - 9, baseY + 9, 362), Color3.fromRGB(255, 170, 30), Enum.Material.Neon)
vortex.Transparency = 0.2

local pPrompt = Instance.new("ProximityPrompt")
pPrompt.ActionText = "Volver al Lobby"
pPrompt.ObjectText = "Portal de Retorno"
pPrompt.HoldDuration = 0.5
pPrompt.MaxActivationDistance = 14
pPrompt.Parent = vortex

returnPortal.Parent = room5
room5.Parent = dungeon

print(">>> MAZMORRA REGIÓN 2: MINAS DEL FUEGO ETERNO TOTALMENTE CONSTRUIDA (5 SALAS + 4 PUERTAS + COFRE + PORTAL) <<<")

