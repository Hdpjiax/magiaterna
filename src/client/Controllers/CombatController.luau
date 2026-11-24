--!strict
--[[
    CombatController.luau
    Client combat controller for spell casting input, debouncing, target selection,
    procedural staff swing animations, arcane spell beams, and rendering boss telegraphs.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Source"):WaitForChild("shared")
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)

local Controllers = script.Parent
local AnimationController = require(Controllers:WaitForChild("AnimationController") :: ModuleScript)
local EffectsController = require(Controllers:WaitForChild("EffectsController") :: ModuleScript)
local SoundController = require(Controllers:WaitForChild("SoundController") :: ModuleScript)
local StaffVisualController = require(Controllers:WaitForChild("StaffVisualController") :: ModuleScript)

local CombatController = {}
local localPlayer = Players.LocalPlayer
local lastCastTime = 0
local CAST_DEBOUNCE = 0.18 -- Max ~5.5 attacks per second on client

local currentDungeonSession: any = nil

-- Locates an enemy instance model in the workspace
local function findEnemyModel(targetEnemyInstanceId: string): (Model?, Vector3?)
	for _, desc in ipairs(Workspace:GetDescendants()) do
		if desc:IsA("Model") and desc:FindFirstChild("Humanoid") then
			local instVal = desc:FindFirstChild("InstanceId") :: StringValue?
			if (instVal and instVal.Value == targetEnemyInstanceId) or desc.Name == targetEnemyInstanceId then
				local root = desc:FindFirstChild("HumanoidRootPart") or desc:FindFirstChild("Head") or desc.PrimaryPart
				if root and root:IsA("BasePart") then
					return desc, root.Position
				end
			end
		end
	end
	return nil, nil
end

-- Casts spell at targeted enemy instance ID with full visual and animation pipeline
function CombatController.CastSpell(targetEnemyInstanceId: string)
	local now = tick()
	if now - lastCastTime < CAST_DEBOUNCE then
		return
	end
	lastCastTime = now

	-- 1. Procedural Character Arm Swing & Staff Recoil
	AnimationController.PlayStaffSwing()
	StaffVisualController.PulseStaffTip()

	-- 2. Visual Arcane Beam from Staff Tip to Target
	local char = localPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	local tipPos = StaffVisualController.GetStaffTipPosition() or (hrp and hrp.Position + Vector3.new(0, 1, 0)) or Vector3.new(0, 5, 0)

	local _, targetPos = findEnemyModel(targetEnemyInstanceId)
	if not targetPos and hrp then
		targetPos = hrp.Position + (hrp.CFrame.LookVector * 25)
	end

	if targetPos then
		EffectsController.FireSpellBeam(tipPos, targetPos)
	end

	-- 3. Ground Ripple & SFX
	if hrp then
		EffectsController.SpawnCastAura(hrp.CFrame)
	end
	SoundController.PlaySFX("SFX_SpellCast")

	-- 4. Server Event
	local combatEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.CombatCastSpell)
	if combatEvent then
		combatEvent:FireServer(targetEnemyInstanceId)
	end
end

-- Requests entry into a dungeon
function CombatController.EnterDungeon(dungeonId: string, difficulty: number)
	local enterEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestEnterDungeon)
	if enterEvent then
		enterEvent:FireServer(dungeonId, difficulty)
	end
end

-- Renders visual ground indicator for telegraphed boss attacks
function CombatController.RenderTelegraph(shape: string, centerPos: Vector3, radius: number, duration: number)
	EffectsController.SpawnTelegraph(centerPos, radius, duration, shape)
end

function CombatController.Init()
	-- Listen for dungeon updates
	local dungeonUpdateEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.DungeonStateUpdated)
	if dungeonUpdateEvent then
		dungeonUpdateEvent.OnClientEvent:Connect(function(data)
			currentDungeonSession = data
			print(string.format("[CombatController] Dungeon Session Updated: Room %d/%d (%s)", data.CurrentRoom, data.MaxRooms, data.Status))
		end)
	end

	-- Listen for dungeon completion
	local dungeonCompleteEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.DungeonCompleted)
	if dungeonCompleteEvent then
		dungeonCompleteEvent.OnClientEvent:Connect(function(success: boolean, rewards: any)
			print("[CombatController] Dungeon Finished! Success:", success)
			currentDungeonSession = nil
			if success then
				AnimationController.PlayCelebrate()
				SoundController.PlaySFX("SFX_DungeonVictory")
			end
		end)
	end

	-- Listen for telegraph warnings
	local telegraphEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.EnemyTelegraphStarted)
	if telegraphEvent then
		telegraphEvent.OnClientEvent:Connect(function(shape: string, pos: Vector3, radius: number, duration: number)
			CombatController.RenderTelegraph(shape, pos, radius, duration)
		end)
	end

	print("[CombatController] Initialized successfully with Spell Beams, Arm Kinematics, and Telegraphs.")
end

return CombatController
