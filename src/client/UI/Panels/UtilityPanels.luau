--!strict
--[[
    UtilityPanels.luau
    Renders Mochila (Materials + Quick Sell Market), Tienda (Monetization), and Ajustes (Settings).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local MonetizationConfig = require(Shared:WaitForChild("Config"):WaitForChild("MonetizationConfig") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local UITheme = require(script.Parent.Parent:WaitForChild("UITheme") :: ModuleScript)

local UtilityPanels = {}

function UtilityPanels.RenderInventory(modal: UITheme.ModalHandle, profile: any)
	modal.ClearContent()
	local mats = (profile and profile.Materials) or {}
	local count = 0

	for matId, qty in pairs(mats) do
		if qty > 0 then
			count += 1
			local card = UITheme.CreateCard(modal.Content, 56)

			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(0.6, 0, 1, 0)
			lbl.Position = UDim2.new(0, 12, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = string.format("%s — Cantidad: %d", matId, qty)
			lbl.TextColor3 = UITheme.Colors.TextPrimary
			lbl.Font = Enum.Font.GothamSemibold
			lbl.TextSize = 13
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.ZIndex = 23
			lbl.Parent = card

			local sellOne = Instance.new("TextButton")
			sellOne.Size = UDim2.new(0, 88, 0, 30)
			sellOne.Position = UDim2.new(1, -188, 0.5, -15)
			sellOne.Text = "Vender x1"
			sellOne.TextSize = 12
			sellOne.ZIndex = 23
			UITheme.StyleButton(sellOne, UITheme.Colors.AccentBlue)
			sellOne.Activated:Connect(function()
				NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestSellMaterial):FireServer(matId, 1)
			end)
			sellOne.Parent = card

			local sellAll = Instance.new("TextButton")
			sellAll.Size = UDim2.new(0, 88, 0, 30)
			sellAll.Position = UDim2.new(1, -94, 0.5, -15)
			sellAll.Text = "Vender Todo"
			sellAll.TextSize = 12
			sellAll.ZIndex = 23
			UITheme.StyleButton(sellAll, UITheme.Colors.AccentGold)
			sellAll.TextColor3 = Color3.fromRGB(20, 20, 30)
			sellAll.Activated:Connect(function()
				NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestSellMaterial):FireServer(matId, qty)
			end)
			sellAll.Parent = card
		end
	end

	if count == 0 then
		local emptyCard = UITheme.CreateCard(modal.Content, 56)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -24, 1, 0)
		lbl.Position = UDim2.new(0, 12, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = "Tu mochila de materiales está vacía. ¡Explora mazmorras para conseguir botín!"
		lbl.TextColor3 = UITheme.Colors.TextMuted
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 13
		lbl.ZIndex = 23
		lbl.Parent = emptyCard
	end
end

function UtilityPanels.RenderShop(modal: UITheme.ModalHandle, profile: any)
	modal.ClearContent()
	local ownedPasses = (profile and profile.OwnedGamePasses) or {}

	for _, product in ipairs(MonetizationConfig.GetAllProducts()) do
		local isOwned = product.Type == "GamePass" and ownedPasses[product.Id] == true
		local card = UITheme.CreateCard(modal.Content, 68)

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(0.68, 0, 0.45, 0)
		title.Position = UDim2.new(0, 12, 0, 4)
		title.BackgroundTransparency = 1
		title.Text = string.format("[%s] %s — %d R$", product.Type, product.Name, product.RobuxPrice)
		title.TextColor3 = UITheme.Colors.AccentGold
		title.Font = Enum.Font.GothamBold
		title.TextSize = 14
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.ZIndex = 23
		title.Parent = card

		local desc = Instance.new("TextLabel")
		desc.Size = UDim2.new(0.68, 0, 0.45, 0)
		desc.Position = UDim2.new(0, 12, 0.48, 0)
		desc.BackgroundTransparency = 1
		desc.Text = product.Description
		desc.TextColor3 = UITheme.Colors.TextMuted
		desc.Font = Enum.Font.Gotham
		desc.TextSize = 11
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.ZIndex = 23
		desc.Parent = card

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 108, 0, 34)
		btn.Position = UDim2.new(1, -120, 0.5, -17)
		btn.TextSize = 13
		btn.ZIndex = 23
		if isOwned then
			btn.Text = "Adquirido"
			UITheme.StyleButton(btn, UITheme.Colors.Success)
		else
			btn.Text = "Comprar"
			UITheme.StyleButton(btn, UITheme.Colors.AccentPurple)
			btn.Activated:Connect(function()
				NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestPurchaseProduct):FireServer(product.Id)
			end)
		end
		btn.Parent = card
	end
end

function UtilityPanels.RenderSettings(modal: UITheme.ModalHandle, profile: any)
	modal.ClearContent()
	local settings = (profile and profile.Settings) or {
		MusicVolume = 1.0,
		SFXVolume = 1.0,
		CameraShake = true,
		ReducedEffects = false,
	}

	local function createToggle(label: string, currentVal: boolean, onToggle: (boolean) -> ())
		local card = UITheme.CreateCard(modal.Content, 56)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.7, 0, 1, 0)
		lbl.Position = UDim2.new(0, 12, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = UITheme.Colors.TextPrimary
		lbl.Font = Enum.Font.GothamSemibold
		lbl.TextSize = 14
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.ZIndex = 23
		lbl.Parent = card

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 110, 0, 34)
		btn.Position = UDim2.new(1, -122, 0.5, -17)
		btn.Text = if currentVal then "ACTIVADO" else "DESACTIVADO"
		btn.TextSize = 12
		btn.ZIndex = 23
		UITheme.StyleButton(btn, if currentVal then UITheme.Colors.Success else Color3.fromRGB(80, 80, 100))
		btn.Activated:Connect(function()
			onToggle(not currentVal)
		end)
		btn.Parent = card
	end

	createToggle("Vibración de Cámara (CameraShake)", settings.CameraShake ~= false, function(newVal)
		NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestUpdateSettings):FireServer({ CameraShake = newVal })
	end)

	createToggle("Efectos Reducidos (Rendimiento / Accesibilidad)", settings.ReducedEffects == true, function(newVal)
		NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestUpdateSettings):FireServer({ ReducedEffects = newVal })
	end)

	createToggle("Música de Fondo (Silenciar / Activar)", (settings.MusicVolume or 1) > 0, function(newVal)
		NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestUpdateSettings):FireServer({ MusicVolume = if newVal then 1.0 else 0.0 })
	end)

	createToggle("Efectos de Sonido (SFX)", (settings.SFXVolume or 1) > 0, function(newVal)
		NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestUpdateSettings):FireServer({ SFXVolume = if newVal then 1.0 else 0.0 })
	end)
end

return UtilityPanels
