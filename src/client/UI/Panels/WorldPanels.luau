--!strict
--[[
    WorldPanels.luau
    Renders Mazmorras (6 regions x 5 difficulties), Rebirth (cost, multiplier, milestone), and Misiones.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local DungeonConfig = require(Shared:WaitForChild("Config"):WaitForChild("DungeonConfig") :: ModuleScript)
local RebirthConfig = require(Shared:WaitForChild("Config"):WaitForChild("RebirthConfig") :: ModuleScript)
local QuestConfig = require(Shared:WaitForChild("Config"):WaitForChild("QuestConfig") :: ModuleScript)
local NumberFormatter = require(Shared:WaitForChild("Modules"):WaitForChild("NumberFormatter") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local UITheme = require(script.Parent.Parent:WaitForChild("UITheme") :: ModuleScript)

local WorldPanels = {}

function WorldPanels.RenderDungeons(modal: UITheme.ModalHandle, _profile: any)
	modal.ClearContent()

	for _, dungeon in ipairs(DungeonConfig.GetAllDungeons()) do
		local card = UITheme.CreateCard(modal.Content, 88)

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(0.9, 0, 0.38, 0)
		title.Position = UDim2.new(0, 12, 0, 4)
		title.BackgroundTransparency = 1
		title.Text = string.format("%s (Nv. %s · %d salas)", dungeon.Name, dungeon.RecommendedLevel, dungeon.RoomsCount)
		title.TextColor3 = UITheme.Colors.AccentGold
		title.Font = Enum.Font.GothamBold
		title.TextSize = 14
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.ZIndex = 23
		title.Parent = card

		-- 5 Difficulty buttons (I to V)
		for diff = 1, 5 do
			local dBtn = Instance.new("TextButton")
			dBtn.Size = UDim2.new(0, 74, 0, 32)
			dBtn.Position = UDim2.new(0, 12 + (diff - 1) * 82, 0.48, 0)
			dBtn.Text = "Dif. " .. NumberFormatter.ToRoman(diff)
			dBtn.TextSize = 12
			dBtn.ZIndex = 23
			UITheme.StyleButton(dBtn, if diff == 5 then UITheme.Colors.Danger else UITheme.Colors.AccentBlue)
			dBtn.Activated:Connect(function()
				NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestEnterDungeon):FireServer(dungeon.Id, diff)
				modal.SetVisible(false)
			end)
			dBtn.Parent = card
		end
	end
end

function WorldPanels.RenderRebirth(modal: UITheme.ModalHandle, profile: any)
	modal.ClearContent()
	local currentRebirths = (profile and profile.Rebirths) or 0
	local currentMagic = (profile and profile.Magic) or 0
	local cost = RebirthConfig.GetCost(currentRebirths)
	local currMult = RebirthConfig.GetMultiplier(currentRebirths)
	local nextMult = RebirthConfig.GetMultiplier(currentRebirths + 1)
	local milestone = RebirthConfig.GetMilestone(currentRebirths + 1)

	local card = UITheme.CreateCard(modal.Content, 180)

	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1, -24, 0.65, 0)
	info.Position = UDim2.new(0, 12, 0, 10)
	info.BackgroundTransparency = 1
	info.TextWrapped = true
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.TextYAlignment = Enum.TextYAlignment.Top
	info.Font = Enum.Font.GothamSemibold
	info.TextSize = 14
	info.TextColor3 = UITheme.Colors.TextPrimary
	local milestoneLine = if milestone then ("\nHito siguiente: " .. milestone.Title .. string.format(" (+%d Fragmentos)", milestone.BonusShards)) else ""
	info.Text = string.format(
		"Rebirth Actual: %d (x%.2f Magia)\nSiguiente Rebirth: %d (x%.2f Magia)\nCosto requerido: %s / %s Magia%s",
		currentRebirths, currMult, currentRebirths + 1, nextMult,
		NumberFormatter.FormatNumber(currentMagic), NumberFormatter.FormatNumber(cost),
		milestoneLine
	)
	info.ZIndex = 23
	info.Parent = card

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 220, 0, 42)
	btn.Position = UDim2.new(0.5, -110, 1, -54)
	btn.Text = "RENACER AHORA"
	btn.TextSize = 15
	btn.ZIndex = 23
	local canAfford = currentMagic >= cost
	UITheme.StyleButton(btn, if canAfford then UITheme.Colors.AccentGold else Color3.fromRGB(70, 70, 90))
	if canAfford then btn.TextColor3 = Color3.fromRGB(20, 20, 30) end
	btn.Activated:Connect(function()
		NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestRebirth):FireServer()
	end)
	btn.Parent = card
end

function WorldPanels.RenderQuests(modal: UITheme.ModalHandle, profile: any)
	modal.ClearContent()
	local questProgress = (profile and profile.Quests) or {}

	for _, q in ipairs(QuestConfig.GetAllQuests()) do
		local rec = questProgress[q.Id]
		local prog = if rec then rec.Progress else 0
		local claimed = if rec then rec.Claimed else false
		local ready = prog >= q.TargetAmount and not claimed

		local card = UITheme.CreateCard(modal.Content, 70)

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(0.68, 0, 0.45, 0)
		title.Position = UDim2.new(0, 12, 0, 4)
		title.BackgroundTransparency = 1
		title.Text = string.format("[%s] %s (%d/%d)", q.Category, q.Name, prog, q.TargetAmount)
		title.TextColor3 = UITheme.Colors.AccentGold
		title.Font = Enum.Font.GothamBold
		title.TextSize = 13
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.ZIndex = 23
		title.Parent = card

		local desc = Instance.new("TextLabel")
		desc.Size = UDim2.new(0.68, 0, 0.45, 0)
		desc.Position = UDim2.new(0, 12, 0.48, 0)
		desc.BackgroundTransparency = 1
		desc.Text = string.format("%s — Recompensa: %s Oro, %d Esencias", q.Description, NumberFormatter.FormatNumber(q.RewardCoins), q.RewardEssences)
		desc.TextColor3 = UITheme.Colors.TextMuted
		desc.Font = Enum.Font.Gotham
		desc.TextSize = 11
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.ZIndex = 23
		desc.Parent = card

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 108, 0, 34)
		btn.Position = UDim2.new(1, -120, 0.5, -17)
		btn.TextSize = 12
		btn.ZIndex = 23
		if claimed then
			btn.Text = "Reclamada"
			UITheme.StyleButton(btn, Color3.fromRGB(60, 65, 80))
		elseif ready then
			btn.Text = "Reclamar"
			UITheme.StyleButton(btn, UITheme.Colors.Success)
			btn.Activated:Connect(function()
				NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestClaimQuest):FireServer(q.Id)
			end)
		else
			btn.Text = "En progreso"
			UITheme.StyleButton(btn, UITheme.Colors.AccentPurple)
		end
		btn.Parent = card
	end
end

return WorldPanels
