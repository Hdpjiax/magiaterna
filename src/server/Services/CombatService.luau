--!strict
--[[
    CombatService.luau
    Authoritative server-side spell casting, damage formula calculations, range & cooldown validations for MAGIA ETERNA.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local NetworkEndpoints = require(ReplicatedStorage.Source.shared.Network.NetworkEndpoints)
local StaffConfig = require(ReplicatedStorage.Source.shared.Config.StaffConfig)
local RebirthConfig = require(ReplicatedStorage.Source.shared.Config.RebirthConfig)
local ArmorConfig = require(ReplicatedStorage.Source.shared.Config.ArmorConfig)

local PlayerDataService = require(script.Parent.PlayerDataService)
local PetService = require(script.Parent.PetService)
local EnemyService = require(script.Parent.EnemyService)
local RemoteGuard = require(script.Parent.RemoteGuard)

local CombatService = {}

-- Callback hook for DungeonService when enemy is defeated or damaged
local onEnemyDefeatedCallback: ((sessionId: string, enemyInstanceId: string, player: Player) -> ())? = nil

function CombatService.SetOnEnemyDefeatedCallback(callback: (sessionId: string, enemyInstanceId: string, player: Player) -> ())
	onEnemyDefeatedCallback = callback
end

-- Calculates final authoritative spell damage for a player
function CombatService.CalculateSpellDamage(player: Player): number
	local profile = PlayerDataService.GetPlayerProfile(player)
	if not profile then
		return 10
	end

	local staffId = profile.EquippedStaff or "Staff_R1_001_RamaAprendiz"
	local staffDef = StaffConfig.GetStaff(staffId)
	local staffPower = staffDef and staffDef.BasePower or 10

	local rebirthMult = RebirthConfig.GetMultiplier(profile.Rebirths or 0)
	local petMult = PetService.GetTotalMagicMultiplier(player)

	local armorStats = ArmorConfig.CalculateTotalStats(profile.EquippedArmor)
	local armorPowerBonus = 1.0 + (armorStats.TotalDefense * 0.005) -- Minor power bonus from armor mastery

	local totalDamage = math.floor(staffPower * rebirthMult * petMult * armorPowerBonus)
	return math.max(1, totalDamage)
end

-- Casts spell at a targeted enemy
function CombatService.CastSpellAtEnemy(player: Player, enemyInstanceId: string): (boolean, number, boolean, boolean)
	local profile = PlayerDataService.GetPlayerProfile(player)
	if not profile then
		return false, 0, false, false
	end

	local enemy = EnemyService.GetEnemy(enemyInstanceId)
	if not enemy or enemy.IsDead then
		return false, 0, false, false
	end

	-- Distance validation if player character exists
	local character = player.Character
	if character and character:FindFirstChild("HumanoidRootPart") then
		local rootPart = character.HumanoidRootPart :: BasePart
		local distance = (rootPart.Position - enemy.Position).Magnitude
		if distance > 100 then -- Maximum spell range is 100 studs
			return false, 0, false, false
		end
	end

	local damage = CombatService.CalculateSpellDamage(player)
	local isDead, damageDealt, phaseShifted = EnemyService.DamageEnemy(enemyInstanceId, damage, player)

	-- Replicar evento de daño visual al cliente atacante
	local damageEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.DamageDealt)
	if damageEvent and damageDealt > 0 then
		damageEvent:FireClient(player, {
			EnemyInstanceId = enemyInstanceId,
			Damage = damageDealt,
			IsDead = isDead,
			PhaseShifted = phaseShifted,
			Position = enemy.Position,
		})
	end

	if isDead and onEnemyDefeatedCallback then
		onEnemyDefeatedCallback(enemy.DungeonSessionId, enemyInstanceId, player)
	end

	return true, damageDealt, isDead, phaseShifted
end

function CombatService.Init()
	local combatEvent = NetworkEndpoints.GetEvent(NetworkEndpoints.Events.CombatCastSpell)
	combatEvent.OnServerEvent:Connect(function(player: Player, ...: any)
		local args = { ... }
		local enemyInstanceId = args[1]
		if typeof(enemyInstanceId) ~= "string" then return end

		local allowed = RemoteGuard.ValidateRequest(player, "CombatCast", 6)
		if not allowed then return end

		CombatService.CastSpellAtEnemy(player, enemyInstanceId)
	end)

	print("[CombatService] Initialized successfully.")
end

return CombatService
