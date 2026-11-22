--!strict
--[[
    HUDManager.luau
    Builds and maintains the adaptive HUD for MAGIA ETERNA across PC, Mobile, and Console.
    Features:
    - Top Currency Bar (Coins, Magic, Rebirths, Shards) with UIFormatters abbreviations
    - Right & Left Navigation Bars covering all 12 game menus without blocking center gameplay
    - Mobile Touch Action Buttons (Entrenar, Hechizo) wired to controllers
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

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

function HUDManager.GetScreenGui(): ScreenGui?
	return screenGui
end

local function createCurrencyPill(parent: GuiObject, name: string, iconText: string, color: Color3): (Frame, TextLabel)
	local pill = Instance.new("Frame")
	pill.Name = name .. "Pill"
	pill.Size = UDim2.new(0, 126, 0, 36)
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

local function createNavButton(parent: GuiObject, name: string, labelText: string, iconText: string, callback: () -> ()): TextButton
	local btn = Instance.new("TextButton")
	btn.Name = name .. "Button"
	btn.Size = UDim2.new(0, 48, 0, 48)
	btn.BackgroundColor3 = Color3.fromRGB(30, 34, 46)
	btn.BorderSizePixel = 0
	btn.Text = iconText
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 20
	btn.Font = Enum.Font.GothamBold
	btn.AutoButtonColor = false
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 24)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(80, 130, 255)
	stroke.Thickness = 1.5
	stroke.Parent = btn

	local subLabel = Instance.new("TextLabel")
	subLabel.Name = "SubLabel"
	subLabel.Size = UDim2.new(1.3, 0, 0, 14)
	subLabel.Position = UDim2.new(-0.15, 0, 1, 1)
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
		TweenService:Create(btn, TweenInfo.new(0.15), { Size = UDim2.new(0, 52, 0, 52) }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), { Size = UDim2.new(0, 48, 0, 48) }):Play()
	end)

	return btn
end

