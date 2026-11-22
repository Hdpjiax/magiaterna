--!strict
--[[
    NotificationController.luau
    Client system for animated toast popups, error alerts, achievement unlocks,
    and server notifications for MAGIA ETERNA.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkEndpoints = require(ReplicatedStorage.Source.shared.Network.NetworkEndpoints)
local SoundController = require(script.Parent.SoundController)

local NotificationController = {}
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui
local toastContainer: Frame? = nil

local function getOrCreateContainer(): Frame
	if toastContainer then return toastContainer end

	local screenGui = playerGui:FindFirstChild("MagiaEternaHUD") :: ScreenGui
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "MagiaEternaNotifications"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.Parent = playerGui
	end

	local container = Instance.new("Frame")
	container.Name = "ToastContainer"
	container.Size = UDim2.new(0, 320, 0, 300)
	container.Position = UDim2.new(0.5, -160, 0, 80)
	container.BackgroundTransparency = 1
	container.Parent = screenGui

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Vertical
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.Padding = UDim.new(0, 8)
	list.Parent = container

	toastContainer = container
	return toastContainer
end

-- Displays an animated toast message
function NotificationController.ShowToast(title: string, message: string, toastType: string?, duration: number?)
	local dur = duration or 3.0
	local container = getOrCreateContainer()

	local card = Instance.new("Frame")
	card.Name = "ToastCard"
	card.Size = UDim2.new(1, 0, 0, 54)
	card.BackgroundColor3 = Color3.fromRGB(22, 25, 33)
	card.BackgroundTransparency = 1
	card.BorderSizePixel = 0
	card.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = card

	local strokeColor = Color3.fromRGB(80, 130, 255)
	if toastType == "Error" then
		strokeColor = Color3.fromRGB(255, 75, 75)
	elseif toastType == "Success" then
		strokeColor = Color3.fromRGB(75, 255, 120)
	end

	local stroke = Instance.new("UIStroke")
	stroke.Color = strokeColor
	stroke.Thickness = 1.5
	stroke.Transparency = 1
	stroke.Parent = card

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -20, 0, 20)
	titleLabel.Position = UDim2.new(0, 10, 0, 6)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = strokeColor
	titleLabel.TextSize = 13
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = card

	local msgLabel = Instance.new("TextLabel")
	msgLabel.Name = "Message"
	msgLabel.Size = UDim2.new(1, -20, 0, 22)
	msgLabel.Position = UDim2.new(0, 10, 0, 26)
	msgLabel.BackgroundTransparency = 1
	msgLabel.Text = message
	msgLabel.TextColor3 = Color3.fromRGB(220, 225, 235)
	msgLabel.TextSize = 12
	msgLabel.Font = Enum.Font.GothamMedium
	msgLabel.TextXAlignment = Enum.TextXAlignment.Left
	msgLabel.Parent = card

	-- Animate In
	TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.05 }):Play()
	TweenService:Create(stroke, TweenInfo.new(0.25), { Transparency = 0 }):Play()

	SoundController.PlaySFX("UI_OpenModal")

	-- Animate Out
	task.delay(dur, function()
		if card and card.Parent then
			local fadeTween = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 })
			TweenService:Create(stroke, TweenInfo.new(0.3), { Transparency = 1 }):Play()
			fadeTween:Play()
			fadeTween.Completed:Connect(function()
				card:Destroy()
			end)
		end
	end)
end

function NotificationController.Init()
	local notifEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.NotificationPrompt)
	notifEvent.OnClientEvent:Connect(function(title: string, message: string, toastType: string?)
		NotificationController.ShowToast(title, message, toastType)
	end)

	print("[NotificationController] Initialized successfully.")
end

return NotificationController
