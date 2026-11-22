--!strict
--[[
    MonetizationService.luau
    Server-authoritative Game Passes and Developer Products handler for MAGIA ETERNA.
    Implements idempotent ProcessReceipt and server-side ownership checks.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("Config"):WaitForChild("GameConfig") :: ModuleScript)
local MonetizationConfig = require(Shared:WaitForChild("Config"):WaitForChild("MonetizationConfig") :: ModuleScript)
local TypeValidators = require(Shared:WaitForChild("Modules"):WaitForChild("TypeValidators") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local Services = script.Parent
local PlayerDataService = require(Services:WaitForChild("PlayerDataService") :: ModuleScript)
local RemoteGuard = require(Services:WaitForChild("RemoteGuard") :: ModuleScript)

local MonetizationService = {}

-- Checks whether a player owns a Game Pass (cached in profile + live MarketplaceService check)
function MonetizationService.HasGamePass(player: Player, passIdKey: string): boolean
	local profile = PlayerDataService.GetProfile(player)
	if profile and profile.OwnedGamePasses and profile.OwnedGamePasses[passIdKey] then
		return true
	end

	local product = MonetizationConfig.GetProduct(passIdKey)
	if not product or product.Type ~= "GamePass" or product.AssetId <= 0 then
		return false
	end

	local success, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, product.AssetId)
	end)

	if success and owns then
		PlayerDataService.UpdateProfile(player, function(data)
			data.OwnedGamePasses = data.OwnedGamePasses or {}
			data.OwnedGamePasses[passIdKey] = true
			if passIdKey == "GP_PET_SLOTS" and data.MaxEquippedPets < 5 then
				data.MaxEquippedPets += 2
			end
		end)
		return true
	end

	return false
end

local function grantDevProduct(player: Player, productIdKey: string): boolean
	return PlayerDataService.UpdateProfile(player, function(data)
		if productIdKey == "DP_WELCOME_PACK" then
			data.Coins += 2500
			data.Essences = (data.Essences or 0) + 25
			data.RebirthShards += 1
		elseif productIdKey == "DP_LUCK_BOOST" then
			-- Boost timer can be tracked; grant immediate bonus essence as fallback
			data.Essences = (data.Essences or 0) + 15
		elseif productIdKey == "DP_COINS_BOOST" then
			data.Coins += 1000
		elseif productIdKey == "DP_DUNGEON_REVIVE" then
			-- Handled during active dungeon session if applicable
			data.Essences = (data.Essences or 0) + 5
		end
	end)
end

-- Idempotent ProcessReceipt callback
local function processReceipt(receiptInfo: any): Enum.ProductPurchaseDecision
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local profile = PlayerDataService.GetProfile(player)
	if not profile then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local receiptKey = tostring(receiptInfo.PurchaseId)
	if profile.ProcessedReceipts and profile.ProcessedReceipts[receiptKey] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local product = MonetizationConfig.GetByAssetId(receiptInfo.ProductId)
	if not product then
		warn("[MonetizationService] Unknown ProductId in ProcessReceipt: " .. tostring(receiptInfo.ProductId))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Record receipt BEFORE granting benefits to prevent duplication
	local recorded = PlayerDataService.UpdateProfile(player, function(data)
		data.ProcessedReceipts = data.ProcessedReceipts or {}
		data.ProcessedReceipts[receiptKey] = true
	end)
	if not recorded then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local granted = grantDevProduct(player, product.Id)
	if granted then
		local ev = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.PurchaseCompleted)
		ev:FireClient(player, { ProductId = product.Id, Name = product.Name })
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

function MonetizationService.Init()
	MarketplaceService.ProcessReceipt = processReceipt

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
		if not wasPurchased then return end
		local product = MonetizationConfig.GetByAssetId(gamePassId)
		if product and product.Type == "GamePass" then
			PlayerDataService.UpdateProfile(player, function(data)
				data.OwnedGamePasses = data.OwnedGamePasses or {}
				data.OwnedGamePasses[product.Id] = true
				if product.Id == "GP_PET_SLOTS" then
					data.MaxEquippedPets += 2
				end
			end)
			local ev = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.PurchaseCompleted)
			ev:FireClient(player, { ProductId = product.Id, Name = product.Name })
		end
	end)

	RemoteGuard.ProtectEvent(
		NetworkEndpoints.Events.RequestPurchaseProduct,
		"EquipItem",
		GameConfig.RATE_LIMITS.EquipItem,
		function(player: Player, productIdKey: any)
			if not TypeValidators.IsValidString(productIdKey, 2, 60) then return end
			local product = MonetizationConfig.GetProduct(productIdKey)
			local notify = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.NotificationPrompt)
			if not product then
				notify:FireClient(player, { Type = "Error", Message = "Producto no encontrado." })
				return
			end
			if product.AssetId <= 0 then
				notify:FireClient(player, { Type = "Info", Message = "Configura el AssetId en MonetizationConfig antes de publicar." })
				return
			end
			if product.Type == "GamePass" then
				MarketplaceService:PromptGamePassPurchase(player, product.AssetId)
			else
				MarketplaceService:PromptProductPurchase(player, product.AssetId)
			end
		end
	)

	print("[MonetizationService] Initialized successfully.")
end

return table.freeze(MonetizationService)
