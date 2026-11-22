--!strict
--[[
    RarityUtils.luau
    Centralized rarity definitions, colors, sort weights, and power multipliers for MAGIA ETERNA.
]]

export type Rarity = "Común" | "Poco común" | "Raro" | "Rara" | "Épico" | "Épica" | "Legendario" | "Legendaria" | "Mítico" | "Mítica"

export type RarityInfo = {
	Name: string,
	Order: number,
	Color: Color3,
	HexColor: string,
	PowerMultiplier: number,
	SellMultiplier: number,
}

local RarityUtils = {}

local RARITY_MAP: { [string]: RarityInfo } = {
	["Común"] = {
		Name = "Común",
		Order = 1,
		Color = Color3.fromRGB(180, 188, 196),
		HexColor = "#B4BCC4",
		PowerMultiplier = 1.0,
		SellMultiplier = 1.0,
	},
	["Poco común"] = {
		Name = "Poco común",
		Order = 2,
		Color = Color3.fromRGB(76, 209, 108),
		HexColor = "#4CD16C",
		PowerMultiplier = 1.35,
		SellMultiplier = 2.0,
	},
	["Raro"] = {
		Name = "Raro",
		Order = 3,
		Color = Color3.fromRGB(64, 156, 255),
		HexColor = "#409CFF",
		PowerMultiplier = 1.85,
		SellMultiplier = 4.5,
	},
	["Épico"] = {
		Name = "Épico",
		Order = 4,
		Color = Color3.fromRGB(168, 85, 247),
		HexColor = "#A855F7",
		PowerMultiplier = 2.75,
		SellMultiplier = 10.0,
	},
	["Legendario"] = {
		Name = "Legendario",
		Order = 5,
		Color = Color3.fromRGB(251, 191, 36),
		HexColor = "#FBBF24",
		PowerMultiplier = 4.25,
		SellMultiplier = 25.0,
	},
	["Mítico"] = {
		Name = "Mítico",
		Order = 6,
		Color = Color3.fromRGB(244, 63, 94),
		HexColor = "#F43F5E",
		PowerMultiplier = 7.0,
		SellMultiplier = 60.0,
	},
}

-- Normalize feminine/masculine Spanish rarity variants
local ALIASES: { [string]: string } = {
	["Rara"] = "Raro",
	["Épica"] = "Épico",
	["Legendaria"] = "Legendario",
	["Mítica"] = "Mítico",
}

function RarityUtils.Normalize(rarity: string): string
	return ALIASES[rarity] or rarity
end

function RarityUtils.GetInfo(rarity: string): RarityInfo
	local normalized = RarityUtils.Normalize(rarity)
	return RARITY_MAP[normalized] or RARITY_MAP["Común"]
end

function RarityUtils.GetColor(rarity: string): Color3
	return RarityUtils.GetInfo(rarity).Color
end

function RarityUtils.GetOrder(rarity: string): number
	return RarityUtils.GetInfo(rarity).Order
end

function RarityUtils.GetPowerMultiplier(rarity: string): number
	return RarityUtils.GetInfo(rarity).PowerMultiplier
end

function RarityUtils.GetSellMultiplier(rarity: string): number
	return RarityUtils.GetInfo(rarity).SellMultiplier
end

return table.freeze(RarityUtils)
