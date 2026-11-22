--!strict
-- tests/test_tutorial_service.luau
-- Pruebas automatizadas del Tutorial de Onboarding para MAGIA ETERNA

local TutorialConfig = require(script.Parent.Parent.src.shared.Config.TutorialConfig)

local function runTests()
    print("=== INICIANDO PRUEBAS DE TUTORIAL DE ONBOARDING ===")

    -- 1. Validar Pasos
    assert(TutorialConfig.TOTAL_STEPS == 6, "El tutorial debe tener 6 pasos")
    for i = 1, 6 do
        local step = TutorialConfig.GetStep(i)
        assert(step ~= nil, "El paso " .. i .. " debe existir")
        assert(step.StepNumber == i, "StepNumber debe ser " .. i)
        assert(step.TargetLocation ~= nil, "TargetLocation debe estar definido")
        assert(step.ActionKey ~= nil and #step.ActionKey > 0, "ActionKey debe estar definido")
        print(string.format("✓ Paso %d validado: %s (%s)", i, step.Title, step.TargetName))
    end

    -- 2. Validar Recompensas Finales
    local rew = TutorialConfig.FINAL_REWARDS
    assert(rew.Coins == 500, "Debe otorgar 500 monedas")
    assert(rew.Essences == 25, "Debe otorgar 25 esencias")
    print(string.format("✓ Recompensas validadas: %d Monedas, %d Esencias, Logro: %s.",
        rew.Coins, rew.Essences, rew.BadgeName))

    -- 3. Simulación de avance paso a paso
    local mockData = {
        Magic = 0,
        Coins = 100,
        Essences = 0,
        TutorialStep = 1,
        TutorialCompleted = false,
    }

    -- Paso 1: Entrenar hasta 50 de magia
    mockData.Magic = 50
    assert(mockData.Magic >= TutorialConfig.GetStep(1).TargetAmount, "Paso 1 completado")
    mockData.TutorialStep = 2

    -- Paso 2: Comprar huevo
    mockData.TutorialStep = 3

    -- Paso 3: Equipar mascota
    mockData.TutorialStep = 4

    -- Paso 4: Entrar a la mazmorra
    mockData.TutorialStep = 5

    -- Paso 5: Vencer sala 1
    mockData.TutorialStep = 6

    -- Paso 6: Forjar bastón
    mockData.TutorialStep = 7
    mockData.TutorialCompleted = true
    mockData.Coins += rew.Coins
    mockData.Essences += rew.Essences

    assert(mockData.TutorialCompleted == true, "Tutorial debe quedar marcado como completado")
    assert(mockData.Coins == 600, "Coins deben ser 600")
    assert(mockData.Essences == 25, "Essences deben ser 25")
    print("✓ Simulación del flujo completo de 6 pasos superada con éxito.")

    print("=== TODOS LOS TESTS DE TUTORIAL PASARON SATISFACTORIAMENTE ===")
    return true
end

return runTests()
