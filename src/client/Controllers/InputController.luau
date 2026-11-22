--!strict
--[[
    InputController.luau
    Universal Cross-Platform Input Controller for MAGIA ETERNA.
    Seamlessly supports PC (Keyboard & Mouse), Mobile / Tablet (Touch UI),
    and Console (Xbox / PlayStation Gamepads) with auto-targeting and dynamic glyph prompts.
]]

local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer

local InputController = {}

export type InputMode = "Keyboard" | "Touch" | "Gamepad"

local currentMode: InputMode = "Keyboard"
local isAutoTrainActive = false

-- Modules referenced lazily to avoid circular dependencies
local UIController = nil
local CombatController = nil
local MagicController = nil
local SoundController = nil

local MODAL_SEQUENCE = {
	"Inventory",
	"Staffs",
	"Armor",
	"Pets",
	"Eggs",
	"Forge",
	"Dungeons",
	"Quests",
	"Rebirth",
	"Shop",
	"Collections",
	"Settings",
}

local function resolveDependencies()
	if not UIController then
		UIController = require(script.Parent:WaitForChild("UIController") :: ModuleScript)
	end
	if not CombatController then
		CombatController = require(script.Parent:WaitForChild("CombatController") :: ModuleScript)
	end
	if not MagicController then
		MagicController = require(script.Parent:WaitForChild("MagicController") :: ModuleScript)
	end
	if not SoundController then
		SoundController = require(script.Parent:WaitForChild("SoundController") :: ModuleScript)
	end
end

-- Detects nearest valid enemy in workspace for Gamepad / Touch auto-aim
function InputController.FindNearestTarget(maxDistance: number?): (Model?, string?)
	local char = localPlayer.Character
	if not char then return nil, nil end
	local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not hrp then return nil, nil end

	local limit = maxDistance or 65
	local nearestEnemy: Model? = nil
	local nearestDist = limit
	local nearestId: string? = nil

	-- Search enemies inside active dungeon or workspace
	for _, desc in ipairs(Workspace:GetDescendants()) do
		if desc:IsA("Model") and desc:FindFirstChild("Humanoid") and desc:FindFirstChild("EnemyId") then
			local root = desc:FindFirstChild("HumanoidRootPart") :: BasePart?
			local humanoid = desc:FindFirstChild("Humanoid") :: Humanoid?
			if root and humanoid and humanoid.Health > 0 then
				local dist = (root.Position - hrp.Position).Magnitude
				if dist < nearestDist then
					nearestDist = dist
					nearestEnemy = desc
					local instId = desc:FindFirstChild("InstanceId") :: StringValue?
					nearestId = instId and instId.Value or desc.Name
				end
			end
		end
	end

	return nearestEnemy, nearestId
end

-- Unified Action: Cast Spell or Train
function InputController.TriggerAttackOrTrain()
	resolveDependencies()

	-- Check if player is near enemies in dungeon
	local _, enemyId = InputController.FindNearestTarget(75)
	if enemyId then
		CombatController.CastSpell(enemyId)
		SoundController.PlaySFX("UI_ButtonClick")
		return
	end

	-- Otherwise trigger Magic training
	MagicController.Train()
	SoundController.PlaySFX("SFX_MagicClick")
end