function HUDManager.BuildHUD(onNavClicked: (menuName: string) -> ())
	if screenGui then return end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MagiaEternaHUD"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	local mainContainer = Instance.new("Frame")
	mainContainer.Name = "MainContainer"
	mainContainer.Size = UDim2.new(1, 0, 1, 0)
	mainContainer.BackgroundTransparency = 1
	mainContainer.Parent = screenGui

	-- Top Currency Bar
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, -40, 0, 48)
	topBar.Position = UDim2.new(0, 20, 0, 20)
	topBar.BackgroundTransparency = 1
	topBar.Parent = mainContainer

	local topList = Instance.new("UIListLayout")
	topList.FillDirection = Enum.FillDirection.Horizontal
	topList.HorizontalAlignment = Enum.HorizontalAlignment.Left
	topList.Padding = UDim.new(0, 10)
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
	local rightNav = Instance.new("Frame")
	rightNav.Name = "SideNav"
	rightNav.Size = UDim2.new(0, 60, 0, 390)
	rightNav.Position = UDim2.new(1, -74, 0.5, -195)
	rightNav.BackgroundTransparency = 1
	rightNav.Parent = mainContainer

	local rightList = Instance.new("UIListLayout")
	rightList.FillDirection = Enum.FillDirection.Vertical
	rightList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	rightList.Padding = UDim.new(0, 16)
	rightList.Parent = rightNav

	createNavButton(rightNav, "Pets", "Mascotas", "🐾", function() onNavClicked("Pets") end)
	createNavButton(rightNav, "Eggs", "Huevos", "🥚", function() onNavClicked("Eggs") end)
	createNavButton(rightNav, "Forge", "Forja", "🔨", function() onNavClicked("Forge") end)
	createNavButton(rightNav, "Dungeons", "Mazmorras", "⚔️", function() onNavClicked("Dungeons") end)
	createNavButton(rightNav, "Quests", "Misiones", "📜", function() onNavClicked("Quests") end)
	createNavButton(rightNav, "Settings", "Ajustes", "⚙️", function() onNavClicked("Settings") end)

	-- Left Side Navigation Bar
	local leftNav = Instance.new("Frame")
	leftNav.Name = "LeftNav"
	leftNav.Size = UDim2.new(0, 60, 0, 390)
	leftNav.Position = UDim2.new(0, 14, 0.5, -195)
	leftNav.BackgroundTransparency = 1
	leftNav.Parent = mainContainer

	local leftList = Instance.new("UIListLayout")
	leftList.FillDirection = Enum.FillDirection.Vertical
	leftList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	leftList.Padding = UDim.new(0, 16)
	leftList.Parent = leftNav

	createNavButton(leftNav, "Inventory", "Mochila", "🎒", function() onNavClicked("Inventory") end)
	createNavButton(leftNav, "Staffs", "Bastones", "🪄", function() onNavClicked("Staffs") end)
	createNavButton(leftNav, "Armor", "Armadura", "🛡️", function() onNavClicked("Armor") end)
	createNavButton(leftNav, "Rebirth", "Rebirth", "🔥", function() onNavClicked("Rebirth") end)
	createNavButton(leftNav, "Collections", "Índice", "📖", function() onNavClicked("Collections") end)
	createNavButton(leftNav, "Shop", "Tienda", "🛒", function() onNavClicked("Shop") end)

	-- Mobile Action Bar & Gamepad Controls
	local mobileBar = Instance.new("Frame")
	mobileBar.Name = "MobileActionBar"
	mobileBar.Size = UDim2.new(0, 220, 0, 160)
	mobileBar.Position = UDim2.new(1, -235, 1, -210)
	mobileBar.BackgroundTransparency = 1
	mobileBar.Visible = UserInputService.TouchEnabled
	mobileBar.Parent = mainContainer

	-- 1. Main Action Button: Hechizo / Entrenar (Large Touch Target)
	local attackBtn = Instance.new("TextButton")
	attackBtn.Name = "MobileAttackButton"
	attackBtn.Size = UDim2.new(0, 74, 0, 74)
	attackBtn.Position = UDim2.new(1, -80, 1, -80)
	attackBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 60)
	attackBtn.Text = "⚡\nATACAR"
	attackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	attackBtn.TextSize = 12
	attackBtn.Font = Enum.Font.GothamBold
	attackBtn.AutoButtonColor = false
	attackBtn.Parent = mobileBar

	local aCorner = Instance.new("UICorner")
	aCorner.CornerRadius = UDim.new(0, 37)
	aCorner.Parent = attackBtn

	local aStroke = Instance.new("UIStroke")
	aStroke.Color = Color3.fromRGB(255, 120, 120)
	aStroke.Thickness = 2.5
	aStroke.Parent = attackBtn

	attackBtn.Activated:Connect(function()
		local InputController = require(script.Parent.Parent.Controllers:WaitForChild("InputController") :: ModuleScript)
		InputController.TriggerAttackOrTrain()
		TweenService:Create(attackBtn, TweenInfo.new(0.08), { Size = UDim2.new(0, 68, 0, 68), Position = UDim2.new(1, -77, 1, -77) }):Play()
		task.delay(0.08, function()
			TweenService:Create(attackBtn, TweenInfo.new(0.08), { Size = UDim2.new(0, 74, 0, 74), Position = UDim2.new(1, -80, 1, -80) }):Play()
		end)
	end)

	-- 2. Auto-Train Toggle Button
	local autoBtn = Instance.new("TextButton")
	autoBtn.Name = "MobileAutoTrainButton"
	autoBtn.Size = UDim2.new(0, 56, 0, 56)
	autoBtn.Position = UDim2.new(0, 70, 1, -65)
	autoBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
	autoBtn.Text = "🔄\nAuto"
	autoBtn.TextColor3 = Color3.fromRGB(200, 220, 255)
	autoBtn.TextSize = 11
	autoBtn.Font = Enum.Font.GothamBold
	autoBtn.AutoButtonColor = false
	autoBtn.Parent = mobileBar

	local auCorner = Instance.new("UICorner")
	auCorner.CornerRadius = UDim.new(0, 28)
	auCorner.Parent = autoBtn

	local auStroke = Instance.new("UIStroke")
	auStroke.Name = "AutoStroke"
	auStroke.Color = Color3.fromRGB(80, 120, 180)
	auStroke.Thickness = 1.5
	auStroke.Parent = autoBtn

	autoBtn.Activated:Connect(function()
		local InputController = require(script.Parent.Parent.Controllers:WaitForChild("InputController") :: ModuleScript)
		local isActive = InputController.ToggleAutoTrain()
		if isActive then
			autoBtn.BackgroundColor3 = Color3.fromRGB(20, 140, 70)
			auStroke.Color = Color3.fromRGB(50, 255, 120)
			autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			autoBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
			auStroke.Color = Color3.fromRGB(80, 120, 180)
			autoBtn.TextColor3 = Color3.fromRGB(200, 220, 255)
		end
	end)

	-- 3. Quick Backpack Button
	local bagBtn = Instance.new("TextButton")
	bagBtn.Name = "MobileBagButton"
	bagBtn.Size = UDim2.new(0, 56, 0, 56)
	bagBtn.Position = UDim2.new(1, -72, 0, 10)
	bagBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
	bagBtn.Text = "🎒\nBolsa"
	bagBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
	bagBtn.TextSize = 11
	bagBtn.Font = Enum.Font.GothamBold
	bagBtn.AutoButtonColor = false
	bagBtn.Parent = mobileBar

	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 28)
	bCorner.Parent = bagBtn

	local bStroke = Instance.new("UIStroke")
	bStroke.Color = Color3.fromRGB(255, 200, 50)
	bStroke.Thickness = 1.5
	bStroke.Parent = bagBtn

	bagBtn.Activated:Connect(function()
		onNavClicked("Inventory")
	end)

	-- Gamepad Quick Prompt Bar (Bottom Center)
	local gamepadBar = Instance.new("Frame")
	gamepadBar.Name = "GamepadPromptBar"
	gamepadBar.AnchorPoint = Vector2.new(0.5, 1)
	gamepadBar.Size = UDim2.new(0, 620, 0, 32)
	gamepadBar.Position = UDim2.new(0.5, 0, 1, -12)
	gamepadBar.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
	gamepadBar.BackgroundTransparency = 0.25
	gamepadBar.Visible = false
	gamepadBar.Parent = mainContainer

	local gpCorner = Instance.new("UICorner")
	gpCorner.CornerRadius = UDim.new(0, 8)
	gpCorner.Parent = gamepadBar

	local gpStroke = Instance.new("UIStroke")
	gpStroke.Color = Color3.fromRGB(70, 90, 140)
	gpStroke.Thickness = 1.2
	gpStroke.Parent = gamepadBar

	local gpLabel = Instance.new("TextLabel")
	gpLabel.Name = "PromptText"
	gpLabel.Size = UDim2.new(1, 0, 1, 0)
	gpLabel.BackgroundTransparency = 1
	gpLabel.Text = "🎮  [RT / X] Hechizo / Entrenar  •  [Y] Mochila  •  [B] Cerrar  •  [LB / RB] Menús  •  [Select] Auto"
	gpLabel.TextColor3 = Color3.fromRGB(210, 225, 255)
	gpLabel.TextSize = 12
	gpLabel.Font = Enum.Font.GothamBold
	gpLabel.Parent = gamepadBar

	-- Mobile Menu Toggle Button (Allows expanding/collapsing side navigation on phone screens)
	local menuToggle = Instance.new("TextButton")
	menuToggle.Name = "MobileMenuToggle"
	menuToggle.Size = UDim2.new(0, 120, 0, 30)
	menuToggle.Position = UDim2.new(0, 20, 0, 72)
	menuToggle.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
	menuToggle.Text = "📱 Ocultar Menús"
	menuToggle.TextColor3 = Color3.fromRGB(180, 205, 255)
	menuToggle.TextSize = 11
	menuToggle.Font = Enum.Font.GothamMedium
	menuToggle.AutoButtonColor = false
	menuToggle.Visible = UserInputService.TouchEnabled
	menuToggle.Parent = mainContainer

	local mtCorner = Instance.new("UICorner")
	mtCorner.CornerRadius = UDim.new(0, 15)
	mtCorner.Parent = menuToggle

	local mtStroke = Instance.new("UIStroke")
	mtStroke.Color = Color3.fromRGB(60, 90, 150)
	mtStroke.Thickness = 1
	mtStroke.Parent = menuToggle

	local menusVisible = true
	menuToggle.Activated:Connect(function()
		menusVisible = not menusVisible
		rightNav.Visible = menusVisible
		leftNav.Visible = menusVisible
		menuToggle.Text = if menusVisible then "📱 Ocultar Menús" else "📱 Mostrar Menús"
		SoundController.PlaySFX("UI_ButtonClick")
	end)

	-- Listen for dynamic input mode changes (Keyboard, Touch, Gamepad)
	task.spawn(function()
		local InputController = require(script.Parent.Parent.Controllers:WaitForChild("InputController") :: ModuleScript)
		local function applyMode(mode: string)
			if mode == "Gamepad" then
				gamepadBar.Visible = true
				mobileBar.Visible = false
				menuToggle.Visible = false
			elseif mode == "Touch" then
				gamepadBar.Visible = false
				mobileBar.Visible = true
				menuToggle.Visible = true
			else -- Keyboard
				gamepadBar.Visible = false
				mobileBar.Visible = false
				menuToggle.Visible = false
				rightNav.Visible = true
				leftNav.Visible = true
			end
		end

		InputController.OnInputModeChanged(applyMode)
		applyMode(InputController.GetInputMode())
	end)

	DataController.OnProfileUpdated:Connect(function(profile)
		HUDManager.UpdateCurrencies(profile)
	end)

	local currentProfile = DataController.GetProfile()
	if currentProfile then
		HUDManager.UpdateCurrencies(currentProfile)
	end

	print("[HUDManager] Adaptive HUD built successfully.")
end

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
