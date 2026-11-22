--!strict
--[[
    EquipmentPanels.luau
    Renders Bastones (120-staff catalog), Armadura (6-piece sets), and Forja (crafting + 5-7s animation).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local StaffConfig = require(Shared:WaitForChild("Config"):WaitForChild("StaffConfig") :: ModuleScript)
local ArmorConfig = require(Shared:WaitForChild("Config"):WaitForChild("ArmorConfig") :: ModuleScript)
local RecipeConfig = require(Shared:WaitForChild("Config"):WaitForChild("RecipeConfig") :: ModuleScript)
local RarityUtils = require(Shared:WaitForChild("Modules"):WaitForChild("RarityUtils") :: ModuleScript)
local NumberFormatter = require(Shared:WaitForChild("Modules"):WaitForChild("NumberFormatter") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local Controllers = script.Parent.Parent.Parent:WaitForChild("Controllers")
local ForgeController = require(Controllers:WaitForChild("ForgeController") :: ModuleScript)
local EffectsController = require(Controllers:WaitForChild("EffectsController") :: ModuleScript)

local UITheme = require(script.Parent.Parent:WaitForChild("UITheme") :: ModuleScript)

local EquipmentPanels = {}

function EquipmentPanels.RenderStaffs(modal: UITheme.ModalHandle, profile: any)
	modal.ClearContent()
	local owned = (profile and profile.OwnedStaffs) or {}
	local equipped = profile and profile.EquippedStaff

	for _, staff in ipairs(StaffConfig.GetAllStaves()) do
		local isOwned = owned[staff.Id] == true
		local isEquipped = equipped == staff.Id
		local card = UITheme.CreateCard(modal.Content, 64)

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(0.65, 0, 0.5, 0)
		title.Position = UDim2.new(0, 12, 0, 4)
		title.BackgroundTransparency = 1
		title.Text = string.format("#%03d %s [%s]", staff.Number, staff.Name, staff.Rarity)
		title.TextColor3 = RarityUtils.GetColor(staff.Rarity)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 14
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.ZIndex = 23
		title.Parent = card

		local stats = Instance.new("TextLabel")
		stats.Size = UDim2.new(0.65, 0, 0.45, 0)
		stats.Position = UDim2.new(0, 12, 0.5, 0)
		stats.BackgroundTransparency = 1
		stats.Text = string.format("%s · Poder: %s · Daño: %s", staff.Region, NumberFormatter.FormatNumber(staff.BasePower), NumberFormatter.FormatNumber(staff.Damage))
		stats.TextColor3 = UITheme.Colors.TextMuted
		stats.Font = Enum.Font.Gotham
		stats.TextSize = 12
		stats.TextXAlignment = Enum.TextXAlignment.Left
		stats.ZIndex = 23
		stats.Parent = card

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 110, 0, 34)
		btn.Position = UDim2.new(1, -122, 0.5, -17)
		btn.TextSize = 13
		btn.ZIndex = 23
		if isEquipped then
			btn.Text = "Equipado"
			UITheme.StyleButton(btn, UITheme.Colors.Success)
		elseif isOwned then
			btn.Text = "Equipar"
			UITheme.StyleButton(btn, UITheme.Colors.AccentBlue)
			btn.Activated:Connect(function()
				ForgeController.EquipStaff(staff.Id)
			end)
		else
			btn.Text = "Bloqueado"
			UITheme.StyleButton(btn, Color3.fromRGB(70, 70, 90))
		end
		btn.Parent = card
	end
end

function EquipmentPanels.RenderArmor(modal: UITheme.ModalHandle, profile: any)
	modal.ClearContent()
	local equipped = (profile and profile.EquippedArmor) or {}
	local inv = (profile and profile.ArmorInventory) or {}
	local stats = ArmorConfig.CalculateTotalStats(equipped)

	local summaryCard = UITheme.CreateCard(modal.Content, 52)
	local summaryLbl = Instance.new("TextLabel")
	summaryLbl.Size = UDim2.new(1, -24, 1, 0)
	summaryLbl.Position = UDim2.new(0, 12, 0, 0)
	summaryLbl.BackgroundTransparency = 1
	local setText = if stats.ActiveSetBonus then ("Set Activo: " .. stats.ActiveSetBonus.SetName) else "Sin bonus de set completo"
	summaryLbl.Text = string.format("Defensa Total: %d | Vida Extra: +%d | %s", stats.TotalDefense, stats.TotalHealth, setText)
	summaryLbl.TextColor3 = UITheme.Colors.AccentGold
	summaryLbl.Font = Enum.Font.GothamBold
	summaryLbl.TextSize = 13
	summaryLbl.TextXAlignment = Enum.TextXAlignment.Left
	summaryLbl.ZIndex = 23
	summaryLbl.Parent = summaryCard

	for _, piece in ipairs(ArmorConfig.GetAllPieces()) do
		local qty = inv[piece.Id] or 0
		local isEq = equipped[piece.Slot] == piece.Id
		local card = UITheme.CreateCard(modal.Content, 60)

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.65, 0, 1, 0)
		lbl.Position = UDim2.new(0, 12, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = string.format("%s (%s) — DEF +%d | HP +%d", piece.Name, piece.Slot, piece.DefenseBonus, piece.HealthBonus)
		lbl.TextColor3 = UITheme.Colors.TextPrimary
		lbl.Font = Enum.Font.GothamSemibold
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.ZIndex = 23
		lbl.Parent = card

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 110, 0, 32)
		btn.Position = UDim2.new(1, -122, 0.5, -16)
		btn.TextSize = 13
		btn.ZIndex = 23
		if isEq then
			btn.Text = "Desequipar"
			UITheme.StyleButton(btn, UITheme.Colors.Danger)
			btn.Activated:Connect(function()
				NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestUnequipArmor):FireServer(piece.Slot)
			end)
		elseif qty > 0 then
			btn.Text = "Equipar"
			UITheme.StyleButton(btn, UITheme.Colors.AccentBlue)
			btn.Activated:Connect(function()
				NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestEquipArmor):FireServer(piece.Id)
			end)
		else
			btn.Text = "Forjar"
			UITheme.StyleButton(btn, Color3.fromRGB(70, 70, 90))
		end
		btn.Parent = card
	end
