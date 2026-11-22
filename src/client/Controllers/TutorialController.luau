--!strict
--[[
    TutorialController.luau
    Controlador de cliente para el Tutorial de Onboarding en MAGIA ETERNA.
    Genera el banner HUD interactivo, la flecha/haz de luz rúnica en el suelo (Waypoints)
    y guía al nuevo jugador a través de los 6 pasos del bucle central.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui

local Shared = ReplicatedStorage:WaitForChild("Shared")
local TutorialConfig = require(Shared:WaitForChild("Config"):WaitForChild("TutorialConfig") :: ModuleScript)
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local TutorialController = {}
local currentStepNumber = 1
local isTutorialActive = false

-- Elementos visuales
local tutorialGui: ScreenGui? = nil
local bannerFrame: Frame? = nil
local stepBadge: TextLabel? = nil
local titleLabel: TextLabel? = nil
local descLabel: TextLabel? = nil
local distanceLabel: TextLabel? = nil

-- Elementos 3D de Waypoint
local activeWaypointPart: Part? = nil
local activeBeam: Beam? = nil
local playerAttachment: Attachment? = nil
local waypointAttachment: Attachment? = nil

local function cleanup3DWaypoints()
	if activeWaypointPart then
		activeWaypointPart:Destroy()
		activeWaypointPart = nil
	end
	if playerAttachment then
		playerAttachment:Destroy()
		playerAttachment = nil
	end
	activeBeam = nil
	waypointAttachment = nil
end

local function spawnWaypointAt(pos: Vector3, stepTitle: string)
	cleanup3DWaypoints()

	-- Crear marcador físico en el suelo
	local wp = Instance.new("Part")
	wp.Name = "Tutorial_Waypoint_Marker"
	wp.Shape = Enum.PartType.Cylinder
	wp.Size = Vector3.new(0.5, 7.0, 7.0)
	wp.CFrame = CFrame.new(pos.X, pos.Y + 0.25, pos.Z) * CFrame.Angles(0, 0, math.rad(90))
	wp.Color = Color3.fromRGB(0, 230, 255)
	wp.Material = Enum.Material.Neon
	wp.Transparency = 0.35
	wp.CanCollide = false
	wp.Anchored = true
	wp.Parent = workspace

	-- Haz de luz vertical
	local beamPillar = Instance.new("Part")
	beamPillar.Name = "Vertical_Beacon"
	beamPillar.Shape = Enum.PartType.Cylinder
	beamPillar.Size = Vector3.new(35, 1.2, 1.2)
	beamPillar.CFrame = CFrame.new(pos.X, pos.Y + 17.5, pos.Z) * CFrame.Angles(0, 0, math.rad(90))
	beamPillar.Color = Color3.fromRGB(0, 255, 200)
	beamPillar.Material = Enum.Material.Neon
	beamPillar.Transparency = 0.65
	beamPillar.CanCollide = false
	beamPillar.Anchored = true
	beamPillar.Parent = wp

	-- Letrero rúnico sobre el waypoint
	local bb = Instance.new("BillboardGui")
	bb.Name = "WaypointSign"
	bb.Size = UDim2.new(0, 200, 0, 40)
	bb.StudsOffset = Vector3.new(0, 5, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = wp
	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.new(1, 0, 1, 0)
	tl.BackgroundTransparency = 1
	tl.Text = "▼ " .. stepTitle
	tl.TextColor3 = Color3.fromRGB(0, 255, 230)
	tl.Font = Enum.Font.GothamBold
	tl.TextScaled = true
	tl.Parent = bb
	bb.Parent = wp

	-- Attachment en el waypoint para el haz guía
	waypointAttachment = Instance.new("Attachment")
	waypointAttachment.Parent = wp

	activeWaypointPart = wp

	-- Conectar haz guía desde el personaje del jugador
	local char = localPlayer.Character
	if char then
		local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if root then
			playerAttachment = Instance.new("Attachment")
			playerAttachment.Parent = root

			local beam = Instance.new("Beam")
			beam.Name = "Tutorial_Guide_Beam"
			beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 150, 255))
			beam.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2),
				NumberSequenceKeypoint.new(1, 0.6)
			})
			beam.Width0 = 1.2
			beam.Width1 = 2.4
			beam.Texture = "rbxassetid://446111271" -- Flechas rúnicas
			beam.TextureSpeed = 1.8
			beam.TextureLength = 4
			beam.FaceCamera = true
			beam.Attachment0 = playerAttachment
			beam.Attachment1 = waypointAttachment
			beam.Parent = root

			activeBeam = beam
		end
	end
end

