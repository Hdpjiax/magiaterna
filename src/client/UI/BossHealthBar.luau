--!strict
--[[
    BossHealthBar.luau
    Barra de Vida Colosal para el Jefe Final (Treant Ancestral) en MAGIA ETERNA.
    Cumple con los requisitos de la Sección 3 y PROMPT 4:
    - Fase 1 (100% - 70% HP): Barra Verde Esmeralda (Pisotón de Raíces).
    - Fase 2 (70% - 30% HP): Barra Naranja Volcánica (Grieta Terrestre y Terremoto).
    - Fase 3 (30% - 0% HP): Barra Roja Corrupta Enfurecida (Nova Ancestral).
    - Marcadores visuales de umbral al 70% y 30%.
    - Animaciones fluidas con TweenService, barra de drenaje (drain lag) y avisos de cambio de fase.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui

local Shared = ReplicatedStorage:WaitForChild("Shared")
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local BossHealthBar = {}

local screenGui: ScreenGui? = nil
local bossContainer: Frame? = nil
local fillBar: Frame? = nil
local drainBar: Frame? = nil
local hpLabel: TextLabel? = nil
local phaseBadge: TextLabel? = nil
local bossTitle: TextLabel? = nil
local bossSubtitle: TextLabel? = nil
local phaseAlertBanner: TextLabel? = nil

local currentPhase = 1
local maxHealth = 1
local currentHealth = 1

local PHASE_CONFIGS = {
	[1] = {
		Name = "[FASE 1: PISOTÓN DE RAÍCES]",
		Color = Color3.fromRGB(40, 220, 90),
		BorderColor = Color3.fromRGB(80, 255, 130),
		Alert = "🌿 ¡FASE 1: EL TREANT INVOCA RAÍCES!",
	},
	[2] = {
		Name = "[FASE 2: GRIETA TERRESTRE Y TERREMOTO]",
		Color = Color3.fromRGB(255, 140, 25),
		BorderColor = Color3.fromRGB(255, 180, 50),
		Alert = "⚠️ ¡FASE 2: GRIETA TERRESTRE Y TERREMOTO!",
	},
	[3] = {
		Name = "[FASE 3: ENFURECIDO - NOVA ANCESTRAL]",
		Color = Color3.fromRGB(255, 45, 55),
		BorderColor = Color3.fromRGB(255, 80, 90),
		Alert = "🔥 ¡FASE 3: ENFURECIDO - NOVA ANCESTRAL!",
	},
}

local function formatNumber(n: number): string
	local formatted = tostring(math.floor(n))
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then break end
	end
	return formatted
end

local function createUI()
	if screenGui then return end

	local sg = Instance.new("ScreenGui")
	sg.Name = "BossHealthBarGui"
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Contenedor principal de la barra (Top Center)
	local container = Instance.new("Frame")
	container.Name = "BossHealthContainer"
	container.AnchorPoint = Vector2.new(0.5, 0)
	container.Size = UDim2.new(0, 560, 0, 78)
	container.Position = UDim2.new(0.5, 0, 0, 18)
	container.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
	container.BackgroundTransparency = 0.15
	container.Visible = false

	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 10)
	cCorner.Parent = container

	local cStroke = Instance.new("UIStroke")
	cStroke.Name = "ContainerStroke"
	cStroke.Color = Color3.fromRGB(220, 180, 50)
	cStroke.Thickness = 2.5
	cStroke.Parent = container

	-- Icono de Jefe (Cráneo / Emblema de Madera)
	local icon = Instance.new("TextLabel")
	icon.Name = "BossIcon"
	icon.Size = UDim2.new(0, 48, 0, 48)
	icon.Position = UDim2.new(0, 12, 0, 15)
	icon.BackgroundColor3 = Color3.fromRGB(30, 20, 15)
	icon.Text = "👑"
	icon.TextSize = 26
	icon.TextColor3 = Color3.fromRGB(255, 215, 80)
	local iCorner = Instance.new("UICorner")
	iCorner.CornerRadius = UDim.new(0, 8)
	iCorner.Parent = icon
	local iStroke = Instance.new("UIStroke")
	iStroke.Color = Color3.fromRGB(240, 190, 40)
	iStroke.Thickness = 1.5
	iStroke.Parent = icon
	icon.Parent = container

	-- Título del Jefe
	local title = Instance.new("TextLabel")
	title.Name = "BossTitle"
	title.Size = UDim2.new(0, 280, 0, 22)
	title.Position = UDim2.new(0, 70, 0, 8)
	title.BackgroundTransparency = 1
	title.Text = "TREANT ANCESTRAL"
	title.TextColor3 = Color3.fromRGB(255, 220, 90)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 15
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = container

	-- Subtítulo
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "BossSubtitle"
	subtitle.Size = UDim2.new(0, 280, 0, 14)
	subtitle.Position = UDim2.new(0, 70, 0, 30)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "JEFE FINAL · REGIÓN 1: BOSQUE DE LOS SUSURROS"
	subtitle.TextColor3 = Color3.fromRGB(160, 170, 185)
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextSize = 10
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.Parent = container

	-- Badge de Fase (Top Right)
	local badge = Instance.new("TextLabel")
	badge.Name = "PhaseBadge"
	badge.Size = UDim2.new(0, 195, 0, 24)
	badge.Position = UDim2.new(1, -207, 0, 8)
	badge.BackgroundColor3 = Color3.fromRGB(20, 35, 25)
	badge.Text = "[FASE 1: PISOTÓN DE RAÍCES]"
	badge.TextColor3 = Color3.fromRGB(50, 255, 120)
	badge.Font = Enum.Font.GothamBold
	badge.TextSize = 10
	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 6)
	bCorner.Parent = badge
	local bStroke = Instance.new("UIStroke")
	bStroke.Color = Color3.fromRGB(40, 220, 90)
	bStroke.Thickness = 1.5
	bStroke.Parent = badge
	badge.Parent = container

	-- Pista de Fondo de la Barra de Vida
	local track = Instance.new("Frame")
	track.Name = "HealthTrack"
	track.Size = UDim2.new(1, -82, 0, 22)
	track.Position = UDim2.new(0, 70, 0, 48)
	track.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	local tCorner = Instance.new("UICorner")
	tCorner.CornerRadius = UDim.new(0, 6)
	tCorner.Parent = track

	-- Barra de Drenaje / Daño recibido (Drain Lag)
	local drain = Instance.new("Frame")
	drain.Name = "DrainBar"
	drain.Size = UDim2.new(1, 0, 1, 0)
	drain.BackgroundColor3 = Color3.fromRGB(255, 240, 150)
	drain.BorderSizePixel = 0
	local dCorner = Instance.new("UICorner")
	dCorner.CornerRadius = UDim.new(0, 6)
	dCorner.Parent = drain
	drain.Parent = track

	-- Barra de Vida Principal
	local fill = Instance.new("Frame")
	fill.Name = "FillBar"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(40, 220, 90)
	fill.BorderSizePixel = 0
	local fCorner = Instance.new("UICorner")
	fCorner.CornerRadius = UDim.new(0, 6)
	fCorner.Parent = fill
	fill.Parent = track

	-- Marcador de Umbral: 70% (Fase 2)
	local notch70 = Instance.new("Frame")
	notch70.Name = "Notch_70"
	notch70.Size = UDim2.new(0, 2, 1, 4)
	notch70.Position = UDim2.new(0.70, -1, 0, -2)
	notch70.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	notch70.BackgroundTransparency = 0.2
	notch70.BorderSizePixel = 0
	notch70.ZIndex = 15
	notch70.Parent = track

	-- Marcador de Umbral: 30% (Fase 3)
	local notch30 = Instance.new("Frame")
	notch30.Name = "Notch_30"
	notch30.Size = UDim2.new(0, 2, 1, 4)
	notch30.Position = UDim2.new(0.30, -1, 0, -2)
	notch30.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	notch30.BackgroundTransparency = 0.2
	notch30.BorderSizePixel = 0
	notch30.ZIndex = 15
	notch30.Parent = track

	-- Texto de HP Numérico
	local hpText = Instance.new("TextLabel")
	hpText.Name = "HPText"
	hpText.Size = UDim2.new(1, 0, 1, 0)
	hpText.BackgroundTransparency = 1
	hpText.Text = "HP: 45,000 / 45,000 (100.0%)"
	hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
	hpText.Font = Enum.Font.GothamBold
	hpText.TextSize = 11
	hpText.ZIndex = 20
	hpText.Parent = track

	track.Parent = container

	-- Banner de Alerta de Cambio de Fase
	local alert = Instance.new("TextLabel")
	alert.Name = "PhaseAlertBanner"
	alert.AnchorPoint = Vector2.new(0.5, 0)
	alert.Size = UDim2.new(0, 480, 0, 36)
	alert.Position = UDim2.new(0.5, 0, 0, 105)
	alert.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	alert.BackgroundTransparency = 0.2
	alert.Text = "🌿 ¡FASE 1: EL TREANT INVOCA RAÍCES!"
	alert.TextColor3 = Color3.fromRGB(50, 255, 120)
	alert.Font = Enum.Font.GothamBold
	alert.TextSize = 14
	alert.Visible = false
	local aCorner = Instance.new("UICorner")
	aCorner.CornerRadius = UDim.new(0, 8)
	aCorner.Parent = alert
	local aStroke = Instance.new("UIStroke")
	aStroke.Name = "AlertStroke"
	aStroke.Color = Color3.fromRGB(50, 255, 120)
	aStroke.Thickness = 2
	aStroke.Parent = alert
	alert.Parent = container

	container.Parent = sg
	sg.Parent = playerGui

	screenGui = sg
	bossContainer = container
	fillBar = fill
	drainBar = drain
	hpLabel = hpText
	phaseBadge = badge
	bossTitle = title
	bossSubtitle = subtitle
	phaseAlertBanner = alert