end

function EquipmentPanels.RenderForge(modal: UITheme.ModalHandle, profile: any)
	modal.ClearContent()
	local mats = (profile and profile.Materials) or {}

	-- Status banner for 5-7s Forge Animation + Skip button
	local statusCard = UITheme.CreateCard(modal.Content, 48)
	local statusLbl = Instance.new("TextLabel")
	statusLbl.Size = UDim2.new(0.72, 0, 1, 0)
	statusLbl.Position = UDim2.new(0, 12, 0, 0)
	statusLbl.BackgroundTransparency = 1
	statusLbl.Text = "Selecciona una receta para forjar en el yunque."
	statusLbl.TextColor3 = UITheme.Colors.AccentGold
	statusLbl.Font = Enum.Font.GothamSemibold
	statusLbl.TextSize = 13
	statusLbl.TextXAlignment = Enum.TextXAlignment.Left
	statusLbl.ZIndex = 23
	statusLbl.Parent = statusCard

	local skipBtn = Instance.new("TextButton")
	skipBtn.Size = UDim2.new(0, 110, 0, 30)
	skipBtn.Position = UDim2.new(1, -120, 0.5, -15)
	skipBtn.Text = "Saltar Anim."
	skipBtn.TextSize = 12
	skipBtn.ZIndex = 23
	UITheme.StyleButton(skipBtn, UITheme.Colors.AccentPurple)
	skipBtn.Activated:Connect(function()
		EffectsController.SkipForgeSequence()
	end)
	skipBtn.Parent = statusCard

	for _, recipe in ipairs(RecipeConfig.GetAllRecipes()) do
		local card = UITheme.CreateCard(modal.Content, 72)

		local reqParts = {}
		for matId, reqAmt in pairs(recipe.RequiredMaterials) do
			local have = mats[matId] or 0
			table.insert(reqParts, string.format("%s %d/%d", matId, have, reqAmt))
		end

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(0.68, 0, 0.45, 0)
		title.Position = UDim2.new(0, 12, 0, 4)
		title.BackgroundTransparency = 1
		title.Text = string.format("[%s] %s — %s Oro (Rebirth %d+)", recipe.Category, recipe.Name, NumberFormatter.FormatNumber(recipe.RequiredCoins), recipe.RequiredRebirth)
		title.TextColor3 = UITheme.Colors.TextPrimary
		title.Font = Enum.Font.GothamBold
		title.TextSize = 13
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.ZIndex = 23
		title.Parent = card

		local reqLbl = Instance.new("TextLabel")
		reqLbl.Size = UDim2.new(0.68, 0, 0.5, 0)
		reqLbl.Position = UDim2.new(0, 12, 0.45, 0)
		reqLbl.BackgroundTransparency = 1
		reqLbl.Text = table.concat(reqParts, " | ")
		reqLbl.TextColor3 = UITheme.Colors.TextMuted
		reqLbl.Font = Enum.Font.Gotham
		reqLbl.TextSize = 11
		reqLbl.TextXAlignment = Enum.TextXAlignment.Left
		reqLbl.ZIndex = 23
		reqLbl.Parent = card

		local forgeBtn = Instance.new("TextButton")
		forgeBtn.Size = UDim2.new(0, 100, 0, 34)
		forgeBtn.Position = UDim2.new(1, -112, 0.5, -17)
		forgeBtn.Text = "Forjar"
		forgeBtn.TextSize = 13
		forgeBtn.ZIndex = 23
		UITheme.StyleButton(forgeBtn, UITheme.Colors.AccentGold)
		forgeBtn.TextColor3 = Color3.fromRGB(20, 20, 30)
		forgeBtn.Activated:Connect(function()
			EffectsController.PlayForgeSequence(recipe.Name, UITheme.Colors.AccentGold, function(stepText)
				statusLbl.Text = stepText
			end, function()
				if recipe.Category == "Staff" then
					ForgeController.Forge(recipe.TargetId)
				else
					NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestForgeArmor):FireServer(recipe.TargetId)
				end
			end)
		end)
		forgeBtn.Parent = card
	end
end

return EquipmentPanels