local function createHUD()
	if tutorialGui then return end

	local sg = Instance.new("ScreenGui")
	sg.Name = "TutorialHUD"
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local banner = Instance.new("Frame")
	banner.Name = "Banner"
	banner.Size = UDim2.new(0, 420, 0, 80)
	banner.Position = UDim2.new(0.5, -210, 0, 15)
	banner.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
	banner.BackgroundTransparency = 0.15

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = banner

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 210, 255)
	stroke.Thickness = 2
	stroke.Parent = banner

	local badge = Instance.new("TextLabel")
	badge.Name = "StepBadge"
	badge.Size = UDim2.new(0, 110, 0, 22)
	badge.Position = UDim2.new(0, 12, 0, 8)
	badge.BackgroundColor3 = Color3.fromRGB(0, 150, 230)
	badge.Text = "PASO 1 / 6"
	badge.TextColor3 = Color3.fromRGB(255, 255, 255)
	badge.Font = Enum.Font.GothamBold
	badge.TextSize = 11
	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 4)
	bCorner.Parent = badge
	badge.Parent = banner

	local title = Instance.new("TextLabel")
	title.Name = "StepTitle"
	title.Size = UDim2.new(0, 280, 0, 22)
	title.Position = UDim2.new(0, 130, 0, 8)
	title.BackgroundTransparency = 1
	title.Text = "⚡ Entrenar Magia"
	title.TextColor3 = Color3.fromRGB(255, 230, 100)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = banner

	local desc = Instance.new("TextLabel")
	desc.Name = "StepDesc"
	desc.Size = UDim2.new(1, -24, 0, 22)
	desc.Position = UDim2.new(0, 12, 0, 32)
	desc.BackgroundTransparency = 1
	desc.Text = "Camina al Campo de Entrenamiento y acumula 50 de Magia."
	desc.TextColor3 = Color3.fromRGB(220, 225, 235)
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 12
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.Parent = banner

	local dist = Instance.new("TextLabel")
	dist.Name = "DistanceLabel"
	dist.Size = UDim2.new(1, -24, 0, 18)
	dist.Position = UDim2.new(0, 12, 0, 54)
	dist.BackgroundTransparency = 1
	dist.Text = "📍 Distancia: Calculando..."
	dist.TextColor3 = Color3.fromRGB(0, 230, 255)
	dist.Font = Enum.Font.GothamMedium
	dist.TextSize = 11
	dist.TextXAlignment = Enum.TextXAlignment.Left
	dist.Parent = banner

	banner.Parent = sg
	sg.Parent = playerGui

	tutorialGui = sg
	bannerFrame = banner
	stepBadge = badge
	titleLabel = title
	descLabel = desc
	distanceLabel = dist
end

-- Actualiza la visualización del paso activo
local function updateStep(stepNum: number)
	currentStepNumber = stepNum
	local stepDef = TutorialConfig.GetStep(stepNum)
	if not stepDef then
		-- Si no hay definición, se completó
		if tutorialGui then
			tutorialGui.Enabled = false
		end
		cleanup3DWaypoints()
		return
	end

	createHUD()
	if tutorialGui then
		tutorialGui.Enabled = true
	end

	if stepBadge then
		stepBadge.Text = string.format("PASO %d / %d", stepNum, TutorialConfig.TOTAL_STEPS)
	end
	if titleLabel then
		titleLabel.Text = stepDef.Title
	end
	if descLabel then
		descLabel.Text = stepDef.Instruction
	end

	-- Desplegar waypoint 3D y haz guía
	spawnWaypointAt(stepDef.TargetLocation, stepDef.TargetName)
end

function TutorialController.Init()
	-- Bucle de renderizado para actualizar la distancia al objetivo en tiempo real
	RunService.RenderStepped:Connect(function()
		if not activeWaypointPart or not distanceLabel or not bannerFrame or not bannerFrame.Visible then return end
		local char = localPlayer.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not root then return end

		local dist = (root.Position - activeWaypointPart.Position).Magnitude
		distanceLabel.Text = string.format("📍 Objetivo a %.1f studs de distancia (%s)", dist, TutorialConfig.GetStep(currentStepNumber) and TutorialConfig.GetStep(currentStepNumber).TargetName or "")

		-- Actualizar attachment del jugador si el personaje reaparece
		if playerAttachment and playerAttachment.Parent ~= root then
			playerAttachment.Parent = root
		end
	end)

	-- Escuchar avance de pasos desde el servidor
	local stepEvt = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.TutorialStepAdvanced)
	if stepEvt then
		stepEvt.OnClientEvent:Connect(function(nextStep: number)
			updateStep(nextStep)
		end)
	end

	-- Escuchar finalización del tutorial
	local compEvt = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.TutorialCompleted)
	if compEvt then
		compEvt.OnClientEvent:Connect(function(rewards: any)
			cleanup3DWaypoints()
			if bannerFrame and titleLabel and descLabel and stepBadge then
				stepBadge.Text = "★ COMPLETADO"
				stepBadge.BackgroundColor3 = Color3.fromRGB(50, 220, 100)
				titleLabel.Text = "🏆 ¡TUTORIAL DE MAGIA SUPERADO!"
				titleLabel.TextColor3 = Color3.fromRGB(255, 215, 80)
				descLabel.Text = string.format("Recompensa otorgada: +%d Monedas de Oro y +%d Esencias. ¡Ya eres un mago libre!",
					rewards.Coins or 500, rewards.Essences or 25)
				task.delay(6, function()
					if tutorialGui then
						tutorialGui:Destroy()
					end
				end)
			end
		end)
	end

	-- Sincronizar estado inicial al entrar
	local profileEvt = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.PlayerProfileUpdated)
	if profileEvt then
		profileEvt.OnClientEvent:Connect(function(profile: any)
			if profile and not profile.TutorialCompleted then
				local step = profile.TutorialStep or 1
				if step ~= currentStepNumber or not activeWaypointPart then
					updateStep(step)
				end
			elseif profile and profile.TutorialCompleted then
				cleanup3DWaypoints()
				if tutorialGui then
					tutorialGui.Enabled = false
				end
			end
		end)
	end

	print("[TutorialController] Inicializado correctamente con haz de waypoints rúnicos.")
end

return TutorialController