-- Cycles through menu tabs using Gamepad Bumpers (LB / RB)
function InputController.CycleTab(direction: number)
	resolveDependencies()
	local active = UIController.GetActiveModal()
	if not active then
		UIController.OpenModal(direction > 0 and MODAL_SEQUENCE[1] or MODAL_SEQUENCE[#MODAL_SEQUENCE])
		return
	end

	local currentIndex = table.find(MODAL_SEQUENCE, active) or 1
	local nextIndex = currentIndex + direction
	if nextIndex > #MODAL_SEQUENCE then
		nextIndex = 1
	elseif nextIndex < 1 then
		nextIndex = #MODAL_SEQUENCE
	end

	UIController.OpenModal(MODAL_SEQUENCE[nextIndex])
end

-- Toggles auto-train mode (especially useful for Mobile / Gamepad idle sessions)
function InputController.ToggleAutoTrain(): boolean
	isAutoTrainActive = not isAutoTrainActive
	resolveDependencies()
	SoundController.PlaySFX("UI_ButtonClick")

	if isAutoTrainActive then
		task.spawn(function()
			while isAutoTrainActive do
				InputController.TriggerAttackOrTrain()
				task.wait(0.25)
			end
		end)
	end

	return isAutoTrainActive
end

function InputController.IsAutoTrainActive(): boolean
	return isAutoTrainActive
end

function InputController.GetInputMode(): InputMode
	return currentMode
end

local onModeChangedCallbacks: { (newMode: InputMode) -> () } = {}
function InputController.OnInputModeChanged(callback: (newMode: InputMode) -> ())
	table.insert(onModeChangedCallbacks, callback)
end

local function setInputMode(newMode: InputMode)
	if currentMode == newMode then return end
	currentMode = newMode
	print(string.format("[InputController] Input mode switched to: %s", newMode))
	for _, cb in ipairs(onModeChangedCallbacks) do
		cb(newMode)
	end
end

function InputController.Init()
	resolveDependencies()

	-- 1. Initial Device Detection
	if UserInputService.GamepadEnabled and UserInputService:GetGamepadConnected(Enum.UserInputType.Gamepad1) then
		setInputMode("Gamepad")
	elseif UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		setInputMode("Touch")
	else
		setInputMode("Keyboard")
	end

	-- 2. Dynamic Input Type Listener
	UserInputService.LastInputTypeChanged:Connect(function(lastType)
		if lastType == Enum.UserInputType.Gamepad1 or lastType == Enum.UserInputType.Gamepad2 then
			setInputMode("Gamepad")
		elseif lastType == Enum.UserInputType.Touch then
			setInputMode("Touch")
		elseif lastType == Enum.UserInputType.Keyboard or lastType == Enum.UserInputType.MouseButton1 or lastType == Enum.UserInputType.MouseButton2 then
			setInputMode("Keyboard")
		end
	end)

	UserInputService.GamepadConnected:Connect(function(gamepad)
		if gamepad == Enum.UserInputType.Gamepad1 then
			setInputMode("Gamepad")
		end
	end)

	UserInputService.GamepadDisconnected:Connect(function(gamepad)
		if gamepad == Enum.UserInputType.Gamepad1 then
			if UserInputService.TouchEnabled then
				setInputMode("Touch")
			else
				setInputMode("Keyboard")
			end
		end
	end)

	-- 3. Gamepad & Keyboard Bindings via UserInputService
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		local code = input.KeyCode

		-- GAMEPAD CONTROLS
		if input.UserInputType == Enum.UserInputType.Gamepad1 then
			-- [ButtonR2] or [ButtonX]: Attack / Train
			if code == Enum.KeyCode.ButtonR2 or code == Enum.KeyCode.ButtonX then
				InputController.TriggerAttackOrTrain()

			-- [ButtonB]: Close Modal
			elseif code == Enum.KeyCode.ButtonB then
				if UIController.GetActiveModal() then
					UIController.CloseModal()
				end

			-- [ButtonY]: Toggle Backpack / Inventory
			elseif code == Enum.KeyCode.ButtonY then
				UIController.OpenModal("Inventory")

			-- [ButtonL1] / [ButtonR1]: Cycle Tabs
			elseif code == Enum.KeyCode.ButtonL1 then
				InputController.CycleTab(-1)
			elseif code == Enum.KeyCode.ButtonR1 then
				InputController.CycleTab(1)

			-- D-PAD SHORTCUTS
			elseif code == Enum.KeyCode.DPadUp then
				UIController.OpenModal("Dungeons")
			elseif code == Enum.KeyCode.DPadDown then
				UIController.OpenModal("Shop")
			elseif code == Enum.KeyCode.DPadLeft then
				UIController.OpenModal("Pets")
			elseif code == Enum.KeyCode.DPadRight then
				UIController.OpenModal("Quests")

			-- [ButtonSelect]: Toggle Auto-Train
			elseif code == Enum.KeyCode.ButtonSelect then
				InputController.ToggleAutoTrain()
			end

		-- KEYBOARD SHORTCUTS
		elseif input.UserInputType == Enum.UserInputType.Keyboard then
			if code == Enum.KeyCode.B then
				UIController.OpenModal("Inventory")
			elseif code == Enum.KeyCode.P then
				UIController.OpenModal("Shop")
			elseif code == Enum.KeyCode.Q then
				UIController.OpenModal("Quests")
			elseif code == Enum.KeyCode.M then
				UIController.OpenModal("Pets")
			elseif code == Enum.KeyCode.K then
				UIController.OpenModal("Staffs")
			elseif code == Enum.KeyCode.F then
				UIController.OpenModal("Forge")
			elseif code == Enum.KeyCode.R then
				UIController.OpenModal("Rebirth")
			elseif code == Enum.KeyCode.G then
				UIController.OpenModal("Dungeons")
			elseif code == Enum.KeyCode.O then
				UIController.OpenModal("Settings")
			elseif code == Enum.KeyCode.T then
				InputController.ToggleAutoTrain()
			end
		end
	end)

	print("[InputController] Cross-platform controls initialized (Gamepad, Touch, Keyboard).")
end

return InputController
