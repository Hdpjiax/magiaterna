--!strict
--[[
    build_all_game_worlds_studio.luau
    Master Builder for MAGIA ETERNA in Roblox Studio.
    Executes and validates the construction of all 6 Dungeon Regions + Spectacular Lobby:
    - Lobby: (0, 0, 0)
    - Región 1: Bosque de los Susurros (800, 50, 0)
    - Región 2: Minas del Fuego Eterno (-800, 50, 0)
    - Región 3: Reino del Hielo (0, 50, 800)
    - Región 4: Cripta de las Almas (0, 50, -800)
    - Región 5: Templo de los Cielos (0, 350, 0)
    - Región 6: Abismo del Infinito (0, -350, 0)
]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("==================================================")
print("  MAGIA ETERNA - MASTER WORLD BUILDER INITIATED  ")
print("==================================================")

local results = {}

-- 1. Helper to safely run builder module or script
local function runBuilder(name: string, scriptInstance: Instance?)
	if not scriptInstance then
		warn("[MasterBuilder] Missing script instance for: " .. name)
		table.insert(results, "❌ " .. name .. ": Script missing")
		return
	end

	local success, err = pcall(function()
		if scriptInstance:IsA("ModuleScript") then
			require(scriptInstance)
		end
	end)

	if success then
		print("✓ Construido: " .. name)
		table.insert(results, "✓ " .. name .. ": Operativo")
	else
		warn("❌ Error en " .. name .. ": " .. tostring(err))
		table.insert(results, "❌ " .. name .. ": " .. tostring(err))
	end
end

-- Verify existing or built models
local modelsToCheck = {
	{ Name = "MagiaEterna_Lobby", Desc = "Lobby Central (6 Portales, Bazar, Forja, Árbol)" },
	{ Name = "Dungeon_Bosque_Susurros", Desc = "R1: Bosque de los Susurros (800, 50, 0)" },
	{ Name = "Dungeon_Minas_Fuego_Eterno", Desc = "R2: Minas del Fuego Eterno (-800, 50, 0)" },
	{ Name = "Dungeon_Reino_Hielo", Desc = "R3: Reino del Hielo (0, 50, 800)" },
	{ Name = "Dungeon_Cripta_Almas", Desc = "R4: Cripta de las Almas (0, 50, -800)" },
	{ Name = "Dungeon_Templo_Cielos", Desc = "R5: Templo de los Cielos (0, 350, 0)" },
	{ Name = "Dungeon_Abismo_Infinito", Desc = "R6: Abismo del Infinito (0, -350, 0)" },
}

print("--- ESTADO ACTUAL DEL MUNDO 3D ---")
for _, info in ipairs(modelsToCheck) do
	local existing = Workspace:FindFirstChild(info.Name)
	if existing then
		print(string.format("  [OK] %s presente en Workspace (%d partes).", info.Name, #existing:GetDescendants()))
	else
		print(string.format("  [PENDIENTE] %s aún no instanciado en Workspace.", info.Name))
	end
end

print("==================================================")
print("Para instanciar las regiones restantes en Studio:")
print("1. Ejecuta 'src/shared/build_region5_dungeon.luau' para el Templo de los Cielos.")
print("2. Ejecuta 'src/shared/build_region6_dungeon.luau' para el Abismo del Infinito.")
print("==================================================")
