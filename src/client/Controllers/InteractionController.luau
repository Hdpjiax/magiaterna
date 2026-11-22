--!strict
--[[
    InteractionController.luau
    Connects in-world 3D Lobby objects (ProximityPrompts and ClickDetectors)
    directly to client controllers and server network requests for MAGIA ETERNA.
]]

local ProximityPromptService = game:GetService("ProximityPromptService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkEndpoints = require(ReplicatedStorage.Source.shared.Network.NetworkEndpoints)
local UIController = require(script.Parent.UIController)
local MagicController = require(script.Parent.MagicController)
local CombatController = require(script.Parent.CombatController)
local SoundController = require(script.Parent.SoundController)

local InteractionController = {}

function InteractionController.Init()
	-- Listen for any ProximityPrompt triggered in the game world
	ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt, player: Player)
		if player ~= Players.LocalPlayer then return end

		local parent = prompt.Parent
		if not parent then return end

		local objText = prompt.ObjectText
		local actText = prompt.ActionText

		SoundController.PlaySFX("UI_ButtonClick")

		-- 1. Training Orb
		if objText == "Orbe de Entrenamiento" or parent.Name == "Training_Magic_Orb" then
			MagicController.Train()
			SoundController.PlaySFX("SFX_MagicClick")

		-- 2. Blacksmith Forge
		elseif objText == "Yunque Arcano" or parent.Name == "Steel_Anvil" then
			UIController.OpenModal("Forge")

		-- 3. Egg & Pet Shop
		elseif objText == "Tienda de Huevos" or parent.Name == "Display_Egg" then
			UIController.OpenModal("Pets")

		-- 4. Quest Board & Reward Chest
		elseif objText == "Tablón de Misiones" or objText == "Cofre Mágico" then
			UIController.OpenModal("Quests")

		-- 5. Rebirth Altar
		elseif objText == "Altar del Renacimiento" or parent.Name == "Rebirth_Spire" then
			local rebEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestRebirth)
			rebEvent:FireServer()

		-- 6. Dungeon Regional Portals
		elseif string.find(objText, "Bosque") or string.find(objText, "Minas") or string.find(objText, "Hielo")
			or string.find(objText, "Almas") or string.find(objText, "Cielos") or string.find(objText, "Abismo") then
			-- Open Dungeons menu or enter Difficulty 1
			UIController.OpenModal("Dungeons")
		end
	end)

	-- Also hook up direct ClickDetector on the Training Magic Orb for PC auto-clickers / rapid training
	task.defer(function()
		local lobby = Workspace:WaitForChild("MagiaEterna_Lobby", 10)
		if lobby then
			local trainingFolder = lobby:WaitForChild("Training_Grounds", 5)
			if trainingFolder then
				local magicOrb = trainingFolder:WaitForChild("Training_Magic_Orb", 5)
				if magicOrb then
					local clickDetector = magicOrb:FindFirstChildOfClass("ClickDetector")
					if clickDetector then
						clickDetector.MouseClick:Connect(function(player)
							if player == Players.LocalPlayer then
								MagicController.Train()
								SoundController.PlaySFX("SFX_MagicClick")
							end
						end)
					end
				end
			end
		end
	end)

	print("[InteractionController] Lobby world interactions wired successfully.")
end

return InteractionController
