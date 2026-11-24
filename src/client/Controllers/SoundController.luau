--!strict
--[[
    SoundController.luau
    Sistema integral de audio y atmósfera musical para MAGIA ETERNA.
    - SoundGroups organizados (Master, Music, SFX, UI, Ambience).
    - Transición suave con Cross-fading (TweenService) entre pistas BGM.
    - Capa de audio ambiental inmersivo (Brisa de Lobby, Ecos y Lava en Mazmorras).
    - Automatización contextual reactiva a eventos de juego (Lobby, Salas 1-4, Sala 5 de Jefe y Victoria).
    - Respeto estricto a las opciones de volumen configuradas por el usuario.
]]

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Source"):WaitForChild("shared")
local SoundConfig = require(Shared:WaitForChild("Config"):WaitForChild("SoundConfig") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local SoundController = {}

-- SoundGroups maestros
local masterGroup: SoundGroup
local musicGroup: SoundGroup
local sfxGroup: SoundGroup
local uiGroup: SoundGroup
local ambienceGroup: SoundGroup

-- Pistas en reproducción activa
local currentMusicSound: Sound? = nil
local currentMusicId: string? = nil

local currentAmbienceSound: Sound? = nil
local currentAmbienceId: string? = nil

-- Preferencias de volumen
local masterVolumeSetting = 1.0
local musicVolumeSetting = 1.0
local sfxVolumeSetting = 1.0

-- Inicializa o recupera los SoundGroups en SoundService
local function setupSoundGroups()
	masterGroup = SoundService:FindFirstChild("Master_Group") :: SoundGroup
	if not masterGroup then
		masterGroup = Instance.new("SoundGroup")
		masterGroup.Name = "Master_Group"
		masterGroup.Volume = 1.0
		masterGroup.Parent = SoundService
	end

	local function getOrCreateSubgroup(name: string, defaultVol: number): SoundGroup
		local group = masterGroup:FindFirstChild(name) :: SoundGroup
		if not group then
			group = Instance.new("SoundGroup")
			group.Name = name
			group.Volume = defaultVol
			group.Parent = masterGroup
		end
		return group
	end

	musicGroup = getOrCreateSubgroup("Music_Group", 0.50)
	sfxGroup = getOrCreateSubgroup("SFX_Group", 0.80)
	uiGroup = getOrCreateSubgroup("UI_Group", 0.65)
	ambienceGroup = getOrCreateSubgroup("Ambience_Group", 0.35)
end

-- Reproduce un efecto de sonido (SFX o UI) con variación de tono
function SoundController.PlaySFX(soundId: string, customPitch: number?): Sound?
	local soundDef = SoundConfig.GetSound(soundId)
	if not soundDef or soundDef.AssetId == "" or soundDef.AssetId == "rbxassetid://0" or soundDef.Category == "Music" or soundDef.Category == "Ambience" then
		return nil
	end

	local sound = Instance.new("Sound")
	sound.Name = "SFX_" .. soundId
	sound.SoundId = soundDef.AssetId
	sound.Volume = soundDef.BaseVolume
	sound.SoundGroup = (soundDef.Category == "UI") and uiGroup or sfxGroup

	if customPitch then
		sound.PlaybackSpeed = customPitch
	elseif soundDef.PitchRange then
		local minP = soundDef.PitchRange.Min
		local maxP = soundDef.PitchRange.Max
		sound.PlaybackSpeed = minP + math.random() * (maxP - minP)
	else
		sound.PlaybackSpeed = 1.0
	end

	sound.Parent = SoundService
	pcall(function()
		sound:Play()
	end)

	sound.Ended:Connect(function()
		sound:Destroy()
	end)

	return sound
end

-- Reproduce una pista de música con Cross-Fading cinematográfico
function SoundController.PlayMusic(musicId: string, fadeDuration: number?)
	local cleanId = string.gsub(musicId, "^BGM_", "")
	local configKey = "BGM_" .. cleanId
	if currentMusicId == configKey and currentMusicSound and currentMusicSound.IsPlaying then
		return
	end

	local soundDef = SoundConfig.GetSound(configKey) or SoundConfig.GetSound(musicId)
	if not soundDef or soundDef.AssetId == "" or soundDef.AssetId == "rbxassetid://0" or soundDef.Category ~= "Music" then
		return
	end

	local fadeTime = fadeDuration or 1.2
	local targetVolume = soundDef.BaseVolume

	-- Desvanecer suavemente (Fade Out) la pista anterior
	if currentMusicSound then
		local oldTrack = currentMusicSound
		local fadeOut = TweenService:Create(oldTrack, TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Volume = 0
		})
		fadeOut:Play()
		fadeOut.Completed:Connect(function()
			oldTrack:Stop()
			oldTrack:Destroy()
		end)
	end

	-- Iniciar la nueva pista con volumen 0 y realizar Fade In
	local newTrack = Instance.new("Sound")
	newTrack.Name = "BGM_" .. cleanId
	newTrack.SoundId = soundDef.AssetId
	newTrack.Volume = 0
	newTrack.Looped = true
	newTrack.SoundGroup = musicGroup or (masterGroup and masterGroup:FindFirstChild("Music_Group") :: SoundGroup?)
	newTrack.Parent = SoundService
	pcall(function()
		newTrack:Play()
	end)

	local fadeIn = TweenService:Create(newTrack, TweenInfo.new(fadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Volume = targetVolume
	})
	fadeIn:Play()

	currentMusicSound = newTrack
	currentMusicId = configKey
