--!strict
--[[
    RecipeConfig.luau
    Central Forge Recipes for Staves and Armor Sets in MAGIA ETERNA.
    Maps target items to their required dungeon materials, gold costs, and rebirth thresholds.
]]

export type RecipeDefinition = {
	TargetId: string,
	Name: string,
	Category: "Staff" | "Armor",
	RequiredMaterials: { [string]: number },
	RequiredCoins: number,
	RequiredRebirth: number,
	Description: string,
}

local RecipeConfig = {}

local recipes: { [string]: RecipeDefinition } = {
	-- Staves (Region 1: Bosque de los Susurros)
	["Staff_R1_002_BastonMaderaVieja"] = {
		TargetId = "Staff_R1_002_BastonMaderaVieja",
		Name = "Bastón de Madera Vieja",
		Category = "Staff",
		RequiredMaterials = {
			["MaderaAntigua"] = 10,
			["HojaMagica"] = 5,
		},
		RequiredCoins = 250,
		RequiredRebirth = 0,
		Description = "Una vara resistente moldeada a partir de raíces antiguas.",
	},
	["Staff_R1_005_VaraLuciernaga"] = {
		TargetId = "Staff_R1_005_VaraLuciernaga",
		Name = "Vara de Luciérnaga",
		Category = "Staff",
		RequiredMaterials = {
			["MaderaAntigua"] = 25,
			["HojaMagica"] = 15,
			["EsenciaVerde"] = 5,
		},
		RequiredCoins = 1200,
		RequiredRebirth = 0,
		Description = "Encantada con esencias verdes que emiten destellos mágicos.",
	},
	["Staff_R1_010_BastonNaturaleza"] = {
		TargetId = "Staff_R1_010_BastonNaturaleza",
		Name = "Bastón de la Naturaleza",
		Category = "Staff",
		RequiredMaterials = {
			["MaderaAntigua"] = 50,
			["EsenciaVerde"] = 20,
			["PiedraRunica"] = 5,
		},
		RequiredCoins = 5000,
		RequiredRebirth = 0,
		Description = "Poder vegetal concentrado en una empuñadura rúnica.",
	},
	["Staff_R1_020_BastonCorazonVerde"] = {
		TargetId = "Staff_R1_020_BastonCorazonVerde",
		Name = "Bastón del Corazón Verde",
		Category = "Staff",
		RequiredMaterials = {
			["MaderaAntigua"] = 150,
			["EsenciaVerde"] = 80,
			["PiedraRunica"] = 30,
			["NucleoTreant"] = 1,
		},
		RequiredCoins = 50000,
		RequiredRebirth = 1,
		Description = "Requiere el Núcleo del Treant Ancestral derrotado en la mazmorra.",
	},
	
	-- Armor Pieces (Region 1: Guardián del Bosque)
	["Armor_Forest_Helmet"] = {
		TargetId = "Armor_Forest_Helmet",
		Name = "Corona del Guardián del Bosque",
		Category = "Armor",
		RequiredMaterials = {
			["MaderaAntigua"] = 15,
			["HojaMagica"] = 10,
		},
		RequiredCoins = 600,
		RequiredRebirth = 0,
		Description = "Yelmo vegetal que agudiza la visión y protege la mente.",
	},
	["Armor_Forest_Chest"] = {
		TargetId = "Armor_Forest_Chest",
		Name = "Pechera del Guardián del Bosque",
		Category = "Armor",
		RequiredMaterials = {
			["MaderaAntigua"] = 30,
			["HojaMagica"] = 20,
			["EsenciaVerde"] = 8,
		},
		RequiredCoins = 1500,
		RequiredRebirth = 0,
		Description = "Pechera de corteza entrelazada que amortigua impactos.",
	},
	["Armor_Forest_Pants"] = {
		TargetId = "Armor_Forest_Pants",
		Name = "Grebas del Guardián del Bosque",
		Category = "Armor",
		RequiredMaterials = {
			["MaderaAntigua"] = 20,
			["HojaMagica"] = 12,
		},
		RequiredCoins = 1000,
		RequiredRebirth = 0,
		Description = "Pantalones de cuero vegetal flexibles para moverse con soltura.",
	},
	["Armor_Forest_Boots"] = {
		TargetId = "Armor_Forest_Boots",
		Name = "Botas del Guardián del Bosque",
		Category = "Armor",
		RequiredMaterials = {
			["MaderaAntigua"] = 15,
			["HojaMagica"] = 8,
		},
		RequiredCoins = 800,
		RequiredRebirth = 0,
		Description = "Botas ligeras que no dejan huellas en la hierba.",
	},
	["Armor_Forest_Gloves"] = {
		TargetId = "Armor_Forest_Gloves",
		Name = "Guanteletes del Guardián del Bosque",
		Category = "Armor",
		RequiredMaterials = {
			["MaderaAntigua"] = 12,
			["HojaMagica"] = 8,
		},
		RequiredCoins = 750,
		RequiredRebirth = 0,
		Description = "Guantes con espinas suaves que mejoran el agarre de los bastones.",
	},
	["Armor_Forest_Cape"] = {
		TargetId = "Armor_Forest_Cape",
		Name = "Capa de Hojas Ancestrales",
		Category = "Armor",
		RequiredMaterials = {
			["HojaMagica"] = 25,
			["EsenciaVerde"] = 10,
		},
		RequiredCoins = 1200,
		RequiredRebirth = 0,
		Description = "Capa tejida con hojas de roble dorado que fluye con el viento.",
	},
}

-- Retrieves recipe by target item ID
function RecipeConfig.GetRecipe(targetId: string): RecipeDefinition?
	return recipes[targetId]
end

-- Checks if recipe exists
function RecipeConfig.Exists(targetId: string): boolean
	return recipes[targetId] ~= nil
end

return table.freeze(RecipeConfig)
