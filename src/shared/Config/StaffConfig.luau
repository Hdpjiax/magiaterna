--!strict
--[[
    StaffConfig.luau
    Catalog and statistical configuration for Magic Staves in MAGIA ETERNA.
    Structured to scale seamlessly up to 120 staves across 6 distinct regions.
]]

export type StaffData = {
	Id: string,
	Name: string,
	Region: string,
	Rarity: "Común" | "Poco común" | "Raro" | "Épico" | "Legendario" | "Mítico",
	BasePower: number,
	Element: "Naturaleza" | "Fuego" | "Hielo" | "Oscuridad" | "Luz" | "Vacío",
	Description: string,
}

local StaffConfig = {}

-- Catalog of Initial Staves (Region 1: Bosque de los Susurros)
-- Scalable to 120 staves
local staves: { [string]: StaffData } = {
	["Staff_R1_001_RamaAprendiz"] = {
		Id = "Staff_R1_001_RamaAprendiz",
		Name = "Rama de Aprendiz",
		Region = "Bosque",
		Rarity = "Común",
		BasePower = 1,
		Element = "Naturaleza",
		Description = "Una sencilla rama impregnada con energía del bosque primigenio.",
	},
	["Staff_R1_002_BastonMaderaVieja"] = {
		Id = "Staff_R1_002_BastonMaderaVieja",
		Name = "Bastón de Madera Vieja",
		Region = "Bosque",
		Rarity = "Común",
		BasePower = 3,
		Element = "Naturaleza",
		Description = "Madera tallada a mano con un ligero resplandor verde.",
	},
	["Staff_R1_005_VaraLuciernaga"] = {
		Id = "Staff_R1_005_VaraLuciernaga",
		Name = "Vara de Luciérnaga",
		Region = "Bosque",
		Rarity = "Poco común",
		BasePower = 10,
		Element = "Naturaleza",
		Description = "Alberga pequeños destellos que iluminan los caminos oscuros.",
	},
	["Staff_R1_010_BastonNaturaleza"] = {
		Id = "Staff_R1_010_BastonNaturaleza",
		Name = "Bastón de la Naturaleza",
		Region = "Bosque",
		Rarity = "Raro",
		BasePower = 35,
		Element = "Naturaleza",
		Description = "Canaliza las raíces de la tierra para potenciar tus hechizos.",
	},
	["Staff_R1_015_VaraAntiguaArboleda"] = {
		Id = "Staff_R1_015_VaraAntiguaArboleda",
		Name = "Vara de la Antigua Arboleda",
		Region = "Bosque",
		Rarity = "Épico",
		BasePower = 120,
		Element = "Naturaleza",
		Description = "Forjada con la corteza de árboles milenarios del bosque.",
	},
	["Staff_R1_018_BastonBosqueEterno"] = {
		Id = "Staff_R1_018_BastonBosqueEterno",
		Name = "Bastón del Bosque Eterno",
		Region = "Bosque",
		Rarity = "Legendario",
		BasePower = 450,
		Element = "Naturaleza",
		Description = "Un cristal esmeralda late con el pulso vivo de la arboleda.",
	},
	["Staff_R1_020_BastonCorazonVerde"] = {
		Id = "Staff_R1_020_BastonCorazonVerde",
		Name = "Bastón del Corazón Verde",
		Region = "Bosque",
		Rarity = "Mítico",
		BasePower = 1500,
		Element = "Naturaleza",
		Description = "El bastón supremo del Bosque de los Susurros. Poder vegetal absoluto.",
	},
	
	-- Region 2 Sample Staves (Minas del Fuego Eterno)
	["Staff_R2_021_VaraCarbon"] = {
		Id = "Staff_R2_021_VaraCarbon",
		Name = "Vara de Carbón",
		Region = "Minas",
		Rarity = "Común",
		BasePower = 1800,
		Element = "Fuego",
		Description = "Emana brasas calientes capaces de encender la magia.",
	},
	["Staff_R2_035_VaraDragonRojo"] = {
		Id = "Staff_R2_035_VaraDragonRojo",
		Name = "Vara del Dragón Rojo",
		Region = "Minas",
		Rarity = "Épico",
		BasePower = 8500,
		Element = "Fuego",
		Description = "Impregnada con el aliento abrasador del Dragón de Magma.",
	},
	
	-- Endgame Capstone Staff
	["Staff_R6_120_BastonMagiaEterna"] = {
		Id = "Staff_R6_120_BastonMagiaEterna",
		Name = "Bastón de la Magia Eterna",
		Region = "Abismo",
		Rarity = "Mítico",
		BasePower = 500000,
		Element = "Vacío",
		Description = "El arma definitiva. Unifica el poder arcano de todas las dimensiones.",
	},
}

-- Retrieves staff configuration by ID
function StaffConfig.GetStaff(id: string): StaffData?
	return staves[id]
end

-- Checks if a staff ID exists in the catalog
function StaffConfig.Exists(id: string): boolean
	return staves[id] ~= nil
end

-- Returns list of all registered staff IDs
function StaffConfig.GetAllIds(): { string }
	local ids = {}
	for id, _ in pairs(staves) do
		table.insert(ids, id)
	end
	return ids
end

return table.freeze(StaffConfig)
