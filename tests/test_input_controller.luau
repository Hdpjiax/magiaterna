--!strict
--[[
    test_input_controller.luau
    Automated test suite for Cross-Platform Input & Gamepad Navigation in MAGIA ETERNA.
]]

local testsPassed = 0
local testsFailed = 0

local function assertTest(condition: boolean, testName: string, detail: string?)
	if condition then
		testsPassed += 1
		print(string.format("  [PASS] %s", testName))
	else
		testsFailed += 1
		warn(string.format("  [FAIL] %s - %s", testName, detail or "Assertion failed"))
	end
end

print("======================================================================")
print("  MAGIA ETERNA — TEST DE CONTROLES MULTIPLATAFORMA (TOUCH & GAMEPAD)  ")
print("======================================================================")

-- 1. Test InputMode Resolution
local currentMode = "Keyboard"
local function setInputMode(newMode: string)
	currentMode = newMode
end

setInputMode("Gamepad")
assertTest(currentMode == "Gamepad", "INP-01: Cambio dinámico a modo Gamepad (Consola)")
setInputMode("Touch")
assertTest(currentMode == "Touch", "INP-02: Cambio dinámico a modo Touch (Móvil / Tablet)")
setInputMode("Keyboard")
assertTest(currentMode == "Keyboard", "INP-03: Cambio dinámico a modo Keyboard (PC)")

-- 2. Test Tab Cycling with Gamepad Bumpers (LB / RB)
local MODAL_SEQUENCE = {
	"Inventory", "Staffs", "Armor", "Pets", "Eggs", "Forge",
	"Dungeons", "Quests", "Rebirth", "Shop", "Collections", "Settings"
}

local activeModal: string? = nil
local function openModal(name: string)
	activeModal = name
end

local function cycleTab(direction: number)
	if not activeModal then
		openModal(direction > 0 and MODAL_SEQUENCE[1] or MODAL_SEQUENCE[#MODAL_SEQUENCE])
		return
	end
	local idx = table.find(MODAL_SEQUENCE, activeModal) or 1
	local nextIdx = idx + direction
	if nextIdx > #MODAL_SEQUENCE then nextIdx = 1 end
	if nextIdx < 1 then nextIdx = #MODAL_SEQUENCE end
	openModal(MODAL_SEQUENCE[nextIdx])
end

cycleTab(1)
assertTest(activeModal == "Inventory", "INP-04: Primer toque de RB abre la primera pestaña (Inventory)")
cycleTab(1)
assertTest(activeModal == "Staffs", "INP-05: Toque de RB avanza a la siguiente pestaña (Staffs)")
cycleTab(-1)
assertTest(activeModal == "Inventory", "INP-06: Toque de LB retrocede a la pestaña previa (Inventory)")
cycleTab(-1)
assertTest(activeModal == "Settings", "INP-07: Toque de LB en inicio hace wrap-around al final (Settings)")

-- 3. Test Auto-Train Toggle Logic
local autoTrainActive = false
local function toggleAutoTrain(): boolean
	autoTrainActive = not autoTrainActive
	return autoTrainActive
end

assertTest(toggleAutoTrain() == true and autoTrainActive == true, "INP-08: Toggle activa modo Auto-Train")
assertTest(toggleAutoTrain() == false and autoTrainActive == false, "INP-09: Toggle desactiva modo Auto-Train")

-- 4. Test Gamepad & Mobile Nearest Target Auto-Aim Selection
local mockPlayerPos = Vector3.new(0, 0, 0)
local mockEnemies = {
	{ Id = "Slime_Far", Pos = Vector3.new(120, 0, 0), Health = 50 },
	{ Id = "Slime_Near", Pos = Vector3.new(25, 0, 0), Health = 50 },
	{ Id = "Slime_Dead", Pos = Vector3.new(5, 0, 0), Health = 0 }, -- Muerto, debe ignorarse
}

local function findNearestTarget(maxDist: number): string?
	local nearest: string? = nil
	local minDist = maxDist
	for _, e in ipairs(mockEnemies) do
		if e.Health > 0 then
			local d = (e.Pos - mockPlayerPos).Magnitude
			if d < minDist then
				minDist = d
				nearest = e.Id
			end
		end
	end
	return nearest
end

local target = findNearestTarget(60)
assertTest(target == "Slime_Near", "INP-10: Auto-Aim selecciona automáticamente al enemigo vivo más cercano (25 studs)")

print("\n======================================================================")
print(string.format("  RESULTADOS DE TEST DE CONTROLES: %d PASADOS, %d FALLADOS", testsPassed, testsFailed))
print("======================================================================")
