--!strict
--[[
    UIController.luau
    Central UI modal orchestration for MAGIA ETERNA.
    Manages active panels (Pets, Forge, Dungeons, Quests, Settings), modal stacking,
    Gamepad B/Escape key closes, and focus navigation.
]]

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local SoundController = require(script.Parent.SoundController)
local HUDManager = require(script.Parent.Parent.UI.HUDManager)

local UIController = {}
local activeModal: string? = nil

-- Opens a specific full-screen or modal panel
function UIController.OpenModal(modalName: string)
	if activeModal == modalName then
		UIController.CloseModal()
		return
	end

	activeModal = modalName
	SoundController.PlaySFX("UI_OpenModal")
	print(string.format("[UIController] Modal opened: %s", modalName))
	-- Future: Toggle visible frame for modalName
end

-- Closes current active modal
function UIController.CloseModal()
	if not activeModal then return end
	local closed = activeModal
	activeModal = nil
	SoundController.PlaySFX("UI_CloseModal")
	print(string.format("[UIController] Modal closed: %s", closed))
end

-- Returns currently active modal
function UIController.GetActiveModal(): string?
	return activeModal
end

function UIController.Init()
	-- Build main adaptive HUD
	HUDManager.BuildHUD(function(menuName: string)
		UIController.OpenModal(menuName)
	end)

	-- Input binding: Escape or Gamepad ButtonB to close active modal
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
			if activeModal then
				UIController.CloseModal()
			end
		end
	end)

	print("[UIController] Initialized successfully.")
end

return UIController