end

-- Muestra el aviso cinemático de cambio de fase
local function showPhaseAlert(phaseNum: number)
	if not phaseAlertBanner then return end
	local cfg = PHASE_CONFIGS[phaseNum] or PHASE_CONFIGS[1]

	phaseAlertBanner.Text = cfg.Alert
	phaseAlertBanner.TextColor3 = cfg.Color
	local stroke = phaseAlertBanner:FindFirstChild("AlertStroke") :: UIStroke?
	if stroke then
		stroke.Color = cfg.BorderColor
	end

	phaseAlertBanner.Visible = true
	phaseAlertBanner.Position = UDim2.new(0.5, 0, 0, 115)
	phaseAlertBanner.TextTransparency = 0
	phaseAlertBanner.BackgroundTransparency = 0.2

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(phaseAlertBanner, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0, 105)
	}):Play()

	task.delay(3.5, function()
		if phaseAlertBanner and phaseAlertBanner.Visible then
			local fade = TweenService:Create(phaseAlertBanner, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				TextTransparency = 1,
				BackgroundTransparency = 1
			})
			fade:Play()
			fade.Completed:Connect(function()
				if phaseAlertBanner then
					phaseAlertBanner.Visible = false
				end
			end)
		end
	end)
end

-- Actualiza la barra con la salud y fase actuales
function BossHealthBar.UpdateHealth(data: {
	InstanceId: string,
	BossName: string,
	CurrentHealth: number,
	MaxHealth: number,
	CurrentPhase: number,
	PhaseShifted: boolean?,
})
	createUI()
	if not bossContainer or not fillBar or not drainBar or not hpLabel or not phaseBadge then return end

	currentHealth = math.max(0, data.CurrentHealth)
	maxHealth = math.max(1, data.MaxHealth)
	local percent = math.clamp(currentHealth / maxHealth, 0, 1)

	-- Determinar fase oficial:
	-- Fase 1: 100% - 70%
	-- Fase 2: 70% - 30%
	-- Fase 3: 30% - 0%
	local targetPhase = 1
	if percent <= 0.30 then
		targetPhase = 3
	elseif percent <= 0.70 then
		targetPhase = 2
	else
		targetPhase = 1
	end

	-- Comprobar si cambió de fase
	local phaseChanged = (targetPhase ~= currentPhase) or (data.PhaseShifted == true)
	currentPhase = targetPhase
	local cfg = PHASE_CONFIGS[currentPhase]

	-- Desplegar contenedor si estaba oculto
	if not bossContainer.Visible then
		bossContainer.Visible = true
		bossContainer.Position = UDim2.new(0.5, 0, 0, -85)
		TweenService:Create(bossContainer, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.5, 0, 0, 18)
		}):Play()
	end

	-- Actualizar textos
	if bossTitle and data.BossName then
		bossTitle.Text = string.upper(data.BossName)
	end

	hpLabel.Text = string.format("HP: %s / %s (%.1f%%)",
		formatNumber(currentHealth),
		formatNumber(maxHealth),
		percent * 100
	)

	-- Actualizar badge y colores según la fase
	phaseBadge.Text = cfg.Name
	phaseBadge.TextColor3 = cfg.Color
	local bStroke = phaseBadge:FindFirstChildOfClass("UIStroke")
	if bStroke then
		bStroke.Color = cfg.BorderColor
	end

	-- Animación de la barra de vida principal con TweenService
	local barTween = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(fillBar, barTween, {
		Size = UDim2.new(percent, 0, 1, 0),
		BackgroundColor3 = cfg.Color
	}):Play()

	-- Barra de drenaje (Drain lag)
	local drainTween = TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(drainBar, drainTween, {
		Size = UDim2.new(percent, 0, 1, 0)
	}):Play()

	-- Alerta cinemática de cambio de fase
	if phaseChanged then
		showPhaseAlert(currentPhase)
	end

	-- Jefe Derrotado
	if currentHealth <= 0 then
		hpLabel.Text = "🏆 ¡JEFE DERROTADO!"
		hpLabel.TextColor3 = Color3.fromRGB(255, 230, 80)
		task.delay(4, function()
			BossHealthBar.Hide()
		end)
	end
