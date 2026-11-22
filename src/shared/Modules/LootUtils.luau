--!strict
--[[
    LootUtils.luau
    Server-safe weighted random selection and dungeon loot table evaluation for MAGIA ETERNA.
]]

export type WeightedEntry = {
	Weight: number,
	[string]: any,
}

export type LootEntry = {
	ItemType: "Coin" | "Essence" | "Material",
	Id: string,
	MinAmount: number,
	MaxAmount: number,
	DropChance: number,
}

export type LootResult = {
	Coins: number,
	Essences: number,
	Materials: { [string]: number },
}

local LootUtils = {}

local rng = Random.new()

-- Performs a weighted random roll across an array of entries having .Weight
function LootUtils.RollWeighted<T>(entries: { T & { Weight: number } }, luckMultiplier: number?): T?
	if #entries == 0 then
		return nil
	end

	local totalWeight = 0
	for _, entry in ipairs(entries) do
		totalWeight += math.max(0, entry.Weight)
	end

	if totalWeight <= 0 then
		return entries[1]
	end

	local roll = rng:NextNumber(0, totalWeight)
	local cumulative = 0
	for _, entry in ipairs(entries) do
		cumulative += math.max(0, entry.Weight)
		if roll <= cumulative then
			return entry
		end
	end

	return entries[#entries]
end

-- Rolls an integer amount between min and max inclusive
function LootUtils.RollAmount(minAmount: number, maxAmount: number): number
	local lo = math.min(minAmount, maxAmount)
	local hi = math.max(minAmount, maxAmount)
	return rng:NextInteger(lo, hi)
end

-- Evaluates a dungeon loot table with reward and luck multipliers
function LootUtils.RollLootTable(
	lootTable: { LootEntry },
	rewardMultiplier: number?,
	luckBonusPercent: number?,
	materialsBonusPercent: number?
): LootResult
	local rMult = rewardMultiplier or 1.0
	local luckMult = 1.0 + ((luckBonusPercent or 0) / 100)
	local matMult = 1.0 + ((materialsBonusPercent or 0) / 100)

	local result: LootResult = {
		Coins = 0,
		Essences = 0,
		Materials = {},
	}

	for _, entry in ipairs(lootTable) do
		local effectiveChance = math.clamp(entry.DropChance * luckMult, 0, 1)
		if rng:NextNumber() <= effectiveChance then
			local baseAmount = LootUtils.RollAmount(entry.MinAmount, entry.MaxAmount)
			if entry.ItemType == "Coin" then
				result.Coins += math.max(1, math.floor(baseAmount * rMult))
			elseif entry.ItemType == "Essence" then
				result.Essences += math.max(1, math.floor(baseAmount * rMult))
			elseif entry.ItemType == "Material" then
				local qty = math.max(1, math.floor(baseAmount * matMult))
				result.Materials[entry.Id] = (result.Materials[entry.Id] or 0) + qty
			end
		end
	end

	return result
end

return table.freeze(LootUtils)
