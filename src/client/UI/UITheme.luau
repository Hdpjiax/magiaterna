--!strict
--[[
    UITheme.luau
    Shared Fantasy RPG Purple/Blue/Gold theme and adaptive modal builder for MAGIA ETERNA.
    Supports PC, Mobile, Tablet, and Gamepad navigation without covering the center action HUD.
]]

local TweenService = game:GetService("TweenService")

local UITheme = {}

UITheme.Colors = {
	Background = Color3.fromRGB(18, 16, 32),
	Panel = Color3.fromRGB(28, 25, 48),
	Card = Color3.fromRGB(38, 35, 66),
	AccentPurple = Color3.fromRGB(139, 92, 246),
	AccentBlue = Color3.fromRGB(59, 130, 246),
	AccentGold = Color3.fromRGB(251, 191, 36),
	Success = Color3.fromRGB(34, 197, 94),
	Danger = Color3.fromRGB(239, 68, 68),
	TextPrimary = Color3.fromRGB(248, 250, 252),
	TextMuted = Color3.fromRGB(168, 178, 196),
	Border = Color3.fromRGB(96, 82, 160),
}

export type ModalHandle = {
	Root: Frame,
	Content: ScrollingFrame,
	CloseButton: TextButton,
	SetVisible: (visible: boolean) -> (),
	ClearContent: () -> (),
}

function UITheme.StyleButton(btn: TextButton, bgColor: Color3?)
	btn.BackgroundColor3 = bgColor or UITheme.Colors.AccentPurple
	btn.TextColor3 = UITheme.Colors.TextPrimary
	btn.Font = Enum.Font.GothamBold
	btn.AutoButtonColor = true
	btn.BorderSizePixel = 0

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.78
	stroke.Thickness = 1
	stroke.Parent = btn
end

function UITheme.CreateModalWindow(parent: Instance, titleText: string, onClose: () -> ()): ModalHandle
	local root = Instance.new("Frame")
	root.Name = "Modal_" .. titleText
	root.Size = UDim2.fromScale(0.76, 0.74)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.BackgroundColor3 = UITheme.Colors.Background
	root.BackgroundTransparency = 0.04
	root.Visible = false
	root.ZIndex = 20
	root.Parent = parent

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MinSize = Vector2.new(320, 280)
	sizeConstraint.MaxSize = Vector2.new(860, 580)
	sizeConstraint.Parent = root

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = root

	local stroke = Instance.new("UIStroke")
	stroke.Color = UITheme.Colors.AccentGold
	stroke.Thickness = 2
	stroke.Transparency = 0.35
	stroke.Parent = root

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 48)
	header.BackgroundColor3 = UITheme.Colors.Panel
	header.BorderSizePixel = 0
	header.ZIndex = 21
	header.Parent = root

	local hCorner = Instance.new("UICorner")
	hCorner.CornerRadius = UDim.new(0, 14)
	hCorner.Parent = header

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -60, 1, 0)
	title.Position = UDim2.new(0, 16, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.TextColor3 = UITheme.Colors.AccentGold
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 22
	title.Parent = header

	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 34, 0, 34)
	closeBtn.Position = UDim2.new(1, -42, 0.5, -17)
	closeBtn.Text = "✕"
	closeBtn.TextSize = 18
	closeBtn.ZIndex = 22
	UITheme.StyleButton(closeBtn, UITheme.Colors.Danger)
	closeBtn.Parent = header

	closeBtn.Activated:Connect(onClose)

	-- Scrolling Content
	local content = Instance.new("ScrollingFrame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -24, 1, -64)
	content.Position = UDim2.new(0, 12, 0, 56)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ScrollBarThickness = 6
	content.ScrollBarImageColor3 = UITheme.Colors.AccentPurple
	content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	content.CanvasSize = UDim2.new(0, 0, 0, 0)
	content.ZIndex = 21
	content.Parent = root

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = content

	local function setVisible(vis: boolean)
		root.Visible = vis
		if vis then
			root.Size = UDim2.fromScale(0.72, 0.70)
			TweenService:Create(root, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.fromScale(0.76, 0.74),
			}):Play()
		end
	end

	local function clearContent()
		for _, child in ipairs(content:GetChildren()) do
			if not child:IsA("UIListLayout") and not child:IsA("UIGridLayout") then
				child:Destroy()
			end
		end
	end

	return {
		Root = root,
		Content = content,
		CloseButton = closeBtn,
		SetVisible = setVisible,
		ClearContent = clearContent,
	}
end

function UITheme.CreateCard(parent: Instance, height: number?): Frame
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -8, 0, height or 68)
	card.BackgroundColor3 = UITheme.Colors.Card
	card.BorderSizePixel = 0
	card.ZIndex = 22
	card.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = UITheme.Colors.Border
	stroke.Thickness = 1
	stroke.Transparency = 0.45
	stroke.Parent = card

	return card
end

return UITheme
