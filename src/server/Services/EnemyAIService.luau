--!strict
--[[
    EnemyAIService.luau
    Server-authoritative enemy AI state machine, navigation, and mobility engine for MAGIA ETERNA.
    Features:
    - Active real-time pursuit: tracks and navigates towards closest living player within detection radius.
    - Dual mobility support: seamlessly drives standard Humanoids or smoothly moves anchored stylized boss rigs via PivotTo.
    - Dynamic attack lunges, strike cooldowns, and player damage application.
    - Automatic periodic Boss Telegraph attacks (AoE ground warnings, slams, and cone breaths).
    - Return-to-spawn leash when player retreats or leaves room.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Source"):WaitForChild("shared")
local NetworkEndpoints = require(Shared:WaitForChild("Network"):WaitForChild("NetworkEndpoints") :: ModuleScript)
local EnemyConfig = require(Shared:WaitForChild("Config"):WaitForChild("EnemyConfig") :: ModuleScript)

local EnemyAIService = {}
local isRunning = false

type TrackedEnemy = {
	Model: Model,
	Humanoid: Humanoid?,
	RootPart: BasePart,
	EnemyDef: EnemyConfig.EnemyDefinition,
	SpawnCFrame: CFrame,
	LastAttackTime: number,
	LastTelegraphTime: number,
}

local trackedEnemies: { [Model]: TrackedEnemy } = {}

-- Finds the closest living player to a given position
local function getClosestLivingPlayer(origin: Vector3, maxRadius: number): (Player?, BasePart?, Humanoid?)
	local closestPlayer: Player? = nil
	local closestRoot: BasePart? = nil
	local closestHum: Humanoid? = nil
	local closestDist = maxRadius

	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hrp and hum and hum.Health > 0 then
				local dist = (hrp.Position - origin).Magnitude
				if dist < closestDist then
					closestDist = dist
					closestPlayer = player
					closestRoot = hrp
					closestHum = hum
				end
			end
		end
	end

	return closestPlayer, closestRoot, closestHum
end

-- Registers an enemy model into the tracking table
function EnemyAIService.RegisterEnemy(model: Model)
	if trackedEnemies[model] then return end

	local enemyId = model:GetAttribute("EnemyId") or model.Name
	local enemyDef = EnemyConfig.GetEnemy(tostring(enemyId))
	if not enemyDef then
		-- Fallback to default definition if unnamed
		enemyDef = EnemyConfig.GetEnemy("Enemy_SlimeVerde")
	end
	if not enemyDef then return end

	local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("Body") or model:FindFirstChildWhichIsA("BasePart")
	if not root or not root:IsA("BasePart") then return end
	if not model.PrimaryPart then
		model.PrimaryPart = root
	end

	local hum = model:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = enemyDef.MoveSpeed
	end

	trackedEnemies[model] = {
		Model = model,
		Humanoid = hum,
		RootPart = root,
		EnemyDef = enemyDef,
		SpawnCFrame = root.CFrame,
		LastAttackTime = 0,
		LastTelegraphTime = 0,
	}
end

-- Unregisters a destroyed or dead enemy
function EnemyAIService.UnregisterEnemy(model: Model)
	trackedEnemies[model] = nil
end

-- Scans workspace for dungeon enemies
local function scanDungeonEnemies()
	for _, child in ipairs(Workspace:GetChildren()) do
		if string.find(child.Name, "Dungeon_") and child:IsA("Model") then
			for _, desc in ipairs(child:GetDescendants()) do
				if desc:IsA("Model") and (desc:GetAttribute("EnemyId") or string.find(desc.Name, "Enemy_") or string.find(desc.Name, "Slime_") or string.find(desc.Name, "Boss_") or string.find(desc.Name, "Golem_") or string.find(desc.Name, "Dragon_") or desc:FindFirstChildOfClass("Humanoid") or desc:FindFirstChild("EnemyId")) then
					EnemyAIService.RegisterEnemy(desc)
				end
			end
		end
	end
end

-- Main AI Loop
local function updateAI(deltaTime: number)
	local now = os.clock()

	for model, data in pairs(trackedEnemies) do
		if not model.Parent or not data.RootPart.Parent then
			trackedEnemies[model] = nil
			continue
		end

		local hum = data.Humanoid
		if hum and hum.Health <= 0 then
			trackedEnemies[model] = nil
			continue
		end

		local rootPos = data.RootPart.Position
		local enemyDef = data.EnemyDef
		local detectionRange = (enemyDef.Category == "Boss" and 85) or (enemyDef.Category == "MiniBoss" and 65) or 45

		local targetPlayer, targetRoot, targetHum = getClosestLivingPlayer(rootPos, detectionRange)

		if targetRoot and targetHum then
			local targetPos = targetRoot.Position
			local distance = (targetPos - rootPos).Magnitude
			local attackRange = enemyDef.AttackRange or 6

			-- 1. Periodic Boss/MiniBoss AoE Telegraph Attacks
			if enemyDef.Telegraphs and #enemyDef.Telegraphs > 0 and (now - data.LastTelegraphTime > 7.0) then
				data.LastTelegraphTime = now
				local teleg = enemyDef.Telegraphs[1]
				local telegEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.EnemyTelegraphStarted)
				if telegEvent then
					telegEvent:FireAllClients({
						Shape = teleg.Shape,
						Position = rootPos,
						Radius = teleg.Radius,
						Duration = teleg.TelegraphDuration,
					})
				end

				-- Damage after telegraph duration
				task.delay(teleg.TelegraphDuration, function()
					if model.Parent and targetRoot and targetRoot.Parent and targetHum and targetHum.Health > 0 then
						local dist = (targetRoot.Position - data.RootPart.Position).Magnitude
						if dist <= teleg.Radius + 2 then
							local dmg = math.floor(enemyDef.BaseDamage * (teleg.DamagePercentOfBase / 100))
							targetHum:TakeDamage(dmg)
						end
					end
				end)
			end

			-- 2. Movement & Pursuit
			if distance > attackRange then
				if hum and not data.RootPart.Anchored then
					hum:MoveTo(targetPos)
				else
					-- Smoothly interpolate anchored stylized models towards player
					local moveStep = math.min(distance - attackRange + 1, enemyDef.MoveSpeed * deltaTime)
					local dir = (targetPos - rootPos).Unit
					local nextPos = rootPos + dir * moveStep
					local lookTarget = Vector3.new(targetPos.X, rootPos.Y, targetPos.Z)
					model:PivotTo(CFrame.new(nextPos, lookTarget))
				end
			else
				-- Within Attack Range -> Attack!
				if now - data.LastAttackTime >= enemyDef.AttackCooldown then
					data.LastAttackTime = now

					-- Face player
					local lookTarget = Vector3.new(targetPos.X, rootPos.Y, targetPos.Z)
					model:PivotTo(CFrame.new(rootPos, lookTarget))

					-- Fire attack animation event to clients
					local attackEvt = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.EnemyAttacked)
					if attackEvt then
						attackEvt:FireAllClients({
							EnemyModel = model,
							TargetPosition = targetPos,
							Category = enemyDef.Category,
						})
					end

					-- Deal damage to player
					targetHum:TakeDamage(enemyDef.BaseDamage)
				end
			end
		else
			-- No player in range -> Leash back to spawn point if moved far
			local distToSpawn = (data.SpawnCFrame.Position - rootPos).Magnitude
			if distToSpawn > 8 then
				if hum and not data.RootPart.Anchored then
					hum:MoveTo(data.SpawnCFrame.Position)
				else
					local dir = (data.SpawnCFrame.Position - rootPos).Unit
					local nextPos = rootPos + dir * (enemyDef.MoveSpeed * 0.5 * deltaTime)
					model:PivotTo(CFrame.new(nextPos, data.SpawnCFrame.Position))
				end
			end
		end
	end
end

function EnemyAIService.Init()
	if isRunning then return end
	isRunning = true

	-- Initial scan + periodic discovery of new dungeon rooms
	scanDungeonEnemies()

	task.spawn(function()
		while isRunning do
			scanDungeonEnemies()
			task.wait(3.0)
		end
	end)

	-- Active tick rate of 10 Hz for fluid movement without server lag
	task.spawn(function()
		local lastTick = os.clock()
		while isRunning do
			local current = os.clock()
			local dt = current - lastTick
			lastTick = current
			updateAI(dt)
			task.wait(0.1)
		end
	end)

	print("[EnemyAIService] Initialized successfully with active player tracking and attack lunges.")
end

return EnemyAIService
