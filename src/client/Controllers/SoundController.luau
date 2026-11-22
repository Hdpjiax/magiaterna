--!strict
--[[
    SoundController.luau
    Client sound system managing background music, sound effects, pitch jitters,
    and volume adjustments tied to player preferences for MAGIA ETERNA.
]]

local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundConfig = require(ReplicatedStorage.Source.shared.Config.SoundConfig)

local SoundController = {}
local currentMusicTrack: Sound? = nil
local musicVolumeSetting = 1.0
local sfxVolumeSetting = 1.0

-- Plays a one-shot sound effect with optional pitch variation
function SoundController.PlaySFX(soundId: string, customPitch: number?): Sound?
	local soundDef = SoundConfig.GetSound(soundId)
	if not soundDef or soundDef.Category == "Music" then
		return nil
	end

	local sound = Instance.new("Sound")
	sound.Name = "SFX_" .. soundId
	sound.SoundId = soundDef.AssetId
	sound.Volume = soundDef.BaseVolume * sfxVolumeSetting

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
	sound:Play()

	sound.Ended:Connect(function()
		sound:Destroy()
	end)

	return sound
end

-- Plays looping background music track with smooth transition
function SoundController.PlayMusic(musicId: string)
	local soundDef = SoundConfig.GetSound(musicId)
	if not soundDef or soundDef.Category ~= "Music" then
		return
	end

	if currentMusicTrack then
		currentMusicTrack:Stop()
		currentMusicTrack:Destroy()
		currentMusicTrack = nil
	end

	local music = Instance.new("Sound")
	music.Name = "BGM_" .. musicId
	music.SoundId = soundDef.AssetId
	music.Volume = soundDef.BaseVolume * musicVolumeSetting
	music.Looped = true
	music.Parent = SoundService
	music:Play()

	currentMusicTrack = music
end

-- Updates master volumes from player settings
function SoundController.UpdateSettings(musicVol: number, sfxVol: number)
	musicVolumeSetting = math.clamp(musicVol, 0, 1)
	sfxVolumeSetting = math.clamp(sfxVol, 0, 1)

	if currentMusicTrack then
		local soundDef = SoundConfig.GetSound(currentMusicTrack.Name:gsub("BGM_", ""))
		local base = soundDef and soundDef.BaseVolume or 0.5
		currentMusicTrack.Volume = base * musicVolumeSetting
	end
end

function SoundController.Init()
	print("[SoundController] Initialized successfully.")
end

return SoundController
