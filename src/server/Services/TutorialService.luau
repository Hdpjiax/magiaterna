--!strict
--[[
    TutorialService.luau
    Servidor autoritativo para el Tutorial de Onboarding de MAGIA ETERNA.
    Controla la progresión de los 6 pasos del bucle central y otorga las recompensas finales.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local TutorialConfig = require(Shared:WaitForChild("Config"):WaitForChild("TutorialConfig") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local Services = script.Parent
local PlayerDataService = require(Services:WaitForChild("PlayerDataService") :: ModuleScript)
local EconomyService = require(Services:WaitForChild("EconomyService") :: ModuleScript)

local TutorialService = {}

-- Comprueba y avanza el paso del tutorial si coincide con la acción realizada
function TutorialService.RecordAction(player: Player, actionKey: string, amount: number?)
	local profile = PlayerDataService.GetPlayerProfile(player)
	if not profile or profile.TutorialCompleted then return end

	local currentStepNum = profile.TutorialStep or 1
	local stepDef = TutorialConfig.GetStep(currentStepNum)
	if not stepDef then return end

	local shouldAdvance = false

	if currentStepNum == 1 and actionKey == "TrainMagic" then
		if profile.Magic >= stepDef.TargetAmount then
			shouldAdvance = true
		end
	elseif currentStepNum == 2 and actionKey == "BuyEgg" then
		shouldAdvance = true
	elseif currentStepNum == 3 and actionKey == "EquipPet" then
		shouldAdvance = true
	elseif currentStepNum == 4 and actionKey == "EnterDungeon" then
		shouldAdvance = true
	elseif currentStepNum == 5 and actionKey == "ClearRoom1" then
		shouldAdvance = true
	elseif currentStepNum == 6 and actionKey == "ForgeStaff" then
		shouldAdvance = true
	end

	if shouldAdvance then
		if currentStepNum < TutorialConfig.TOTAL_STEPS then
			local nextStep = currentStepNum + 1
			PlayerDataService.UpdateProfile(player, function(data)
				data.TutorialStep = nextStep
			end)

			local advanceEvt = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.TutorialStepAdvanced)
			if advanceEvt then
				advanceEvt:FireClient(player, nextStep)
			end
			print(string.format("[TutorialService] Jugador %s avanzó al Paso %d del Tutorial.", player.Name, nextStep))
		else
			-- ¡Tutorial completado con éxito!
			PlayerDataService.UpdateProfile(player, function(data)
				data.TutorialStep = TutorialConfig.TOTAL_STEPS + 1
				data.TutorialCompleted = true
			end)

			-- Conceder recompensa de bienvenida
			local rewards = TutorialConfig.FINAL_REWARDS
			EconomyService.AddCoins(player, rewards.Coins)
			EconomyService.AddEssences(player, rewards.Essences)

			local completeEvt = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.TutorialCompleted)
			if completeEvt then
				completeEvt:FireClient(player, rewards)
			end
			print(string.format("[TutorialService] ¡Jugador %s completó el tutorial! Otorgadas %d Monedas y %d Esencias.",
				player.Name, rewards.Coins, rewards.Essences))
		end
	end
end

function TutorialService.Init()
	print("[TutorialService] Inicializado correctamente.")
end

return TutorialService
