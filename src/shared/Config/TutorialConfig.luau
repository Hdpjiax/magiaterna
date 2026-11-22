--!strict
--[[
    TutorialConfig.luau
    Configuración oficial del Tutorial de Onboarding para MAGIA ETERNA (Alpha 0.1).
    Define los 6 pasos del bucle central con objetivos, coordenadas 3D para waypoints
    y recompensas garantizadas al completar.
]]

export type TutorialStep = {
	StepNumber: number,
	Title: string,
	Instruction: string,
	TargetLocation: Vector3,
	TargetName: string,
	ActionKey: string,
	TargetAmount: number,
	HintText: string,
}

local TutorialConfig = {}

local steps: { [number]: TutorialStep } = {
	[1] = {
		StepNumber = 1,
		Title = "⚡ Entrenar Magia",
		Instruction = "Camina al Campo de Entrenamiento y acumula 50 de Magia.",
		TargetLocation = Vector3.new(80, 3, 0),
		TargetName = "Campo de Entrenamiento",
		ActionKey = "TrainMagic",
		TargetAmount = 50,
		HintText = "Haz clic en el orbe o entrena frente al dummy de paja.",
	},
	[2] = {
		StepNumber = 2,
		Title = "🥚 Comprar Mascota",
		Instruction = "Ve al Pabellón de Mascotas y compra tu primer Huevo del Bosque.",
		TargetLocation = Vector3.new(-75, 3, 45),
		TargetName = "Pabellón de Mascotas",
		ActionKey = "BuyEgg",
		TargetAmount = 1,
		HintText = "Interactúa con el expositor de huevos (cuesta 100 de Oro).",
	},
	[3] = {
		StepNumber = 3,
		Title = "🐾 Equipar Compañero",
		Instruction = "Abre el menú de Mascotas en tu pantalla y equipa a tu nuevo aliado.",
		TargetLocation = Vector3.new(-75, 3, 45),
		TargetName = "Menú de Mascotas",
		ActionKey = "EquipPet",
		TargetAmount = 1,
		HintText = "Pulsa el botón 'Mascotas' en el HUD lateral y selecciona 'Equipar'.",
	},
	[4] = {
		StepNumber = 4,
		Title = "🌀 Cruzar al Bosque",
		Instruction = "Dirígete al Portal 1 y viaja a la Mazmorra 'Bosque de los Susurros'.",
		TargetLocation = Vector3.new(-38, 3, -40),
		TargetName = "Portal 1: Bosque de los Susurros",
		ActionKey = "EnterDungeon",
		TargetAmount = 1,
		HintText = "Acércate al portal verde esmeralda y pulsa interactuar [E].",
	},
	[5] = {
		StepNumber = 5,
		Title = "⚔️ Primera Victoria",
		Instruction = "Derrota a los Slimes de la primera sala para abrir la Puerta Rúnica.",
		TargetLocation = Vector3.new(800, 52, 10),
		TargetName = "Sala 1: Ruinas de Entrada",
		ActionKey = "ClearRoom1",
		TargetAmount = 1,
		HintText = "Lanza tus proyectiles mágicos contra los 4 Slimes verdes.",
	},
	[6] = {
		StepNumber = 6,
		Title = "⚒️ Forja Tu Bastón",
		Instruction = "Regresa al Lobby, ve a la Forja Real y crea tu primer bastón mejorado.",
		TargetLocation = Vector3.new(-85, 3, -10),
		TargetName = "Taller de la Forja Real",
		ActionKey = "ForgeStaff",
		TargetAmount = 1,
		HintText = "Usa la Madera y Hojas obtenidas para forjar un bastón superior.",
	},
}

TutorialConfig.TOTAL_STEPS = 6

TutorialConfig.FINAL_REWARDS = {
	Coins = 500,
	Essences = 25,
	BadgeName = "Iniciado en la Magia",
}

function TutorialConfig.GetStep(stepNum: number): TutorialStep?
	return steps[stepNum]
end

function TutorialConfig.GetAllSteps(): { [number]: TutorialStep }
	return steps
end

return table.freeze(TutorialConfig)
