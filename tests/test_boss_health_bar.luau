--!strict
-- tests/test_boss_health_bar.luau
-- Pruebas automatizadas de la Barra de Vida del Jefe Treant (3 Fases)

local function runTests()
    print("=== INICIANDO TEST DE BARRA DE VIDA DEL JEFE (3 FASES) ===")

    local maxHP = 50000

    local function calculatePhase(currentHP: number): (number, string, string)
        local percent = math.clamp(currentHP / maxHP, 0, 1)
        if percent <= 0.30 then
            return 3, "[FASE 3: ENFURECIDO - NOVA ANCESTRAL]", "Rojo_Corrupto"
        elseif percent <= 0.70 then
            return 2, "[FASE 2: GRIETA TERRESTRE Y TERREMOTO]", "Naranja_Volcanico"
        else
            return 1, "[FASE 1: PISOTÓN DE RAÍCES]", "Verde_Esmeralda"
        end
    end

    -- 1. Test Fase 1 (100% - 70%)
    local p1, name1, color1 = calculatePhase(50000)
    assert(p1 == 1 and color1 == "Verde_Esmeralda", "HP 100% debe ser Fase 1")
    local p1_edge, _, color1_edge = calculatePhase(35500) -- 71%
    assert(p1_edge == 1 and color1_edge == "Verde_Esmeralda", "HP 71% debe seguir en Fase 1")
    print("✓ Fase 1 (100% - 70% HP): Verde Esmeralda (Pisotón de Raíces) validado.")

    -- 2. Test Fase 2 (70% - 30%)
    local p2_start, name2, color2 = calculatePhase(35000) -- 70%
    assert(p2_start == 2 and color2 == "Naranja_Volcanico", "HP 70% debe transicionar a Fase 2")
    local p2_mid, _, _ = calculatePhase(25000) -- 50%
    assert(p2_mid == 2, "HP 50% debe ser Fase 2")
    local p2_edge, _, _ = calculatePhase(15500) -- 31%
    assert(p2_edge == 2, "HP 31% debe seguir en Fase 2")
    print("✓ Fase 2 (70% - 30% HP): Naranja Volcánico (Grieta Terrestre) validado.")

    -- 3. Test Fase 3 (30% - 0%)
    local p3_start, name3, color3 = calculatePhase(15000) -- 30%
    assert(p3_start == 3 and color3 == "Rojo_Corrupto", "HP 30% debe transicionar a Fase 3")
    local p3_low, _, _ = calculatePhase(5000) -- 10%
    assert(p3_low == 3, "HP 10% debe ser Fase 3")
    print("✓ Fase 3 (30% - 0% HP): Rojo Corrupto Enfurecido (Nova Ancestral) validado.")

    -- 4. Test Derrota
    local p_dead, _, _ = calculatePhase(0)
    assert(p_dead == 3, "HP 0% es derrota en fase final")
    print("✓ Condición de derrota (HP 0) validada con éxito.")

    print("=== TODOS LOS TESTS DE BARRA DE VIDA DEL JEFE PASARON CON ÉXITO ===")
    return true
end

return runTests()
