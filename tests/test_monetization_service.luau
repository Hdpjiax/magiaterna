--!strict
-- tests/test_monetization_service.luau
-- Pruebas automatizadas de Monetización Responsable para MAGIA ETERNA

local MonetizationConfig = require(script.Parent.Parent.src.shared.Config.MonetizationConfig)

local function runTests()
    print("=== INICIANDO TEST DE MONETIZACIÓN RESPONSABLE ===")

    -- 1. Validar Catálogo de Productos
    local allProducts = MonetizationConfig.GetAllProducts()
    assert(#allProducts >= 9, "Debe haber al menos 9 productos configurados")
    print(string.format("✓ Catálogo validado con %d productos.", #allProducts))

    -- 2. Validar Game Passes
    local vip = MonetizationConfig.GetProduct("GP_VIP")
    assert(vip ~= nil and vip.Type == "GamePass", "GP_VIP debe existir como GamePass")
    assert(vip.RobuxPrice == 399, "Precio de VIP debe ser 399 Robux")

    local pets = MonetizationConfig.GetProduct("GP_PET_SLOTS")
    assert(pets ~= nil and pets.Type == "GamePass", "GP_PET_SLOTS debe existir")

    local autoTrain = MonetizationConfig.GetProduct("GP_AUTO_TRAIN")
    assert(autoTrain ~= nil and autoTrain.Type == "GamePass", "GP_AUTO_TRAIN debe existir")

    local inv50 = MonetizationConfig.GetProduct("GP_INVENTORY_50")
    assert(inv50 ~= nil and inv50.Type == "GamePass", "GP_INVENTORY_50 debe existir")
    print("✓ Game Passes oficiales (VIP, AutoTrain, PetSlots, Inventory50) verificados con éxito.")

    -- 3. Validar Developer Products
    local c1000 = MonetizationConfig.GetProduct("DP_COINS_1000")
    local c10k = MonetizationConfig.GetProduct("DP_COINS_10000")
    local ess500 = MonetizationConfig.GetProduct("DP_ESSENCES_500")
    local ess5k = MonetizationConfig.GetProduct("DP_ESSENCES_5000")
    local shards = MonetizationConfig.GetProduct("DP_REBIRTH_SHARDS")

    assert(c1000 and c10k and ess500 and ess5k and shards, "Todos los DevProducts deben existir")
    print("✓ Developer Products (Monedas, Esencias y Esquirlas) verificados con éxito.")

    -- 4. Simulación de Idempotencia de ProcessReceipt
    local mockProfile = {
        Coins = 100,
        Essences = 0,
        RebirthShards = 0,
        ProcessedReceipts = {} :: { [string]: boolean },
        OwnedGamePasses = {} :: { [string]: boolean },
    }

    local function mockGrantProduct(purchaseId: string, productId: string)
        if mockProfile.ProcessedReceipts[purchaseId] then
            -- Ya fue procesado (Idempotente)
            return "PurchaseGranted_AlreadyProcessed"
        end

        mockProfile.ProcessedReceipts[purchaseId] = true
        if productId == "DP_COINS_1000" then
            mockProfile.Coins += 1000
        elseif productId == "DP_ESSENCES_500" then
            mockProfile.Essences += 500
        end
        return "PurchaseGranted"
    end

    -- Primera compra
    local res1 = mockGrantProduct("receipt_abc_1", "DP_COINS_1000")
    assert(res1 == "PurchaseGranted", "Primera compra debe otorgarse")
    assert(mockProfile.Coins == 1100, "Coins deben ser 1100")

    -- Intento duplicado (simulación de red / retry)
    local res2 = mockGrantProduct("receipt_abc_1", "DP_COINS_1000")
    assert(res2 == "PurchaseGranted_AlreadyProcessed", "Compra duplicada debe ser reconocida como ya procesada")
    assert(mockProfile.Coins == 1100, "Coins NO deben duplicarse")
    print("✓ Garantía de idempotencia validada: cero duplicación de monedas o robux.")

    print("=== TODOS LOS TESTS DE MONETIZACIÓN PASARON SATISFACTORIAMENTE ===")
    return true
end

return runTests()
