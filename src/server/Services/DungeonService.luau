--!strict
--[[
    DungeonService.luau
    Manages Dungeon sessions, room transitions (Rooms 1-3 combat, Room 4 miniboss, Room 5 boss),
    and server-authoritative loot generation for MAGIA ETERNA.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local NetworkEndpoints = require(ReplicatedStorage.Source.shared.Network.NetworkEndpoints)
local DungeonConfig = require(ReplicatedStorage.Source.shared.Config.DungeonConfig)
local LootUtils = require(ReplicatedStorage.Source.shared.Modules.LootUtils)

local PlayerDataService = require(script.Parent.PlayerDataService)
local EnemyService = require(script.Parent.EnemyService)
local CombatService = require(script.Parent.CombatService)
local RemoteGuard = require(script.Parent.RemoteGuard)
local EconomyService = require(script.Parent.EconomyService)
local QuestService = require(script.Parent.QuestService)
local TutorialService = require(script.Parent.TutorialService)

export type DungeonSession = {
	SessionId: string,
	Player: Player,
	DungeonId: string,
	Difficulty: DungeonConfig.DungeonDifficulty,
	CurrentRoom: number,
	MaxRooms: number,
	Status: "Active" | "Completed" | "Failed",
	StartTime: number,
}

local DungeonService = {}
local activeSessions: { [string]: DungeonSession } = {}
local playerSessionMap: { [Player]: string } = {}

-- Spawns enemies for the session's current room
local function spawnRoomEnemies(session: DungeonSession)
	local dungeonDef = DungeonConfig.GetDungeon(session.DungeonId)
	if not dungeonDef then return end

	local currentRoom = session.CurrentRoom
	if currentRoom < 4 then
		-- Rooms 1-3: Normal Enemies
		local enemyPool = dungeonDef.NormalEnemies
		local count = 3
		for i = 1, count do
			local chosenEnemy = enemyPool[((i - 1) % #enemyPool) + 1]
			local offset = Vector3.new((i - 2) * 12, 0, 30)
			EnemyService.SpawnEnemy(session.SessionId, chosenEnemy, session.Difficulty, offset)
		end
	elseif currentRoom == 4 then
		-- Room 4: MiniBoss
		local offset = Vector3.new(0, 0, 35)
		EnemyService.SpawnEnemy(session.SessionId, dungeonDef.MiniBossId, session.Difficulty, offset)
	elseif currentRoom == 5 then
		-- Room 5: Final Boss
		local offset = Vector3.new(0, 0, 45)
		local bossInstance = EnemyService.SpawnEnemy(session.SessionId, dungeonDef.BossId, session.Difficulty, offset)
		if bossInstance then
			local bossEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.BossHealthUpdated)
			if bossEvent then
				bossEvent:FireClient(session.Player, {
					InstanceId = bossInstance.InstanceId,
					BossName = bossInstance.EnemyDef.Name,
					CurrentHealth = bossInstance.CurrentHealth,
					MaxHealth = bossInstance.MaxHealth,
					CurrentPhase = 1,
					PhaseShifted = false,
				})
			end
		end
	end
end

-- Requests entry into a dungeon instance
function DungeonService.EnterDungeon(player: Player, dungeonId: string, difficulty: number): (boolean, string?)
	local profile = PlayerDataService.GetPlayerProfile(player)
	if not profile then
		return false, "Player data not loaded"
	end

	local dungeonDef = DungeonConfig.GetDungeon(dungeonId)
	if not dungeonDef then
		return false, "Dungeon does not exist"
	end

	local validDiff = math.clamp(difficulty, 1, 5) :: DungeonConfig.DungeonDifficulty
	local normalizedKey = string.gsub(dungeonId, "Dungeon_", "")
	local unlockedDiff = profile.UnlockedDungeons[dungeonId] or profile.UnlockedDungeons[normalizedKey] or 1

	if validDiff > unlockedDiff then
		return false, "Difficulty locked"
	end

	-- Terminate any existing session for player
	if playerSessionMap[player] then
		local oldSessionId = playerSessionMap[player]
		EnemyService.ClearSession(oldSessionId)
		activeSessions[oldSessionId] = nil
	end

	local sessionId = HttpService:GenerateGUID(false)
	local session: DungeonSession = {
		SessionId = sessionId,
		Player = player,
		DungeonId = dungeonId,
		Difficulty = validDiff,
		CurrentRoom = 1,
		MaxRooms = dungeonDef.RoomsCount,
		Status = "Active",
		StartTime = os.time(),
	}

	activeSessions[sessionId] = session
	playerSessionMap[player] = sessionId

	spawnRoomEnemies(session)

	-- Notify client
	local updateEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.DungeonStateUpdated)
	updateEvent:FireClient(player, {
		SessionId = sessionId,
		DungeonId = dungeonId,
		Difficulty = validDiff,
		CurrentRoom = 1,
		MaxRooms = session.MaxRooms,
		Status = "Active",
	})

	TutorialService.RecordAction(player, "EnterDungeon", 1)

	-- Teletransportar físicamente al jugador a la entrada de la mazmorra correspondiente
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if hrp then
		if dungeonId == "Dungeon_Minas" then
			hrp.CFrame = CFrame.new(-800, 54, -15)
		else
			hrp.CFrame = CFrame.new(800, 54, -15)
		end
	end

	return true, nil
end

-- Completes a dungeon session, calculating and distributing loot rewards via EconomyService & LootUtils
function DungeonService.CompleteDungeon(session: DungeonSession)
	session.Status = "Completed"
	local player = session.Player
	local profile = PlayerDataService.GetPlayerProfile(player)
	if not profile then return end

	local dungeonDef = DungeonConfig.GetDungeon(session.DungeonId)
	if not dungeonDef then return end

	local diffStats = DungeonConfig.DIFFICULTIES[session.Difficulty] or DungeonConfig.DIFFICULTIES[1]
	
	-- 1. Authoritative Loot Roll via LootUtils
	local lootResult = LootUtils.RollLootTable(
		dungeonDef.LootTable :: any,
		diffStats.RewardMultiplier,
		0, -- Luck bonus
		0  -- Material bonus
	)

	-- 2. Deliver Coins & Essences via EconomyService
	if lootResult.Coins > 0 then
		EconomyService.AddCoins(player, lootResult.Coins)
	end
	if lootResult.Essences > 0 then
		EconomyService.AddEssences(player, lootResult.Essences)
	end

	-- 3. Atomic Profile Update: Materials, Guaranteed Shard & Difficulty Unlock
	PlayerDataService.UpdateProfile(player, function(data)
		-- Materials
		for matId, qty in pairs(lootResult.Materials) do
			data.Materials[matId] = (data.Materials[matId] or 0) + qty
		end

		-- Guaranteed Rebirth Shard on Diff V
		if diffStats.GuaranteeRebirthShard then
			data.RebirthShards = (data.RebirthShards or 0) + 1
		end

		-- Unlock next difficulty tier if completing highest
		local normalizedKey = string.gsub(session.DungeonId, "Dungeon_", "")
		local currentUnlocked = data.UnlockedDungeons[session.DungeonId] or data.UnlockedDungeons[normalizedKey] or 1
		if session.Difficulty == currentUnlocked and currentUnlocked < 5 then
			data.UnlockedDungeons[session.DungeonId] = currentUnlocked + 1
		end
	end)

	-- 4. Record Quest Progress for Dungeon Completion
	QuestService.RecordProgress(player, "CompleteDungeon", 1)

	local grantedRewards = {
		Coins = lootResult.Coins,
		Essences = lootResult.Essences,
		Materials = lootResult.Materials,
		RebirthShards = diffStats.GuaranteeRebirthShard and 1 or 0,
	}

	-- Clean up session
	EnemyService.ClearSession(session.SessionId)
	activeSessions[session.SessionId] = nil
	playerSessionMap[player] = nil

	-- Sync safe client state and fire completion summary
	PlayerDataService.SyncClient(player)

	local completeEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.DungeonCompleted)
	completeEvent:FireClient(player, true, grantedRewards)

	print(string.format("[DungeonService] Player %s completed %s (Diff %d) - Awarded %d Coins, %d Essences via EconomyService & LootUtils.",
		player.Name, session.DungeonId, session.Difficulty, lootResult.Coins, lootResult.Essences))
end

-- Called when an enemy in a session is defeated
function DungeonService.OnEnemyDefeated(sessionId: string, enemyInstanceId: string, player: Player)
	local session = activeSessions[sessionId]
	if not session or session.Status ~= "Active" then return end

	-- Check remaining living enemies in session
	local remainingEnemies = EnemyService.GetEnemiesInSession(sessionId)
	if #remainingEnemies == 0 then
		-- Room cleared!
		if session.CurrentRoom < session.MaxRooms then
			local clearedRoom = session.CurrentRoom
			session.CurrentRoom += 1
			spawnRoomEnemies(session)

			if clearedRoom == 1 then
				TutorialService.RecordAction(player, "ClearRoom1", 1)
			end

			-- Desbloquear físicamente la puerta entre las salas en el mundo 3D
			local dungeonModelName = (session.DungeonId == "Dungeon_Minas") and "Dungeon_Minas_Fuego_Eterno" or "Dungeon_Bosque_Susurros"
			local dungeonModel = workspace:FindFirstChild(dungeonModelName)
			if dungeonModel then
				local gates = dungeonModel:FindFirstChild("Dungeon_Gates")
				if gates then
					local gate = gates:FindFirstChild("Gate_Room" .. clearedRoom .. "_To_Room" .. session.CurrentRoom)
					if gate then
						gate:SetAttribute("IsOpen", true)
						for _, part in ipairs(gate:GetDescendants()) do
							if part:IsA("BasePart") and (part.Name == "Runic_Barrier" or part.Name == "Fire_Barrier") then
								part.Transparency = 0.95
								part.CanCollide = false
							elseif part:IsA("BillboardGui") then
								part.Enabled = false
							end
						end
					end
				end
			end

			local updateEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.DungeonStateUpdated)
			updateEvent:FireClient(player, {
				SessionId = sessionId,
				DungeonId = session.DungeonId,
				Difficulty = session.Difficulty,
				CurrentRoom = session.CurrentRoom,
				MaxRooms = session.MaxRooms,
				Status = "Active",
			})
		else
			-- Boss room cleared -> Victory!
			DungeonService.CompleteDungeon(session)
		end
	end
