--!strict
--[[
    ForgeService.luau
    Blacksmith Crafting and Forge Service for MAGIA ETERNA.
    Enforces server-authoritative validation for recipes, material consumption, and gold costs.
    Guarantees anti-duplication through atomic profile transactions.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local RecipeConfig = require(Shared:WaitForChild("Config"):WaitForChild("RecipeConfig") :: ModuleScript)
local StaffConfig = require(Shared:WaitForChild("Config"):WaitForChild("StaffConfig") :: ModuleScript)
local ArmorConfig = require(Shared:WaitForChild("Config"):WaitForChild("ArmorConfig") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local Services = script.Parent
local PlayerDataService = require(Services:WaitForChild("PlayerDataService") :: ModuleScript)
local RemoteGuard = require(Services:WaitForChild("RemoteGuard") :: ModuleScript)

local ForgeService = {}

-- Attempts to forge an item (Staff or Armor) for the player
function ForgeService.CraftItem(player: Player, targetId: string): (boolean, string)
	if not RemoteGuard.Validate(player, "ForgeItem") then
		return false, "Demasiadas solicitudes de forja. Espera un momento."
	end
	
	local recipe = RecipeConfig.GetRecipe(targetId)
	if not recipe then
		return false, "La receta solicitada no existe."
	end
	
	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return false, "Perfil del jugador no disponible."
	end
	
	-- 1. Check Rebirth Requirement
	if profile.Rebirths < recipe.RequiredRebirth then
		return false, string.format("Requiere Renacimiento nivel %d.", recipe.RequiredRebirth)
	end
	
	-- 2. Check Gold Coins
	if profile.Coins < recipe.RequiredCoins then
		return false, string.format("Oro insuficiente para forjar. Necesitas %d monedas.", recipe.RequiredCoins)
	end
	
	-- 3. Check Materials
	for matName, requiredAmount in pairs(recipe.RequiredMaterials) do
		local currentAmount = profile.Materials[matName] or 0
		if currentAmount < requiredAmount then
			return false, string.format("Materiales insuficientes: %s (%d/%d).", matName, currentAmount, requiredAmount)
		end
	end
	
	-- 4. Check Duplicate for Staves (Staves are unique collectibles)
	if recipe.Category == "Staff" and profile.OwnedStaffs[targetId] then
		return false, "Ya has forjado y posees este bastón."
	end
	
	-- 5. Atomic Transaction: Deduct costs and grant item
	local updateSuccess = PlayerDataService.UpdateProfile(player, function(data)
		-- Deduct coins
		data.Coins -= recipe.RequiredCoins
		
		-- Deduct materials
		for matName, requiredAmount in pairs(recipe.RequiredMaterials) do
			data.Materials[matName] = (data.Materials[matName] or 0) - requiredAmount
		end
		
		-- Grant item
		if recipe.Category == "Staff" then
			data.OwnedStaffs[targetId] = true
		elseif recipe.Category == "Armor" then
			data.ArmorInventory[targetId] = (data.ArmorInventory[targetId] or 0) + 1
		end
	end)
	
	if updateSuccess then
		-- Fire notification
		local notifEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.NotificationPrompt)
		if notifEvent then
			notifEvent:FireClient(player, "¡Forja Exitosa!", string.format("Has forjado con éxito: %s.", recipe.Name), "Success")
		end
		print(string.format("[ForgeService] %s forged %s (%s).", player.Name, recipe.Name, targetId))
		return true, "Objeto forjado con éxito."
	else
		return false, "Error interno durante la transacción de forja."
	end
end

-- Initializes ForgeService and hooks remote events
function ForgeService.Init()
	local forgeStaffEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestForgeStaff)
	forgeStaffEvent.OnServerEvent:Connect(function(player: Player, targetId: any)
		if typeof(targetId) == "string" then
			ForgeService.CraftItem(player, targetId)
		end
	end)
	
	print("[ForgeService] Initialized and connected to RequestForgeStaff.")
end

return table.freeze(ForgeService)
