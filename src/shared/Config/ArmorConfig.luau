--!strict
--[[
    ArmorConfig.luau
    All 6 Regional 6-Piece Armor Sets (36 pieces total) for MAGIA ETERNA.
]]

export type ArmorSlot = "Helmet" | "Chest" | "Gloves" | "Pants" | "Boots" | "Cape"

export type ArmorPieceDefinition = {
	Id: string,
	Name: string,
	SetId: string,
	Slot: ArmorSlot,
	DefenseBonus: number,
	HealthBonus: number,
	Description: string,
}

export type ArmorSetDefinition = {
	SetId: string,
	SetName: string,
	Region: string,
	FullSetBonusName: string,
	HealthMultiplier: number,
	DamageMultiplier: number,
	DamageReductionBonus: number,
	Pieces: { [ArmorSlot]: string },
}

local ArmorConfig = {}

local armorSets: { [string]: ArmorSetDefinition } = {
	["Set_Forest"] = {
		SetId = "Set_Forest",
		SetName = "Guardián del Bosque",
		Region = "Bosque",
		FullSetBonusName = "Vigor del Roble Ancestral",
		HealthMultiplier = 1.15,
		DamageMultiplier = 1.1,
		DamageReductionBonus = 0.08,
		Pieces = {
			Helmet = "Armor_Forest_Helmet",
			Chest = "Armor_Forest_Chest",
			Gloves = "Armor_Forest_Gloves",
			Pants = "Armor_Forest_Pants",
			Boots = "Armor_Forest_Boots",
			Cape = "Armor_Forest_Cape",
		},
	},
	["Set_Magma"] = {
		SetId = "Set_Magma",
		SetName = "Señor de Magma",
		Region = "Minas",
		FullSetBonusName = "Furia del Volcán",
		HealthMultiplier = 1.15,
		DamageMultiplier = 1.15,
		DamageReductionBonus = 0.1,
		Pieces = {
			Helmet = "Armor_Magma_Helmet",
			Chest = "Armor_Magma_Chest",
			Gloves = "Armor_Magma_Gloves",
			Pants = "Armor_Magma_Pants",
			Boots = "Armor_Magma_Boots",
			Cape = "Armor_Magma_Cape",
		},
	},
	["Set_Glacial"] = {
		SetId = "Set_Glacial",
		SetName = "Guardián Glacial",
		Region = "Hielo",
		FullSetBonusName = "Coraza de Escarcha",
		HealthMultiplier = 1.2,
		DamageMultiplier = 1.12,
		DamageReductionBonus = 0.15,
		Pieces = {
			Helmet = "Armor_Glacial_Helmet",
			Chest = "Armor_Glacial_Chest",
			Gloves = "Armor_Glacial_Gloves",
			Pants = "Armor_Glacial_Pants",
			Boots = "Armor_Glacial_Boots",
			Cape = "Armor_Glacial_Cape",
		},
	},
	["Set_Spectral"] = {
		SetId = "Set_Spectral",
		SetName = "Rey Espectral",
		Region = "Cripta",
		FullSetBonusName = "Sombra Inmortal",
		HealthMultiplier = 1.18,
		DamageMultiplier = 1.18,
		DamageReductionBonus = 0.16,
		Pieces = {
			Helmet = "Armor_Spectral_Helmet",
			Chest = "Armor_Spectral_Chest",
			Gloves = "Armor_Spectral_Gloves",
			Pants = "Armor_Spectral_Pants",
			Boots = "Armor_Spectral_Boots",
			Cape = "Armor_Spectral_Cape",
		},
	},
	["Set_Archangel"] = {
		SetId = "Set_Archangel",
		SetName = "Arcángel",
		Region = "Cielos",
		FullSetBonusName = "Gracia Celestial",
		HealthMultiplier = 1.22,
		DamageMultiplier = 1.2,
		DamageReductionBonus = 0.18,
		Pieces = {
			Helmet = "Armor_Archangel_Helmet",
			Chest = "Armor_Archangel_Chest",
			Gloves = "Armor_Archangel_Gloves",
			Pants = "Armor_Archangel_Pants",
			Boots = "Armor_Archangel_Boots",
			Cape = "Armor_Archangel_Cape",
		},
	},
	["Set_Void"] = {
		SetId = "Set_Void",
		SetName = "Dios del Vacío",
		Region = "Abismo",
		FullSetBonusName = "Supremacía Cósmica",
		HealthMultiplier = 1.25,
		DamageMultiplier = 1.25,
		DamageReductionBonus = 0.22,
		Pieces = {
			Helmet = "Armor_Void_Helmet",
			Chest = "Armor_Void_Chest",
			Gloves = "Armor_Void_Gloves",
			Pants = "Armor_Void_Pants",
			Boots = "Armor_Void_Boots",
			Cape = "Armor_Void_Cape",
		},
	},
}

