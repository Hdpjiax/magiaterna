--!strict
--[[
    GameConfig.luau
    Central configuration for MAGIA ETERNA.
    Contains versioning, data store settings, default schemas, and rate limit thresholds.
]]

export type PlayerData = {
	Version: number,
	Coins: number,
	Magic: number,
	Rebirths: number,
	RebirthShards: number,
	
	EquippedStaff: string,
	OwnedStaffs: { [string]: boolean },
	
	EquippedPets: { string }, -- List of unique Pet UUIDs
	PetInventory: { [string]: {
		Id: string,
		Species: string,
		Tier: string, -- "Normal", "Golden", "Rainbow"
		Level: number,
		Locked: boolean,
	} },
	MaxEquippedPets: number,
	MaxPetInventory: number,
	
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
	
	UnlockedDungeons: { [string]: number }, -- DungeonName -> HighestDifficulty (1-5)
	
	Settings: {
		MusicVolume: number,
		SFXVolume: number,
		CameraShake: boolean,
	},
}

local GameConfig = {}

-- Versioning & DataStore
GameConfig.DATA_VERSION = 1
GameConfig.DATASTORE_NAME = "MagiaEterna_PlayerData_v1"
GameConfig.AUTO_SAVE_INTERVAL = 180 -- seconds (3 minutes)
GameConfig.SESSION_LOCK_TIMEOUT = 1200 -- seconds (20 minutes)

-- Rate Limiting Thresholds (Max calls per second per action)
GameConfig.RATE_LIMITS = {
	ClickMagic = 15,       -- Max 15 clicks/sec (human clicks or basic auto-train)
	EquipItem = 5,         -- Max 5 equip calls/sec
	OpenEgg = 3,           -- Max 3 egg openings/sec
	ForgeItem = 2,         -- Max 2 forge attempts/sec
	Rebirth = 1,           -- Max 1 rebirth request per 2 seconds
	DungeonInteract = 5,   -- Max 5 dungeon interactions/sec
}

-- Default Player Data Profile Template
function GameConfig.GetDefaultData(): PlayerData
	return {
		Version = GameConfig.DATA_VERSION,
		Coins = 100,
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
		
		Settings = {
			MusicVolume = 1.0,
			SFXVolume = 1.0,
			CameraShake = true,
		},
	}
end

return table.freeze(GameConfig)
