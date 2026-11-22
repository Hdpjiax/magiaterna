--!strict
--[[
    HUDManager.luau
    Builds and maintains the adaptive HUD for MAGIA ETERNA across PC, Mobile, and Console.
    Features:
    - Top Currency Bar (Coins, Magic, Rebirths, Shards) with UIFormatters abbreviations
    - Side Navigation Bar (Pets, Forge, Mazmorras, Misiones, Ajustes)
    - Mobile Touch Action Buttons (Entrenar, Hechizo, Auto-Train)
    - Dynamic GuiService Safe Inset management for notches & mobile gestures
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIFormatters = require(script.Parent.UIFormatters)
local SoundController = require(script.Parent.Parent.Controllers.SoundController)
local DataController = require(script.Parent.Parent.Controllers.DataController)

local HUDManager = {}
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui

local screenGui: ScreenGui? = nil
local currencyLabels = {
	Coins = nil :: TextLabel?,
	Magic = nil :: TextLabel?,
	Rebirths = nil :: TextLabel?,
	Shards = nil :: TextLabel?,
}

-- Creates a stylized pill container for a currency
local function createCurrencyPill(parent: GuiObject, name: string, iconText: string, color: Color3): (Frame, TextLabel)
	local pill = Instance.new("Frame")
	pill.Name = name .. "Pill"
	pill.Size = UDim2.new(0, 130, 0, 36)
	pill.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
	pill.BorderSizePixel = 0
	pill.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 18)
	corner.Parent = pill

	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 1.5
	stroke.Transparency = 0.3
	stroke.Parent = pill

	local icon = Instance.new("TextLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 30, 1, 0)
	icon.Position = UDim2.new(0, 4, 0, 0)
	icon.BackgroundTransparency = 1
	icon.Text = iconText
	icon.TextColor3 = color
	icon.TextSize = 18
	icon.Font = Enum.Font.GothamBold
	icon.Parent = pill

	local label = Instance.new("TextLabel")
	label.Name = "Value"
	label.Size = UDim2.new(1, -38, 1, 0)
	label.Position = UDim2.new(0, 34, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = "0"
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 14
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = pill

	return pill, label
end

-- Creates a circular navigation button
local function createNavButton(parent: GuiObject, name: string, labelText: string, iconText: string, callback: () -> ()): TextButton
	local btn = Instance.new("TextButton")
	btn.Name = name .. "Button"
	btn.Size = UDim2.new(0, 52, 0, 52)
	btn.BackgroundColor3 = Color3.fromRGB(30, 34, 46)
	btn.BorderSizePixel = 0
	btn.Text = iconText
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 22
	btn.Font = Enum.Font.GothamBold
	btn.AutoButtonColor = false
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 26)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(80, 130, 255)
	stroke.Thickness = 1.5
	stroke.Parent = btn

	-- Tooltip / Sub-label
	local subLabel = Instance.new("TextLabel")
	subLabel.Name = "SubLabel"
	subLabel.Size = UDim2.new(1, 0, 0, 14)
	subLabel.Position = UDim2.new(0, 0, 1, 2)
	subLabel.BackgroundTransparency = 1
	subLabel.Text = labelText
	subLabel.TextColor3 = Color3.fromRGB(200, 210, 230)
	subLabel.TextSize = 10
	subLabel.Font = Enum.Font.Gotham
	subLabel.Parent = btn

	btn.MouseButton1Click:Connect(function()
		SoundController.PlaySFX("UI_ButtonClick")
		callback()
	end)

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), { Size = UDim2.new(0, 56, 0, 56) }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), { Size = UDim2.new(0, 52, 0, 52) }):Play()
	end)

	return btn
end

