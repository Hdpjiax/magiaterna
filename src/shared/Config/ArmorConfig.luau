--!strict
--[[
    ArmorConfig.luau
    6-Piece Armor Sets, individual piece stats, and set bonus configurations for MAGIA ETERNA.
    Sets: Guardián del Bosque, Señor de Magma, Guardián Glacial, Rey Espectral, Arcángel, Dios del Vacío.
]]

export type ArmorSlot = "Helmet" | "Chest" | "Gloves" | "Pants" | "Boots" | "Cape"

export type ArmorPieceDefinition = {
	Id: string,
	Name: string,
	SetId: string,
	Slot: ArmorSlot,
	DefenseBonus: number, -- Flat damage reduction
	HealthBonus: number,  -- Added to character max HP
	Description: string,
}

export type ArmorSetDefinition = {
	SetId: string,
	SetName: string,
	Region: string,
	FullSetBonusName: string,
	HealthMultiplier: number,     -- e.g. 1.15 = +15% Health
	DamageMultiplier: number,     -- e.g. 1.15 = +15% Elemental Damage
	DamageReductionBonus: number, -- e.g. 0.10 = +10% Damage Reduction
	Pieces: { [ArmorSlot]: string },
}

local ArmorConfig = {}

-- Catalog of Armor Sets
local armorSets: { [string]: ArmorSetDefinition } = {
	["Set_Forest"] = {
		SetId = "Set_Forest",
		SetName = "Guardián del Bosque",
		Region = "Bosque",
		FullSetBonusName = "Vigor del Roble Ancestral",
		HealthMultiplier = 1.15, -- +15% max health
		DamageMultiplier = 1.10, -- +10% nature damage
		DamageReductionBonus = 0.08, -- +8% armor resistance
		Pieces = {
			Helmet = "Armor_Forest_Helmet",
			Chest = "Armor_Forest_Chest",
			Gloves = "Armor_Forest_Gloves",
			Pants = "Armor_Forest_Pants",
			Boots = "Armor_Forest_Boots",
			Cape = "Armor_Forest_Cape",
		},
	},
}

-- Catalog of Armor Pieces
local armorPieces: { [string]: ArmorPieceDefinition } = {
	["Armor_Forest_Helmet"] = {
		Id = "Armor_Forest_Helmet",
		Name = "Corona del Guardián del Bosque",
		SetId = "Set_Forest",
		Slot = "Helmet",
		DefenseBonus = 5,
		HealthBonus = 25,
		Description = "Yelmo vegetal que agudiza la visión y protege la mente.",
	},
	["Armor_Forest_Chest"] = {
		Id = "Armor_Forest_Chest",
		Name = "Pechera del Guardián del Bosque",
		SetId = "Set_Forest",
		Slot = "Chest",
		DefenseBonus = 15,
		HealthBonus = 60,
		Description = "Pechera de corteza entrelazada que amortigua impactos.",
	},
	["Armor_Forest_Gloves"] = {
		Id = "Armor_Forest_Gloves",
		Name = "Guanteletes del Guardián del Bosque",
		SetId = "Set_Forest",
		Slot = "Gloves",
		DefenseBonus = 6,
		HealthBonus = 20,
		Description = "Guantes con espinas suaves que mejoran el agarre de los bastones.",
	},
	["Armor_Forest_Pants"] = {
		Id = "Armor_Forest_Pants",
		Name = "Grebas del Guardián del Bosque",
		SetId = "Set_Forest",
		Slot = "Pants",
		DefenseBonus = 10,
		HealthBonus = 40,
		Description = "Pantalones de cuero vegetal flexibles para moverse con soltura.",
	},
	["Armor_Forest_Boots"] = {
		Id = "Armor_Forest_Boots",
		Name = "Botas del Guardián del Bosque",
		SetId = "Set_Forest",
		Slot = "Boots",
		DefenseBonus = 6,
		HealthBonus = 25,
		Description = "Botas ligeras que no dejan huellas en la hierba.",
	},
	["Armor_Forest_Cape"] = {
		Id = "Armor_Forest_Cape",
		Name = "Capa de Hojas Ancestrales",
		SetId = "Set_Forest",
		Slot = "Cape",
		DefenseBonus = 8,
		HealthBonus = 30,
		Description = "Capa tejida con hojas de roble dorado que fluye con el viento.",
	},
}

-- Retrieves piece by ID
function ArmorConfig.GetPiece(pieceId: string): ArmorPieceDefinition?
	return armorPieces[pieceId]
end

-- Retrieves set definition by SetId
function ArmorConfig.GetSet(setId: string): ArmorSetDefinition?
	return armorSets[setId]
end

-- Checks if the equipped pieces form a complete 6-piece set
function ArmorConfig.GetActiveSetBonus(equippedArmor: { [string]: string? }): ArmorSetDefinition?
	for setId, setDef in pairs(armorSets) do
		local isFull = true
		for slot, requiredPieceId in pairs(setDef.Pieces) do
			if equippedArmor[slot] ~= requiredPieceId then
				isFull = false
				break
			end
		end
		if isFull then
			return setDef
		end
	end
	return nil
end

-- Computes total defensive stats from equipped armor pieces
function ArmorConfig.CalculateTotalStats(equippedArmor: { [string]: string? }): {
	TotalDefense: number,
	TotalHealthBonus: number,
	ActiveSetBonus: ArmorSetDefinition?,
}
	local totalDef = 0
	local totalHp = 0
	
	for _, pieceId in pairs(equippedArmor) do
		if pieceId then
			local piece = armorPieces[pieceId]
			if piece then
				totalDef += piece.DefenseBonus
				totalHp += piece.HealthBonus
			end
		end
	end
	
	local setBonus = ArmorConfig.GetActiveSetBonus(equippedArmor)
	if setBonus then
		totalHp = math.floor(totalHp * setBonus.HealthMultiplier)
	end
	
	return {
		TotalDefense = totalDef,
		TotalHealthBonus = totalHp,
		ActiveSetBonus = setBonus,
	}
end

return table.freeze(ArmorConfig)
