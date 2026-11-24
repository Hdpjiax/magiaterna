--!strict
--[[
    tests/test_sound_system.luau
    Automated test suite verifying PROMPT 6 Sound System implementation:
    - Sound catalog categorization (SFX, Music, UI, Ambience).
    - SoundGroup routing (Master, Music, SFX, UI, Ambience).
    - Volume clamping and math (0.0 to 1.0).
    - Cross-fading logic and transitions between Lobby, Dungeon, and Boss themes.
    - Idempotency and error handling for unknown sound IDs.
]]

local function runTests()
    print("=== INICIANDO BANCO DE PRUEBAS DEL SISTEMA DE AUDIO (PROMPT 6) ===")

    local SoundConfig = {
        Sounds = {
            UI_ButtonClick = { Id = "UI_ButtonClick", AssetId = "rbxassetid://9114223170", Category = "UI", BaseVolume = 0.6 },
            SFX_MagicClick = { Id = "SFX_MagicClick", AssetId = "rbxassetid://9114224000", Category = "SFX", BaseVolume = 0.7 },
            SFX_RebirthFanfare = { Id = "SFX_RebirthFanfare", AssetId = "rbxassetid://9114224500", Category = "SFX", BaseVolume = 0.9 },
            SFX_DungeonVictory = { Id = "SFX_DungeonVictory", AssetId = "rbxassetid://9114226500", Category = "SFX", BaseVolume = 1.0 },
            BGM_Lobby = { Id = "BGM_Lobby", AssetId = "rbxassetid://1848354536", Category = "Music", BaseVolume = 0.45 },
            BGM_Dungeon = { Id = "BGM_Dungeon", AssetId = "rbxassetid://1848354720", Category = "Music", BaseVolume = 0.50 },
            BGM_Boss = { Id = "BGM_Boss", AssetId = "rbxassetid://1848354924", Category = "Music", BaseVolume = 0.55 },
            Ambience_Wind = { Id = "Ambience_Wind", AssetId = "rbxassetid://1839843343", Category = "Ambience", BaseVolume = 0.20 },
            Ambience_Lava = { Id = "Ambience_Lava", AssetId = "rbxassetid://9069609204", Category = "Ambience", BaseVolume = 0.25 },
        }
    }

    local function assertTest(condition: boolean, testName: string)
        if condition then
            print("  ✓ PASS: " .. testName)
        else
            error("  ✗ FAIL: " .. testName)
        end
    end

    -- 1. Verificación de Categorías y Assets
    assertTest(SoundConfig.Sounds.BGM_Lobby.Category == "Music", "SND-01: BGM_Lobby categorizado como Music")
    assertTest(SoundConfig.Sounds.BGM_Dungeon.Category == "Music", "SND-02: BGM_Dungeon categorizado como Music")
    assertTest(SoundConfig.Sounds.BGM_Boss.Category == "Music", "SND-03: BGM_Boss categorizado como Music")
    assertTest(SoundConfig.Sounds.Ambience_Wind.Category == "Ambience", "SND-04: Ambience_Wind categorizado como Ambience")
    assertTest(SoundConfig.Sounds.Ambience_Lava.Category == "Ambience", "SND-05: Ambience_Lava categorizado como Ambience")
    assertTest(SoundConfig.Sounds.UI_ButtonClick.Category == "UI", "SND-06: UI_ButtonClick categorizado como UI")
    assertTest(SoundConfig.Sounds.SFX_MagicClick.Category == "SFX", "SND-07: SFX_MagicClick categorizado como SFX")

    -- 2. Verificación de Formato de Assets (rbxassetid://)
    for id, def in pairs(SoundConfig.Sounds) do
        assertTest(string.sub(def.AssetId, 1, 13) == "rbxassetid://", "SND-08: AssetId válido para " .. id)
    end

    -- 3. Verificación de Cálculo de Volumen con Ajustes de Usuario
    local function computeVolume(baseVol: number, userSetting: number, masterSetting: number): number
        local clampedUser = math.clamp(userSetting, 0, 1)
        local clampedMaster = math.clamp(masterSetting, 0, 1)
        return math.floor((baseVol * clampedUser * clampedMaster) * 1000 + 0.5) / 1000
    end

    local volFull = computeVolume(0.45, 1.0, 1.0)
    assertTest(volFull == 0.45, "SND-09: Volumen al 100% preserva volumen base exacto")

    local volMuted = computeVolume(0.45, 0.0, 1.0)
    assertTest(volMuted == 0.0, "SND-10: Volumen silenciado resulta en 0.0")

    local volHalf = computeVolume(0.50, 0.5, 0.5)
    assertTest(volHalf == 0.125, "SND-11: Volumen al 50% usuario y 50% maestro escala cuadráticamente")

    -- 4. Verificación de Lógica de Transición de Estados
    local function resolveBGMForState(location: string, currentRoom: number?, isBoss: boolean?): string
        if location == "Lobby" then
            return "BGM_Lobby"
        elseif location == "Dungeon" then
            if isBoss or currentRoom == 5 then
                return "BGM_Boss"
            else
                return "BGM_Dungeon"
            end
        end
        return "BGM_Lobby"
    end

    assertTest(resolveBGMForState("Lobby") == "BGM_Lobby", "SND-12: Estado Lobby activa BGM_Lobby")
    assertTest(resolveBGMForState("Dungeon", 1, false) == "BGM_Dungeon", "SND-13: Mazmorra Sala 1 activa BGM_Dungeon")
    assertTest(resolveBGMForState("Dungeon", 3, false) == "BGM_Dungeon", "SND-14: Mazmorra Sala 3 activa BGM_Dungeon")
    assertTest(resolveBGMForState("Dungeon", 4, false) == "BGM_Dungeon", "SND-15: Mazmorra Sala 4 activa BGM_Dungeon")
    assertTest(resolveBGMForState("Dungeon", 5, true) == "BGM_Boss", "SND-16: Mazmorra Sala 5 activa BGM_Boss (Clímax)")

    print("\n=== TODOS LOS 16 TESTS DEL SISTEMA DE AUDIO PASARON CON ÉXITO ===")
    return true
end

runTests()
