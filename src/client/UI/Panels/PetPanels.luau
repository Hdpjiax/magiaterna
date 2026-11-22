--!strict
--[[
    PetPanels.luau
    Renders Mascotas (inventory, equip, lock, fuse, safe sell), Huevos (6 regional eggs + odds), and Colecciones.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local PetConfig = require(Shared:WaitForChild("Config"):WaitForChild("PetConfig") :: ModuleScript)
local EggConfig = require(Shared:WaitForChild("Config"):WaitForChild("EggConfig") :: ModuleScript)
local StaffConfig = require(Shared:WaitForChild("Config"):WaitForChild("StaffConfig") :: ModuleScript)
local RarityUtils = require(Shared:WaitForChild("Modules"):WaitForChild("RarityUtils") :: ModuleScript)
local NumberFormatter = require(Shared:WaitForChild("Modules"):WaitForChild("NumberFormatter") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local UITheme = require(script.Parent.Parent:WaitForChild("UITheme") :: ModuleScript)

local PetPanels = {}

function PetPanels.RenderPets(modal: UITheme.ModalHandle, profile: any)
	modal.ClearContent()
	local inv = (profile and profile.PetInventory) or {}
	local equippedList = (profile and profile.EquippedPets) or {}
	local maxEq = (profile and profile.MaxEquippedPets) or 3

	local equippedSet: { [string]: boolean } = {}
	for _, uuid in ipairs(equippedList) do
		equippedSet[uuid] = true
	end

	local headerCard = UITheme.CreateCard(modal.Content, 44)
	local headerLbl = Instance.new("TextLabel")
	headerLbl.Size = UDim2.new(1, -24, 1, 0)
	headerLbl.Position = UDim2.new(0, 12, 0, 0)
	headerLbl.BackgroundTransparency = 1
	headerLbl.Text = string.format("Mascotas Equipadas: %d / %d", #equippedList, maxEq)
	headerLbl.TextColor3 = UITheme.Colors.AccentGold
	headerLbl.Font = Enum.Font.GothamBold
	headerLbl.TextSize = 14
	headerLbl.TextXAlignment = Enum.TextXAlignment.Left
	headerLbl.ZIndex = 23
	headerLbl.Parent = headerCard

	for uuid, pet in pairs(inv) do
		local def = PetConfig.GetPet(pet.Species)
		local stats = PetConfig.CalculateStats(pet.Species, pet.Tier)
		local isEq = equippedSet[uuid] == true
		local card = UITheme.CreateCard(modal.Content, 68)

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(0.55, 0, 0.5, 0)
		title.Position = UDim2.new(0, 12, 0, 4)
		title.BackgroundTransparency = 1
		title.Text = string.format("%s [%s · %s]", def and def.Name or pet.Species, pet.Tier, def and def.Rarity or "Común")
		title.TextColor3 = RarityUtils.GetColor(def and def.Rarity or "Común")
		title.Font = Enum.Font.GothamBold
		title.TextSize = 13
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.ZIndex = 23
		title.Parent = card

		local sub = Instance.new("TextLabel")
		sub.Size = UDim2.new(0.55, 0, 0.45, 0)
		sub.Position = UDim2.new(0, 12, 0.5, 0)
		sub.BackgroundTransparency = 1
		sub.Text = string.format("+%d%% Magia | +%d%% Oro | +%d%% Suerte", stats.MagicBonus, stats.CoinsBonus, stats.LuckBonus)
		sub.TextColor3 = UITheme.Colors.TextMuted
		sub.Font = Enum.Font.Gotham
		sub.TextSize = 11
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.ZIndex = 23
		sub.Parent = card

		-- Equip/Unequip
		local eqBtn = Instance.new("TextButton")
		eqBtn.Size = UDim2.new(0, 84, 0, 30)
		eqBtn.Position = UDim2.new(1, -248, 0.5, -15)
		eqBtn.TextSize = 12
		eqBtn.ZIndex = 23
		eqBtn.Text = if isEq then "Quitar" else "Equipar"
		UITheme.StyleButton(eqBtn, if isEq then UITheme.Colors.AccentPurple else UITheme.Colors.AccentBlue)
		eqBtn.Activated:Connect(function()
			local evName = if isEq then NetworkEndpoints.Events.RequestUnequipPet else NetworkEndpoints.Events.RequestEquipPet
			NetworkEndpoints.GetEvent(evName):FireServer(uuid)
		end)
		eqBtn.Parent = card

		-- Lock Toggle
		local lockBtn = Instance.new("TextButton")
		lockBtn.Size = UDim2.new(0, 72, 0, 30)
		lockBtn.Position = UDim2.new(1, -156, 0.5, -15)
		lockBtn.TextSize = 12
		lockBtn.ZIndex = 23
		lockBtn.Text = if pet.Locked then "🔒 Fijo" else "🔓 Libre"
		UITheme.StyleButton(lockBtn, if pet.Locked then UITheme.Colors.AccentGold else Color3.fromRGB(70, 70, 90))
		lockBtn.Activated:Connect(function()
			NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestLockPet):FireServer(uuid)
		end)
		lockBtn.Parent = card

		-- Safe Sell
		local sellBtn = Instance.new("TextButton")
		sellBtn.Size = UDim2.new(0, 70, 0, 30)
		sellBtn.Position = UDim2.new(1, -78, 0.5, -15)
		sellBtn.TextSize = 12
		sellBtn.ZIndex = 23
		sellBtn.Text = "Vender"
		UITheme.StyleButton(sellBtn, UITheme.Colors.Danger)
		sellBtn.Activated:Connect(function()
			NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestSellPet):FireServer(uuid)
		end)
		sellBtn.Parent = card
	end
end

function PetPanels.RenderEggs(modal: UITheme.ModalHandle, _profile: any)
	modal.ClearContent()

	for _, egg in ipairs(EggConfig.GetAllEggs()) do
		local card = UITheme.CreateCard(modal.Content, 84)

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(0.7, 0, 0.4, 0)
		title.Position = UDim2.new(0, 12, 0, 4)
		title.BackgroundTransparency = 1
		title.Text = string.format("%s (%s) — %s Oro", egg.Name, egg.Region, NumberFormatter.FormatNumber(egg.CostCoins))
		title.TextColor3 = UITheme.Colors.AccentGold
		title.Font = Enum.Font.GothamBold
		title.TextSize = 14
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.ZIndex = 23
		title.Parent = card

		local oddsParts = {}
		for _, drop in ipairs(egg.Drops) do
			table.insert(oddsParts, string.format("%s: %.1f%%", drop.Rarity, drop.Percentage))
		end

		local oddsLbl = Instance.new("TextLabel")
		oddsLbl.Size = UDim2.new(0.7, 0, 0.55, 0)
		oddsLbl.Position = UDim2.new(0, 12, 0.4, 0)
		oddsLbl.BackgroundTransparency = 1
		oddsLbl.Text = table.concat(oddsParts, " · ")
		oddsLbl.TextColor3 = UITheme.Colors.TextMuted
		oddsLbl.Font = Enum.Font.Gotham
		oddsLbl.TextSize = 11
		oddsLbl.TextWrapped = true
		oddsLbl.TextXAlignment = Enum.TextXAlignment.Left
		oddsLbl.ZIndex = 23
		oddsLbl.Parent = card

		local openBtn = Instance.new("TextButton")
		openBtn.Size = UDim2.new(0, 108, 0, 36)
		openBtn.Position = UDim2.new(1, -120, 0.5, -18)
		openBtn.Text = "Abrir Huevo"
		openBtn.TextSize = 13
		openBtn.ZIndex = 23
		UITheme.StyleButton(openBtn, UITheme.Colors.Success)
		openBtn.Activated:Connect(function()
			NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestOpenEgg):FireServer(egg.Id)
		end)
		openBtn.Parent = card
	end
end

function PetPanels.RenderCollections(modal: UITheme.ModalHandle, profile: any)
	modal.ClearContent()
	local ownedStaves = (profile and profile.OwnedStaffs) or {}
	local staffCount = 0
	for _, _ in pairs(ownedStaves) do staffCount += 1 end

	local allPets = PetConfig.GetAllPets()
	local discovered = (profile and profile.DiscoveredPets) or {}
	local petDiscCount = 0
	for _, _ in pairs(discovered) do petDiscCount += 1 end

	local summary = UITheme.CreateCard(modal.Content, 56)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -24, 1, 0)
	lbl.Position = UDim2.new(0, 12, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = string.format("Índice de Colección — Bastones: %d / %d | Mascotas: %d / %d", staffCount, #StaffConfig.GetAllIds(), petDiscCount, #allPets)
	lbl.TextColor3 = UITheme.Colors.AccentGold
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 23
	lbl.Parent = summary

	for _, pet in ipairs(allPets) do
		local isDisc = discovered[pet.Id] == true
		local card = UITheme.CreateCard(modal.Content, 46)
		local pLbl = Instance.new("TextLabel")
		pLbl.Size = UDim2.new(1, -24, 1, 0)
		pLbl.Position = UDim2.new(0, 12, 0, 0)
		pLbl.BackgroundTransparency = 1
		pLbl.Text = if isDisc then string.format("✓ %s (%s · %s)", pet.Name, pet.Region, pet.Rarity) else string.format("? ??? (%s · %s)", pet.Region, pet.Rarity)
		pLbl.TextColor3 = if isDisc then RarityUtils.GetColor(pet.Rarity) else UITheme.Colors.TextMuted
		pLbl.Font = Enum.Font.GothamSemibold
		pLbl.TextSize = 13
		pLbl.TextXAlignment = Enum.TextXAlignment.Left
		pLbl.ZIndex = 23
		pLbl.Parent = card
	end
end

return PetPanels
