--!strict
--[[
    MagicController.luau
    Client-side controller for training magic and executing rebirths in MAGIA ETERNA.
    Features client-side debounce to optimize network traffic and connects UI triggers.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local MagicController = {}
local lastClickTime = 0
local CLICK_COOLDOWN = 0.065 -- Approx 15 clicks/sec max from client

-- Triggers a training pulse from client
function MagicController.Train()
	local now = os.clock()
	if now - lastClickTime < CLICK_COOLDOWN then
		return -- Cooldown active, throttle locally
	end
	lastClickTime = now
	
	local trainEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestTrainMagic)
	if trainEvent then
		trainEvent:FireServer()
	end
end

-- Requests a rebirth from client
function MagicController.RequestRebirth()
	local rebirthEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestRebirth)
	if rebirthEvent then
		rebirthEvent:FireServer()
	end
end

-- Initializes notification listener
function MagicController.Init()
	local notifEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.NotificationPrompt)
	if notifEvent then
		notifEvent.OnClientEvent:Connect(function(title: string, message: string, alertType: string)
			print(string.format("[NOTIFICACIÓN - %s]: %s (%s)", title, message, alertType))
		end)
	end
	
	print("[MagicController] Initialized successfully.")
end

return table.freeze(MagicController)
