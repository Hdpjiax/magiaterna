--!strict
--[[
    MonetizationService.luau
    Gestor de Monetización Responsable con ProcessReceipt transaccional e idempotente para MAGIA ETERNA.
    Cumple con todas las normas de Roblox:
    - Uso de DataStore dedicado 'PurchaseHistory_v1' para registro permanente de compras.
    - Prevención estricta de pérdida de Robux y duplicación de beneficios.
    - Validación del lado del servidor de Game Passes y Developer Products.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local MonetizationConfig = require(Shared:WaitForChild("Config"):WaitForChild("MonetizationConfig") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local Services = script.Parent
local PlayerDataService = require(Services:WaitForChild("PlayerDataService") :: ModuleScript)
local EconomyService = require(Services:WaitForChild("EconomyService") :: ModuleScript)

local MonetizationService = {}

-- DataStore dedicado para compras para máxima resiliencia ante reinicios de servidor
local purchaseHistoryStore: DataStore? = nil
pcall(function()
	purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory_v1")
end)

-- Comprueba si el jugador posee un Game Pass oficial
function MonetizationService.HasGamePass(player: Player, passIdKey: string): boolean
	local profile = PlayerDataService.GetPlayerProfile(player)
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
				data.MaxEquippedPets = 5
			elseif passIdKey == "GP_INVENTORY_50" then
				data.MaxInventorySlots = (data.MaxInventorySlots or 50) + 50
			end
		end)
		return true
	end

	return false
end

-- Otorga los beneficios de un Developer Product de forma segura en servidor
local function grantDeveloperProduct(player: Player, productIdKey: string): boolean
	return PlayerDataService.UpdateProfile(player, function(data)
		if productIdKey == "DP_COINS_1000" then
			data.Coins += 1000
		elseif productIdKey == "DP_COINS_10000" then
			data.Coins += 10000
		elseif productIdKey == "DP_ESSENCES_500" then
			data.Essences = (data.Essences or 0) + 500
		elseif productIdKey == "DP_ESSENCES_5000" then
			data.Essences = (data.Essences or 0) + 5000
		elseif productIdKey == "DP_REBIRTH_SHARDS" then
			data.RebirthShards = (data.RebirthShards or 0) + 1
		else
			warn("[MonetizationService] Producto de desarrollador desconocido: " .. tostring(productIdKey))
		end
	end)
end

-- ProcessReceipt Idempotente y Transaccional
local function processReceipt(receiptInfo: any): Enum.ProductPurchaseDecision
	local userId = receiptInfo.PlayerId
	local purchaseId = tostring(receiptInfo.PurchaseId)
	local productId = receiptInfo.ProductId

	local player = Players:GetPlayerByUserId(userId)
	if not player then
		-- El jugador no está en el servidor actual; Roblox reintentará cuando se conecte
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local profile = PlayerDataService.GetPlayerProfile(player)
	if not profile then
		-- Los datos del jugador aún se están cargando
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- 1. Verificación en perfil local (Caché rápido)
	if profile.ProcessedReceipts and profile.ProcessedReceipts[purchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	-- 2. Verificación en DataStore dedicado (Persistencia global)
	if purchaseHistoryStore then
		local recordKey = string.format("receipt_%d_%s", userId, purchaseId)
		local success, isProcessed = pcall(function()
			return purchaseHistoryStore:GetAsync(recordKey)
		end)
		if success and isProcessed == true then
			-- Registrar en caché local y confirmar
			PlayerDataService.UpdateProfile(player, function(data)
				data.ProcessedReceipts = data.ProcessedReceipts or {}
				data.ProcessedReceipts[purchaseId] = true
			end)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end

	-- 3. Identificar el producto comprado
	local product = MonetizationConfig.GetByAssetId(productId)
	if not product then
		warn(string.format("[MonetizationService] ProductId desconocido en ProcessReceipt: %d (Compra: %s)", productId, purchaseId))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- 4. Guardar recibo en DataStore dedicado ANTES de otorgar beneficios (Garantía idempotente)
	if purchaseHistoryStore then
		local recordKey = string.format("receipt_%d_%s", userId, purchaseId)
		local saved, saveErr = pcall(function()
			purchaseHistoryStore:SetAsync(recordKey, true)
		end)
		if not saved then
			warn("[MonetizationService] Error al guardar recibo en DataStore: " .. tostring(saveErr))
			-- Si falla el guardado del recibo, reintentar para no perder la transacción
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end

	-- 5. Otorgar beneficios atómicamente y actualizar caché del perfil
	local granted = grantDeveloperProduct(player, product.Id)
	if granted then
		PlayerDataService.UpdateProfile(player, function(data)
			data.ProcessedReceipts = data.ProcessedReceipts or {}
			data.ProcessedReceipts[purchaseId] = true
		end)

		PlayerDataService.SyncClient(player)
		print(string.format("[MonetizationService] Compra completada con éxito: %s para %s (Recibo: %s)", product.Name, player.Name, purchaseId))
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		warn("[MonetizationService] Fallo al actualizar el perfil del jugador para la compra: " .. purchaseId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

-- Inicialización del Servicio
function MonetizationService.Init()
	MarketplaceService.ProcessReceipt = processReceipt

	-- Detección de Game Passes comprados durante la sesión
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player: Player, gamePassId: number, wasPurchased: boolean)
		if wasPurchased then
			local product = MonetizationConfig.GetByAssetId(gamePassId)
			if product and product.Type == "GamePass" then
				PlayerDataService.UpdateProfile(player, function(data)
					data.OwnedGamePasses = data.OwnedGamePasses or {}
					data.OwnedGamePasses[product.Id] = true
					if product.Id == "GP_PET_SLOTS" then
						data.MaxEquippedPets = 5
					elseif product.Id == "GP_INVENTORY_50" then
						data.MaxInventorySlots = (data.MaxInventorySlots or 50) + 50
					end
				end)
				PlayerDataService.SyncClient(player)
				print(string.format("[MonetizationService] Game Pass adquirido en sesión: %s por %s", product.Name, player.Name))
			end
		end
	end)

	print("[MonetizationService] Servicio de Monetización Responsable inicializado correctamente.")
end

return MonetizationService