local armorPieces: { [string]: ArmorPieceDefinition } = {
	["Armor_Forest_Helmet"] = {
		Id = "Armor_Forest_Helmet",
		Name = "Casco de Guardián del Bosque",
		SetId = "Set_Forest",
		Slot = "Helmet",
		DefenseBonus = 10,
		HealthBonus = 40,
		Description = "Pieza del conjunto Guardián del Bosque (Bosque).",
	},
	["Armor_Forest_Chest"] = {
		Id = "Armor_Forest_Chest",
		Name = "Pechera de Guardián del Bosque",
		SetId = "Set_Forest",
		Slot = "Chest",
		DefenseBonus = 22,
		HealthBonus = 90,
		Description = "Pieza del conjunto Guardián del Bosque (Bosque).",
	},
	["Armor_Forest_Gloves"] = {
		Id = "Armor_Forest_Gloves",
		Name = "Guantes de Guardián del Bosque",
		SetId = "Set_Forest",
		Slot = "Gloves",
		DefenseBonus = 8,
		HealthBonus = 25,
		Description = "Pieza del conjunto Guardián del Bosque (Bosque).",
	},
	["Armor_Forest_Pants"] = {
		Id = "Armor_Forest_Pants",
		Name = "Pantalones de Guardián del Bosque",
		SetId = "Set_Forest",
		Slot = "Pants",
		DefenseBonus = 16,
		HealthBonus = 65,
		Description = "Pieza del conjunto Guardián del Bosque (Bosque).",
	},
	["Armor_Forest_Boots"] = {
		Id = "Armor_Forest_Boots",
		Name = "Botas de Guardián del Bosque",
		SetId = "Set_Forest",
		Slot = "Boots",
		DefenseBonus = 10,
		HealthBonus = 35,
		Description = "Pieza del conjunto Guardián del Bosque (Bosque).",
	},
	["Armor_Forest_Cape"] = {
		Id = "Armor_Forest_Cape",
		Name = "Capa de Guardián del Bosque",
		SetId = "Set_Forest",
		Slot = "Cape",
		DefenseBonus = 14,
		HealthBonus = 50,
		Description = "Pieza del conjunto Guardián del Bosque (Bosque).",
	},
	["Armor_Magma_Helmet"] = {
		Id = "Armor_Magma_Helmet",
		Name = "Casco de Señor de Magma",
		SetId = "Set_Magma",
		Slot = "Helmet",
		DefenseBonus = 25,
		HealthBonus = 100,
		Description = "Pieza del conjunto Señor de Magma (Minas).",
	},
	["Armor_Magma_Chest"] = {
		Id = "Armor_Magma_Chest",
		Name = "Pechera de Señor de Magma",
		SetId = "Set_Magma",
		Slot = "Chest",
		DefenseBonus = 55,
		HealthBonus = 225,
		Description = "Pieza del conjunto Señor de Magma (Minas).",
	},
	["Armor_Magma_Gloves"] = {
		Id = "Armor_Magma_Gloves",
		Name = "Guantes de Señor de Magma",
		SetId = "Set_Magma",
		Slot = "Gloves",
		DefenseBonus = 20,
		HealthBonus = 62,
		Description = "Pieza del conjunto Señor de Magma (Minas).",
	},
	["Armor_Magma_Pants"] = {
		Id = "Armor_Magma_Pants",
		Name = "Pantalones de Señor de Magma",
		SetId = "Set_Magma",
		Slot = "Pants",
		DefenseBonus = 40,
		HealthBonus = 162,
		Description = "Pieza del conjunto Señor de Magma (Minas).",
	},
	["Armor_Magma_Boots"] = {
		Id = "Armor_Magma_Boots",
		Name = "Botas de Señor de Magma",
		SetId = "Set_Magma",
		Slot = "Boots",
		DefenseBonus = 25,
		HealthBonus = 88,
		Description = "Pieza del conjunto Señor de Magma (Minas).",
	},
	["Armor_Magma_Cape"] = {
		Id = "Armor_Magma_Cape",
		Name = "Capa de Señor de Magma",
		SetId = "Set_Magma",
		Slot = "Cape",
		DefenseBonus = 35,
		HealthBonus = 125,
		Description = "Pieza del conjunto Señor de Magma (Minas).",
	},
	["Armor_Glacial_Helmet"] = {
		Id = "Armor_Glacial_Helmet",
		Name = "Casco de Guardián Glacial",
		SetId = "Set_Glacial",
		Slot = "Helmet",
		DefenseBonus = 55,
		HealthBonus = 220,
		Description = "Pieza del conjunto Guardián Glacial (Hielo).",
	},
	["Armor_Glacial_Chest"] = {
		Id = "Armor_Glacial_Chest",
		Name = "Pechera de Guardián Glacial",
		SetId = "Set_Glacial",
		Slot = "Chest",
		DefenseBonus = 121,
		HealthBonus = 495,
		Description = "Pieza del conjunto Guardián Glacial (Hielo).",
	},
	["Armor_Glacial_Gloves"] = {
		Id = "Armor_Glacial_Gloves",
		Name = "Guantes de Guardián Glacial",
		SetId = "Set_Glacial",
		Slot = "Gloves",
		DefenseBonus = 44,
		HealthBonus = 138,
		Description = "Pieza del conjunto Guardián Glacial (Hielo).",
	},
	["Armor_Glacial_Pants"] = {
		Id = "Armor_Glacial_Pants",
		Name = "Pantalones de Guardián Glacial",
		SetId = "Set_Glacial",
		Slot = "Pants",
		DefenseBonus = 88,
		HealthBonus = 358,
		Description = "Pieza del conjunto Guardián Glacial (Hielo).",
	},
	["Armor_Glacial_Boots"] = {
		Id = "Armor_Glacial_Boots",
		Name = "Botas de Guardián Glacial",
		SetId = "Set_Glacial",
		Slot = "Boots",
		DefenseBonus = 55,
		HealthBonus = 192,
		Description = "Pieza del conjunto Guardián Glacial (Hielo).",
	},
	["Armor_Glacial_Cape"] = {
		Id = "Armor_Glacial_Cape",
		Name = "Capa de Guardián Glacial",
		SetId = "Set_Glacial",
		Slot = "Cape",
		DefenseBonus = 77,
		HealthBonus = 275,
		Description = "Pieza del conjunto Guardián Glacial (Hielo).",
	},
	["Armor_Spectral_Helmet"] = {
		Id = "Armor_Spectral_Helmet",
		Name = "Casco de Rey Espectral",
		SetId = "Set_Spectral",
		Slot = "Helmet",
		DefenseBonus = 120,
		HealthBonus = 480,
		Description = "Pieza del conjunto Rey Espectral (Cripta).",
	},
	["Armor_Spectral_Chest"] = {
		Id = "Armor_Spectral_Chest",
		Name = "Pechera de Rey Espectral",
		SetId = "Set_Spectral",
		Slot = "Chest",
		DefenseBonus = 264,
		HealthBonus = 1080,
		Description = "Pieza del conjunto Rey Espectral (Cripta).",
	},
	["Armor_Spectral_Gloves"] = {
		Id = "Armor_Spectral_Gloves",
		Name = "Guantes de Rey Espectral",
		SetId = "Set_Spectral",
		Slot = "Gloves",
		DefenseBonus = 96,
		HealthBonus = 300,
		Description = "Pieza del conjunto Rey Espectral (Cripta).",
	},
	["Armor_Spectral_Pants"] = {
		Id = "Armor_Spectral_Pants",
		Name = "Pantalones de Rey Espectral",
		SetId = "Set_Spectral",
		Slot = "Pants",
		DefenseBonus = 192,
		HealthBonus = 780,
		Description = "Pieza del conjunto Rey Espectral (Cripta).",
	},
	["Armor_Spectral_Boots"] = {
		Id = "Armor_Spectral_Boots",
		Name = "Botas de Rey Espectral",
		SetId = "Set_Spectral",
		Slot = "Boots",
		DefenseBonus = 120,
		HealthBonus = 420,
		Description = "Pieza del conjunto Rey Espectral (Cripta).",
	},
	["Armor_Spectral_Cape"] = {
		Id = "Armor_Spectral_Cape",
		Name = "Capa de Rey Espectral",
		SetId = "Set_Spectral",
		Slot = "Cape",
		DefenseBonus = 168,
		HealthBonus = 600,
		Description = "Pieza del conjunto Rey Espectral (Cripta).",
	},
	["Armor_Archangel_Helmet"] = {
		Id = "Armor_Archangel_Helmet",
		Name = "Casco de Arcángel",
		SetId = "Set_Archangel",
		Slot = "Helmet",
		DefenseBonus = 250,
		HealthBonus = 1000,
		Description = "Pieza del conjunto Arcángel (Cielos).",
	},
	["Armor_Archangel_Chest"] = {
		Id = "Armor_Archangel_Chest",
		Name = "Pechera de Arcángel",
		SetId = "Set_Archangel",
		Slot = "Chest",
		DefenseBonus = 550,
		HealthBonus = 2250,
		Description = "Pieza del conjunto Arcángel (Cielos).",
	},
	["Armor_Archangel_Gloves"] = {
		Id = "Armor_Archangel_Gloves",
		Name = "Guantes de Arcángel",
		SetId = "Set_Archangel",
		Slot = "Gloves",
		DefenseBonus = 200,
		HealthBonus = 625,
		Description = "Pieza del conjunto Arcángel (Cielos).",
	},
	["Armor_Archangel_Pants"] = {
		Id = "Armor_Archangel_Pants",
		Name = "Pantalones de Arcángel",
		SetId = "Set_Archangel",
		Slot = "Pants",
		DefenseBonus = 400,
		HealthBonus = 1625,
		Description = "Pieza del conjunto Arcángel (Cielos).",
	},
	["Armor_Archangel_Boots"] = {
		Id = "Armor_Archangel_Boots",
		Name = "Botas de Arcángel",
		SetId = "Set_Archangel",
		Slot = "Boots",
		DefenseBonus = 250,
		HealthBonus = 875,
		Description = "Pieza del conjunto Arcángel (Cielos).",
	},
	["Armor_Archangel_Cape"] = {
		Id = "Armor_Archangel_Cape",
		Name = "Capa de Arcángel",
		SetId = "Set_Archangel",
		Slot = "Cape",
		DefenseBonus = 350,
		HealthBonus = 1250,
		Description = "Pieza del conjunto Arcángel (Cielos).",
	},
	["Armor_Void_Helmet"] = {
		Id = "Armor_Void_Helmet",
		Name = "Casco de Dios del Vacío",
		SetId = "Set_Void",
		Slot = "Helmet",
		DefenseBonus = 550,
		HealthBonus = 2200,
		Description = "Pieza del conjunto Dios del Vacío (Abismo).",
	},
	["Armor_Void_Chest"] = {
		Id = "Armor_Void_Chest",
		Name = "Pechera de Dios del Vacío",
		SetId = "Set_Void",
		Slot = "Chest",
		DefenseBonus = 1210,
		HealthBonus = 4950,
		Description = "Pieza del conjunto Dios del Vacío (Abismo).",
	},
	["Armor_Void_Gloves"] = {
		Id = "Armor_Void_Gloves",
		Name = "Guantes de Dios del Vacío",
		SetId = "Set_Void",
		Slot = "Gloves",
		DefenseBonus = 440,
		HealthBonus = 1375,
		Description = "Pieza del conjunto Dios del Vacío (Abismo).",
	},
	["Armor_Void_Pants"] = {
		Id = "Armor_Void_Pants",
		Name = "Pantalones de Dios del Vacío",
		SetId = "Set_Void",
		Slot = "Pants",
		DefenseBonus = 880,
		HealthBonus = 3575,
		Description = "Pieza del conjunto Dios del Vacío (Abismo).",
	},
	["Armor_Void_Boots"] = {
		Id = "Armor_Void_Boots",
		Name = "Botas de Dios del Vacío",
		SetId = "Set_Void",
		Slot = "Boots",
		DefenseBonus = 550,
		HealthBonus = 1925,
		Description = "Pieza del conjunto Dios del Vacío (Abismo).",
	},
	["Armor_Void_Cape"] = {
		Id = "Armor_Void_Cape",
		Name = "Capa de Dios del Vacío",
		SetId = "Set_Void",
		Slot = "Cape",
		DefenseBonus = 770,
		HealthBonus = 2750,
		Description = "Pieza del conjunto Dios del Vacío (Abismo).",
	},
}