end

-- Reproduce la pista ambiental con Fade In/Out
function SoundController.PlayAmbience(ambienceId: string, fadeDuration: number?)
	local cleanId = string.gsub(ambienceId, "^Ambience_", "")
	local configKey = "Ambience_" .. cleanId
	if currentAmbienceId == configKey and currentAmbienceSound and currentAmbienceSound.IsPlaying then
		return
	end

	local soundDef = SoundConfig.GetSound(configKey) or SoundConfig.GetSound(ambienceId)
	if not soundDef or soundDef.AssetId == "" or soundDef.AssetId == "rbxassetid://0" or soundDef.Category ~= "Ambience" then
		return
	end

	local fadeTime = fadeDuration or 1.5
	local targetVolume = soundDef.BaseVolume

	if currentAmbienceSound then
		local oldAmbience = currentAmbienceSound
		local fadeOut = TweenService:Create(oldAmbience, TweenInfo.new(fadeTime, Enum.EasingStyle.Linear), {
			Volume = 0
		})
		fadeOut:Play()
		fadeOut.Completed:Connect(function()
			oldAmbience:Stop()
			oldAmbience:Destroy()
		end)
	end

	local newAmbience = Instance.new("Sound")
	newAmbience.Name = "Ambience_" .. cleanId
	newAmbience.SoundId = soundDef.AssetId
	newAmbience.Volume = 0
	newAmbience.Looped = true
	newAmbience.SoundGroup = ambienceGroup or (masterGroup and masterGroup:FindFirstChild("Ambience_Group") :: SoundGroup?)
	newAmbience.Parent = SoundService
	pcall(function()
		newAmbience:Play()
	end)

	local fadeIn = TweenService:Create(newAmbience, TweenInfo.new(fadeTime, Enum.EasingStyle.Linear), {
		Volume = targetVolume
	})
	fadeIn:Play()

	currentAmbienceSound = newAmbience
	currentAmbienceId = configKey
end

-- Ajusta las configuraciones de volumen desde el menú de opciones
function SoundController.UpdateSettings(musicVol: number, sfxVol: number, masterVol: number?)
	musicVolumeSetting = math.clamp(musicVol, 0, 1)
	sfxVolumeSetting = math.clamp(sfxVol, 0, 1)
	if masterVol ~= nil then
		masterVolumeSetting = math.clamp(masterVol, 0, 1)
	end

	if masterGroup then
		masterGroup.Volume = masterVolumeSetting
	end
	if musicGroup then
		musicGroup.Volume = 0.50 * musicVolumeSetting
	end
	if sfxGroup then
		sfxGroup.Volume = 0.80 * sfxVolumeSetting
	end
	if uiGroup then
		uiGroup.Volume = 0.65 * sfxVolumeSetting
	end
	if ambienceGroup then
		ambienceGroup.Volume = 0.35 * musicVolumeSetting
	end
end

-- Inicialización y automatización contextual
function SoundController.Init()
	setupSoundGroups()

	-- Iniciar música pacífica y brisa del Lobby
	SoundController.PlayMusic("BGM_Lobby", 2.0)
	SoundController.PlayAmbience("Ambience_Wind", 2.0)

	-- Automatización de Música reactiva al estado de la Mazmorra
	local dungeonStateEvt = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.DungeonStateUpdated)
	if dungeonStateEvt then
		dungeonStateEvt.OnClientEvent:Connect(function(data: any)
			if data and data.Status == "Active" then
				if data.CurrentRoom == 5 then
					-- Sala 5: Jefe Final -> Música de Combate Clímax
					SoundController.PlayMusic("BGM_Boss", 1.0)
					if data.DungeonId == "Dungeon_Minas" then
						SoundController.PlayAmbience("Ambience_Lava", 1.5)
					end
				else
					-- Salas 1 a 4: Música de Mazmorra
					SoundController.PlayMusic("BGM_Dungeon", 1.2)
					if data.DungeonId == "Dungeon_Minas" then
						SoundController.PlayAmbience("Ambience_Lava", 1.5)
					else
						SoundController.PlayAmbience("Ambience_Wind", 1.5)
					end
				end
			else
				-- Retorno al Lobby
				SoundController.PlayMusic("BGM_Lobby", 1.5)
				SoundController.PlayAmbience("Ambience_Wind", 1.5)
			end
		end)
	end

	-- Victoria de Mazmorra
	local dungeonCompletedEvt = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.DungeonCompleted)
	if dungeonCompletedEvt then
		dungeonCompletedEvt.OnClientEvent:Connect(function()
			SoundController.PlaySFX("SFX_DungeonVictory")
			task.delay(3.5, function()
				SoundController.PlayMusic("BGM_Lobby", 2.0)
				SoundController.PlayAmbience("Ambience_Wind", 2.0)
			end)
		end)
	end

	-- Verificación geográfica de retorno al Lobby
	local localPlayer = Players.LocalPlayer
	task.spawn(function()
		while task.wait(4) do
			local char = localPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
			if hrp then
				local pos = hrp.Position
				if math.abs(pos.X) < 250 and math.abs(pos.Z) < 250 and pos.Y < 35 then
					if currentMusicId ~= "BGM_Lobby" then
						SoundController.PlayMusic("BGM_Lobby", 1.5)
						SoundController.PlayAmbience("Ambience_Wind", 1.5)
					end
				end
			end
		end
	end)

	print("[SoundController] Sistema de audio orquestal y SoundGroups inicializado.")
end

return SoundController
