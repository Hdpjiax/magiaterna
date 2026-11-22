--!strict
--[[
    SoundConfig.luau
    Central sound registry and audio configuration for MAGIA ETERNA.
    Contains asset IDs, base volumes, pitch variations, and categories.
]]

export type SoundDefinition = {
	Id: string,
	AssetId: string,
	Category: "SFX" | "Music" | "UI",
	BaseVolume: number,
	PitchRange: { Min: number, Max: number }?,
}

local SoundConfig = {}

SoundConfig.Sounds = {
	-- UI Sounds
	UI_ButtonClick = {
		Id = "UI_ButtonClick",
		AssetId = "rbxassetid://9114223170",
		Category = "UI",
		BaseVolume = 0.6,
		PitchRange = { Min = 0.95, Max = 1.05 },
	},
	UI_OpenModal = {
		Id = "UI_OpenModal",
		AssetId = "rbxassetid://9114223400",
		Category = "UI",
		BaseVolume = 0.5,
	},
	UI_CloseModal = {
		Id = "UI_CloseModal",
		AssetId = "rbxassetid://9114223650",
		Category = "UI",
		BaseVolume = 0.5,
	},

	-- Gameplay SFX
	SFX_MagicClick = {
		Id = "SFX_MagicClick",
		AssetId = "rbxassetid://9114224000",
		Category = "SFX",
		BaseVolume = 0.7,
		PitchRange = { Min = 0.90, Max = 1.15 },
	},
	SFX_RebirthFanfare = {
		Id = "SFX_RebirthFanfare",
		AssetId = "rbxassetid://9114224500",
		Category = "SFX",
		BaseVolume = 0.9,
	},
	SFX_EggHatch = {
		Id = "SFX_EggHatch",
		AssetId = "rbxassetid://9114225000",
		Category = "SFX",
		BaseVolume = 0.85,
	},
	SFX_ForgeSuccess = {
		Id = "SFX_ForgeSuccess",
		AssetId = "rbxassetid://9114225500",
		Category = "SFX",
		BaseVolume = 0.8,
	},
	SFX_SpellCast = {
		Id = "SFX_SpellCast",
		AssetId = "rbxassetid://9114226000",
		Category = "SFX",
		BaseVolume = 0.75,
		PitchRange = { Min = 0.95, Max = 1.05 },
	},
	SFX_DungeonVictory = {
		Id = "SFX_DungeonVictory",
		AssetId = "rbxassetid://9114226500",
		Category = "SFX",
		BaseVolume = 1.0,
	},

	-- Music
	BGM_Lobby = {
		Id = "BGM_Lobby",
		AssetId = "rbxassetid://1848354536",
		Category = "Music",
		BaseVolume = 0.45,
	},
	BGM_Dungeon = {
		Id = "BGM_Dungeon",
		AssetId = "rbxassetid://1848354720",
		Category = "Music",
		BaseVolume = 0.50,
	},
} :: { [string]: SoundDefinition }

function SoundConfig.GetSound(id: string): SoundDefinition?
	return SoundConfig.Sounds[id]
end

return table.freeze(SoundConfig)
