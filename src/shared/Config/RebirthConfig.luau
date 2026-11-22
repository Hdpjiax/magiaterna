--!strict
--[[
    RebirthConfig.luau
    Formulas, scaling curves, and milestone rewards for the Rebirth System in MAGIA ETERNA.
]]

export type RebirthMilestone = {
	RebirthLevel: number,
	Title: string,
	AuraName: string?,
	BonusPetSlots: number?,
	RewardStaffId: string?,
	RewardPetId: string?,
	BonusShards: number,
}

local RebirthConfig = {}

-- Calculates the Magic required to perform the next rebirth
function RebirthConfig.GetCost(currentRebirths: number): number
	-- Cost(R) = 10,000 * 10^(R * 0.60)
	local cost = 10000 * (10 ^ (currentRebirths * 0.60))
	return math.floor(cost)
end

-- Calculates the permanent magic multiplier provided by a given rebirth level
function RebirthConfig.GetMultiplier(rebirthLevel: number): number
	if rebirthLevel <= 0 then
		return 1.0
	end
	-- Scales smoothly: R1 = 1.25x, R2 = 1.50x, R5 = 2.75x, R10 = 6.0x, R25 = 25.0x
	if rebirthLevel < 5 then
		return 1.0 + (rebirthLevel * 0.25)
	elseif rebirthLevel < 10 then
		return 2.75 + ((rebirthLevel - 5) * 0.65)
	elseif rebirthLevel < 25 then
		return 6.0 + ((rebirthLevel - 10) * 1.25)
	else
		return 25.0 + ((rebirthLevel - 25) * 3.50)
	end
end

-- Special Milestone Rewards
local milestones: { [number]: RebirthMilestone } = {
	[1] = {
		RebirthLevel = 1,
		Title = "Aprendiz de la Magia",
		BonusShards = 1,
	},
	[2] = {
		RebirthLevel = 2,
		Title = "Iniciado de Fuego",
		BonusShards = 2,
	},
	[3] = {
		RebirthLevel = 3,
		Title = "Conjurador Espectral",
		AuraName = "AuraEspectralMenor",
		BonusShards = 3,
	},
	[5] = {
		RebirthLevel = 5,
		Title = "Señor de las Bestias",
		BonusPetSlots = 1, -- Unlocks 4th equipped pet slot!
		BonusShards = 5,
	},
	[10] = {
		RebirthLevel = 10,
		Title = "Mago Maestro",
		BonusPetSlots = 1, -- Unlocks 5th equipped pet slot!
		BonusShards = 10,
	},
	[25] = {
		RebirthLevel = 25,
		Title = "Archimago del Infinito",
		BonusShards = 25,
	},
}

-- Checks if a milestone exists at a given rebirth level
function RebirthConfig.GetMilestone(rebirthLevel: number): RebirthMilestone?
	return milestones[rebirthLevel]
end

return table.freeze(RebirthConfig)
