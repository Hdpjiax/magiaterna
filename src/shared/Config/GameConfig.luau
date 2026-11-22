--!strict
--[[
    GameConfig.luau
    Central configuration for MAGIA ETERNA.
    Contains versioning, data store settings, default schemas, and rate limit thresholds.
]]

export type QuestProgressRecord = {
	Progress: number,
	Claimed: boolean,
}

export type PlayerData = {
	Version: number,
	Coins: number,
	Essences: number,
	Magic: number,
	Rebirths: number,
	RebirthShards: number,

	EquippedStaff: string,
	OwnedStaffs: { [string]: boolean },

	EquippedPets: { string },
	PetInventory: { [string]: {
		Id: string,
		Species: string,
		Tier: string,
		Level: number,
		Locked: boolean,
	} },
	MaxEquippedPets: number,
	MaxPetInventory: number,
	DiscoveredPets: { [string]: boolean },

	Materials: { [string]: number },

	EquippedArmor: {
		Helmet: string?,
		Chest: string?,
		Gloves: string?,
		Pants: string?,
		Boots: string?,
		Cape: string?,
	},
	ArmorInventory: { [string]: number },

	UnlockedDungeons: { [string]: number },

	Quests: { [string]: QuestProgressRecord },
	OwnedGamePasses: { [string]: boolean },
	ProcessedReceipts: { [string]: boolean },

	Settings: {
		MusicVolume: number,
		SFXVolume: number,
		CameraShake: boolean,
		ReducedEffects: boolean,
	},
}

local GameConfig = {}

GameConfig.DATA_VERSION = 2
GameConfig.DATASTORE_NAME = "MagiaEterna_PlayerData_v1"
GameConfig.AUTO_SAVE_INTERVAL = 180
GameConfig.SESSION_LOCK_TIMEOUT = 1200

GameConfig.RATE_LIMITS = {
	ClickMagic = 15,
	EquipItem = 5,
	OpenEgg = 3,
	ForgeItem = 2,
	Rebirth = 1,
	DungeonInteract = 5,
	EconomySell = 5,
	QuestClaim = 3,
	SettingsUpdate = 3,
}

function GameConfig.GetDefaultData(): PlayerData
	return {
		Version = GameConfig.DATA_VERSION,
		Coins = 100,
		Essences = 0,
		Magic = 0,
		Rebirths = 0,
		RebirthShards = 0,

		EquippedStaff = "Staff_R1_001_RamaAprendiz",
		OwnedStaffs = {
			["Staff_R1_001_RamaAprendiz"] = true,
		},

		EquippedPets = {},
		PetInventory = {},
		MaxEquippedPets = 3,
		MaxPetInventory = 50,
		DiscoveredPets = {},

		Materials = {
			["MaderaAntigua"] = 5,
			["HojaMagica"] = 2,
		},

		EquippedArmor = {
			Helmet = nil,
			Chest = nil,
			Gloves = nil,
			Pants = nil,
			Boots = nil,
			Cape = nil,
		},
		ArmorInventory = {},

		UnlockedDungeons = {
			["Bosque"] = 1,
		},

		Quests = {},
		OwnedGamePasses = {},
		ProcessedReceipts = {},

		Settings = {
			MusicVolume = 1.0,
			SFXVolume = 1.0,
			CameraShake = true,
			ReducedEffects = false,
		},
	}
end

return table.freeze(GameConfig)