end

-- Retrieves active session for a player
function DungeonService.GetPlayerSession(player: Player): DungeonSession?
	local sessionId = playerSessionMap[player]
	return sessionId and activeSessions[sessionId] or nil
end

function DungeonService.Init()
	CombatService.SetOnEnemyDefeatedCallback(function(sessionId: string, enemyInstanceId: string, player: Player)
		DungeonService.OnEnemyDefeated(sessionId, enemyInstanceId, player)
	end)

	local enterEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.RequestEnterDungeon)
	enterEvent.OnServerEvent:Connect(function(player: Player, ...: any)
		local args = { ... }
		local dungeonId = args[1]
		local difficulty = args[2]

		if typeof(dungeonId) ~= "string" or typeof(difficulty) ~= "number" then return end

		local allowed = RemoteGuard.ValidateRequest(player, "EnterDungeon", 2)
		if not allowed then return end

		DungeonService.EnterDungeon(player, dungeonId, difficulty)
	end)

	Players.PlayerRemoving:Connect(function(player)
		local sessionId = playerSessionMap[player]
		if sessionId then
			EnemyService.ClearSession(sessionId)
			activeSessions[sessionId] = nil
			playerSessionMap[player] = nil
		end
	end)

	print("[DungeonService] Initialized successfully.")
end

return DungeonService
