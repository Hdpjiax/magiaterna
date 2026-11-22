--!strict
--[[
    UtilityPanels.luau
    Renders Mochila (Materials + Quick Sell Market), Tienda (Monetization), and Ajustes (Settings).
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
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
	local localPlayer = Players.LocalPlayer
	local ownedPasses = (profile and profile.OwnedGamePasses) or {}

	for _, product in ipairs(MonetizationConfig.GetAllProducts()) do
		local isOwned = product.Type == "GamePass" and ownedPasses[product.Id] == true
		local card = UITheme.CreateCard(modal.Content, 74)

		-- Badge de tipo
		local badge = Instance.new("TextLabel")
		badge.Size = UDim2.new(0, 95, 0, 18)
		badge.Position = UDim2.new(0, 12, 0, 6)
		badge.BackgroundColor3 = product.Type == "GamePass" and Color3.fromRGB(130, 60, 220) or Color3.fromRGB(40, 140, 220)
		badge.Text = product.Type == "GamePass" and "★ GAME PASS" or "◆ CONSUMIBLE"
		badge.TextColor3 = Color3.fromRGB(255, 255, 255)
		badge.Font = Enum.Font.GothamBold
		badge.TextSize = 9
		badge.ZIndex = 23
		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 4)
		bCorner.Parent = badge
		badge.Parent = card

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(0.65, 0, 0, 22)
		title.Position = UDim2.new(0, 115, 0, 4)
		title.BackgroundTransparency = 1
		title.Text = string.format("%s — %d R$", product.Name, product.RobuxPrice)
		title.TextColor3 = UITheme.Colors.AccentGold
		title.Font = Enum.Font.GothamBold
		title.TextSize = 14
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.ZIndex = 23
		title.Parent = card

		local benefit = Instance.new("TextLabel")
		benefit.Size = UDim2.new(0.65, 0, 0, 16)
		benefit.Position = UDim2.new(0, 12, 0, 26)
		benefit.BackgroundTransparency = 1
		benefit.Text = "✨ " .. (product.BenefitText or product.Description)
		benefit.TextColor3 = Color3.fromRGB(80, 240, 180)
		benefit.Font = Enum.Font.GothamMedium
		benefit.TextSize = 11
		benefit.TextXAlignment = Enum.TextXAlignment.Left
		benefit.ZIndex = 23
		benefit.Parent = card

		local desc = Instance.new("TextLabel")
		desc.Size = UDim2.new(0.65, 0, 0, 16)
		desc.Position = UDim2.new(0, 12, 0, 44)
		desc.BackgroundTransparency = 1
		desc.Text = product.Description
		desc.TextColor3 = UITheme.Colors.TextMuted
		desc.Font = Enum.Font.Gotham
		desc.TextSize = 10
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.ZIndex = 23
		desc.Parent = card

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 115, 0, 36)
		btn.Position = UDim2.new(1, -125, 0.5, -18)
		btn.TextSize = 13
		btn.ZIndex = 23

		if isOwned then
			btn.Text = "✓ Adquirido"
			UITheme.StyleButton(btn, UITheme.Colors.Success)
		else
			btn.Text = string.format("Comprar (%d R$)", product.RobuxPrice)
			UITheme.StyleButton(btn, UITheme.Colors.AccentPurple)
			btn.Activated:Connect(function()
				if product.AssetId and product.AssetId > 0 then
					if product.Type == "GamePass" then
						MarketplaceService:PromptGamePassPurchase(localPlayer, product.AssetId)
					else
						MarketplaceService:PromptProductPurchase(localPlayer, product.AssetId)
					end
				else
					-- Modo desarrollo / prueba sin AssetId en Creator Hub
					local evt = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestPurchaseProduct)
					if evt then
						evt:FireServer(product.Id)
					end
				end
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
		local card = UITheme.CreateCard(modal.Content, 48)

		local tLabel = Instance.new("TextLabel")
		tLabel.Size = UDim2.new(0.7, 0, 1, 0)
		tLabel.Position = UDim2.new(0, 12, 0, 0)
		tLabel.BackgroundTransparency = 1
		tLabel.Text = label
		tLabel.TextColor3 = UITheme.Colors.TextPrimary
		tLabel.Font = Enum.Font.GothamSemibold
		tLabel.TextSize = 13
		tLabel.TextXAlignment = Enum.TextXAlignment.Left
		tLabel.ZIndex = 23
		tLabel.Parent = card

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 72, 0, 28)
		btn.Position = UDim2.new(1, -84, 0.5, -14)
		btn.Text = currentVal and "SÍ" or "NO"
		btn.TextSize = 12
		btn.ZIndex = 23
		UITheme.StyleButton(btn, currentVal and UITheme.Colors.Success or UITheme.Colors.TextMuted)

		btn.Activated:Connect(function()
			currentVal = not currentVal
			btn.Text = currentVal and "SÍ" or "NO"
			UITheme.StyleButton(btn, currentVal and UITheme.Colors.Success or UITheme.Colors.TextMuted)
			onToggle(currentVal)
		end)

		btn.Parent = card
	end

	createToggle("Vibración de Cámara", settings.CameraShake, function(val)
		NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestUpdateSettings):FireServer("CameraShake", val)
	end)

	createToggle("Efectos Visuales Reducidos", settings.ReducedEffects, function(val)
		NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestUpdateSettings):FireServer("ReducedEffects", val)
	end)
end

return UtilityPanels