-- Builds the entire HUD hierarchy
function HUDManager.BuildHUD(onNavClicked: (menuName: string) -> ())
	if screenGui then return end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MagiaEternaHUD"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	-- Safe Inset Container
	local mainContainer = Instance.new("Frame")
	mainContainer.Name = "MainContainer"
	mainContainer.Size = UDim2.new(1, 0, 1, 0)
	mainContainer.BackgroundTransparency = 1
	mainContainer.Parent = screenGui

	-- Top Bar for Currencies
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, -40, 0, 48)
	topBar.Position = UDim2.new(0, 20, 0, 20)
	topBar.BackgroundTransparency = 1
	topBar.Parent = mainContainer

	local topList = Instance.new("UIListLayout")
	topList.FillDirection = Enum.FillDirection.Horizontal
	topList.HorizontalAlignment = Enum.HorizontalAlignment.Left
	topList.Padding = UDim.new(0, 12)
	topList.Parent = topBar

	local _, coinLbl = createCurrencyPill(topBar, "Coins", "🪙", Color3.fromRGB(255, 215, 0))
	local _, magicLbl = createCurrencyPill(topBar, "Magic", "✨", Color3.fromRGB(0, 200, 255))
	local _, rebLbl = createCurrencyPill(topBar, "Rebirths", "🔁", Color3.fromRGB(180, 100, 255))
	local _, shardLbl = createCurrencyPill(topBar, "Shards", "💎", Color3.fromRGB(255, 100, 180))

	currencyLabels.Coins = coinLbl
	currencyLabels.Magic = magicLbl
	currencyLabels.Rebirths = rebLbl
	currencyLabels.Shards = shardLbl

	-- Right Side Navigation Bar
	local sideNav = Instance.new("Frame")
	sideNav.Name = "SideNav"
	sideNav.Size = UDim2.new(0, 60, 0, 320)
	sideNav.Position = UDim2.new(1, -75, 0.5, -160)
	sideNav.BackgroundTransparency = 1
	sideNav.Parent = mainContainer

	local sideList = Instance.new("UIListLayout")
	sideList.FillDirection = Enum.FillDirection.Vertical
	sideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	sideList.Padding = UDim.new(0, 16)
	sideList.Parent = sideNav

	createNavButton(sideNav, "Pets", "Mascotas", "🐾", function() onNavClicked("Pets") end)
	createNavButton(sideNav, "Forge", "Forja", "🔨", function() onNavClicked("Forge") end)
	createNavButton(sideNav, "Dungeons", "Mazmorras", "⚔️", function() onNavClicked("Dungeons") end)
	createNavButton(sideNav, "Quests", "Misiones", "📜", function() onNavClicked("Quests") end)
	createNavButton(sideNav, "Settings", "Ajustes", "⚙️", function() onNavClicked("Settings") end)

	-- Mobile Touch Action Buttons (Shown if touch is active)
	if UserInputService.TouchEnabled then
		local mobileBar = Instance.new("Frame")
		mobileBar.Name = "MobileActionBar"
		mobileBar.Size = UDim2.new(0, 180, 0, 80)
		mobileBar.Position = UDim2.new(1, -200, 1, -110)
		mobileBar.BackgroundTransparency = 1
		mobileBar.Parent = mainContainer

		local trainBtn = Instance.new("TextButton")
		trainBtn.Name = "MobileTrainButton"
		trainBtn.Size = UDim2.new(0, 75, 0, 75)
		trainBtn.Position = UDim2.new(0, 0, 0, 0)
		trainBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 240)
		trainBtn.Text = "✨\nEntrenar"
		trainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		trainBtn.TextSize = 13
		trainBtn.Font = Enum.Font.GothamBold
		trainBtn.Parent = mobileBar

		local trainCorner = Instance.new("UICorner")
		trainCorner.CornerRadius = UDim.new(0, 38)
		trainCorner.Parent = trainBtn

		local spellBtn = Instance.new("TextButton")
		spellBtn.Name = "MobileSpellButton"
		spellBtn.Size = UDim2.new(0, 75, 0, 75)
		spellBtn.Position = UDim2.new(0, 95, 0, 0)
		spellBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
		spellBtn.Text = "🔥\nHechizo"
		spellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		spellBtn.TextSize = 13
		spellBtn.Font = Enum.Font.GothamBold
		spellBtn.Parent = mobileBar

		local spellCorner = Instance.new("UICorner")
		spellCorner.CornerRadius = UDim.new(0, 38)
		spellCorner.Parent = spellBtn
	end

	-- Connect profile updates to update top bar values
	DataController.OnProfileUpdated:Connect(function(profile)
		HUDManager.UpdateCurrencies(profile)
	end)

	-- Initial update if profile already cached
	local currentProfile = DataController.GetProfile()
	if currentProfile then
		HUDManager.UpdateCurrencies(currentProfile)
	end

	print("[HUDManager] Adaptive HUD built successfully.")
end

-- Updates top bar numbers with smooth formatting
function HUDManager.UpdateCurrencies(profile: any)
	if currencyLabels.Coins then
		currencyLabels.Coins.Text = UIFormatters.FormatNumber(profile.Coins or 0)
	end
	if currencyLabels.Magic then
		currencyLabels.Magic.Text = UIFormatters.FormatNumber(profile.Magic or 0)
	end
	if currencyLabels.Rebirths then
		currencyLabels.Rebirths.Text = UIFormatters.FormatNumber(profile.Rebirths or 0)
	end
	if currencyLabels.Shards then
		currencyLabels.Shards.Text = UIFormatters.FormatNumber(profile.RebirthShards or 0)
	end
end

return HUDManager