end

-- Oculta la barra suavemente
function BossHealthBar.Hide()
	if not bossContainer or not bossContainer.Visible then return end
	local fade = TweenService:Create(bossContainer, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, 0, -90)
	})
	fade:Play()
	fade.Completed:Connect(function()
		if bossContainer then
			bossContainer.Visible = false
		end
	end)
end

function BossHealthBar.Init()
	createUI()

	-- Escuchar evento de actualización de salud del jefe
	local bossEvt = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.BossHealthUpdated)
	if bossEvt then
		bossEvt.OnClientEvent:Connect(function(data)
			if data then
				BossHealthBar.UpdateHealth(data)
			end
		end)
	end

	-- Escuchar estado de la mazmorra: solo se muestra en la Sala 5 (Jefe Final)
	local dungeonStateEvt = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.DungeonStateUpdated)
	if dungeonStateEvt then
		dungeonStateEvt.OnClientEvent:Connect(function(data: any)
			if not data or data.CurrentRoom ~= 5 or data.Status ~= "Active" then
				BossHealthBar.Hide()
			end
		end)
	end

	-- Ocultar si la mazmorra se completa o finaliza (o al retornar al Lobby)
	local dungeonComp = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.DungeonCompleted)
	if dungeonComp then
		dungeonComp.OnClientEvent:Connect(function()
			BossHealthBar.Hide()
		end)
	end

	print("[BossHealthBar] Inicializado y enlazado con BossHealthUpdated (Fases 1, 2 y 3).")
end

return BossHealthBar
