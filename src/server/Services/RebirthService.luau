--!strict
--[[
    RebirthService.luau
    Rebirth progression manager for MAGIA ETERNA.
    Validates magic requirements, resets magic, increments rebirths, grants shards,
    and applies permanent milestone bonuses (such as extra pet slots).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local RebirthConfig = require(Shared:WaitForChild("Config"):WaitForChild("RebirthConfig") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local Services = script.Parent
local PlayerDataService = require(Services:WaitForChild("PlayerDataService") :: ModuleScript)
local RemoteGuard = require(Services:WaitForChild("RemoteGuard") :: ModuleScript)

local RebirthService = {}

-- Validates and executes a rebirth for the player
function RebirthService.ExecuteRebirth(player: Player): (boolean, string)
	if not RemoteGuard.Validate(player, "Rebirth") then
		return false, "Demasiadas solicitudes. Espera un momento."
	end
	
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return false, "Error al cargar datos del jugador."
	end
	
	local currentRebirths = profile.Rebirths
	local magicRequired = RebirthConfig.GetCost(currentRebirths)
	
	if profile.Magic < magicRequired then
		return false, string.format("Magia insuficiente. Necesitas %s de poder mágico.", tostring(magicRequired))
	end
	
	-- Atomic transaction: Reset magic, increment rebirths, grant rewards
	local newRebirthLevel = currentRebirths + 1
	local milestone = RebirthConfig.GetMilestone(newRebirthLevel)
	local shardsGained = milestone and milestone.BonusShards or 1
	
	local success = PlayerDataService.UpdateProfile(player, function(data)
		data.Magic = 0 -- Reset current magic
		data.Rebirths = newRebirthLevel
		data.RebirthShards += shardsGained
		
		-- Apply milestone pet slots if unlocked
		if milestone and milestone.BonusPetSlots then
			data.MaxEquippedPets += milestone.BonusPetSlots
		end
	end)
	
	if success then
		-- Notify client of successful rebirth
		local notifEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.NotificationPrompt)
		if notifEvent then
			local msg = string.format("¡Has renacido con éxito! Nivel de Renacimiento: %d. Multiplicador: %.2fx",
				newRebirthLevel, RebirthConfig.GetMultiplier(newRebirthLevel))
			notifEvent:FireClient(player, "Renacimiento", msg, "Success")
		end
		print(string.format("[RebirthService] %s performed Rebirth to Level %d.", player.Name, newRebirthLevel))
		return true, "¡Renacimiento completado con éxito!"
	else
		return false, "Error interno durante la transacción de renacimiento."
	end
end

-- Initializes RebirthService and connects RemoteEvent
function RebirthService.Init()
	local rebirthEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestRebirth)
	rebirthEvent.OnServerEvent:Connect(function(player: Player)
		RebirthService.ExecuteRebirth(player)
	end)
	
	print("[RebirthService] Initialized and connected to RequestRebirth.")
end

return table.freeze(RebirthService)
