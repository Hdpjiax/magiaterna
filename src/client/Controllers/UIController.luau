--!strict
--[[
    UIController.luau
    Central UI modal orchestration for MAGIA ETERNA.
    Manages all 12 adaptive panels (Pets, Eggs, Collections, Staffs, Armor, Forge,
    Dungeons, Rebirth, Quests, Inventory, Shop, Settings), Escape/ButtonB close, and live re-renders.
]]

local UserInputService = game:GetService("UserInputService")
local SoundController = require(script.Parent.SoundController)
local DataController = require(script.Parent.DataController)
local HUDManager = require(script.Parent.Parent.UI.HUDManager)
local UITheme = require(script.Parent.Parent.UI.UITheme)

local Panels = script.Parent.Parent.UI:WaitForChild("Panels")
local EquipmentPanels = require(Panels:WaitForChild("EquipmentPanels") :: ModuleScript)
local PetPanels = require(Panels:WaitForChild("PetPanels") :: ModuleScript)
local WorldPanels = require(Panels:WaitForChild("WorldPanels") :: ModuleScript)
local UtilityPanels = require(Panels:WaitForChild("UtilityPanels") :: ModuleScript)

local UIController = {}
local activeModal: string? = nil
local modals: { [string]: UITheme.ModalHandle } = {}

local MENU_TITLES: { [string]: string } = {
	Pets = "Mascotas",
	Eggs = "Tienda de Huevos",
	Collections = "Colecciones e Índice",
	Staffs = "Armería de Bastones",
	Armor = "Armaduras",
	Forge = "Forja Real",
	Dungeons = "Portal de Mazmorras",
	Rebirth = "Torre de Rebirth",
	Quests = "Misiones y Logros",
	Inventory = "Mochila y Mercado",
	Shop = "Tienda Premium",
	Settings = "Ajustes",
}

local function renderModalContent(modalName: string)
	local handle = modals[modalName]
	if not handle then return end
	local profile = DataController.GetProfile()

	if modalName == "Staffs" then
		EquipmentPanels.RenderStaffs(handle, profile)
	elseif modalName == "Armor" then
		EquipmentPanels.RenderArmor(handle, profile)
	elseif modalName == "Forge" then
		EquipmentPanels.RenderForge(handle, profile)
	elseif modalName == "Pets" then
		PetPanels.RenderPets(handle, profile)
	elseif modalName == "Eggs" then
		PetPanels.RenderEggs(handle, profile)
	elseif modalName == "Collections" then
		PetPanels.RenderCollections(handle, profile)
	elseif modalName == "Dungeons" then
		WorldPanels.RenderDungeons(handle, profile)
	elseif modalName == "Rebirth" then
		WorldPanels.RenderRebirth(handle, profile)
	elseif modalName == "Quests" then
		WorldPanels.RenderQuests(handle, profile)
	elseif modalName == "Inventory" then
		UtilityPanels.RenderInventory(handle, profile)
	elseif modalName == "Shop" then
		UtilityPanels.RenderShop(handle, profile)
	elseif modalName == "Settings" then
		UtilityPanels.RenderSettings(handle, profile)
	end
end

function UIController.OpenModal(modalName: string)
	if activeModal == modalName then
		UIController.CloseModal()
		return
	end

	if activeModal and modals[activeModal] then
		modals[activeModal].SetVisible(false)
	end

	local handle = modals[modalName]
	if not handle then
		warn("[UIController] Unknown modal: " .. tostring(modalName))
		return
	end

	activeModal = modalName
	renderModalContent(modalName)
	handle.SetVisible(true)
	SoundController.PlaySFX("UI_OpenModal")
end

function UIController.CloseModal()
	if not activeModal then return end
	local handle = modals[activeModal]
	if handle then
		handle.SetVisible(false)
	end
	activeModal = nil
	SoundController.PlaySFX("UI_CloseModal")
end

function UIController.GetActiveModal(): string?
	return activeModal
end

function UIController.Init()
	HUDManager.BuildHUD(function(menuName: string)
		UIController.OpenModal(menuName)
	end)

	local gui = HUDManager.GetScreenGui()
	if gui then
		for key, title in pairs(MENU_TITLES) do
			modals[key] = UITheme.CreateModalWindow(gui, title, function()
				UIController.CloseModal()
			end)
		end
	end

	-- Re-render currently open modal whenever player data updates
	DataController.OnProfileUpdated:Connect(function()
		if activeModal then
			renderModalContent(activeModal)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
			if activeModal then
				UIController.CloseModal()
			end
		end
	end)

	print("[UIController] Initialized successfully with all 12 adaptive modals.")
end

return UIController
