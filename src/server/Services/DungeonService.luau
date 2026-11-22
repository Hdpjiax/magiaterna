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

local PlayerDataService = require(script.Parent.PlayerDataService)
local EnemyService = require(script.Parent.EnemyService)
local CombatService = require(script.Parent.CombatService)
local RemoteGuard = require(script.Parent.RemoteGuard)

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
		EnemyService.SpawnEnemy(session.SessionId, dungeonDef.BossId, session.Difficulty, offset)
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

	return true, nil
end

-- Completes a dungeon session, calculating and distributing loot rewards
function DungeonService.CompleteDungeon(session: DungeonSession)
	session.Status = "Completed"
	local player = session.Player
	local profile = PlayerDataService.GetPlayerProfile(player)
	if not profile then return end

	local dungeonDef = DungeonConfig.GetDungeon(session.DungeonId)
	if not dungeonDef then return end

	local diffStats = DungeonConfig.DIFFICULTIES[session.Difficulty] or DungeonConfig.DIFFICULTIES[1]
	local grantedRewards = {
		Coins = 0,
		Materials = {} :: { [string]: number },
		RebirthShards = 0,
	}

	-- Roll Loot Table
	for _, drop in ipairs(dungeonDef.LootTable) do
		local roll = math.random()
		if roll <= drop.DropChance then
			local baseAmount = math.random(drop.MinAmount, drop.MaxAmount)
			local finalAmount = math.floor(baseAmount * diffStats.RewardMultiplier)

			if drop.ItemType == "Coin" then
				profile.Coins += finalAmount
				grantedRewards.Coins += finalAmount
			elseif drop.ItemType == "Essence" or drop.ItemType == "Material" then
				profile.Materials[drop.Id] = (profile.Materials[drop.Id] or 0) + finalAmount
				grantedRewards.Materials[drop.Id] = finalAmount
			end
		end
	end

	-- Guaranteed Rebirth Shard on Diff V
	if diffStats.GuaranteeRebirthShard then
		profile.RebirthShards = (profile.RebirthShards or 0) + 1
		grantedRewards.RebirthShards += 1
	end

	-- Unlock next difficulty if currently on highest unlocked tier
	local normalizedKey = string.gsub(session.DungeonId, "Dungeon_", "")
	local currentUnlocked = profile.UnlockedDungeons[session.DungeonId] or profile.UnlockedDungeons[normalizedKey] or 1
	if session.Difficulty == currentUnlocked and currentUnlocked < 5 then
		profile.UnlockedDungeons[session.DungeonId] = currentUnlocked + 1
	end

	-- Clean up session
	EnemyService.ClearSession(session.SessionId)
	activeSessions[session.SessionId] = nil
	playerSessionMap[player] = nil

	-- Sync safe client state and fire completion summary
	PlayerDataService.SyncClient(player)

	local completeEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.DungeonCompleted)
	completeEvent:FireClient(player, true, grantedRewards)

	print(string.format("[DungeonService] Player %s completed %s (Diff %d)", player.Name, session.DungeonId, session.Difficulty))
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
			session.CurrentRoom += 1
			spawnRoomEnemies(session)

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