function ArmorConfig.GetPiece(pieceId: string): ArmorPieceDefinition?
	return armorPieces[pieceId]
end

function ArmorConfig.GetSet(setId: string): ArmorSetDefinition?
	return armorSets[setId]
end

function ArmorConfig.GetAllSets(): { ArmorSetDefinition }
	local list = {}
	for _, s in pairs(armorSets) do
		table.insert(list, s)
	end
	return list
end

function ArmorConfig.GetAllPieces(): { ArmorPieceDefinition }
	local list = {}
	for _, p in pairs(armorPieces) do
		table.insert(list, p)
	end
	return list
end

function ArmorConfig.GetActiveSetBonus(equippedArmor: { [string]: string? }): ArmorSetDefinition?
	for _, setDef in pairs(armorSets) do
		local count = 0
		for slot, expectedId in pairs(setDef.Pieces) do
			if equippedArmor[slot] == expectedId then
				count += 1
			end
		end
		if count == 6 then
			return setDef
		end
	end
	return nil
end

function ArmorConfig.CalculateTotalStats(equippedArmor: { [string]: string? }): {
	TotalDefense: number,
	TotalHealth: number,
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
	local activeSet = ArmorConfig.GetActiveSetBonus(equippedArmor)
	return {
		TotalDefense = totalDef,
		TotalHealth = totalHp,
		ActiveSetBonus = activeSet,
	}
end

return table.freeze(ArmorConfig)
