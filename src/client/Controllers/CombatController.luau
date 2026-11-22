--!strict
--[[
    CombatController.luau
    Client combat controller for spell casting input, debouncing, target selection,
    and rendering boss telegraph visual indicators for MAGIA ETERNA.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local NetworkEndpoints = require(ReplicatedStorage.Source.shared.Network.NetworkEndpoints)

local CombatController = {}
local localPlayer = Players.LocalPlayer
local lastCastTime = 0
local CAST_DEBOUNCE = 0.20 -- Max 5 attacks per second on client

local currentDungeonSession: any = nil

-- Casts spell at targeted enemy instance ID
function CombatController.CastSpell(targetEnemyInstanceId: string)
	local now = tick()
	if now - lastCastTime < CAST_DEBOUNCE then
		return
	end
	lastCastTime = now

	local combatEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.CombatCastSpell)
	combatEvent:FireServer(targetEnemyInstanceId)
end

-- Requests entry into a dungeon
function CombatController.EnterDungeon(dungeonId: string, difficulty: number)
	local enterEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestEnterDungeon)
	enterEvent:FireServer(dungeonId, difficulty)
end

-- Renders visual ground indicator for telegraphed boss attacks
function CombatController.RenderTelegraph(shape: string, centerPos: Vector3, radius: number, duration: number)
	-- Spawns a non-collidable red highlight on the ground
	local indicator = Instance.new("Part")
	indicator.Name = "BossTelegraphIndicator"
	indicator.Anchored = true
	indicator.CanCollide = false
	indicator.CanTouch = false
	indicator.CanQuery = false
	indicator.Material = Enum.Material.Neon
	indicator.Color = Color3.fromRGB(255, 60, 60)
	indicator.Transparency = 0.65

	if shape == "Circle" then
		indicator.Shape = Enum.PartType.Cylinder
		indicator.Size = Vector3.new(0.2, radius * 2, radius * 2)
		indicator.CFrame = CFrame.new(centerPos) * CFrame.Angles(0, 0, math.rad(90))
	else
		indicator.Shape = Enum.PartType.Block
		indicator.Size = Vector3.new(radius, 0.2, radius)
		indicator.CFrame = CFrame.new(centerPos)
	end

	indicator.Parent = workspace

	-- Tween fade out or destroy after duration
	task.delay(duration, function()
		if indicator and indicator.Parent then
			indicator:Destroy()
		end
	end)
end

function CombatController.Init()
	-- Listen for dungeon updates
	local dungeonUpdateEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.DungeonStateUpdated)
	dungeonUpdateEvent.OnClientEvent:Connect(function(data)
		currentDungeonSession = data
		print(string.format("[CombatController] Dungeon Session Updated: Room %d/%d (%s)", data.CurrentRoom, data.MaxRooms, data.Status))
	end)

	-- Listen for dungeon completion
	local dungeonCompleteEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.DungeonCompleted)
	dungeonCompleteEvent.OnClientEvent:Connect(function(success: boolean, rewards: any)
		print("[CombatController] Dungeon Finished! Success:", success)
		currentDungeonSession = nil
	end)

	-- Listen for telegraph warnings
	local telegraphEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.EnemyTelegraphStarted)
	telegraphEvent.OnClientEvent:Connect(function(shape: string, pos: Vector3, radius: number, duration: number)
		CombatController.RenderTelegraph(shape, pos, radius, duration)
	end)

	-- Input binding: Click or Touch
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			-- If in dungeon, auto-target nearest enemy if any
			-- Note: Target selection can be wired with raycasting / hit tests
		end
	end)

	print("[CombatController] Initialized successfully.")
end

return CombatController
